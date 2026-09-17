# PowerShell 5.1/7 launcher. Python is needed for validation, not Skill use.
param(
    [string]$SkillsRoot = (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) '.agents/skills'),
    [string]$ManifestFile = ''
)
$ErrorActionPreference = 'Stop'
try {
    $engine = Join-Path $PSScriptRoot 'validate_suite.py'
    if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) {
        Write-Output 'E_ENGINE: structural validation engine is missing.'; exit 2
    }
    # Resolve an executable runtime, not merely a Windows application alias.
    $candidates = @(@{ Command = 'py'; Arguments = @('-3') }, @{ Command = 'python'; Arguments = @() })
    if ($env:MINO_PYTHON) { $candidates = @(@{ Command = $env:MINO_PYTHON; Arguments = @() }) }
    $python = ''
    $pythonArgs = @()
    foreach ($candidate in $candidates) {
        if (-not (Get-Command $candidate.Command -ErrorAction SilentlyContinue)) { continue }
        $candidateArgs = $candidate.Arguments
        try {
            & $candidate.Command @candidateArgs -c 'import sys; sys.exit(0 if sys.version_info >= (3, 10) else 2)' *> $null
            if ($LASTEXITCODE -ne 0) { continue }
            $python = $candidate.Command
            $pythonArgs = $candidateArgs
            break
        } catch { continue }
    }
    if (-not $python) {
        Write-Output 'E_PYTHON: Python 3.10+ is required; set MINO_PYTHON to an executable runtime.'
        exit 2
    }
    $arguments = $pythonArgs + @('-B', $engine, '--skills-root', $SkillsRoot)
    if ($ManifestFile) { $arguments += @('--manifest-file', $ManifestFile) }
    & $python @arguments
    exit $LASTEXITCODE
} catch { Write-Output "E_IO: $($_.Exception.Message)"; exit 2 }
