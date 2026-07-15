$ErrorActionPreference = 'Stop'

function Show-Usage {
    @'
Usage: validate-suite.ps1 [-SkillsRoot PATH] [-ManifestFile PATH]

Validates the mino skill suite from a Windows PowerShell environment.
Detailed validation is limited to manifest-listed suite skills. Other installed
skills are ignored, while unlisted mino-* skills are reported.
'@
}

$SkillsRoot = ''
$ManifestFile = ''
$argumentIndex = 0
while ($argumentIndex -lt $args.Count) {
    $argument = [string]$args[$argumentIndex]
    switch -CaseSensitive ($argument) {
        { $_ -in @('-SkillsRoot', '--skills-root') } {
            if ($argumentIndex + 1 -ge $args.Count) {
                [Console]::Error.WriteLine('Missing value for -SkillsRoot')
                exit 2
            }
            $SkillsRoot = [string]$args[$argumentIndex + 1]
            $argumentIndex += 2
            continue
        }
        { $_ -in @('-ManifestFile', '--manifest-file') } {
            if ($argumentIndex + 1 -ge $args.Count) {
                [Console]::Error.WriteLine('Missing value for -ManifestFile')
                exit 2
            }
            $ManifestFile = [string]$args[$argumentIndex + 1]
            $argumentIndex += 2
            continue
        }
        { $_ -in @('-h', '--help') } {
            Show-Usage
            exit 0
        }
        default {
            [Console]::Error.WriteLine("Unknown argument: $argument")
            Show-Usage | ForEach-Object { [Console]::Error.WriteLine($_) }
            exit 2
        }
    }
}

if (-not $SkillsRoot) {
    $skillDirectory = [System.IO.Directory]::GetParent($PSScriptRoot)
    $SkillsRoot = [System.IO.Directory]::GetParent($skillDirectory.FullName).FullName
} else {
    $SkillsRoot = [System.IO.Path]::GetFullPath($SkillsRoot)
}

$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

function Get-UnicodeScalarCount {
    param([string]$Value)

    $count = 0
    for ($index = 0; $index -lt $Value.Length; $index++) {
        if ([char]::IsHighSurrogate($Value[$index]) -and $index + 1 -lt $Value.Length -and [char]::IsLowSurrogate($Value[$index + 1])) {
            $index++
        }
        $count++
    }
    return $count
}

if (-not (Test-Path -LiteralPath $SkillsRoot -PathType Container)) {
    [Console]::Error.WriteLine("Skills root not found: $SkillsRoot")
    exit 2
}

$manifestPath = if ($ManifestFile) {
    [System.IO.Path]::GetFullPath($ManifestFile)
} else {
    Join-Path $PSScriptRoot 'suite-manifest.txt'
}
$suiteVersion = ''
$suiteOwner = ''
$suiteSkillNames = @()
$suiteVersionCount = 0
$suiteOwnerCount = 0
$seenSkillNames = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    $errors.Add('Missing suite manifest: skills/mino-core/scripts/suite-manifest.txt')
} else {
    foreach ($line in Get-Content -LiteralPath $manifestPath -Encoding UTF8) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            continue
        }
        $separatorIndex = $line.IndexOf('=')
        if ($separatorIndex -le 0) {
            $errors.Add("Invalid suite manifest line: $line")
            continue
        }
        $key = $line.Substring(0, $separatorIndex).Trim()
        $value = $line.Substring($separatorIndex + 1).Trim()
        if ([string]::IsNullOrWhiteSpace($key)) {
            $errors.Add("Invalid suite manifest line: $line")
            continue
        }
        switch -CaseSensitive ($key) {
            'suite_version' {
                $suiteVersionCount++
                if ($suiteVersionCount -gt 1) {
                    $errors.Add("Duplicate suite_version in $manifestPath")
                } else {
                    $suiteVersion = $value
                }
            }
            'owner' {
                $suiteOwnerCount++
                if ($suiteOwnerCount -gt 1) {
                    $errors.Add("Duplicate owner in $manifestPath")
                } else {
                    $suiteOwner = $value
                }
            }
            'skill' {
                if ($value -cnotmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
                    $errors.Add("Invalid suite skill name '$value': $manifestPath")
                } elseif (-not $seenSkillNames.Add($value)) {
                    $errors.Add("Duplicate suite skill '$value': $manifestPath")
                } else {
                    $suiteSkillNames += $value
                }
            }
            default { $errors.Add("Unsupported suite manifest key '$key': $manifestPath") }
        }
    }
}

