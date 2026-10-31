Add-Type -AssemblyName System.Drawing

$logoPath = "c:\flutter_projects\ahl_bader_institute\assets\images\logo.png"
$outputPath = "c:\flutter_projects\ahl_bader_institute\assets\images\app_icon.png"

$orig = [System.Drawing.Bitmap]::FromFile($logoPath)
$size = 1024
$canvas = New-Object System.Drawing.Bitmap($size, $size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)

$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

# Clear with white background
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$graphics.FillRectangle($brush, 0, 0, $size, $size)

# Scale down logo to 65% so it fits safely within Android Squircle/Circle
$scale = 0.65
$targetW = [int]($size * $scale)
$targetH = [int]($size * $scale)
$left = [int](($size - $targetW) / 2)
$top = [int](($size - $targetH) / 2)

$graphics.DrawImage($orig, $left, $top, $targetW, $targetH)

$canvas.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)

$orig.Dispose()
$canvas.Dispose()
$graphics.Dispose()
$brush.Dispose()

Write-Host "DONE_PERFECT: Created padded icon at $outputPath"
