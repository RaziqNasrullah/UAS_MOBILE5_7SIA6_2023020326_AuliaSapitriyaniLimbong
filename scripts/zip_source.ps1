# Membuat ZIP source code untuk dikumpulkan (Windows PowerShell).
# Mengecualikan: build\, .dart_tool\, .idea\, .gradle\, android\local.properties, .git\
# Pemakaian:  powershell -ExecutionPolicy Bypass -File scripts\zip_source.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$out = Join-Path $root 'Delights_AuliaSapitriyaniLimbong_2023020326_source.zip'
if (Test-Path $out) { Remove-Item $out }

$excludeDirs = @('build', '.dart_tool', '.idea', '.gradle', '.git')
$excludeFiles = @('android\local.properties', '.flutter-plugins-dependencies')

$files = Get-ChildItem -Path $root -Recurse -File -Force | Where-Object {
    $rel = $_.FullName.Substring($root.Length + 1)
    $parts = $rel -split '[\\/]'
    -not ($parts | Where-Object { $excludeDirs -contains $_ }) -and
    -not ($excludeFiles -contains $rel) -and
    -not $rel.EndsWith('.iml') -and
    $_.FullName -ne $out
}

$staging = Join-Path ([System.IO.Path]::GetTempPath()) ('delights_zip_' + [guid]::NewGuid())
foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1)
    $target = Join-Path $staging $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
    Copy-Item $f.FullName $target
}
Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $out
Remove-Item -Recurse -Force $staging
Write-Host "Selesai: $out"
