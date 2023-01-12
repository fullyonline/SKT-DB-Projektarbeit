<#
 .Synopsis
  Importiert die Daten
 .Description
  Laded die Daten herunter und startet den Datenbankimport mit einem Dedizierten User.
 .Parameter Server
  Der Servername, in welchen importiert werden soll.
 .Parameter Database
  Die Datenbank, in welche importiert werden soll.
 .Example
  Import-Data -Server 'DESKTOP-VUM307Q\SQLEXPRESS' -Database 'Corona'
#>
function Import-Data {    
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Server,
        [Parameter(Mandatory = $true, Position = 1)][string]$Database
    )
    # Download der Daten
    $File = 'file.csv'
    Invoke-WebRequest https://raw.githubusercontent.com/openZH/covid_19/master/COVID19_Fallzahlen_CH_total_v2.csv -OutFile $File
    Write-Verbose "Download der Daten erfolgreich abgeschlossen"

    # Import Anstossen mit dediziertem User mit Write-Rechten
    $Sql = "EXEC dbo.uspImportCoronaData @CsvPath = '" + $PWD + "\" + $File + "'"

    $Username = "ScriptingUser"
    $Password = ConvertTo-SecureString "S1cheresPassw0rt" -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, $Password)
    Write-Verbose "Credentials für $Username erstellt"

    # Import der Daten
    Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Sql -Credential $Credentials -QueryTimeout 120 | Write-Verbose | Out-Null
    Write-Verbose "Import der Daten erfolgreich abgeschlossen"
}

Write-Verbose "Module ImportData.psm1 erfolgreich importiert"