if (-not $suiteVersion) {
    $errors.Add("Missing suite_version in $manifestPath")
} elseif ($suiteVersion -cnotmatch '^(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)$') {
    $errors.Add("Invalid suite_version '$suiteVersion': $manifestPath")
}
if (-not $suiteOwner) {
    $errors.Add("Missing owner in $manifestPath")
}
if ($suiteSkillNames.Count -eq 0) {
    $errors.Add("Suite manifest contains no skills: $manifestPath")
}

if ($suiteVersion -cmatch '^(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)\.(?:0|[1-9][0-9]*)$') {
    $currentCaseLogical = "skills/mino-core/evaluations/cases/$suiteVersion.md"
    $currentOracleLogical = "skills/mino-core/evaluations/oracles/$suiteVersion.md"
    $currentEvaluationLogical = "skills/mino-core/evaluations/$suiteVersion.md"
    $currentCaseFile = Join-Path $SkillsRoot $currentCaseLogical.Substring('skills/'.Length).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $currentOracleFile = Join-Path $SkillsRoot $currentOracleLogical.Substring('skills/'.Length).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $currentEvaluationFile = Join-Path $SkillsRoot $currentEvaluationLogical.Substring('skills/'.Length).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $currentCaseFile -PathType Leaf)) {
        $errors.Add("Missing versioned solver case: $currentCaseLogical")
    } else {
        $currentCaseLines = @(Get-Content -LiteralPath $currentCaseFile -Encoding UTF8)
        if ($currentCaseLines.Count -eq 0 -or $currentCaseLines[0] -cne "# Evaluation cases $suiteVersion") {
            $errors.Add("Versioned solver case heading does not match suite_version: $currentCaseLogical")
        }
        $allowedCaseFields = @('mode', 'required_platforms', 'raw_request', 'confirmed_evidence', 'known_unknowns', 'allowed_assumptions', 'prohibited_changes')
        $inYaml = $false
        $caseFieldCounts = @{}
        $blockScalar = $false
        foreach ($caseLine in $currentCaseLines) {
            if ($caseLine -cmatch '^```yaml\s*$') {
                $inYaml = $true
                $caseFieldCounts = @{}
                $blockScalar = $false
                continue
            }
            if ($inYaml -and $caseLine -cmatch '^```\s*$') {
                foreach ($requiredCaseField in $allowedCaseFields) {
                    if (-not $caseFieldCounts.ContainsKey($requiredCaseField) -or $caseFieldCounts[$requiredCaseField] -ne 1) {
                        $errors.Add("Solver case field must appear exactly once: $requiredCaseField`: $currentCaseLogical")
                    }
                }
                $inYaml = $false
                $blockScalar = $false
                continue
            }
            if ($inYaml -and $caseLine -cmatch '^(?<key>[A-Za-z_][A-Za-z0-9_]*)\s*:') {
                $caseKey = $Matches['key']
                $blockScalar = $caseLine -cmatch ':\s*[>|][+-]?\s*$'
                if ($allowedCaseFields -cnotcontains $caseKey) {
                    $errors.Add("Solver case contains unsupported top-level field: $caseKey`: $currentCaseLogical")
                }
                if (-not $caseFieldCounts.ContainsKey($caseKey)) {
                    $caseFieldCounts[$caseKey] = 0
                }
                $caseFieldCounts[$caseKey]++
                if ($caseFieldCounts[$caseKey] -gt 1) {
                    $errors.Add("Solver case field appears more than once: $caseKey`: $currentCaseLogical")
                }
                continue
            }
            if ($inYaml -and -not $blockScalar -and $caseLine -cmatch '^\s+(?<key>[A-Za-z_][A-Za-z0-9_]*)\s*:') {
                $errors.Add("Solver case contains nested mapping field: $($Matches['key']): $currentCaseLogical")
            }
        }
        if ($inYaml) {
            $errors.Add("Solver case has an unclosed yaml fence: $currentCaseLogical")
        }
    }
    if (-not (Test-Path -LiteralPath $currentOracleFile -PathType Leaf)) {
        $errors.Add("Missing versioned evaluator oracle: $currentOracleLogical")
    } else {
        $currentOracleLines = @(Get-Content -LiteralPath $currentOracleFile -Encoding UTF8)
        if ($currentOracleLines.Count -eq 0 -or $currentOracleLines[0] -cne "# Evaluator oracles $suiteVersion") {
            $errors.Add("Versioned evaluator oracle heading does not match suite_version: $currentOracleLogical")
        }
        if ($currentOracleLines -cnotcontains '## Runner-only metadata') {
            $errors.Add("Evaluator oracle is missing runner-only metadata: $currentOracleLogical")
        }
    }
    if (-not (Test-Path -LiteralPath $currentEvaluationFile -PathType Leaf)) {
        $errors.Add("Missing versioned evaluation record: $currentEvaluationLogical")
    } else {
        $currentEvaluationLines = @(Get-Content -LiteralPath $currentEvaluationFile -Encoding UTF8)
        if ($currentEvaluationLines.Count -eq 0 -or $currentEvaluationLines[0] -cne "# Evaluation $suiteVersion") {
            $errors.Add("Versioned evaluation heading does not match suite_version: $currentEvaluationLogical")
        }
    }

    $benchmarkFile = Join-Path (Join-Path $SkillsRoot 'mino-core') (Join-Path 'references' 'benchmark.md')
    if (Test-Path -LiteralPath $benchmarkFile -PathType Leaf) {
        $benchmarkRaw = Get-Content -LiteralPath $benchmarkFile -Raw -Encoding UTF8
        foreach ($currentBundlePath in @($currentCaseLogical, $currentOracleLogical, $currentEvaluationLogical)) {
            if (-not $benchmarkRaw.Contains('`' + $currentBundlePath + '`')) {
                $errors.Add("Benchmark does not reference current versioned artifact '$currentBundlePath': $benchmarkFile")
            }
        }
    }
}

