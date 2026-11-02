# Draws the ShiftPurse home-screen icon and iPhone splash screens.
# Run from the project folder:  powershell -ExecutionPolicy Bypass -File tools\make-icons.ps1
Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root "icons"
New-Item -ItemType Directory -Force $out | Out-Null

function Hex($h, $a = 255) { [System.Drawing.Color]::FromArgb($a, [Convert]::ToInt32($h.Substring(1,2),16), [Convert]::ToInt32($h.Substring(3,2),16), [Convert]::ToInt32($h.Substring(5,2),16)) }
function RoundRect($x, $y, $w, $h, $r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90); $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90); $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure(); return $p
}
# The mark: three job cards stacked like the Today deck (Thirst behind, Avila, Co-op in front with a pound sign).
function DrawMark($g, $cx, $cy, $s) {
  $w = 0.62 * $s; $h = 0.40 * $s; $r = 0.085 * $s
  $layers = @(@("#7c4ddb", 150, 0.80, -0.215), @("#d9562b", 220, 0.90, -0.115), @("#1d9a62", 255, 1.0, 0))
  foreach ($l in $layers) {
    $lw = $w * $l[2]; $lh = $h * $l[2]
    $x = $cx - $lw / 2; $y = $cy - $h / 2 + $l[3] * $s + 0.07 * $s
    $path = RoundRect $x $y $lw $lh ($r * $l[2])
    $g.FillPath((New-Object System.Drawing.SolidBrush (Hex $l[0] $l[1])), $path)
  }
  $fy = $cy - $h / 2 + 0.07 * $s
  $font = New-Object System.Drawing.Font("Segoe UI", [single](0.25 * $s), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = "Center"; $fmt.LineAlignment = "Center"
  $g.DrawString([string][char]0x00A3, $font, [System.Drawing.Brushes]::White, (New-Object System.Drawing.RectangleF(($cx - $w / 2), $fy, $w, $h)), $fmt)
  # a lime "paid" dot on the front card
  $dr = 0.045 * $s
  $g.FillEllipse((New-Object System.Drawing.SolidBrush (Hex "#b7ea3c")), ($cx + $w / 2 - 0.12 * $s), ($fy + 0.07 * $s), $dr * 2, $dr * 2)
}
function NewCanvas($w, $h) {
  $bmp = New-Object System.Drawing.Bitmap($w, $h)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = "AntiAlias"; $g.TextRenderingHint = "AntiAliasGridFit"; $g.InterpolationMode = "HighQualityBicubic"
  $rect = New-Object System.Drawing.Rectangle(-2, -2, ($w + 4), ($h + 4))
  $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, (Hex "#1d1f27"), (Hex "#0f1014"), 90)
  $g.FillRectangle($bg, $rect)
  return @($bmp, $g)
}

# Icons: iOS rounds the corners itself, so these are full squares.
foreach ($sz in @(180, 192, 512, 1024)) {
  $c = NewCanvas $sz $sz; DrawMark $c[1] ($sz / 2) ($sz / 2) $sz
  $name = if ($sz -eq 180) { "apple-touch-icon.png" } else { "icon-$sz.png" }
  $c[0].Save((Join-Path $out $name), [System.Drawing.Imaging.ImageFormat]::Png); $c[1].Dispose(); $c[0].Dispose()
}
# Maskable icon (Android): mark kept inside the safe zone.
$c = NewCanvas 512 512; DrawMark $c[1] 256 256 360
$c[0].Save((Join-Path $out "icon-maskable-512.png"), [System.Drawing.Imaging.ImageFormat]::Png); $c[1].Dispose(); $c[0].Dispose()

# Splash screens (portrait, device pixels).
$splash = @(@(1320,2868),@(1206,2622),@(1290,2796),@(1179,2556),@(1284,2778),@(1170,2532),@(1125,2436),@(1242,2688),@(828,1792),@(1080,2340),@(750,1334),@(1242,2208))
foreach ($s in $splash) {
  $w = $s[0]; $h = $s[1]
  $c = NewCanvas $w $h; $g = $c[1]
  $m = 0.34 * $w
  DrawMark $g ($w / 2) ($h / 2 - 0.06 * $w) $m
  $font = New-Object System.Drawing.Font("Segoe UI Semibold", [single](0.075 * $w), [System.Drawing.GraphicsUnit]::Pixel)
  $fmt = New-Object System.Drawing.StringFormat; $fmt.Alignment = "Center"
  $g.DrawString("ShiftPurse", $font, [System.Drawing.Brushes]::White, (New-Object System.Drawing.RectangleF(0, ($h / 2 + 0.16 * $w), $w, (0.12 * $w))), $fmt)
  $small = New-Object System.Drawing.Font("Segoe UI", [single](0.034 * $w), [System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString("Thirst  " + [char]0x00B7 + "  Avila  " + [char]0x00B7 + "  Co-op", $small, (New-Object System.Drawing.SolidBrush (Hex "#9b9fac")), (New-Object System.Drawing.RectangleF(0, ($h / 2 + 0.27 * $w), $w, (0.06 * $w))), $fmt)
  $c[0].Save((Join-Path $out "splash-${w}x${h}.png"), [System.Drawing.Imaging.ImageFormat]::Png); $g.Dispose(); $c[0].Dispose()
}
"icons written to $out"
