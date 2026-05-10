# _transform-main.ps1
# Aplica diseno PostHog light + grid paper a index.html (ES).
# Ejecutar desde WebDesign\ o desde la raiz del repo.

$root = if ($PSScriptRoot) {
  (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
} else {
  (Get-Location).Path
}

$indexPath  = Join-Path $root "index.html"
$cssPath    = Join-Path $root "WebDesign\_new-style-main.css"

Write-Host "Root: $root"
Write-Host "index.html: $indexPath"

# Leer archivos
$c   = Get-Content -Path $indexPath -Raw -Encoding UTF8
$css = Get-Content -Path $cssPath   -Raw -Encoding UTF8

# 1. theme-color meta
$c = $c.Replace('content="#111827"', 'content="#ffffff"')

# 2. Google Fonts: Space Mono / Figtree / JetBrains -> IBM Plex
$oldFonts = @(
  'family=Space+Mono:wght@400;700&family=Figtree:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;600',
  'family=Space+Mono:wght@400;700&family=Figtree:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;600'
)
$newFont = 'family=IBM+Plex+Sans:ital,wght@0,400;0,500;0,600;0,700;1,400&family=IBM+Plex+Mono:wght@400;500'
foreach ($old in $oldFonts) {
  $c = $c.Replace($old, $newFont)
}

# 3. Reemplazar bloque <style>...</style> con nueva CSS
$si = $c.IndexOf('<style>')
$ei = $c.IndexOf('</style>') + 8
if ($si -ge 0 -and $ei -gt $si) {
  $newBlock = "<style>`n" + $css.TrimEnd() + "`n</style>"
  $c = $c.Substring(0, $si) + $newBlock + $c.Substring($ei)
  Write-Host "  CSS reemplazado ($($css.Length) chars)"
} else {
  Write-Host "  ERROR: no se encontro bloque <style>"
  exit 1
}

# 4. Eliminar orbs
$c = $c.Replace("<div class=""orb o1""></div>", '')
$c = $c.Replace("<div class=""orb o2""></div>", '')
$c = $c.Replace("<div class=""orb o3""></div>", '')
# Eliminar linea en blanco que queda tras los orbs
$c = [regex]::Replace($c, '(?m)^\r?\n\r?\n<header', "`n<header")

# 5. Eliminar theme-toggle button
$c = [regex]::Replace($c, '[ \t]*<button[^>]*theme-toggle[^>]*>.*?</button>\r?\n', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# 6. Eliminar bloque JS del theme toggle
$c = [regex]::Replace($c, '\(function\(\)\{[\s\S]*?localStorage\.setItem\(''workshopTheme'',''light''\);\s*\}\s*\};\s*\}\)\(\);', '', [System.Text.RegularExpressions.RegexOptions]::Singleline)

# 7. Actualizar footer text
$c = $c.Replace('Glassmorphism on purpose', 'PostHog light · Grid paper')

# Guardar
Set-Content -Path $indexPath -Value $c -Encoding UTF8 -NoNewline
Write-Host "  index.html guardado OK"
Write-Host ""
Write-Host "Siguiente paso: ejecutar _transform-all.ps1 para en/index.html"
