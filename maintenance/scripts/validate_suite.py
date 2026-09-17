#!/usr/bin/env python3
"""Read-only structural checks for the complete seven-skill distribution.

Python 3.10+ standard library only. This checks package structure and declared
contracts; it does not prove model behavior, application correctness or approval.
"""
import argparse
import hashlib
import json
import re
import sys
from pathlib import Path
from urllib.parse import unquote

NAMES = {
    'mino-core', 'mino-problem-framing', 'mino-domain-model-completeness',
    'mino-design-by-contract', 'mino-interface-implementation-separation',
    'mino-architecture-quality-strategy', 'mino-reproducible-development',
}
REQUIRED_HEADINGS = {
    'Outcome Contract', 'Reference Routing', 'Workflow', 'Hard Gates', 'Completion',
}
CASE_FIELDS = {'mode','required_platforms','raw_request','confirmed_evidence',
               'known_unknowns','allowed_assumptions','prohibited_changes'}
ROOTS = {
    'mino-core':'core_result', 'mino-problem-framing':'problem_framing_package',
    'mino-domain-model-completeness':'completeness_package',
    'mino-design-by-contract':'contract_package',
    'mino-interface-implementation-separation':'boundary_package',
    'mino-architecture-quality-strategy':'architecture_strategy_package',
    'mino-reproducible-development':'reproducible_development_result',
}
CANONICAL = {
    'decision_status':['pass','revise','blocked','awaiting_approval'],
    'artifact_readiness':['ready','incomplete','blocked'],
    'engineering_status':['not_started','planned','changed','verified','failed'],
    'release_status':['not_applicable','not_ready','awaiting_approval','approved'],
    'evidence_status':['confirmed','inferred','assumption','unknown','contradiction'],
    'decision_maturity':['proposed','approved','frozen','unknown','contradiction'],
}
MODES = {'internal', 'design', 'review', 'implementation', 'reproduction-test'}
OWNERS = {
    'evidence_authority_decision': 'mino-core',
    'problem_framing': 'mino-problem-framing',
    'use_case_model_audit': 'mino-domain-model-completeness',
    'condition_authority_oracle': 'mino-design-by-contract',
    'consumer_boundary': 'mino-interface-implementation-separation',
    'system_quality_data_authority_transition': 'mino-architecture-quality-strategy',
    'integration_verification': 'mino-reproducible-development',
}


def render_oracle(oracle):
    """Render the evaluator-only Markdown from its authoritative JSON record."""
    lines = [
        '# Evaluator oracles ' + oracle['evaluation_revision'], '',
        'Evaluator-only。solverのworkspaceからevaluations全体を除外する。',
        'このMarkdownは同版JSONから生成する。変更はJSONへ行い、再生成して一致を検査する。', '',
        'Suite version: ' + oracle['suite_version'],
        'Case maturity: ' + oracle['case_maturity'],
        'Freeze owner: ' + (oracle['freeze_owner'] or 'unassigned'), '',
        '## Runner metadata', '',
        '| Case | Section | Evaluation type | Expected primary skill | Input SHA-256 |',
        '|---|---|---|---|---|',
    ]
    for row in oracle['cases']:
        lines.append(f"| {row['case_id']} | {row['section']} | {row['evaluation_type']} | "
                     f"{row['expected_skill']} | `{row['input_sha256']}` |")
    lines += ['', '## Evaluation rules', '',
              '主成果物・判定層・根拠を照合する。キーワード出現だけでpassとしない。',
              'judgmentとinstruction_followingは別集計とし、実toolがない操作を成功としない。',
              'caseをfrozenにする承認とfresh-context実行のEvidenceがないrunはrelease母数へ数えない。']
    for row in oracle['cases']:
        lines += ['', f"## {row['case_id']} oracle", '',
                  'Tags: ' + ', '.join(row['tags']), '', 'Required:']
        lines += ['- ' + item for item in row['required']]
        lines += ['', 'Forbidden:']
        lines += ['- ' + item for item in row['forbidden']]
    return '\n'.join(lines) + '\n'


