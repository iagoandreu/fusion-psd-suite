# Download every add-in of the suite and install it into Fusion.
#
#   powershell -ExecutionPolicy Bypass -File install_all.ps1
#   powershell -ExecutionPolicy Bypass -File install_all.ps1 -Only axis-cylinder,bone-guide
#
# Each tool is downloaded into -Dest (git clone / pull when git is installed, a zip
# download otherwise) and then its own install.ps1 copies it into Fusion's AddIns
# folder. Running it again updates everything. Restart Fusion afterwards.

param(
    [string]$Dest = (Join-Path $HOME 'Documents\fusion-psd-suite-tools'),
    [string[]]$Only = @(),
    [string]$Owner = 'iagoandreu'
)

$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Definition
$tools = Get-Content -Raw -LiteralPath (Join-Path $here 'tools.json') | ConvertFrom-Json
if ($Only.Count -gt 0) { $tools = $tools | Where-Object { $Only -contains $_.repo } }
$haveGit = [bool](Get-Command git -ErrorAction SilentlyContinue)

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
$failed = @()

foreach ($t in $tools) {
    $dir = Join-Path $Dest $t.repo
    $url = "https://github.com/$Owner/$($t.repo)"
    Write-Host ""
    Write-Host "== $($t.name)  ($url)"
    try {
        if ($haveGit -and (Test-Path -LiteralPath (Join-Path $dir '.git'))) {
            git -C $dir pull --ff-only
        } elseif ($haveGit -and -not (Test-Path -LiteralPath $dir)) {
            git clone "$url.git" $dir
        } else {
            # no git (or a previous zip download): fetch the current version as a zip
            $zip = Join-Path $env:TEMP "$($t.repo).zip"
            $tmp = Join-Path $env:TEMP "$($t.repo)-unzip"
            Invoke-WebRequest -UseBasicParsing -Uri "$url/archive/HEAD.zip" -OutFile $zip
            if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
            Expand-Archive -LiteralPath $zip -DestinationPath $tmp
            if (Test-Path -LiteralPath $dir) { Remove-Item -LiteralPath $dir -Recurse -Force }
            Move-Item -LiteralPath (Get-ChildItem -LiteralPath $tmp -Directory | Select-Object -First 1).FullName -Destination $dir
            Remove-Item -LiteralPath $zip, $tmp -Recurse -Force
        }
        & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $dir 'install.ps1')
        if ($LASTEXITCODE -ne 0) { throw "install.ps1 exited with $LASTEXITCODE" }
    } catch {
        Write-Host "FAILED: $_" -ForegroundColor Red
        $failed += $t.name
    }
}

# the external Python the heavier tools run their maths in
$needPy = @($tools | Where-Object { $_.python } | ForEach-Object { $_.name })
if ($needPy.Count -gt 0) {
    Write-Host ""
    Write-Host "== External Python (needed by: $($needPy -join ', '))"
    $check = 'import numpy, scipy, trimesh, pyvista, shapely, gmsh, pynanoinstantmeshes, pymeshlab'
    $ok = $false
    if (Get-Command py -ErrorAction SilentlyContinue) {
        try {
            & py -3.10 -c $check 2>$null
            $ok = ($LASTEXITCODE -eq 0)
        } catch { $ok = $false }
    }
    if ($ok) {
        Write-Host "py -3.10 has every package."
    } else {
        Write-Host "Not found or incomplete. Install Python 3.10 (64-bit) from python.org, then:" -ForegroundColor Yellow
        Write-Host "    py -3.10 -m pip install -r `"$(Join-Path $here 'requirements.txt')`""
        Write-Host "Each tool's README says how to point it at another interpreter (python_path.txt)."
    }
}

Write-Host ""
if ($failed.Count -gt 0) { Write-Host "Not installed: $($failed -join ', ')" -ForegroundColor Red }
Write-Host "Done. Restart Fusion; the add-ins start on their own (Utilities > Add-Ins lists them)."
