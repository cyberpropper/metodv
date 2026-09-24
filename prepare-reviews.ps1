Add-Type -AssemblyName System.Drawing
$work=Join-Path $PSScriptRoot '.review-work'
New-Item -ItemType Directory -Force -Path $work | Out-Null
$seen=@{};$items=@();$duplicates=@()
foreach($f in (Get-ChildItem (Join-Path $PSScriptRoot 'review') -File | Sort-Object Name)){
 $hash=(Get-FileHash -LiteralPath $f.FullName).Hash
 if($seen.ContainsKey($hash)){$duplicates+=@{file=$f.Name;duplicateOf=$seen[$hash]};continue}
 $seen[$hash]=$f.Name;$im=[Drawing.Image]::FromFile($f.FullName)
 $items+=@{id=$items.Count+1;name=$f.Name;w=$im.Width;h=$im.Height};$im.Dispose()
}
@{items=$items;duplicates=$duplicates}|ConvertTo-Json -Depth 5|Set-Content -Encoding UTF8 (Join-Path $work 'manifest.json')
for($start=0;$start -lt $items.Count;$start+=6){
 $sheet=New-Object Drawing.Bitmap(1200,1800);$g=[Drawing.Graphics]::FromImage($sheet);$g.Clear([Drawing.Color]::White);$font=New-Object Drawing.Font('Arial',15)
 for($n=0;$n -lt 6 -and ($start+$n) -lt $items.Count;$n++){
 $it=$items[$start+$n];$im=[Drawing.Image]::FromFile((Join-Path $PSScriptRoot ('review/'+$it.name)))
 $x=($n%3)*400;$y=[math]::Floor($n/3)*900
 $g.DrawString(('#'+$it.id+' '+$it.w+'x'+$it.h),$font,[Drawing.Brushes]::Black,$x+5,$y+2)
 $scale=[math]::Min(394/$im.Width,865/$im.Height)
 $g.DrawImage($im,[Drawing.Rectangle]::new($x,$y+30,[int]($im.Width*$scale),[int]($im.Height*$scale)));$im.Dispose()
 }
 $g.Dispose();$font.Dispose();$sheet.Save((Join-Path $work ('sheet-'+([int]($start/6)+1)+'.jpg')),[Drawing.Imaging.ImageFormat]::Jpeg);$sheet.Dispose()
}
Write-Output ('Prepared '+$items.Count)

