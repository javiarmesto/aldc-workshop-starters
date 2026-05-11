# _recolor-badges.ps1
# Sustituye colores de badges shields.io (hex y nombrados) por la paleta Base44.
# Idempotente: sustituciones literales seguras.

$ErrorActionPreference = 'Stop'

$root = if ($PSScriptRoot) {
    (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
} else {
    (Get-Location).Path
}

# Mapeo hex Base44
#   lime-deep  #7a9e00  -> accion positiva / ALDC
#   sunset     #d8723c  -> enfasis secundario
#   blazing    #ff631f  -> enfasis decorativo
#   ink        #232529  -> neutro fuerte (workshop, version)
$hexMap = @{
    '818CF8' = '232529'  # workshop indigo -> ink
    '38BDF8' = '7a9e00'  # cyan -> lime-deep
    'FBBF24' = 'd8723c'  # amber -> sunset
    'E879A8' = 'ff631f'  # pink -> blazing
    '34D399' = '7a9e00'  # emerald -> lime-deep
}
# Mapeo de colores nombrados (solo cuando aparecen como query/segmento de shields.io)
$namedMap = @{
    '-purple.svg' = '-7a9e00.svg'
    '-purple)'    = '-7a9e00)'
    '-blue)'      = '-232529)'
    '-green)'     = '-7a9e00)'
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$files = Get-ChildItem -Path $root -Recurse -Filter '*.md' -File -Force `
    | Where-Object { $_.FullName -notmatch '\\\.git\\' } `
    | Where-Object { (Select-String -Path $_.FullName -Pattern 'shields.io/badge' -Quiet) }

foreach ($f in $files) {
    $content = [System.IO.File]::ReadAllText($f.FullName, $utf8NoBom)
    $orig    = $content

    foreach ($k in $hexMap.Keys) {
        $content = $content.Replace($k, $hexMap[$k])
    }
    foreach ($k in $namedMap.Keys) {
        $content = $content.Replace($k, $namedMap[$k])
    }

    if ($content -ne $orig) {
        [System.IO.File]::WriteAllText($f.FullName, $content, $utf8NoBom)
        Write-Host "Recoloreado: $($f.FullName)"
    }
}

Write-Host ''
Write-Host 'Badges recoloreados a paleta Base44.'