foreach ($requiredScript in @('validate-suite.ps1', 'validate-suite.sh', 'test-validator-fixtures.ps1', 'test-validator-fixtures.sh')) {
    $scriptPath = Join-Path (Join-Path $SkillsRoot 'mino-core') (Join-Path 'scripts' $requiredScript)
    if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
        $errors.Add("Missing platform validator: skills/mino-core/scripts/$requiredScript")
    }
}

$skillDirs = @()
foreach ($skillName in $suiteSkillNames) {
    $skillPath = [System.IO.Path]::GetFullPath((Join-Path $SkillsRoot $skillName))
    $expectedParent = [System.IO.Path]::GetFullPath($SkillsRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    if ([System.IO.Path]::GetDirectoryName($skillPath).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) -cne $expectedParent -or [System.IO.Path]::GetFileName($skillPath) -cne $skillName) {
        $errors.Add("Suite skill must resolve directly inside skills root: skills/$skillName")
        continue
    }
    if (-not (Test-Path -LiteralPath $skillPath -PathType Container)) {
        $errors.Add("Missing suite skill: skills/$skillName")
        continue
    }
    $skillItem = Get-Item -LiteralPath $skillPath
    if (($skillItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        $errors.Add("Suite skill must resolve directly inside skills root: skills/$skillName")
        continue
    }
    $skillDirs += $skillItem
}

foreach ($discoveredSkillFile in Get-ChildItem -LiteralPath $SkillsRoot -Recurse -File -Filter 'SKILL.md') {
    if ($discoveredSkillFile.Directory.Parent.FullName -ne $SkillsRoot) {
        continue
    }
    $discoveredName = $discoveredSkillFile.Directory.Name
    if ($discoveredName.StartsWith('mino-', [System.StringComparison]::Ordinal) -and $suiteSkillNames -notcontains $discoveredName) {
        $errors.Add("Skill directory is not listed in suite manifest: skills/$discoveredName")
    }
}

foreach ($dir in $skillDirs) {
    if ($dir.Name.Length -gt 64 -or $dir.Name -notmatch '^[a-z0-9]+(?:-[a-z0-9]+)*$') {
        $errors.Add("Invalid skill folder name: $($dir.Name)")
    }

    $skillFileItem = Get-ChildItem -LiteralPath $dir.FullName -File | Where-Object { $_.Name -ceq 'SKILL.md' } | Select-Object -First 1
    if (-not $skillFileItem) {
        $errors.Add("Missing SKILL.md: skills/$($dir.Name)")
        continue
    }
    $skillFile = $skillFileItem.FullName

    $skillLines = @(Get-Content -LiteralPath $skillFile -Encoding UTF8)
    $raw = Get-Content -LiteralPath $skillFile -Raw -Encoding UTF8
    $frontmatter = [regex]::Match($raw, '(?s)\A---\r?\n(?<body>.*?)\r?\n---(?=\r?\n|\z)')
    if (-not $frontmatter.Success) {
        $errors.Add("Invalid frontmatter: $skillFile")
        continue
    }

    $frontmatterLines = @($frontmatter.Groups['body'].Value -split '\r?\n')
    $keys = @()
    foreach ($frontmatterLine in $frontmatterLines) {
        if ($frontmatterLine -cnotmatch '^(?<key>[A-Za-z0-9_-]+):') {
            $errors.Add("Invalid frontmatter line '$frontmatterLine': $skillFile")
            continue
        }
        $keys += $Matches['key']
    }
    foreach ($required in @('name', 'description')) {
        if (@($keys | Where-Object { $_ -ceq $required }).Count -ne 1) {
            $errors.Add("Frontmatter key '$required' must appear exactly once: $skillFile")
        }
    }
    foreach ($key in $keys) {
        if ($key -notin @('name', 'description')) {
            $errors.Add("Unsupported frontmatter key '$key': $skillFile")
        }
    }

    $nameMatch = [regex]::Match($frontmatter.Groups['body'].Value, '(?m)^name:\s*(?:"(?<double>[^"\r\n]+)"|''(?<single>[^''\r\n]+)''|(?<plain>[A-Za-z0-9-]+))\s*$')
    $declaredName = if ($nameMatch.Groups['double'].Success) {
        $nameMatch.Groups['double'].Value
    } elseif ($nameMatch.Groups['single'].Success) {
        $nameMatch.Groups['single'].Value
    } else {
        $nameMatch.Groups['plain'].Value
    }
    if (-not $nameMatch.Success -or $declaredName -cne $dir.Name) {
        $errors.Add("Skill name must match folder: $skillFile")
    }

    $descriptionMatch = [regex]::Match($frontmatter.Groups['body'].Value, '(?m)^description:\s*(?<description>.+)$')
    if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups['description'].Value)) {
        $errors.Add("Skill description must not be empty: $skillFile")
    } else {
        $description = $descriptionMatch.Groups['description'].Value.Trim()
        if ($description.Length -gt 1024) {
            $errors.Add("Skill description exceeds 1024 characters: $skillFile")
        }
        if ($description.Contains('<') -or $description.Contains('>')) {
            $errors.Add("Skill description cannot contain angle brackets: $skillFile")
        }
    }

    if ($skillLines.Count -gt 500) {
        $errors.Add("SKILL.md exceeds 500 lines: $skillFile")
    }

    if (Get-ChildItem -LiteralPath $dir.FullName -File | Where-Object { $_.Name.ToLowerInvariant() -eq 'readme.md' } | Select-Object -First 1) {
        $errors.Add("README.md is not allowed in a skill directory: $($dir.FullName)")
    }

    foreach ($requiredHeading in @('## Outcome Contract', '## Reference Routing', '## Workflow', '## Completion')) {
        if ($skillLines -cnotcontains $requiredHeading) {
            $errors.Add("Missing required section '$requiredHeading': $skillFile")
        }
    }
    if ($skillLines -cnotcontains '## Hard Gates') {
        $errors.Add("Missing hard gate section: $skillFile")
    }

    $platformReference = 'skills/mino-core/references/platform-compatibility.md'
    if (-not $raw.Contains('`' + $platformReference + '`')) {
        $errors.Add("SKILL.md must route Windows/Linux compatibility reference '$platformReference': $skillFile")
    }

    $agentsDirectory = Get-ChildItem -LiteralPath $dir.FullName -Directory | Where-Object { $_.Name -ceq 'agents' } | Select-Object -First 1
    $agentFileItem = if ($agentsDirectory) {
        Get-ChildItem -LiteralPath $agentsDirectory.FullName -File | Where-Object { $_.Name -ceq 'openai.yaml' } | Select-Object -First 1
    } else {
        $null
    }
    if (-not $agentFileItem) {
        $errors.Add("Missing agents/openai.yaml: skills/$($dir.Name)")
    } else {
        $agentFile = $agentFileItem.FullName
        $agentLines = @(Get-Content -LiteralPath $agentFile -Encoding UTF8)
        $validMetadataStructure = $agentLines.Count -eq 6 -and
            $agentLines[0] -ceq 'interface:' -and
            $agentLines[1] -cmatch '^  display_name:\s*"[^"]+"$' -and
            $agentLines[2] -cmatch '^  short_description:\s*"[^"]+"$' -and
            $agentLines[3] -cmatch '^  default_prompt:\s*"[^"]+"$' -and
            $agentLines[4] -ceq 'policy:' -and
            $agentLines[5] -cmatch '^  allow_implicit_invocation:\s*(?:true|false)$'
        if (-not $validMetadataStructure) {
            $errors.Add("Invalid agents/openai.yaml structure: $agentFile")
        }
        $agentRaw = Get-Content -LiteralPath $agentFile -Raw -Encoding UTF8
        $display = [regex]::Match($agentRaw, '(?m)^  display_name:\s*"(?<value>[^"]+)"$')
        if (-not $display.Success) {
            $errors.Add("Quoted display_name not found: $agentFile")
        }
        $short = [regex]::Match($agentRaw, '(?m)^  short_description:\s*"(?<value>[^"]+)"$')
        if (-not $short.Success) {
            $errors.Add("Quoted short_description not found: $agentFile")
        } else {
            $shortLength = Get-UnicodeScalarCount -Value $short.Groups['value'].Value
            if ($shortLength -lt 25 -or $shortLength -gt 64) {
                $errors.Add("short_description must be 25-64 Unicode scalar values: $agentFile")
            }
        }
        $defaultPrompt = [regex]::Match($agentRaw, '(?m)^  default_prompt:\s*"(?<value>[^"]+)"$')
        if (-not $defaultPrompt.Success) {
            $errors.Add("Quoted default_prompt not found: $agentFile")
        } else {
            $token = '$' + $dir.Name
            if (-not $defaultPrompt.Groups['value'].Value.Contains($token)) {
                $errors.Add("default_prompt must mention $($token): $agentFile")
            }
        }
    }

    $referenceRoot = Join-Path $dir.FullName 'references'
    if (Test-Path -LiteralPath $referenceRoot -PathType Container) {
        foreach ($referenceFile in Get-ChildItem -LiteralPath $referenceRoot -File | Where-Object { $_.Extension.ToLowerInvariant() -eq '.md' }) {
            $logicalPath = "skills/$($dir.Name)/references/$($referenceFile.Name)"
            if (-not $raw.Contains('`' + $logicalPath + '`')) {
                $errors.Add("SKILL.md must directly route bundled reference '$logicalPath': $skillFile")
            }
        }
    }
}

