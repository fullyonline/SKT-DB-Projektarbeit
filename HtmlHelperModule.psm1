<#
 .Synopsis

 .Description

 .Parameter Kantonname

 .Example

 .Example
 
#>
$NavigationFilePath = $PWD.Path + '.\navigation.html'

function Get-HtmlNameFromKanton {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Name
    )
    $NewName = $Name.ToLower().Replace(".", "").Replace(" ", "_")
    $NewName = $NewName + '.html';
    Write-Verbose "Name: $Name"
    Write-Verbose "NewName: $NewName"
    $NewName
}

function Write-Navigation {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string[]]$Kantone
    )
    $Navigation = '<div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">' + "`n"
    Foreach ($Kanton in $Kantone) {
        $Url = Get-HtmlNameFromKanton $Kanton
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
        [Parameter(Mandatory = $true, Position = 2)][System.Management.Automation.PSCredential]$Credentials,
        [Parameter(Mandatory = $true, Position = 3)][string[]]$Kantone
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

    $KantoneHtml = '<ul>'
    $KantoneHtml += $Kantone | ForEach-Object { "<li>$_</li>" }
    $KantoneHtml += '</ul>'
    
    $FileInhalt = '<script src="https://www.gstatic.com/charts/loader.js">
    </script>
    <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
        <button id="btnPositiv" style="margin: 0.5rem;">Positive Faelle</button>
        <button id="btnVerstorben" style="margin: 0.5rem;">Verstorbene Faelle</button>
        <button id="btnIsoliert" style="margin: 0.5rem;">Isolierte Personen</button>
        <button id="btnQuarantaene" style="margin: 0.5rem;">Personmen in Quarantaene</button>
    </div>
    <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
        <div id="myChart" style="width:1800px; height:400px"></div>
    </div>

    <br/>
    <br/>
    
    <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
        <div>    
            <p>Alle Daten sind aus den folgenden Kantonen:</p>
            <br/>
            ' + $KantoneHtml + '
        </div>
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
            title: "Anzahl Positiv Getestete Faelle",
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
            title: "Anzahl Personen in Quarantaene",
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

function Write-CantonData {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Server,
        [Parameter(Mandatory = $true, Position = 1)][string]$Database,
        [Parameter(Mandatory = $true, Position = 2)][System.Management.Automation.PSCredential]$Credentials,
        [Parameter(Mandatory = $true, Position = 3)][string[]]$Kantone
    )

    $CantonData = @{}
    Foreach ($Kanton in $Kantone) {
        $CantonData[$Kanton] = [pscustomobject]@{
            Positiv = [System.Collections.ArrayList]@()
            Verstorben = [System.Collections.ArrayList]@()
            Isoliert = [System.Collections.ArrayList]@()
            InQuarantaene = [System.Collections.ArrayList]@()
        }
    }

    $Data = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetCantonData ORDER BY Datum;" -Credential $Credentials    
    
    Foreach ($Row in $Data) {
        $Datum = $Row.Item(6).ToString("dd.MM.yyyy")
        $CurrentCanton = $CantonData[$Row.Kantonname]
        $CurrentCanton.Positiv.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(2)
            }) | Out-Null
        $CurrentCanton.Verstorben.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(3)
            }) | Out-Null
        $CurrentCanton.Isoliert.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(4)
            }) | Out-Null
        $CurrentCanton.InQuarantaene.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(5)
            }) | Out-Null

    }

    Foreach ($Canton in $CantonData.GetEnumerator()) {
        $PositivDatenVariabel = 'var positiv = [["Datum", "Positive Tests"]'
        $PositivDatenVariabel += $Canton.Value.Positiv | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
        $PositivDatenVariabel += ']'
        $VerstorbenDatenVariabel = 'var verstorben = [["Datum", "Verstorben"]'
        $VerstorbenDatenVariabel += $Canton.Value.Verstorben | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
        $VerstorbenDatenVariabel += ']'
        $IsoliertDatenVariabel = 'var isoliert = [["Datum", "Isoliert"]'
        $IsoliertDatenVariabel += $Canton.Value.Isoliert | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
        $IsoliertDatenVariabel += ']'
        $InQuarantaeneDatenVariabel = 'var quarantaene = [["Datum", "Isoliert"]'
        $InQuarantaeneDatenVariabel += $Canton.Value.InQuarantaene | ForEach-Object { ',["' + $_.Datum + '",' + $_.Wert + ']' }
        $InQuarantaeneDatenVariabel += ']'

        $FileInhalt = '<script src="https://www.gstatic.com/charts/loader.js">
        </script>
        <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
        <h1>' + $Canton.Name + '</h1>
        </div>
        <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
            <button id="btnPositiv" style="margin: 0.5rem;">Positive Faelle</button>
            <button id="btnVerstorben" style="margin: 0.5rem;">Verstorbene Faelle</button>
            <button id="btnIsoliert" style="margin: 0.5rem;">Isolierte Personen</button>
            <button id="btnQuarantaene" style="margin: 0.5rem;">Personen in Quarantaene</button>
        </div>
        <div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">
            <div id="myChart" style="width:1800px; height:400px"></div>
        </div>

        <br/>
        <br/>
        
        '

        $FileInhalt += Get-Javascript -PositivDaten $PositivDatenVariabel -VerstorbenDaten $VerstorbenDatenVariabel -IsoliertDaten $IsoliertDatenVariabel -InQuarantaeneDaten $InQuarantaeneDatenVariabel

        $HtmlName = Get-HtmlNameFromKanton $Canton.Name
        Write-HtmlPage -Body $FileInhalt -Filename $HtmlName
    }
}

function Get-Javascript {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$PositivDaten,
        [Parameter(Mandatory = $true, Position = 1)][string]$VerstorbenDaten,
        [Parameter(Mandatory = $true, Position = 2)][string]$IsoliertDaten,
        [Parameter(Mandatory = $true, Position = 3)][string]$InQuarantaeneDaten
    )
    
    $JavascriptCode = '<script>
    ' + $PositivDatenVariabel + ';
    ' + $VerstorbenDatenVariabel + ';
    ' + $IsoliertDatenVariabel + ';
    ' + $InQuarantaeneDatenVariabel + ';
    function drawPositivChart() {
        // Set Data
        var data = google.visualization.arrayToDataTable(positiv);
        // Set Options
        var options = {
            title: "Anzahl Positiv Getestete Faelle",
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
            title: "Anzahl Personen in Quarantaene",
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

    $JavascriptCode
}