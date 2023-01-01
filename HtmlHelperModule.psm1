<#
 .Synopsis

 .Description

 .Parameter Kantonname

 .Example

 .Example
 
#>
$NavigationFilePath = $PWD.Path + '.\navigation.html'

function Write-Navigation {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string[]]$Kantone
    )

    
    $Navigation = '<div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">' + "`n"
    Foreach ($Kanton in $Kantone) {
        $Url = $Kanton + '.html'
        $Navigation += '<a style= "margin: 0.5rem;" href="' + $Url + '">' + $Kanton + '</a>' + "`n"
    }
    $Navigation += '<a style= "margin: 0.5rem;" href="schweiz.html">Gesammte Schweiz</a>' + "`n"
    $Navigation += '</div>'
    $Navigation | Out-File -FilePath $NavigationFilePath
}

function Write-HtmlPage {    
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Body,
        [Parameter(Mandatory = $true, Position = 1)][string]$Filename
    )
    $Navbar = Get-Content -Path $NavigationFilePath
    Write-Host $Navbar
    $Content = '<!doctype html>
    <html lang="de">
        <head>
	        <meta charset="utf-8">
	        <title>DB-SKT Projektarbeit</title>
        </head>
        <body>
            ' + $Navbar + '
            ' + $Body + '
        </body>
    </html>'
    $FilePath = $PWD.Path + "\" + $Filename
    $Content | Out-File -FilePath $FilePath
}

function Write-SwissData {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Server,
        [Parameter(Mandatory = $true, Position = 1)][string]$Database,
        [Parameter(Mandatory = $true, Position = 2)][System.Management.Automation.PSCredential]$Credentials
    )
    $Positiv = [System.Collections.ArrayList]@()
    $Verstorben = [System.Collections.ArrayList]@()
    $Isoliert = [System.Collections.ArrayList]@()
    $InQuarantaene = [System.Collections.ArrayList]@()

    $Data = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetSwissData ORDER BY Datum;" -Credential $Credentials    
    Foreach ($Row in $Data) {
        $Datum = $Row.Item(4).ToString("dd.MM.yyyy")
        $Positiv.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(0)
            })
        $Verstorben.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(1)
            })
        $Isoliert.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(2)
            })
        $InQuarantaene.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(3)
            })

    }
    $PositivDatenVariabel = 'var positiv = [["Datum", "Positive Tests"]'
    $PositivDatenVariabel += $Positiv | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
    $PositivDatenVariabel += ']'
    $VerstorbenDatenVariabel = 'var verstorben = [["Datum", "Verstorben"]'
    $VerstorbenDatenVariabel += $Verstorben | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
    $VerstorbenDatenVariabel += ']'
    $IsoliertDatenVariabel = 'var isoliert = [["Datum", "Isoliert"]'
    $IsoliertDatenVariabel += $Isoliert | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
    $IsoliertDatenVariabel += ']'
    $InQuarantaeneDatenVariabel = 'var quarantaene = [["Datum", "Isoliert"]'
    $InQuarantaeneDatenVariabel += $InQuarantaene | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
    $InQuarantaeneDatenVariabel += ']'
    
    $FileInhalt = '<script src="https://www.gstatic.com/charts/loader.js">
    </script>
    <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
        <button id="btnPositiv" style="margin: 0.5rem;">Positive Fälle</button>
        <button id="btnVerstorben" style="margin: 0.5rem;">Verstorbene Fälle</button>
        <button id="btnIsoliert" style="margin: 0.5rem;">Isolierte Personen</button>
        <button id="btnQuarantaene" style="margin: 0.5rem;">Personmen in Quarantäne</button>
    </div>

    <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
        <div id="myChart" style="width:1800px; height:400px"></div>
    </div>

    <script>
    ' + $PositivDatenVariabel + ';
    ' + $VerstorbenDatenVariabel + ';
    ' + $IsoliertDatenVariabel + ';
    ' + $InQuarantaeneDatenVariabel + ';
    function drawPositivChart() {
        // Set Data
        var data = google.visualization.arrayToDataTable(positiv);
        // Set Options
        var options = {
            title: "Anzahl Positiv Getestete Fälle",
            hAxis: { title: "Datum" },
            vAxis: { title: "Anzahl" },
            legend: "none"
        };
        // Draw Chart
        var chart = new google.visualization.LineChart(document.getElementById("myChart"));
        chart.draw(data, options);
    }
    function drawVerstorbenChart() {
        // Set Data
        var data = google.visualization.arrayToDataTable(verstorben);
        // Set Options
        var options = {
            title: "Anzahl Verstorbene Personen",
            hAxis: { title: "Datum" },
            vAxis: { title: "Anzahl" },
            legend: "none"
        };
        // Draw Chart
        var chart = new google.visualization.LineChart(document.getElementById("myChart"));
        chart.draw(data, options);
    }
    function drawIsoliertChart() {
        // Set Data
        var data = google.visualization.arrayToDataTable(isoliert);
        // Set Options
        var options = {
            title: "Anzahl isolierte Personen",
            hAxis: { title: "Datum" },
            vAxis: { title: "Anzahl" },
            legend: "none"
        };
        // Draw Chart
        var chart = new google.visualization.LineChart(document.getElementById("myChart"));
        chart.draw(data, options);
    }
    function drawQuarantaeneChart() {
        // Set Data
        var data = google.visualization.arrayToDataTable(quarantaene);
        // Set Options
        var options = {
            title: "Anzahl Personen in Quarantäne",
            hAxis: { title: "Datum" },
            vAxis: { title: "Anzahl" },
            legend: "none"
        };
        // Draw Chart
        var chart = new google.visualization.LineChart(document.getElementById("myChart"));
        chart.draw(data, options);
    }
    google.charts.load("current", { packages: ["corechart"] });
    google.charts.setOnLoadCallback(drawPositivChart);

    document.getElementById("btnPositiv").addEventListener("click", drawPositivChart);
    document.getElementById("btnVerstorben").addEventListener("click", drawVerstorbenChart);    
    document.getElementById("btnIsoliert").addEventListener("click", drawIsoliertChart);
    document.getElementById("btnQuarantaene").addEventListener("click", drawQuarantaeneChart);

    </script>'

    Write-HtmlPage -Body $FileInhalt -Filename "schweiz.html"
}


$badBytes = [byte[]]@(0xC3, 0x80)
$utf8Str = [System.Text.Encoding]::UTF8.GetString($badBytes)
$bytes = [System.Text.Encoding]::ASCII.GetBytes('Write-Output "') + [byte[]]@(0xC3, 0x80) + [byte[]]@(0x22)
$path = Join-Path ([System.IO.Path]::GetTempPath()) 'encodingtest.ps1'

try {
    [System.IO.File]::WriteAllBytes($path, $bytes)

    switch (& $path) {
        $utf8Str {
            return 'UTF-8'
            break
        }

        default {
            return 'Windows-1252'
            break
        }
    }
}
finally {
    Remove-Item $path
}