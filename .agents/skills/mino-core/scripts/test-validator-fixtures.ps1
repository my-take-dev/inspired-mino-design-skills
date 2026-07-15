[CmdletBinding()]
param(
    [string]$SkillsRoot
)

$ErrorActionPreference = 'Stop'

if (-not $SkillsRoot) {
    $skillDirectory = [System.IO.Directory]::GetParent($PSScriptRoot)
    $SkillsRoot = [System.IO.Directory]::GetParent($skillDirectory.FullName).FullName
} else {
    $SkillsRoot = [System.IO.Path]::GetFullPath($SkillsRoot)
}

if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
    Write-Error "Skills root not found: $SkillsRoot"
    exit 2
}

$manifestPath = Join-Path (Join-Path $SkillsRoot 'mino-core') (Join-Path 'scripts' 'suite-manifest.txt')
$suiteVersionLines = @([System.IO.File]::ReadAllLines($manifestPath) | Where-Object { $_.StartsWith('suite_version=') })
if ($suiteVersionLines.Count -ne 1 -or [string]::IsNullOrWhiteSpace($suiteVersionLines[0].Substring(('suite_version=').Length))) {
    Write-Error "Expected exactly one non-empty suite_version in $manifestPath"
    exit 2
}
$suiteVersion = $suiteVersionLines[0].Substring(('suite_version=').Length)
$fixtureRoot = "mino-core/evaluations/fixtures/$suiteVersion"
$caseRelative = "mino-core/evaluations/cases/$suiteVersion.md"

$engine = Get-Command powershell.exe -ErrorAction SilentlyContinue
if (-not $engine) {
    $engine = Get-Command pwsh -ErrorAction SilentlyContinue
}
if (-not $engine) {
    Write-Error 'Neither powershell.exe nor pwsh is available'
    exit 2
}

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('mino-validator-' + [guid]::NewGuid().ToString('N'))
$null = New-Item -ItemType Directory -Path $tempRoot
$script:caseSkills = ''
$total = 0
$passed = 0
$failed = 0

function Write-Utf8Lf {
    param([string]$Path, [string]$Content)
    [System.IO.File]::WriteAllText($Path, $Content.Replace("`r`n", "`n"), $utf8NoBom)
}

function Replace-First {
    param([string]$Content, [string]$OldValue, [string]$NewValue)
    $index = $Content.IndexOf($OldValue, [System.StringComparison]::Ordinal)
    if ($index -lt 0) {
        throw "Fixture mutation target not found: $OldValue"
    }
    return $Content.Substring(0, $index) + $NewValue + $Content.Substring($index + $OldValue.Length)
}

function New-FixtureCopy {
    param([string]$Name)
    $caseRoot = Join-Path $tempRoot $Name
    $script:caseSkills = Join-Path $caseRoot 'skills'
    $null = New-Item -ItemType Directory -Path $caseRoot
    Copy-Item -LiteralPath $SkillsRoot -Destination $script:caseSkills -Recurse
}

function Test-FixtureResult {
    param(
        [string]$Name,
        [int]$ExpectedStatus,
        [string]$ExpectedText,
        [string]$ManifestRelative = '',
        [int]$ExpectedErrorCount = -1
    )

    $validator = Join-Path (Join-Path $script:caseSkills 'mino-core') (Join-Path 'scripts' 'validate-suite.ps1')
    $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $validator, '-SkillsRoot', $script:caseSkills)
    if ($ManifestRelative) {
        $arguments += @('-ManifestFile', (Join-Path $script:caseSkills $ManifestRelative))
    }
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $output = (& $engine.Source @arguments 2>&1 | Out-String)
    $status = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference

    $script:total++
    $errorCountMatches = $ExpectedErrorCount -lt 0 -or $output.Contains("Errors: $ExpectedErrorCount;")
    if ($status -eq $ExpectedStatus -and (-not $ExpectedText -or $output.Contains($ExpectedText)) -and $errorCountMatches) {
        $script:passed++
        Write-Host "PASS $Name"
    } else {
        $script:failed++
        Write-Error "FAIL $Name`: expected exit $ExpectedStatus, text '$ExpectedText', and error count $ExpectedErrorCount; got exit $status`n$output" -ErrorAction Continue
    }
}