class Check:
    def __init__(self):
        self.errors=[]; self.capabilities=[]; self.checks=0
    def require(self, ok, code, detail):
        self.checks += 1
        if not ok: self.errors.append(f'{code}: {detail}')
    def read(self, path):
        try:
            data=path.read_bytes()
        except OSError as exc:
            self.capabilities.append(f'E_IO: {path.name}: {exc}'); return None
        try:
            text=data.decode('utf-8',errors='strict')
        except UnicodeDecodeError:
            self.errors.append(f'E_UTF8: {path.name}'); return None
        self.require(not data.startswith(b'\xef\xbb\xbf'),'E_BOM',str(path))
        self.require(b'\r' not in data,'E_LF',str(path))
        self.require(bool(data) and data.endswith(b'\n'),'E_NEWLINE',str(path))
        self.require(all(line==line.rstrip(' \t') for line in text.splitlines()),
                     'E_TRAILING_SPACE',str(path))
        return text
    def result(self):
        for line in self.errors+self.capabilities: print(line)
        print(f'Checks: {self.checks}; Errors: {len(self.errors)}; '
              f'Warnings: 0; Capability errors: {len(self.capabilities)}')
        return 2 if self.capabilities else (1 if self.errors else 0)

def is_link(path):
    try:
        return path.is_symlink() or (hasattr(path,'is_junction') and path.is_junction()) or \
            bool(getattr(path.lstat(),'st_file_attributes',0) & 0x400)
    except OSError:
        return False

def markdown_prose_blocks(text):
    """引用・リストのcontainerを解き、リンクを持ち得る本文だけを返す。"""
    containers=[]
    fence=None
    paragraph=[]
    indented_code=False
    for raw in text.expandtabs(4).splitlines():
        line=raw
        matched=0
        for kind,width in containers:
            if kind=='quote':
                marker=re.match(r'^ {0,3}> ?',line)
                if not marker: break
                line=line[marker.end():]
            elif not line.strip():
                line=''
            elif line.startswith(' '*width):
                line=line[width:]
            else:
                break
            matched+=1
        if matched<len(containers):
            # paragraphのlazy continuationだけはcontainerを継続する。
            if paragraph and line.strip() and not re.match(
                    r'^ {0,3}(?:>|[-+*] |\d{1,9}[.)] |`{3,}|~{3,}|#{1,6} )',line):
                paragraph.append(line)
                continue
            if paragraph:
                yield '\n'.join(paragraph)
                paragraph=[]
            containers=containers[:matched]
            fence=None
            indented_code=False
        if fence:
            char,length=fence
            if re.fullmatch(r' {0,3}'+re.escape(char)+'{'+str(length)+r',} *',line):
                fence=None
            continue
        # code中には新しいcontainerを開かない。継続indentとcode indentを分ける。
        while True:
            quote=re.match(r'^ {0,3}> ?',line)
            item=re.match(r'^ {0,3}(?:[-+*]|\d{1,9}[.)])( +|$)',line)
            if not quote and not item: break
            if paragraph:
                yield '\n'.join(paragraph)
                paragraph=[]
            if quote:
                containers.append(('quote',0))
                line=line[quote.end():]
            else:
                # marker後の5文字以上の空白は、1文字だけcontainerへ属する。
                width=item.end() if len(item[1])<=4 else item.start(1)+1
                containers.append(('list',width))
                line=line[width:]
            indented_code=False
        opening=re.match(r'^ {0,3}(`{3,}|~{3,})(.*)$',line)
        if opening and not (opening[1][0]=='`' and '`' in opening[2]):
            if paragraph:
                yield '\n'.join(paragraph)
                paragraph=[]
            fence=(opening[1][0],len(opening[1]))
            indented_code=False
        elif not line.strip():
            if paragraph:
                yield '\n'.join(paragraph)
                paragraph=[]
        elif line.startswith('    ') and (indented_code or not paragraph):
            indented_code=True
        else:
            indented_code=False
            # 見出し・罫線の前後へcode spanや参照定義を跨がせない。
            boundary=re.match(r'^ {0,3}(?:#{1,6}(?: |$)|(?:[-*_] *){3,}$|[=-]+ *$)',line)
            if boundary:
                if paragraph:
                    yield '\n'.join(paragraph)
                    paragraph=[]
                yield line
            else:
                paragraph.append(line)
    if paragraph:
        yield '\n'.join(paragraph)


def mask_code_spans(text):
    """同じ長さのbacktickで閉じたcode spanだけを除外する。"""
    parts=[]
    pos=0
    while pos<len(text):
        if text[pos]=='\\' and pos+1<len(text):
            parts.append(text[pos:pos+2])
            pos+=2
            continue
        if text[pos]!='`':
            parts.append(text[pos])
            pos+=1
            continue
        opener=re.match(r'`+',text[pos:])[0]
        end=pos+len(opener)
        closer=re.search(r'(?<!`)'+opener+r'(?!`)',text[end:])
        if closer:
            stop=end+closer.end()
            parts.append(re.sub(r'[^\n]',' ',text[pos:stop]))
            pos=stop
        else:
            parts.append(opener)
            pos=end
    return ''.join(parts)


