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

<#
 .Synopsis
  Schreibt die Navigation in eine .html Datei
 .Description
  Schreibt die Navigation in eine .html Datei, 
  welche beim Schreiben weiterer Datein gelesen und eingebunden wird.
 .Parameter Kantone
  Ein Array aller Kantone
 .Example
  Write-Navigation "Zug", "Bern" 
#>
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

    Write-Verbose "Writing Navigation to $NavigationFilePath with -Encoding utf8 and Content:"
    Write-Verbose  $Navigation
    $Navigation | Out-File -FilePath $NavigationFilePath -Encoding utf8
}

<#
 .Synopsis
  Schreibt eine .html Datei
 .Description
  Schreibt eine .html Datei inklusive vorherig erstellter Navigation.
 .Parameter Body
  Das inner html der html Datei.
 .Parameter Filename
  Der Filename der zu erstellenden html Datei.
 .Example
  Write-HtmlPage -Body "<div><p>Ein Paragraph</p></div>" -Filename "Test.html"
#>
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
    Write-Verbose "Writing $FilePath with -Encoding utf8 and Content:"
    Write-Verbose  $Content
    $Content | Out-File -FilePath $FilePath -Encoding utf8
}

<#
 .Synopsis
  Liest die Daten der Schweiz aus und schreibt diese in "schweiz.html"
 .Description
  Liest die Daten der Schweiz aus der Datenbank aus und schreibt diese in "schweiz.html"
 .Parameter Server
  Der Server, bei welchem die Daten gelesen werden sollen.
 .Parameter Database
  Die Datenbank, in welcher die Daten gelesen werden sollen.
 .Parameter Credentials
  Die Credentials des Users, welcher die Daten lesen wird.
 .Parameter Kantone
  Die Kantone, welche sich in der Datenbank befinden.
 .Example
  $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ("Username", "Password")
  Write-SwissData -Server "LOKALER_SERVER" -Database "Corona" -Credentials $Credentials -Kantone "Zug", "Bern"
#>
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
            }) | Write-Verbose | Out-Null
        $Verstorben.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(1)
            }) | Write-Verbose | Out-Null
        $Isoliert.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(2)
            }) | Write-Verbose | Out-Null
        $InQuarantaene.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(3)
            }) | Write-Verbose | Out-Null

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

<#
 .Synopsis
  Liest die Daten der Schweiz gruppiert in Kantone aus und schreibt diese in html Dateien.
 .Description
  Liest die Daten der Schweiz gruppiert in Kantone aus und schreibt diese in html Dateien.
  Die html Dateien werden nach dem Schema <kanton>.html erzeugt.
 .Parameter Server
  Der Server, bei welchem die Daten gelesen werden sollen.
 .Parameter Database
  Die Datenbank, in welcher die Daten gelesen werden sollen.
 .Parameter Credentials
  Die Credentials des Users, welcher die Daten lesen wird.
 .Parameter Kantone
  Die Kantone, welche sich in der Datenbank befinden.
 .Example
  $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ("Username", "Password")
  Write-CantonData -Server "LOKALER_SERVER" -Database "Corona" -Credentials $Credentials -Kantone "Zug", "Bern"
#>
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
            Positiv       = [System.Collections.ArrayList]@()
            Verstorben    = [System.Collections.ArrayList]@()
            Isoliert      = [System.Collections.ArrayList]@()
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
            })  | Write-Verbose | Out-Null
        $CurrentCanton.Verstorben.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(3)
            }) | Write-Verbose | Out-Null
        $CurrentCanton.Isoliert.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(4)
            }) | Write-Verbose | Out-Null
        $CurrentCanton.InQuarantaene.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(5)
            }) | Write-Verbose | Out-Null

    }

    Foreach ($Canton in $CantonData.GetEnumerator()) {
        $PositivDatenVariabel = 'var positiv = [["Datum", "Positive Tests"]'
        $PositivDatenVariabel += $Canton.Value.Positiv | ForEach-Object { ',["' + $_.Datum + '",' + $(If ($_.Wert -is [DBNull]) { 'null' } Else { $_.Wert }) + ']' }
        $PositivDatenVariabel += ']'
        $VerstorbenDatenVariabel = 'var verstorben = [["Datum", "Verstorben"]'
        $VerstorbenDatenVariabel += $Canton.Value.Verstorben | ForEach-Object { ',["' + $_.Datum + '",' + $(If ($_.Wert -is [DBNull]) { 'null' } Else { $_.Wert }) + ']' }
        $VerstorbenDatenVariabel += ']'
        $IsoliertDatenVariabel = 'var isoliert = [["Datum", "Isoliert"]'
        $IsoliertDatenVariabel += $Canton.Value.Isoliert | ForEach-Object { ',["' + $_.Datum + '",' + $(If ($_.Wert -is [DBNull]) { 'null' } Else { $_.Wert }) + ']' }
        $IsoliertDatenVariabel += ']'
        $InQuarantaeneDatenVariabel = 'var quarantaene = [["Datum", "In Quarantaene"]'
        $InQuarantaeneDatenVariabel += $Canton.Value.InQuarantaene | ForEach-Object { ',["' + $_.Datum + '",' + $(If ($_.Wert -is [DBNull]) { 'null' } Else { $_.Wert }) + ']' }
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

<#
 .Synopsis
  Liefert das Javascript für die einzelnen Kantone für Funktion Write-CantonData zurück.
 .Description
  Liefert das Javascript für die einzelnen Kantone für Funktion Write-CantonData zurück.
 .Parameter PositivDaten
  Die Daten der positiven Fälle der Kantones.
 .Parameter VerstorbenDaten
  Die Daten der verstorbenen Personen des Kantones.
 .Parameter IsoliertDaten
  Die Daten der isolierten Personen des Kantones.
 .Parameter InQuarantaeneDaten
  Die Daten der Personen, welche sich in Quarantäne befinden, des Kantones.
 .Example
  Get-Javascript -PositivDaten "'var positiv = [["Datum", "Positive Tests"], ['30.07.2022', 1143]]'" -VerstorbenDaten "'var verstorben = [["Datum", "Verstorben"], ['30.07.2022', 1143]]'" -IsoliertDaten "'var isoliert = [["Datum", "Isoliert"], ['30.07.2022', 1143]]'" -InQuarantaeneDaten "'var quarantaene = [["Datum", "In Quarantaene"], ['30.07.2022', 1143]]'"
#>
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

Write-Verbose "Module HtmlHelperModule.psm1 erfolgreich importiert"