$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$work=Join-Path $PSScriptRoot '.review-work'
$plan=Get-Content (Join-Path $work 'crop-plan.json') -Raw -Encoding UTF8|ConvertFrom-Json
$manifest=Get-Content (Join-Path $work 'manifest.json') -Raw -Encoding UTF8|ConvertFrom-Json
$out=Join-Path $PSScriptRoot 'assets/reviews'
New-Item -ItemType Directory -Force $out|Out-Null
$catalog=@()
foreach($it in $manifest.items){
 $key=[string]$it.id
 $crops=$plan.crops.$key
 if(!$crops -or !$crops.Count){continue}
 $source=[Drawing.Bitmap]::new((Join-Path $PSScriptRoot ('review/'+$it.name)))
 $g=[Drawing.Graphics]::FromImage($source)
 foreach($m in $plan.masks.$key){
  $g.FillRectangle([Drawing.Brushes]::Black,[int]($m[0]*$source.Width/1000),[int]($m[1]*$source.Height/1000),[int][math]::Ceiling(($m[2]-$m[0])*$source.Width/1000),[int][math]::Ceiling(($m[3]-$m[1])*$source.Height/1000))
 }
 $g.Dispose()
 $rects=@();$width=0;$height=0
 foreach($c in $crops){
  $r=[Drawing.Rectangle]::new([int]($c[0]*$source.Width/1000),[int]($c[1]*$source.Height/1000),[int](($c[2]-$c[0])*$source.Width/1000),[int](($c[3]-$c[1])*$source.Height/1000))
  $rects+=$r;$width=[math]::Max($width,$r.Width);$height+=$r.Height
 }
 $height+=24*($rects.Count-1)
 $result=[Drawing.Bitmap]::new($width,$height);$g=[Drawing.Graphics]::FromImage($result);$g.Clear([Drawing.ColorTranslator]::FromHtml('#e7e2d8'))
 $y=0
 foreach($r in $rects){
  $part=$source.Clone($r,[Drawing.Imaging.PixelFormat]::Format24bppRgb)
  $dest=[Drawing.Rectangle]::new([int](($width-$r.Width)/2),$y,$r.Width,$r.Height)
  $g.DrawImage($part,$dest,0,0,$r.Width,$r.Height,[Drawing.GraphicsUnit]::Pixel);$y+=$r.Height+24;$part.Dispose()
 }
 $g.Dispose();$source.Dispose()
 $name=('review-{0:d3}.jpg' -f [int]$it.id)
 $encoder=[Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()|Where-Object {$_.MimeType -eq 'image/jpeg'}
 $params=[Drawing.Imaging.EncoderParameters]::new(1);$params.Param[0]=[Drawing.Imaging.EncoderParameter]::new([Drawing.Imaging.Encoder]::Quality,[long]94)
 $result.Save((Join-Path $out $name),$encoder,$params);$params.Dispose();$result.Dispose()
 $catalog+=@{id=$it.id;file=$name;width=$width;height=$height}
}
$catalog|ConvertTo-Json|Set-Content -Encoding UTF8 (Join-Path $work 'clean-catalog.json')
for($start=0;$start -lt $catalog.Count;$start+=9){
 $sheet=[Drawing.Bitmap]::new(1500,1800);$g=[Drawing.Graphics]::FromImage($sheet);$g.Clear([Drawing.Color]::White);$font=[Drawing.Font]::new('Arial',15)
 for($n=0;$n -lt 9 -and ($start+$n) -lt $catalog.Count;$n++){
  $it=$catalog[$start+$n];$im=[Drawing.Image]::FromFile((Join-Path $out $it.file))
  $x=($n%3)*500;$y=[math]::Floor($n/3)*600
  $g.DrawString(('#'+$it.id),$font,[Drawing.Brushes]::Black,$x+5,$y+2)
  $scale=[math]::Min(494/$im.Width,565/$im.Height)
  $g.DrawImage($im,[Drawing.Rectangle]::new($x,$y+30,[int]($im.Width*$scale),[int]($im.Height*$scale)));$im.Dispose()
 }
 $g.Dispose();$font.Dispose();$sheet.Save((Join-Path $work ('clean-sheet-'+([int]($start/9)+1)+'.jpg')),[Drawing.Imaging.ImageFormat]::Jpeg);$sheet.Dispose()
}
Write-Output ('Rendered '+$catalog.Count)
