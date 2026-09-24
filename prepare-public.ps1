$ErrorActionPreference='Stop'
$destination=Join-Path $PSScriptRoot 'public'
New-Item -ItemType Directory -Force $destination|Out-Null
Get-ChildItem $PSScriptRoot -File|Where-Object {$_.Extension -in '.html','.css','.js'}|Copy-Item -Destination $destination -Force
$publicAssets=Join-Path $destination 'assets'
New-Item -ItemType Directory -Force $publicAssets|Out-Null
Copy-Item (Join-Path $PSScriptRoot 'assets/source') $publicAssets -Recurse -Force
$publicReviews=Join-Path $publicAssets 'reviews'
New-Item -ItemType Directory -Force $publicReviews|Out-Null
$html=Get-Content (Join-Path $PSScriptRoot 'reviews.html') -Raw -Encoding UTF8
[regex]::Matches($html,'assets/reviews/(review-[0-9]+\.jpg)')|ForEach-Object {$_.Groups[1].Value}|Sort-Object -Unique|ForEach-Object {
 Copy-Item (Join-Path $PSScriptRoot ('assets/reviews/'+$_)) $publicReviews -Force
}
if(Test-Path (Join-Path $PSScriptRoot 'docs')){Copy-Item (Join-Path $PSScriptRoot 'docs') $destination -Recurse -Force}
Write-Output ('Public files: '+(Get-ChildItem $destination -Recurse -File).Count)
Write-Output ('Published reviews: '+(Get-ChildItem $publicReviews -File).Count)

