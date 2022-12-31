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
$Navigation += '<a style= "margin: 0.5rem;" href="Schweiz.html">Gesammte Schweiz</a>' + "`n"
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
    $InQuarantäne = [System.Collections.ArrayList]@()    

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
        $InQuarantäne.Add([pscustomobject]@{
                Datum = $Datum
                Wert  = $Row.Item(3)
            })
    }

}

Get-SwissData -Kantone $Kantone -Server $Server -Database $Database -Credentials $Credentials

# 1 View: Alle Kantone Alphabetisch --> für Schweizer View verwenden.


