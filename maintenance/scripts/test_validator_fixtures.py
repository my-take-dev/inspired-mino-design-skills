#!/usr/bin/env python3
"""Structural-validator regression fixtures; no model/API calls or live writes.

Python 3.10+ standard library. Every mutation is confined to a disposable copy.
A passing fixture verifies a validator response, not a Skill's behavior.
"""
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

SOURCE = Path(__file__).resolve().parents[2]/'.agents/skills'
MAINTENANCE = Path(__file__).resolve().parents[1]

class Fixtures(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='mino-fixture-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)/'skills'
        # Only copy this suite, never unrelated installed Skills or links.
        for name in ('mino-core','mino-problem-framing','mino-domain-model-completeness',
                     'mino-design-by-contract','mino-interface-implementation-separation',
                     'mino-architecture-quality-strategy','mino-reproducible-development'):
            source = SOURCE/name
            if source.is_symlink(): self.fail('Source Skill must not be a symlink')
            shutil.copytree(source,self.root/name,symlinks=True)
        self.maintenance = Path(self.temp.name)/'maintenance'
        shutil.copytree(MAINTENANCE,self.maintenance,symlinks=True)
        registry=json.loads(self.path('mino-core/references/suite-contract.json').read_text(encoding='utf-8'))
        self.version=registry['suite_version']
        self.revision=registry['evaluation_revision']
    def path(self,relative):
        # 旧fixtureの対象名を新しい物理配置へ接続する。
        for prefix,target in [('mino-core/scripts/',self.maintenance/'scripts'),
                              ('mino-core/evaluations/',self.maintenance/'evaluations')]:
            if relative.startswith(prefix): return target/relative[len(prefix):]
        if relative=='mino-core/references/suite-contract.json':
            return self.maintenance/'suite-contract.json'
        return self.root/relative
    def change(self,relative,old,new):
        path=self.path(relative); text=path.read_text(encoding='utf-8')
        self.assertIn(old,text)
        path.write_text(text.replace(old,new,1),encoding='utf-8',newline='\n')
    def run_python(self,command):
        # PIPEの送受信だけをUTF-8へそろえ、file I/Oの既定encodingは維持する。
        return subprocess.run(command,env={**os.environ,'PYTHONIOENCODING':'utf-8'},
                              capture_output=True,text=True,encoding='utf-8',timeout=30)
    def probe(self,code=0,token=None,root=None,extra=()):
        command=[sys.executable,'-B',str(self.maintenance/'scripts/validate_suite.py'),
                 '--skills-root',str(root or self.root),*extra]
        completed=self.run_python(command)
        output=completed.stdout+completed.stderr
        self.assertEqual(completed.returncode,code,output)
        if token:self.assertIn(token,output)
    def manifest(self):return self.path('mino-core/scripts/suite-manifest.txt')
    def mutate_registry(self,update):
        p=self.path('mino-core/references/suite-contract.json')
        data=json.loads(p.read_text(encoding='utf-8'));update(data)
        p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
    def test_positive(self):self.probe()
    def test_unrelated_skill_ignored(self):
        p=self.path('unrelated/SKILL.md');p.parent.mkdir();p.write_bytes(b'\xff\r\n')
        self.probe()
    def test_unlisted_mino_skill(self):
        self.path('mino-unlisted').mkdir();self.probe(1,'E_UNLISTED_SKILL')
    def test_missing_skill(self):
        shutil.rmtree(self.path('mino-problem-framing'));self.probe(1,'E_SKILL_MISSING')
    def test_missing_root(self):self.probe(2,'E_ROOT',root=self.path('missing'))
    def test_missing_manifest(self):self.manifest().unlink();self.probe(2,'E_MANIFEST_MISSING')
    def test_duplicate_version(self):
        with self.manifest().open('a',encoding='utf-8',newline='\n') as f:f.write(f'suite_version={self.version}\n')
        self.probe(1,'E_MANIFEST_SCALAR')
    def test_duplicate_owner(self):
        with self.manifest().open('a',encoding='utf-8',newline='\n') as f:f.write('owner=other\n')
        self.probe(1,'E_MANIFEST_SCALAR')
    def test_duplicate_skill(self):
        with self.manifest().open('a',encoding='utf-8',newline='\n') as f:f.write('skill=mino-core\n')
        self.probe(1,'E_DUP_SKILL')
    def test_empty_manifest_key(self):
        with self.manifest().open('a',encoding='utf-8',newline='\n') as f:f.write('=value\n')
        self.probe(1,'E_MANIFEST_LINE')
    def test_leading_zero_version(self):
        self.change('mino-core/scripts/suite-manifest.txt','0.12.0','0.012.0');self.probe(1,'E_VERSION')
    def test_prerelease_not_supported(self):
        self.change('mino-core/scripts/suite-manifest.txt','0.12.0','0.12.0-beta');self.probe(1,'E_VERSION')
    def test_manifest_traversal(self):
        self.change('mino-core/scripts/suite-manifest.txt','skill=mino-core','skill=../outside');self.probe(1,'E_SKILL_NAME')
    def test_manifest_owner_whitespace(self):
        self.change('mino-core/scripts/suite-manifest.txt','owner=suite-maintainers','owner= ');self.probe(1,'E_MANIFEST_LINE')
    def test_stale_file(self):
        self.path('mino-core/references/old.md').write_text('# Obsolete\n',encoding='utf-8',newline='\n');self.probe(1,'E_INVENTORY')
    def test_missing_inventory(self):
        self.path('mino-core/scripts/suite-files.txt').unlink();self.probe(1,'E_INVENTORY_MISSING')
    def test_inventory_duplicate(self):
        p=self.path('mino-core/scripts/suite-files.txt')
        with p.open('a',encoding='utf-8',newline='\n') as f:f.write(p.read_text(encoding='utf-8').splitlines()[0]+'\n')
        self.probe(1,'E_INVENTORY_DUP')
    def test_invalid_utf8(self):
        self.path('mino-core/agents/openai.yaml').write_bytes(b'\xff\n');self.probe(1,'E_UTF8')
    def test_utf8_bom(self):
        p=self.path('mino-core/agents/openai.yaml');p.write_bytes(b'\xef\xbb\xbf'+p.read_bytes());self.probe(1,'E_BOM')
    def test_crlf(self):
        p=self.path('mino-core/agents/openai.yaml');p.write_bytes(p.read_bytes().replace(b'\n',b'\r\n'));self.probe(1,'E_LF')
    def test_no_final_newline(self):
        p=self.path('mino-core/agents/openai.yaml');p.write_bytes(p.read_bytes().rstrip(b'\n'));self.probe(1,'E_NEWLINE')
    def test_trailing_space(self):
        self.change('mino-core/SKILL.md','# Shared Core','# Shared Core ');self.probe(1,'E_TRAILING_SPACE')
    def test_bad_frontmatter(self):
        self.change('mino-core/SKILL.md','---\n','---junk\n');self.probe(1,'E_FRONTMATTER')
    def test_wrong_skill_name(self):
        self.change('mino-core/SKILL.md','name: mino-core','name: wrong');self.probe(1,'E_FRONTMATTER_FIELDS')
    def test_missing_heading(self):
        self.change('mino-core/SKILL.md','## Completion','## Done');self.probe(1,'E_HEADINGS')
    def test_missing_contents(self):
        self.change('mino-core/schemas/core.md','## Contents','## Index');self.probe(1,'E_CONTENTS')
    def test_bare_path(self):
        p=self.path('mino-core/references/code-design.md')
        with p.open('a',encoding='utf-8',newline='\n') as f:f.write('\n`unknown.md`\n')
        self.probe(1,'E_BARE_PATH')
    def test_missing_reference(self):
        self.change('mino-core/SKILL.md','skills/mino-core/schemas/core.md','skills/mino-core/references/missing.md');self.probe(1,'E_REFERENCE')
    def test_path_traversal(self):
        p=self.path('mino-core/references/code-design.md')
        with p.open('a',encoding='utf-8',newline='\n') as f:f.write('\n`skills/../outside.md`\n')
        self.probe(1,'E_PATH')
    def test_markdown_reference_reachability(self):
        # 全参照をリンク形式へ変え、リンクだけで到達性を維持できることを確認する。
        for path in self.root.rglob('*.md'):
            if 'evaluations' in path.parts: continue
            content=path.read_text(encoding='utf-8')
            content=re.sub(r'`(skills/[^`\n]+)`',r'[参照](\1)',content)
            path.write_text(content,encoding='utf-8',newline='\n')
        self.probe()
    def test_markdown_reference_formats(self):
        p=self.path('mino-core/references/code-design.md')
        with p.open('a',encoding='utf-8',newline='\n') as f:
            f.write('\n[参照](<skills/mino-core/schemas/core.md#entry-and-reuse> "説明")\n'
                    '[同じ文書](#contents)\n[参照][core]\n'
                    '[core]: skills/mino-core/schemas/core.md "説明"\n')
        self.probe()
    def test_markdown_missing_reference(self):
        self.change('mino-core/references/code-design.md','# Purpose-driven code design',
                    '# Purpose-driven code design\n\n[参照](skills/mino-core/references/missing.md)')
        self.probe(1,'E_REFERENCE')
    def test_markdown_bare_path(self):
        self.change('mino-core/references/code-design.md','# Purpose-driven code design',
                    '# Purpose-driven code design\n\n[参照](references/missing.md)')
        self.probe(1,'E_BARE_PATH')
    def test_markdown_path_traversal(self):
        self.change('mino-core/references/code-design.md','# Purpose-driven code design',
                    '# Purpose-driven code design\n\n[参照](skills/../outside.md)')
        self.probe(1,'E_PATH')
    def test_markdown_absolute_path(self):
        p=self.path('mino-core/references/code-design.md')
        original=p.read_text(encoding='utf-8')
        for target in ('/outside.md','../outside.md','~/outside.md','C:/outside.md'):
            with self.subTest(target=target):
                p.write_text(original+f'\n[参照](<{target}>)\n',encoding='utf-8',newline='\n')
                self.probe(1,'E_ABSOLUTE_LINK')
    def test_markdown_reference_definition_missing(self):
        self.change('mino-core/references/code-design.md','# Purpose-driven code design',
                    '# Purpose-driven code design\n\n[参照][missing]\n'
                    '[missing]: <skills/mino-core/references/missing.md> "説明"')
        self.probe(1,'E_REFERENCE')
    def markdown_probe(self,snippet,code=0,token=None):
        path=self.path('mino-core/references/code-design.md')
        original=path.read_text(encoding='utf-8')
        try:
            path.write_text(original+'\n'+snippet+'\n',encoding='utf-8',newline='\n')
            self.probe(code,token)
        finally:
            path.write_text(original,encoding='utf-8',newline='\n')
    def test_markdown_code_is_not_a_link(self):
        examples=(
            '`handlers[kind](request)`',
            '``a ` handlers[kind](request)``',
            '`handlers[kind]\n(request)`',
            '```python\nhandlers[kind](request)\n```',
            '~~~python\nhandlers[kind](request)\n~~~',
            '````python\n```\nhandlers[kind](request)\n````',
            '    handlers[kind](request)',
            '\thandlers[kind](request)',
            '> ```python\n> handlers[kind](request)\n> ```',
            '>     handlers[kind](request)',
            '- ```python\n  handlers[kind](request)\n  ```',
            '- 説明\n\n      handlers[kind](request)',
            '1. 説明\n\n       handlers[kind](request)',
            '> - ```python\n>   handlers[kind](request)\n>   ```',
            '```markdown\n> [core]: missing\n- [core]: missing\n```',
            '> ```markdown\n> > ```\n> [core]: missing\n> ```',
        )
        for snippet in examples:
            with self.subTest(snippet=snippet): self.markdown_probe(snippet)
    def test_markdown_links_survive_code_filtering(self):
        broken='[参照](skills/mino-core/references/missing.md)'
        examples=(
            '`handlers[kind](request)` '+broken,
            '```python\nhandlers[kind](request)\n```\n\n'+broken,
            '    handlers[kind](request)\n\n'+broken,
            '> ```python\n> handlers[kind](request)\n\n'+broken,
            '- ```python\n  handlers[kind](request)\n\n'+broken,
            '説明\n    '+broken,
            '[`label`](skills/mino-core/references/missing.md)',
        )
        for snippet in examples:
            with self.subTest(snippet=snippet): self.markdown_probe(snippet,1,'E_REFERENCE')
    def test_markdown_explicit_code_path_still_checked(self):
        self.markdown_probe('`skills/mino-core/references/missing.md`',1,'E_REFERENCE')
    def test_markdown_container_definitions(self):
        layouts=(
            '> [参照][core]\n>\n> [core]: {target}',
            '- [参照][core]\n\n  [core]: {target}',
            '1. [参照][core]\n\n   [core]: {target}',
            '> - [参照][core]\n>\n>   [core]: {target}',
            '- > [参照][core]\n  >\n  > [core]: {target}',
        )
        targets=(
            ('skills/mino-core/schemas/core.md',0,None),
            ('skills/mino-core/references/missing.md',1,'E_REFERENCE'),
            ('skills/../outside.md',1,'E_PATH'),
            ('../outside.md',1,'E_ABSOLUTE_LINK'),
        )
        for layout in layouts:
            for target,code,token in targets:
                with self.subTest(layout=layout,target=target):
                    self.markdown_probe(layout.format(target=target),code,token)
    def test_markdown_multiline_definitions(self):
        layouts=(
            '[参照][core]\n\n[core]:\n  <{target}> "説明"',
            '> [参照][core]\n>\n> [core]:\n>   {target}',
            '- [参照][core]\n\n  [core]:\n    {target}',
        )
        for layout in layouts:
            for name,code,token in (('core',0,None),('missing',1,'E_REFERENCE')):
                with self.subTest(layout=layout,name=name):
                    self.markdown_probe(layout.format(target=f'skills/mino-core/schemas/{name}.md'),code,token)
    def test_markdown_container_reference_reachability(self):
        # 同じfileへ他の参照がない状態で、container内の定義をgraphへ登録する。
        logical='skills/mino-core/references/linked-only.md'
        self.path('mino-core/references/linked-only.md').write_text('# Linked only\n',encoding='utf-8',newline='\n')
        inventory=self.path('mino-core/scripts/suite-files.txt')
        items=inventory.read_text(encoding='utf-8').splitlines()+[logical]
        inventory.write_text('\n'.join(sorted(items))+'\n',encoding='utf-8',newline='\n')
        self.probe(1,'E_ORPHAN_REFERENCE')
        self.markdown_probe('> [参照][only]\n>\n> [only]:\n>   '+logical)
    def test_repository_runtime_dependency(self):
        p=self.path('mino-core/references/code-design.md')
        with p.open('a',encoding='utf-8',newline='\n') as f:f.write('\nmino-doc/README.mdを読む。\n')
        self.probe(1,'E_PORTABILITY')
    def test_external_runtime_dependency(self):
        p=self.path('mino-core/references/code-design.md')
        with p.open('a',encoding='utf-8',newline='\n') as f:f.write('\nhttps://example.invalid/guide\n')
        self.probe(1,'E_RUNTIME_WEB')
    def test_bad_metadata(self):
        self.change('mino-core/agents/openai.yaml','interface:\n','interface: inline\n');self.probe(1,'E_METADATA')
    def test_implicit_core(self):
        self.change('mino-core/agents/openai.yaml','false','true');self.probe(1,'E_IMPLICIT')
    def test_default_prompt_wrong_field(self):
        p=self.path('mino-core/agents/openai.yaml');text=p.read_text(encoding='utf-8')
        text=text.replace('$mino-core','mino-core');p.write_text(text,encoding='utf-8',newline='\n');self.probe(1,'E_DEFAULT_PROMPT')
    def test_short_description(self):
        p=self.path('mino-core/agents/openai.yaml');lines=p.read_text(encoding='utf-8').splitlines()
        lines[2]='  short_description: "短い"';p.write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n');self.probe(1,'E_SHORT_DESCRIPTION')
    def test_unicode_description_limit(self):
        p=self.path('mino-core/agents/openai.yaml');lines=p.read_text(encoding='utf-8').splitlines()
        lines[2]='  short_description: "'+('a'*63)+'😀"';p.write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n');self.probe()
    def test_enum_drift(self):
        self.mutate_registry(lambda d:d['decision_status'].append('verified'));self.probe(1,'E_CANONICAL_ENUM')
    def test_artifact_root_drift(self):
        self.mutate_registry(lambda d:d['skills']['mino-reproducible-development'].update(root='integrated_result'));self.probe(1,'E_CANONICAL_ROOT')
    def test_dimension_duplication(self):
        self.mutate_registry(lambda d:d['model_dimensions'].__setitem__(0,'concept'));self.probe(1,'E_DIMENSIONS')
    def test_registry_mode_drift(self):
        self.mutate_registry(lambda d:d['skills']['mino-problem-framing'].update(modes=['implementation']))
        self.probe(1,'E_CANONICAL_MODES')
    def test_registry_invocation_drift(self):
        self.mutate_registry(lambda d:d['skills']['mino-core'].update(allow_implicit_invocation=True))
        self.probe(1,'E_CANONICAL_IMPLICIT')
    def test_subject_verdict_drift(self):
        self.mutate_registry(lambda d:d['skills']['mino-design-by-contract'].update(subject_verdict=['complete']))
        self.probe(1,'E_SUBJECT_VERDICT')
    def test_dimension_name_drift(self):
        self.mutate_registry(lambda d:d['model_dimensions'].__setitem__(0,'invented'))
        self.probe(1,'E_DIMENSIONS')
    def test_registry_invalid_json(self):
        self.path('mino-core/references/suite-contract.json').write_text('{\n',encoding='utf-8',newline='\n');self.probe(1,'E_CONTRACT_JSON')
    def test_case_expected_field_leak(self):
        self.change(f'mino-core/evaluations/cases/{self.revision}.md','mode:','expected_skill: mino-core\nmode:');self.probe(1,'E_CASE_KEYS')
    def test_case_nested_metadata_leak(self):
        self.change(f'mino-core/evaluations/cases/{self.revision}.md','confirmed_evidence:\n','confirmed_evidence:\n  expected_skill: mino-core\n');self.probe(1,'E_CASE_NESTED')
    def test_case_duplicate_field(self):
        self.change(f'mino-core/evaluations/cases/{self.revision}.md','mode:','mode: review\nmode:');self.probe(1,'E_CASE_KEYS')
    def test_payload_digest(self):
        self.change(f'mino-core/evaluations/cases/{self.revision}.md','Redis','Memcached');self.probe(1,'E_CASE_DIGEST')
    def test_evaluation_heading_version(self):
        self.change(f'mino-core/evaluations/cases/{self.revision}.md',f'# Evaluation cases {self.revision}','# Evaluation cases 0.0.0');self.probe(1,'E_EVALUATION_HEADING')
    def evaluation_format_probe(self,mutate,token):
        for relative in (f'cases/{self.revision}.md',f'oracles/{self.revision}.json',
                         f'oracles/{self.revision}.md'):
            path=self.maintenance/'evaluations'/relative
            original=path.read_bytes()
            with self.subTest(path=relative):
                try:
                    # 異常形式だけをbyte操作で作り、別ファイルの違反を混入させない。
                    path.write_bytes(mutate(original))
                    self.probe(1,token)
                finally:
                    path.write_bytes(original)
    def test_evaluation_crlf(self):
        self.evaluation_format_probe(lambda data:data.replace(b'\n',b'\r\n'),'E_LF')
    def test_evaluation_cr(self):
        self.evaluation_format_probe(lambda data:data.replace(b'\n',b'\r'),'E_LF')
    def test_evaluation_invalid_utf8(self):
        self.evaluation_format_probe(lambda data:b'\xff'+data,'E_UTF8')
    def test_evaluation_utf8_bom(self):
        self.evaluation_format_probe(lambda data:b'\xef\xbb\xbf'+data,'E_BOM')
    def test_evaluation_no_final_newline(self):
        self.evaluation_format_probe(lambda data:data.rstrip(b'\n'),'E_NEWLINE')
    def test_evaluation_empty(self):
        self.evaluation_format_probe(lambda data:b'','E_NEWLINE')
    def test_case_body_crlf_digest(self):
        path=self.maintenance/'evaluations/cases'/(self.revision+'.md')
        data=path.read_bytes()
        body=re.search(rb'^```yaml\n(.*?)^```$',data,re.M|re.S)
        self.assertIsNotNone(body)
        changed=body.group(1).replace(b'\n',b'\r\n')
        path.write_bytes(data[:body.start(1)]+changed+data[body.end(1):])
        self.probe(1,'E_CASE_DIGEST')
    def test_oracle_unknown_route(self):
        p=self.path(f'mino-core/evaluations/oracles/{self.revision}.json');d=json.loads(p.read_text(encoding='utf-8'))
        d['cases'][0]['expected_skill']='invented';p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n');self.probe(1,'E_ORACLE_ROUTE')
    def test_oracle_markdown_drift(self):
        self.change(f'mino-core/evaluations/oracles/{self.revision}.md','mino-problem-framing','mino-design-by-contract')
        self.probe(1,'E_ORACLE_PARITY')
    def test_render_oracle_reproducible(self):
        target=self.path(f'mino-core/evaluations/oracles/{self.revision}.md')
        expected=target.read_bytes()
        target.write_bytes(b'# Outdated derived document\n')
        command=[sys.executable,'-B',str(self.maintenance/'scripts/render_evaluation_oracle.py'),
                 '--maintenance-root',str(self.maintenance)]
        result=self.run_python(command)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
        self.assertEqual(target.read_bytes(),expected)
        self.probe()
    def test_render_oracle_missing_source(self):
        source=self.path(f'mino-core/evaluations/oracles/{self.revision}.json')
        source.unlink()
        command=[sys.executable,'-B',str(self.maintenance/'scripts/render_evaluation_oracle.py'),
                 '--maintenance-root',str(self.maintenance)]
        result=self.run_python(command)
        self.assertEqual(result.returncode,2,result.stdout+result.stderr)
        self.assertIn('E_ORACLE',result.stdout)
        self.assertIn(repr(str(source)),result.stdout)
    def test_japanese_temp_legacy_stdio(self):
        # fixture親はCP932、UTF-8 mode 0で起動し、孫Pythonとの通信を検査する。
        japanese_temp=Path(self.temp.name)/'日本語 TEMP'
        japanese_temp.mkdir()
        script=(
            'import sys, tempfile, unittest\n'
            'from pathlib import Path\n'
            'sys.path.insert(0, sys.argv[1])\n'
            'import test_validator_fixtures as fixtures\n'
            'fixtures.SOURCE = Path(sys.argv[2])\n'
            'assert sys.flags.utf8_mode == 0\n'
            'assert sys.stdout.encoding == "cp932"\n'
            'assert Path(tempfile.gettempdir()) == Path(sys.argv[3])\n'
            'names = ["Fixtures.test_utf8_bom", "Fixtures.test_crlf", '
            '"Fixtures.test_render_oracle_reproducible", "Fixtures.test_render_oracle_missing_source"]\n'
            'suite = unittest.defaultTestLoader.loadTestsFromNames(names, fixtures)\n'
            'result = unittest.TextTestRunner(verbosity=2).run(suite)\n'
            'sys.exit(0 if result.wasSuccessful() else 1)\n'
        )
        env={**os.environ,'PYTHONUTF8':'0','PYTHONIOENCODING':'cp932',
             **{name:str(japanese_temp) for name in ('TMP','TEMP','TMPDIR')}}
        result=subprocess.run([sys.executable,'-B','-c',script,
                               str(MAINTENANCE/'scripts'),str(SOURCE),str(japanese_temp)],
                              env=env,capture_output=True,text=True,encoding='cp932',timeout=60)
        self.assertEqual(result.returncode,0,result.stdout+result.stderr)
    def test_judgment_case_hint(self):
        p=self.path(f'mino-core/evaluations/oracles/{self.revision}.json')
        d=json.loads(p.read_text(encoding='utf-8'))
        d['cases'][0]['forbidden'].append('対象systemのcode・設定・運用dataの変更')
        p.write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8',newline='\n')
        self.probe(1,'E_CASE_HINT')
    def test_link_outside(self):
        outside=Path(self.temp.name)/'outside';outside.mkdir()
        (outside/'secret.md').write_text('# Must not read\n',encoding='utf-8',newline='\n')
        try:self.path('mino-core/references/external').symlink_to(outside,target_is_directory=True)
        except (OSError,NotImplementedError):self.skipTest('Native link creation unavailable')
        self.probe(1,'E_LINK')
    def test_entry_read_budget(self):
        self.markdown_entry_probe('説明'*6000,1,'E_ENTRY_READ_BUDGET')
    def test_shared_policy_routing(self):
        self.change('mino-core/SKILL.md','skills/mino-core/references/shared-policies.md',
                    'skills/mino-core/schemas/core.md')
        self.probe(1,'E_COMMON_ROUTING')
    def markdown_entry_probe(self,snippet,code,token):
        path=self.path('mino-core/SKILL.md')
        with path.open('a',encoding='utf-8',newline='\n') as f: f.write('\n'+snippet+'\n')
        self.probe(code,token)
    def test_eager_schema(self):
        self.markdown_entry_probe('```yaml\nrecord: {}\n```',1,'E_EAGER_SCHEMA')
    def test_person_name(self):
        self.markdown_entry_probe('ミノ駆動氏の方法',1,'E_RUNTIME_NAME')
    def test_model_name(self):
        self.markdown_entry_probe('Astra',1,'E_RUNTIME_NAME')
    def test_authoring_provenance(self):
        self.markdown_entry_probe('method_provenance: {}',1,'E_RUNTIME_HISTORY')
    def test_maintenance_reference(self):
        self.markdown_entry_probe('maintenance/benchmark.mdを読む',1,'E_RUNTIME_MAINTENANCE')
    def test_maintenance_payload(self):
        # path helperは保守領域へ解決するので、混入fixtureを直接runtimeに作る。
        p=self.root/'mino-core/evaluations/accidental.md'
        p.parent.mkdir();p.write_text('# Evaluation history\n',encoding='utf-8',newline='\n')
        self.probe(1,'E_RUNTIME_MAINTENANCE')
    def test_condition_owner_field_missing(self):
        self.change('mino-design-by-contract/schemas/package.md','  authoritative_owner:', '  invented_owner:')
        self.probe(1,'E_SCHEMA_FIELDS')
    def test_platform_schema_field_missing(self):
        self.change('mino-core/schemas/platform.md','      required_runner:', '      runner_missing:')
        self.probe(1,'E_SCHEMA_FIELDS')
    def test_bad_cli_argument(self):self.probe(2,'unrecognized arguments',extra=['--unknown'])

def main():
    global SOURCE
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--skills-root',type=Path,default=SOURCE)
    args=parser.parse_args();SOURCE=args.skills_root.resolve()
    if not (SOURCE/'mino-core/SKILL.md').is_file() or not (MAINTENANCE/'scripts/validate_suite.py').is_file():
        print('E_ENGINE: fixture source/engine missing');return 2
    result=unittest.TextTestRunner(verbosity=2).run(unittest.defaultTestLoader.loadTestsFromTestCase(Fixtures))
    print(f'Fixture summary: total={result.testsRun}; failures={len(result.failures)}; '
          f'errors={len(result.errors)}; skipped={len(result.skipped)}')
    return 0 if result.wasSuccessful() else 1
if __name__=='__main__':
    if sys.version_info<(3,10):print('E_PYTHON: Python 3.10+ required');sys.exit(2)
    sys.exit(main())