$textExtensions = @('.md', '.yaml', '.yml', '.json', '.sh', '.ps1', '.py', '.txt', '.toml', '.xml', '.csv')
$strictUtf8 = [System.Text.UTF8Encoding]::new($false, $true)
$forbiddenPathPattern = 'mino-doc' + '/|\.agents' + '/skills/|\$HOME/\.agents' + '/skills/|`\.\./|/home' + '/[^\s`]*'
$textFiles = @(
    foreach ($dir in $skillDirs) {
        Get-ChildItem -LiteralPath $dir.FullName -Recurse -File | Where-Object { $textExtensions -contains $_.Extension.ToLowerInvariant() }
    }
)
foreach ($textFile in $textFiles) {
    $bytes = [System.IO.File]::ReadAllBytes($textFile.FullName)
    try {
        $null = $strictUtf8.GetString($bytes)
    } catch {
        $errors.Add("Text file is not valid UTF-8: $($textFile.FullName)")
    }
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $errors.Add("UTF-8 BOM is not allowed: $($textFile.FullName)")
    }
    if ($bytes -contains 13) {
        $errors.Add("CR or CRLF is not allowed: $($textFile.FullName)")
    }
    if ($bytes.Length -gt 0 -and $bytes[$bytes.Length - 1] -ne 10) {
        $errors.Add("Text file must end with a newline: $($textFile.FullName)")
    }
    $text = [System.Text.Encoding]::UTF8.GetString($bytes)
    if ($text -match $forbiddenPathPattern) {
        $errors.Add("Runtime skill text contains a repository-specific or physical path: $($textFile.FullName)")
    }
}

