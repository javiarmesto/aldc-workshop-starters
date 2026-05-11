# _apply-base44.ps1
# Inyecta el bloque "Base44 Softly Lit Gradient Canvas" en cada HTML
# entre los marcadores fijos:
#   /* ===== Base44 Softly Lit Gradient Canvas . global ===== */
#   /* ===== fin Base44 Softly Lit ===== */
#
# Idempotente: si los marcadores ya existen, reemplaza el bloque.
# Si no, lo anade justo antes de </style>.
# Codificacion: UTF-8 sin BOM.

[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

$root = if ($PSScriptRoot) {
    (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
} else {
    (Get-Location).Path
}

$cssPath = Join-Path $root 'WebDesign\_base44-override.css'

if (-not (Test-Path $cssPath)) {
    Write-Error "No se encuentra $cssPath"
    exit 1
}

$startMarker = '/* ===== Base44 Softly Lit Gradient Canvas'
$endMarker   = '/* ===== fin Base44 Softly Lit ===== */'

# Bloque CSS a inyectar
$cssBlock = (Get-Content -Path $cssPath -Raw -Encoding UTF8).TrimEnd()

# UTF-8 sin BOM
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

$htmlFiles = @(
    (Join-Path $root 'index.html'),
    (Join-Path $root 'en\index.html')
)

foreach ($htmlPath in $htmlFiles) {
    if (-not (Test-Path $htmlPath)) {
        Write-Host "Saltado (no existe): $htmlPath"
        continue
    }

    $content = [System.IO.File]::ReadAllText($htmlPath, $utf8NoBom)

    $startIdx = $content.IndexOf($startMarker)
    $endIdx   = $content.IndexOf($endMarker)

    if ($startIdx -ge 0 -and $endIdx -gt $startIdx) {
        # Reemplazar bloque existente entre marcadores (inclusive)
        $endIdxFull = $endIdx + $endMarker.Length
        $newContent = $content.Substring(0, $startIdx) + $cssBlock + $content.Substring($endIdxFull)
        Write-Host "Reemplazado bloque Base44 en: $htmlPath"
    } else {
        # Anadir antes de </style>
        $styleEnd = $content.IndexOf('</style>')
        if ($styleEnd -lt 0) {
            Write-Warning "No se encontro </style> en $htmlPath; saltado."
            continue
        }
        # Inyectar con dos saltos de linea de separacion
        $injection = "`r`n" + $cssBlock + "`r`n"
        $newContent = $content.Substring(0, $styleEnd) + $injection + $content.Substring($styleEnd)
        Write-Host "Inyectado bloque Base44 en: $htmlPath"
    }

    [System.IO.File]::WriteAllText($htmlPath, $newContent, $utf8NoBom)
}

Write-Host ''
Write-Host 'Base44 Softly Lit Gradient Canvas aplicado.'