try {
    New-FixtureCopy -Name 'positive'
    Test-FixtureResult -Name 'positive' -ExpectedStatus 0 -ExpectedText ''

    New-FixtureCopy -Name 'unrelated-skill-ignored'
    $path = Join-Path $script:caseSkills 'unrelated-skill/SKILL.md'
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $path)
    [System.IO.File]::WriteAllText($path, "not part of the mino suite`r`n", $utf8NoBom)
    Test-FixtureResult -Name 'unrelated-skill-ignored' -ExpectedStatus 0 -ExpectedText ''

    New-FixtureCopy -Name 'unlisted-mino-skill'
    $path = Join-Path $script:caseSkills 'mino-unlisted/SKILL.md'
    $null = New-Item -ItemType Directory -Path (Split-Path -Parent $path)
    Write-Utf8Lf -Path $path -Content "not listed in the suite manifest`n"
    Test-FixtureResult `
        -Name 'unlisted-mino-skill' `
        -ExpectedStatus 1 `
        -ExpectedText 'Skill directory is not listed in suite manifest: skills/mino-unlisted' `
        -ExpectedErrorCount 1

    $validator = Join-Path (Join-Path $SkillsRoot 'mino-core') (Join-Path 'scripts' 'validate-suite.ps1')
    $missingRoot = Join-Path $tempRoot 'does-not-exist'
    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $missingOutput = (& $engine.Source -NoProfile -ExecutionPolicy Bypass -File $validator -SkillsRoot $missingRoot 2>&1 | Out-String)
    $missingStatus = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    $total++
    if ($missingStatus -eq 2 -and $missingOutput.Contains('Skills root not found')) {
        $passed++
        Write-Host 'PASS missing-skills-root'
    } else {
        $failed++
        Write-Error "FAIL missing-skills-root`: expected exit 2; got exit $missingStatus`n$missingOutput" -ErrorAction Continue
    }

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $unknownOutput = (& $engine.Source -NoProfile -ExecutionPolicy Bypass -File $validator --unknown 2>&1 | Out-String)
    $unknownStatus = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    $total++
    if ($unknownStatus -eq 2 -and $unknownOutput.Contains('Unknown argument: --unknown')) {
        $passed++
        Write-Host 'PASS unknown-argument'
    } else {
        $failed++
        Write-Error "FAIL unknown-argument`: expected exit 2; got exit $unknownStatus`n$unknownOutput" -ErrorAction Continue
    }

    $previousPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $missingValueOutput = (& $engine.Source -NoProfile -ExecutionPolicy Bypass -File $validator -SkillsRoot 2>&1 | Out-String)
    $missingValueStatus = $LASTEXITCODE
    $ErrorActionPreference = $previousPreference
    $total++
    if ($missingValueStatus -eq 2 -and $missingValueOutput.Contains('Missing value for -SkillsRoot')) {
        $passed++
        Write-Host 'PASS missing-option-value'
    } else {
        $failed++
        Write-Error "FAIL missing-option-value`: expected exit 2; got exit $missingValueStatus`n$missingValueOutput" -ErrorAction Continue
    }

    $manifestFixtures = @(
        @('empty-key', 'Invalid suite manifest line', 'manifest-empty-key.txt', -1),
        @('duplicate-suite-version', 'Duplicate suite_version', 'manifest-duplicate-suite-version.txt', 1),
        @('duplicate-owner', 'Duplicate owner', 'manifest-duplicate-owner.txt', 1),
        @('duplicate-skill', 'Duplicate suite skill', 'manifest-duplicate-skill.txt', 1),
        @('invalid-version', 'Invalid suite_version', 'manifest-invalid-version.txt', -1),
        @('invalid-version-separator', 'Invalid suite_version', 'manifest-invalid-version-separator.txt', -1),
        @('leading-zero-version', 'Invalid suite_version', 'manifest-leading-zero-version.txt', -1),
        @('invalid-skill', 'Invalid suite skill name', 'manifest-invalid-skill.txt', -1)
    )
    foreach ($fixture in $manifestFixtures) {
        New-FixtureCopy -Name $fixture[0]
        Test-FixtureResult -Name $fixture[0] -ExpectedStatus 1 -ExpectedText $fixture[1] `
            -ManifestRelative "$fixtureRoot/$($fixture[2])" -ExpectedErrorCount $fixture[3]
    }

    New-FixtureCopy -Name 'solver-field-allowlist'
    $path = Join-Path $script:caseSkills $caseRelative
    $content = [System.IO.File]::ReadAllText($path)
    Write-Utf8Lf -Path $path -Content (Replace-First -Content $content -OldValue "mode: design`n" -NewValue "expected_skill: mino-core`nmode: design`n")
    Test-FixtureResult -Name 'solver-field-allowlist' -ExpectedStatus 1 -ExpectedText 'unsupported top-level field: expected_skill'

    New-FixtureCopy -Name 'solver-nested-metadata'
    $path = Join-Path $script:caseSkills $caseRelative
    $content = [System.IO.File]::ReadAllText($path)
    Write-Utf8Lf -Path $path -Content (Replace-First -Content $content -OldValue "confirmed_evidence:`n" -NewValue "confirmed_evidence:`n  expected_skill: mino-core`n")
    Test-FixtureResult -Name 'solver-nested-metadata' -ExpectedStatus 1 -ExpectedText 'nested mapping field: expected_skill'

    New-FixtureCopy -Name 'stale-version-heading'
    $path = Join-Path $script:caseSkills $caseRelative
    $content = [System.IO.File]::ReadAllText($path)
    Write-Utf8Lf -Path $path -Content (Replace-First -Content $content -OldValue "# Evaluation cases $suiteVersion" -NewValue '# Evaluation cases 0.0.0')
    Test-FixtureResult -Name 'stale-version-heading' -ExpectedStatus 1 -ExpectedText 'heading does not match suite_version'

    New-FixtureCopy -Name 'malformed-frontmatter-delimiter'
    $path = Join-Path $script:caseSkills 'mino-core/SKILL.md'
    $lines = [System.IO.File]::ReadAllLines($path)
    $lines[3] = '---junk'
    Write-Utf8Lf -Path $path -Content (($lines -join "`n") + "`n")
    Test-FixtureResult -Name 'malformed-frontmatter-delimiter' -ExpectedStatus 1 -ExpectedText 'Invalid frontmatter'

    New-FixtureCopy -Name 'frontmatter-name-trailing-garbage'
    $path = Join-Path $script:caseSkills 'mino-core/SKILL.md'
    $content = [System.IO.File]::ReadAllText($path)
    Write-Utf8Lf -Path $path -Content (Replace-First -Content $content -OldValue 'name: mino-core' -NewValue 'name: "mino-core" trailing')
    Test-FixtureResult -Name 'frontmatter-name-trailing-garbage' -ExpectedStatus 1 -ExpectedText 'Skill name must match folder'

    New-FixtureCopy -Name 'flattened-agent-metadata'
    $path = Join-Path $script:caseSkills 'mino-core/agents/openai.yaml'
    $lines = [System.IO.File]::ReadAllLines($path) | Where-Object { $_ -cne 'interface:' -and $_ -cne 'policy:' } | ForEach-Object { $_.TrimStart() }
    Write-Utf8Lf -Path $path -Content (($lines -join "`n") + "`n")
    Test-FixtureResult -Name 'flattened-agent-metadata' -ExpectedStatus 1 -ExpectedText 'Invalid agents/openai.yaml structure'

    New-FixtureCopy -Name 'prompt-token-wrong-field'
    $path = Join-Path $script:caseSkills 'mino-core/agents/openai.yaml'
    $content = [System.IO.File]::ReadAllText($path)
    $content = $content.Replace('display_name: "Shared Core"', 'display_name: "Shared Core $mino-core"')
    $content = $content.Replace('Use $mino-core', 'Use mino-core')
    Write-Utf8Lf -Path $path -Content $content
    Test-FixtureResult -Name 'prompt-token-wrong-field' -ExpectedStatus 1 -ExpectedText 'default_prompt must mention $mino-core'

    New-FixtureCopy -Name 'unicode-scalar-length'
    $path = Join-Path $script:caseSkills 'mino-core/agents/openai.yaml'
    $lines = [System.IO.File]::ReadAllLines($path)
    $shortValue = ('a' * 63) + [char]::ConvertFromUtf32(0x1F600)
    $lines[2] = '  short_description: "' + $shortValue + '"'
    Write-Utf8Lf -Path $path -Content (($lines -join "`n") + "`n")
    Test-FixtureResult -Name 'unicode-scalar-length' -ExpectedStatus 0 -ExpectedText ''

    New-FixtureCopy -Name 'bare-runtime-path'
    $path = Join-Path $script:caseSkills 'mino-core/references/core.md'
    $content = [System.IO.File]::ReadAllText($path)
    $invalidAsset = 'shared-policies' + '.md'
    Write-Utf8Lf -Path $path -Content ($content + "`n``$invalidAsset```n")
    Test-FixtureResult -Name 'bare-runtime-path' -ExpectedStatus 1 -ExpectedText "Runtime asset path must start with 'skills/'"

    New-FixtureCopy -Name 'noncanonical-logical-path'
    $path = Join-Path $script:caseSkills 'mino-core/references/core.md'
    $content = [System.IO.File]::ReadAllText($path)
    $invalidLogicalPath = 'skills/' + '/mino-core/SKILL.md'
    Write-Utf8Lf -Path $path -Content ($content + "`n``$invalidLogicalPath```n")
    Test-FixtureResult -Name 'noncanonical-logical-path' -ExpectedStatus 1 -ExpectedText 'Invalid skills-rooted path'

    New-FixtureCopy -Name 'link-escape'
    $outsideReferenceDirectory = Join-Path $tempRoot 'link-escape-outside'
    $null = New-Item -ItemType Directory -Path $outsideReferenceDirectory
    Write-Utf8Lf -Path (Join-Path $outsideReferenceDirectory 'probe.md') -Content "# Outside probe`n"
    $linkPath = Join-Path $script:caseSkills 'mino-core/references/external-link'
    $null = New-Item -ItemType Junction -Path $linkPath -Target $outsideReferenceDirectory
    $path = Join-Path $script:caseSkills 'mino-core/references/core.md'
    $content = [System.IO.File]::ReadAllText($path)
    Write-Utf8Lf -Path $path -Content ($content + "`n``skills/mino-core/references/external-link/probe.md```n")
    Test-FixtureResult -Name 'link-escape' -ExpectedStatus 1 -ExpectedText 'Skills-rooted path must not traverse a link'

    New-FixtureCopy -Name 'missing-contents'
    $path = Join-Path $script:caseSkills 'mino-core/references/benchmark.md'
    $content = [System.IO.File]::ReadAllText($path)
    Write-Utf8Lf -Path $path -Content (Replace-First -Content $content -OldValue "## Contents`n" -NewValue '')
    Test-FixtureResult -Name 'missing-contents' -ExpectedStatus 1 -ExpectedText 'Reference over 100 lines has no Contents section'

    New-FixtureCopy -Name 'uppercase-extension-format'
    $path = Join-Path $script:caseSkills 'mino-core/references/Upper.MD'
    [System.IO.File]::WriteAllText($path, 'no final newline', $utf8NoBom)
    Test-FixtureResult -Name 'uppercase-extension-format' -ExpectedStatus 1 -ExpectedText 'Text file must end with a newline'
} finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Validator fixtures: $passed passed, $failed failed, $total total"
if ($failed -gt 0) {
    exit 1
}