def markdown_link_targets(text):
    # code例はリンクにしない。明示的なbacktick内pathは呼出元で別途検査する。
    text='\n\n'.join(mask_code_spans(block) for block in markdown_prose_blocks(text))
    # destinationは定義の次行にも置ける。空行を跨いでは収集しない。
    starts=r'\]\([ \t\n]*|^ {0,3}\[[^\]\n]+\]:[ \t]*(?:\n[ \t]*)?'
    for match in re.finditer(starts,text,re.M):
        start=match.end()
        if text[start:start+1]=='<':
            end=text.find('>',start+1)
            if end<0 or '\n' in text[start:end]: continue
            target=text[start+1:end]
        else:
            end=start; depth=0
            while end<len(text) and not text[end].isspace():
                char=text[end]
                if char=='\\' and end+1<len(text) and text[end+1] in '()':
                    end+=2; continue
                if char=='(':
                    depth+=1
                elif char==')':
                    if depth==0: break
                    depth-=1
                end+=1
            target=text[start:end]
        # URL escapeやMarkdown escapeでも同じpath検査を通す。
        yield unquote(re.sub(r'\\([()])',r'\1',target))

def schema_field_paths(text):
    """同梱schemaの宣言fieldを取り出し、保守側の契約と照合する。"""
    fields=set()
    for block in re.findall(r'^```yaml\n(.*?)^```$',text,re.M|re.S):
        stack=[]
        for line in block.splitlines():
            match=re.match(r'^( *)(?:- )?([a-z_][a-z_0-9]*):',line)
            if not match: continue
            indent=len(match[1])+(2 if line.lstrip().startswith('- ') else 0)
            while stack and stack[-1][0]>=indent: stack.pop()
            stack.append((indent,match[2]))
            fields.add('.'.join(key for _,key in stack))
    return fields


