# Die nachfolgende Zeile muss mit Administratorenrechten installiert werden!
# Install-Module -Name SqlServer -AllowClobber

# $Server = 'DESKTOP-EJV4955\SQLEXPRESS'
$Server = 'DESKTOP-VUM307Q\SQLEXPRESS'
$Database = 'Corona'
$File = 'file.csv'


# Invoke-WebRequest https://raw.githubusercontent.com/openZH/covid_19/master/COVID19_Fallzahlen_CH_total_v2.csv -OutFile $File

# Import Anstossen mit dediziertem User mit Write-Rechten
$Sql = "EXEC dbo.uspImportCoronaData @CsvPath = '" + $PWD + "\" + $File + "'"

$Username = "ScriptingUser"
$Password = ConvertTo-SecureString "S1cheresPassw0rt" -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, $Password)

#Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Sql | Out-Null
Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Sql -Credential $Credentials -QueryTimeout 120 | Out-Null

# Lesen mit dediziertem User von View --> nur Read rechte

$Username = "ReadingUser"
$Password = ConvertTo-SecureString "S1cheresJuventusPassw0rt" -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, $Password)
$Server = 'DESKTOP-VUM307Q\SQLEXPRESS'
$Database = 'Corona'
# 1 View: Daten gruppiert nach Kanton

function Get-CleanCantonUrl {
    param(
        [Parameter(Mandatory = $true)][string]$Kantonname
    )
    $NeuerName = $Kantonname.ToLower()
    $NeuerName = $NeuerName -replace "ä", "ae"
    $NeuerName = $NeuerName -replace "ü", "ue"
    $NeuerName = $NeuerName -replace "ö", "oe"
    $NeuerName = $NeuerName -replace ".", ""
    $NeuerName = $NeuerName -replace " ", "_"
    return $NeuerName + '.html';
}

#Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Sql | Out-Null
$Kantone = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetCanton ORDER BY Kantonname;" -Credential $Credentials
$Kantone = $Kantone.ItemArray

$Navigation = '<div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">' + "`n"
Foreach ($Kanton in $Kantone) {
    $Url = Get-CleanCantonUrl $Kanton
    $Navigation += '<a style= "margin: 0.5rem;" href="' + $Url + '">' + $Kanton + '</a>' + "`n"
}
$Navigation += '<a style= "margin: 0.5rem;" href="schweiz.html">Gesammte Schweiz</a>' + "`n"
$Navigation += '</div>'
# 1 View: Daten gruppiert nach Datum für gesammte Schweiz
function Get-SwissData {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Kantone,
        [string]$Server,
        [string]$Database,
        [System.Management.Automation.PSCredential]$Credentials
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
        <div id="myChart" style="max-width:1800px; height:400px"></div>
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

    $Path = $PWD.Path + "\schweiz.html"
    $FileInhalt | Out-File -FilePath $Path

}

Get-SwissData -Kantone $Kantone -Server $Server -Database $Database -Credentials $Credentials

# 1 View: Alle Kantone Alphabetisch --> für Schweizer View verwenden.