$markdownFiles = @(
    foreach ($dir in $skillDirs) {
        Get-ChildItem -LiteralPath $dir.FullName -Recurse -File | Where-Object { $_.Extension.ToLowerInvariant() -eq '.md' }
    }
)

function Test-LogicalSkillPath {
    param(
        [string]$LogicalPath,
        [string]$SourceFile
    )

    if (($LogicalPath -cne 'skills/' -and $LogicalPath -notmatch '^skills(?:/[A-Za-z0-9._-]+)+/?$') -or $LogicalPath -match '(^|/)\.\.?(/|$)') {
        $errors.Add("Invalid skills-rooted path '$LogicalPath' in $SourceFile")
        return
    }

    $relativePath = $LogicalPath.Substring('skills/'.Length).Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $target = if ($relativePath) { Join-Path $SkillsRoot $relativePath } else { $SkillsRoot }
    if (-not (Test-Path -LiteralPath $target)) {
        $errors.Add("Unresolved skills-rooted path '$LogicalPath' in $SourceFile")
        return
    }
    $currentPath = $SkillsRoot
    foreach ($segment in $LogicalPath.Substring('skills/'.Length).Split([char[]]@('/'), [System.StringSplitOptions]::RemoveEmptyEntries)) {
        $currentPath = Join-Path $currentPath $segment
        $currentItem = Get-Item -LiteralPath $currentPath
        if (($currentItem.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            $errors.Add("Skills-rooted path must not traverse a link '$LogicalPath' in $SourceFile")
            return
        }
    }
}

foreach ($file in $markdownFiles) {
    $raw = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

    foreach ($match in [regex]::Matches($raw, '\$([a-z0-9-]+)')) {
        $target = Join-Path (Join-Path $SkillsRoot $match.Groups[1].Value) 'SKILL.md'
        if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
            $errors.Add("Unresolved skill reference '$($match.Value)' in $($file.FullName)")
        }
    }

    foreach ($match in [regex]::Matches($raw, '`(?<token>[^`]*)`')) {
        $token = $match.Groups['token'].Value
        if ($token.StartsWith('skills/', [System.StringComparison]::Ordinal)) {
            Test-LogicalSkillPath -LogicalPath $token -SourceFile $file.FullName
        } elseif ($token -match '^(?:/|[A-Za-z]:[\\/]|\\\\)' -or $token -match '\.(?:md|sh|ps1|txt|yaml|yml|json|py|toml|xml|csv)$') {
            $errors.Add("Runtime asset path must start with 'skills/': '$token' in $($file.FullName)")
        }
    }

    foreach ($match in [regex]::Matches($raw, '`(?<path>(?:references|scripts|evaluations)/[^`]+)`')) {
        $errors.Add("Internal path must start with 'skills/': '$($match.Groups['path'].Value)' in $($file.FullName)")
    }

    foreach ($match in [regex]::Matches($raw, '`(?<path>(?:[^`\s]+/)+skills/[^`]+)`')) {
        $errors.Add("Internal path must use 'skills/' as its top-level root: '$($match.Groups['path'].Value)' in $($file.FullName)")
    }

    foreach ($match in [regex]::Matches($raw, '\]\((?<target>[^)\s]+)(?:\s+"[^"]*")?\)')) {
        $target = $match.Groups['target'].Value
        if ($target.StartsWith('#')) {
            continue
        }
        if (-not $target.StartsWith('skills/')) {
            $errors.Add("Markdown link must start with 'skills/': '$target' in $($file.FullName)")
            continue
        }
        Test-LogicalSkillPath -LogicalPath $target -SourceFile $file.FullName
    }

    $markdownLines = @(Get-Content -LiteralPath $file.FullName -Encoding UTF8)
    $lineCount = $markdownLines.Count
    if ($file.Name -ne 'SKILL.md' -and $lineCount -gt 100 -and $markdownLines -cnotcontains '## Contents') {
        $errors.Add("Reference over 100 lines has no Contents section: $($file.FullName)")
    }
}

foreach ($warning in $warnings) {
    Write-Warning $warning
}
foreach ($errorMessage in $errors) {
    Write-Error $errorMessage -ErrorAction Continue
}

Write-Host "Validated $($skillDirs.Count) suite skills and $($markdownFiles.Count) markdown files from: $SkillsRoot"
Write-Host "Suite version: $suiteVersion; Owner: $suiteOwner"
Write-Host "Errors: $($errors.Count); Warnings: $($warnings.Count)"

if ($errors.Count -gt 0) {
    exit 1
}