def validate(root, manifest, maintenance):
    c=Check()
    if not root.is_dir() or is_link(root):
        c.capabilities.append('E_ROOT: missing or linked skills root'); return c.result()
    root=root.resolve()
    if not manifest.is_file():
        c.capabilities.append('E_MANIFEST_MISSING: manifest unavailable'); return c.result()
    text=c.read(manifest)
    if text is None: return c.result()
    data={'suite_version':[],'owner':[],'skill':[]}
    for line in text.splitlines():
        if not line or line.startswith('#'): continue
        key,sep,value=line.partition('=')
        if not sep or key not in data or not value.strip():
            c.require(False,'E_MANIFEST_LINE',line); continue
        data[key].append(value)
    for scalar in ['suite_version','owner']:
        c.require(len(data[scalar])==1,'E_MANIFEST_SCALAR',scalar)
    version=data['suite_version'][0] if data['suite_version'] else ''
    c.require(bool(re.fullmatch(r'(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)',version)),
              'E_VERSION',version)
    names=data['skill']
    c.require(len(names)==len(set(names)),'E_DUP_SKILL','duplicate skill')
    c.require(set(names)==NAMES and len(names)==7,'E_SKILL_SET','expected seven canonical skills')
    c.require(all(re.fullmatch(r'mino-[a-z0-9-]+',n) for n in names),'E_SKILL_NAME','manifest names')
    actual={p.name for p in root.iterdir() if p.name.startswith('mino-')}
    c.require(actual==NAMES,'E_UNLISTED_SKILL',repr(actual-NAMES))
    runtime={}; actual_files=set()
    for name in sorted(NAMES):
        directory=root/name
        if not directory.is_dir():
            c.require(False,'E_SKILL_MISSING',name); continue
        if is_link(directory):
            c.require(False,'E_LINK',name); continue
        # Reject linked files/directories before reading or following them.
        for path in sorted(directory.rglob('*')):
            rel='skills/'+path.relative_to(root).as_posix()
            if is_link(path) or any(is_link(a) for a in path.parents if a!=root and root in a.parents):
                c.require(False,'E_LINK',rel); continue
            if not path.is_file(): continue
            actual_files.add(rel)
            content=c.read(path)
            if content is not None:
                runtime[rel]=content
    inventory=maintenance/'scripts/suite-files.txt'
    if not inventory.is_file():
        c.require(False,'E_INVENTORY_MISSING',str(inventory))
    else:
        inventory_text=c.read(inventory)
        items=inventory_text.splitlines() if inventory_text is not None else []
        c.require(len(items)==len(set(items)),'E_INVENTORY_DUP','inventory')
        c.require(items==sorted(items),'E_INVENTORY_ORDER','inventory')
        c.require(set(items)==actual_files,'E_INVENTORY',
                  f'missing={sorted(set(items)-actual_files)}; extra={sorted(actual_files-set(items))}')
    graph={}
    for logical,t in runtime.items():
        c.require(not any(part in {'evaluations','scripts'} for part in logical.split('/')),
                  'E_RUNTIME_MAINTENANCE',logical)
        c.require(not re.search(r'ミノ駆動|\b(?:Astra|Sol|Terra|Luna)\b|\bgpt-\d',t,re.I),
                  'E_RUNTIME_NAME',logical)
        c.require(not re.search(r'method_provenance|suite[_ ]operationalization|source[-_]derived|repository[_ ]policy|登壇予告|著者本人',t,re.I),
                  'E_RUNTIME_HISTORY',logical)
        if not logical.endswith('.md'): continue
        c.require('maintenance/' not in t,'E_RUNTIME_MAINTENANCE',logical)
        c.require('mino-doc/' not in t and '.agents/skills/' not in t and '$HOME/' not in t,
                  'E_PORTABILITY',logical)
        c.require(not re.search(r'https?://',t),'E_RUNTIME_WEB',logical)
        if any(part in logical for part in ['/references/','/schemas/']) and len(t.splitlines())>100:
            c.require('## Contents' in t.splitlines(),'E_CONTENTS',logical)
        refs=set()
        items=[(item,False) for item in re.findall(r'`([^`\n]+)`',t)]
        items.extend((item,True) for item in markdown_link_targets(t))
        for item,from_link in items:
            if from_link and item.startswith('#'): continue
            if item.startswith('skills/'):
                target=item.split('#',1)[0].rstrip('/')
                if not from_link and ('<' in target or '*' in target): continue
                c.require('..' not in target.split('/') and '//' not in target and '\\' not in target,
                          'E_PATH',logical+': '+item)
                q=root/target[len('skills/'):]
                exists=q.exists() and q.resolve().is_relative_to(root)
                c.require(exists,'E_REFERENCE',logical+': '+item)
                refs.add(target)
            elif from_link and re.match(r'(?:\.\./|[/\\~]|[A-Za-z]:)',item):
                c.require(False,'E_ABSOLUTE_LINK',logical+': '+item)
            elif from_link or re.fullmatch(r'[A-Za-z0-9_./-]+\.(md|json|yaml|yml|py|sh|ps1|txt)',item):
                c.require(False,'E_BARE_PATH',logical+': '+item)
        graph[logical]=refs
        for name in re.findall(r'\$(mino-[a-z0-9-]+)',t):
            c.require(name in NAMES,'E_SKILL_CALL',logical+': '+name)
    for name in sorted(NAMES):
        logical=f'skills/{name}/SKILL.md'; t=runtime.get(logical,'')
        lines=t.splitlines()
        c.require(len(lines)>=4 and lines[0]=='---' and lines[3]=='---', 'E_FRONTMATTER',name)
        c.require(len(lines)>=3 and lines[1]=='name: '+name and lines[2].startswith('description: '),
                  'E_FRONTMATTER_FIELDS',name)
        c.require(len(lines)<=500,'E_SKILL_LENGTH',name)
        # 判断本文と共通規則の上限。schemaを入口へ戻す変更も検出する。
        common=runtime.get('skills/mino-core/references/shared-policies.md','')
        c.require(len(t.encode('utf-8'))+len(common.encode('utf-8'))<=14000,
                  'E_ENTRY_READ_BUDGET',name)
        c.require(not re.search(r'^```(?:yaml|json)',t,re.M),'E_EAGER_SCHEMA',name)
        headings={line[3:] for line in lines if line.startswith('## ')}
        c.require(REQUIRED_HEADINGS<=headings,'E_HEADINGS',name+': '+repr(REQUIRED_HEADINGS-headings))
        for asset in ['shared-policies.md','platform-compatibility.md']:
            c.require('skills/mino-core/references/'+asset in t,'E_COMMON_ROUTING',name+': '+asset)
        c.require('`'+ROOTS[name]+'`' in t,'E_ROOT_CONTRACT',name)
        meta=runtime.get(f'skills/{name}/agents/openai.yaml','')
        pattern=(r'interface:\n  display_name: "[^"\n]+"\n  short_description: "([^"\n]+)"\n'
                 r'  default_prompt: "([^"\n]+)"\npolicy:\n  allow_implicit_invocation: (true|false)\n')
        m=re.fullmatch(pattern,meta)
        c.require(bool(m),'E_METADATA',name)
        if m:
            c.require(25<=len(m.group(1))<=64,'E_SHORT_DESCRIPTION',name)
            c.require('$'+name in m.group(2),'E_DEFAULT_PROMPT',name)
            c.require(m.group(3)==('false' if name=='mino-core' else 'true'),'E_IMPLICIT',name)
    cp=maintenance/'suite-contract.json'
    revision=''
    try:
        contract=json.loads(cp.read_text(encoding='utf-8'))
        c.require(contract.get('suite_version')==version,'E_CONTRACT_VERSION',version)
        c.require(set(contract.get('skills',{}))==NAMES,'E_CONTRACT_SKILLS','registry')
        for key,values in CANONICAL.items():
            c.require(contract.get(key)==values,'E_CANONICAL_ENUM',key)
        for name in NAMES:
            spec=contract.get('skills',{}).get(name,{})
            c.require(spec.get('root')==ROOTS[name],
                      'E_CANONICAL_ROOT',name)
            entry=runtime.get(f'skills/{name}/SKILL.md','')
            declarations=re.findall(r'^対応mode: (.+)。$',entry,re.M)
            modes=declarations[0].split(', ') if len(declarations)==1 else []
            c.require(bool(modes) and len(modes)==len(set(modes)) and set(modes)<=MODES
                      and modes==spec.get('modes'),'E_CANONICAL_MODES',name)
            meta=runtime.get(f'skills/{name}/agents/openai.yaml','')
            implicit=re.search(r'^  allow_implicit_invocation: (true|false)$',meta,re.M)
            c.require(implicit is not None and type(spec.get('allow_implicit_invocation')) is bool
                      and spec['allow_implicit_invocation']==(implicit.group(1)=='true'),
                      'E_CANONICAL_IMPLICIT',name)
            workflow=f'skills/{name}/schemas/package.md'
            if name=='mino-core': workflow='skills/mino-core/schemas/core.md'
            verdicts=re.findall(r'^\s+subject_verdict: ([a-z_]+(?: \| [a-z_]+)+)$',
                                runtime.get(workflow,''),re.M)
            expected=verdicts[0].split(' | ') if verdicts else []
            c.require(spec.get('subject_verdict')==expected and len(set(verdicts))<=1,
                      'E_SUBJECT_VERDICT',name)
        owners=contract.get('owner_by_concern',{})
        c.require(owners==OWNERS,'E_OWNERSHIP','registry')
        dims=contract.get('model_dimensions',[])
        model_workflow=runtime.get('skills/mino-domain-model-completeness/schemas/package.md','')
        dimension_match=re.search(r'^  dimension: (.+)$',model_workflow,re.M)
        c.require(len(dims)==12 and len(set(dims))==12 and dimension_match is not None
                  and dims==dimension_match.group(1).split(' | '),'E_DIMENSIONS','canonical dimensions')
        revision=contract.get('evaluation_revision','')
        c.require(isinstance(revision,str) and bool(re.fullmatch(re.escape(version)+r'-r[1-9]\d*',revision)),
                  'E_EVALUATION_REVISION','expected suite version followed by -rN')
    except (OSError,ValueError,TypeError,KeyError) as e:
        c.require(False,'E_CONTRACT_JSON',str(e))
    try:
        shapes=json.loads((maintenance/'package-shapes.json').read_text(encoding='utf-8'))
        for logical,fields in shapes.items():
            actual=schema_field_paths(runtime.get(logical,''))
            c.require(set(fields)<=actual,'E_SCHEMA_FIELDS',logical+': '+repr(sorted(set(fields)-actual)))
    except (OSError,ValueError,TypeError) as exc:
        c.require(False,'E_SCHEMA_CONTRACT',str(exc))
    seen=set(); pending=[f'skills/{n}/SKILL.md' for n in NAMES]
    while pending:
        p=pending.pop()
        if p in seen: continue
        seen.add(p); pending.extend(graph.get(p,set())-seen)
    for p in runtime:
        if any(part in p for part in ['/references/','/schemas/']) and p.endswith(('.md','.json')):
            c.require(p in seen,'E_ORPHAN_REFERENCE',p)
    if re.fullmatch(r'\d+\.\d+\.\d+',version) and isinstance(revision,str) and \
            re.fullmatch(re.escape(version)+r'-r[1-9]\d*',revision):
        base=maintenance/'evaluations'
        evaluation_text={}
        for path,head,label in [(base/(version+'.md'),'Evaluation',version),
                               (base/'cases'/(revision+'.md'),'Evaluation cases',revision),
                               (base/'oracles'/(revision+'.md'),'Evaluator oracles',revision)]:
            c.require(path.is_file(),'E_EVALUATION_FILE',str(path))
            if path.is_file():
                text=c.read(path)
                evaluation_text[path]=text
                if text is not None:
                    c.require(text.partition('\n')[0]==f'# {head} {label}',
                              'E_EVALUATION_HEADING',str(path))
        cases=base/'cases'/(revision+'.md'); oracle=base/'oracles'/(revision+'.json')
        if oracle.is_file(): evaluation_text[oracle]=c.read(oracle)
        if cases.is_file() and oracle.is_file():
            text=evaluation_text.get(cases); oracle_text=evaluation_text.get(oracle)
            if text is None or oracle_text is None: return c.result()
            # 生bytesからdecodeしたtextを再利用し、入力の改行を正規化しない。
            bodies=re.findall(r'^```yaml\n(.*?)^```$',text,re.M|re.S)
            try:
                oracle_data=json.loads(oracle_text)
                rows=oracle_data['cases']
                c.require(oracle_data.get('suite_version')==version and
                          oracle_data.get('evaluation_revision')==revision,'E_ORACLE_VERSION',revision)
                markdown=base/'oracles'/(revision+'.md')
                markdown_text=evaluation_text.get(markdown)
                c.require(markdown_text is not None and
                          markdown_text.encode('utf-8')==render_oracle(oracle_data).encode('utf-8'),
                          'E_ORACLE_PARITY',revision)
                c.require(len(bodies)==len(rows) and len(bodies)>0,'E_CASE_COUNT','cases/oracles')
                c.require(len({r['case_id'] for r in rows})==len(rows),'E_CASE_ID','unique IDs')
                for body,row in zip(bodies,rows):
                    keys=re.findall(r'^([A-Za-z_][A-Za-z0-9_]*):',body,re.M)
                    c.require(set(keys)==CASE_FIELDS and len(keys)==len(CASE_FIELDS),
                              'E_CASE_KEYS',row['case_id'])
                    c.require(not re.search(r'^\s+[A-Za-z_][A-Za-z0-9_]*:',body,re.M),
                              'E_CASE_NESTED',row['case_id'])
                    c.require(hashlib.sha256(body.encode('utf-8')).hexdigest()==row['input_sha256'],
                              'E_CASE_DIGEST',row['case_id'])
                    c.require(row.get('expected_skill') in NAMES|{'none'},'E_ORACLE_ROUTE',row['case_id'])
                    evaluation_type=row.get('evaluation_type')
                    c.require(evaluation_type in {'judgment','instruction_following'},
                              'E_EVALUATION_TYPE',row['case_id'])
                    if evaluation_type=='judgment':
                        constraints=body.partition('prohibited_changes:')[2]
                        values=[json.loads(item) for item in re.findall(r'^  - (".*")$',constraints,re.M)]
                        c.require(not set(values).intersection(row['required']+row['forbidden']),
                                  'E_CASE_HINT',row['case_id'])
            except (ValueError,KeyError,TypeError) as e:
                c.require(False,'E_ORACLE_JSON',str(e))
        else: c.require(False,'E_ORACLE_FILE','missing cases or JSON oracle')
    return c.result()

def main():
    if sys.version_info<(3,10):
        print('E_PYTHON: Python 3.10+ is required for structural validation.');return 2
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--skills-root','-SkillsRoot',type=Path,
                        default=Path(__file__).resolve().parents[2]/'.agents/skills')
    parser.add_argument('--maintenance-root',type=Path,default=Path(__file__).resolve().parents[1])
    parser.add_argument('--manifest-file','-ManifestFile',type=Path)
    args=parser.parse_args()
    return validate(args.skills_root,args.manifest_file or args.maintenance_root/'scripts/suite-manifest.txt',args.maintenance_root)
if __name__=='__main__':
    try: sys.exit(main())
    except (OSError, UnicodeError) as exc:
        print(f'E_IO: {exc}');sys.exit(2)
