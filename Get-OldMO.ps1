$wikiUrl = "https://commons.wikimedia.org"
$MOUrl = "https://commons.wikimedia.org/wiki/Category:Monitorul_Oficial"
$c = Invoke-WebRequest -Uri $MOUrl
$h = ConvertFrom-Html $c
$body = $h.SelectNodes("//body")
$body.SelectNodes("//div[@class='CategoryTreeItem']") | ForEach-Object {
    $yearUrl = $wikiUrl + $_.ChildNodes[2].Attributes[0].value
    $yearPage = Invoke-WebRequest -Uri $yearUrl
    $yearHtmlContent = ConvertFrom-Html $yearPage
    $yearBody = $yearHtmlContent.SelectNodes("//body")
    $yearBody.SelectNodes("//div[@class='CategoryTreeItem']") | ForEach-Object {
        $monthUrl = "https://commons.wikimedia.org/" + $_.ChildNodes[2].Attributes[0].value
        $monthPage = Invoke-WebRequest -uri $monthUrl
        $monthPageHtml = ConvertFrom-Html $monthPage
        $hrefs = $monthPageHtml.SelectNodes("//body").selectNodes("//a[contains(@href,'File:')]/@href")
        $hrefs | ForEach-Object {
            if ($_.InnerText.Length -gt 0) {
                $dayUrl = "https://commons.wikimedia.org/" + $_.attributes[0].value
                $dayPage = Invoke-WebRequest -uri $dayUrl
                $dayPageHtml = ConvertFrom-Html -Content $dayPage.Content
                $fileUrl = $dayPageHtml.SelectNodes("//*[@id='file']/a").attributes.value
                $fileName = "c:\mo\" + $dayPageHtml.SelectNodes("//*[@id='firstHeading']/span[3]").InnerText.replace(" ", "-")
                $cond = Test-Path -Path $fileName -PathType Leaf
                if ($cond -eq $false) {
                    Invoke-WebRequest -Uri $fileUrl -OutFile $fileName
                }
                else {
                    "skip " + $fileName
                }
            }
        }
    }
}
