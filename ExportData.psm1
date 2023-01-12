<#
 .Synopsis
  Exportiert die Daten in html Files
 .Description
  Laded die Daten aus der Datenbank mit einem Dedizierten User und erstellt html Dateien.
 .Parameter Server
  Der Servername, aus welchem exportiert werden soll.
 .Parameter Database
  Die Datenbank, aus welcher exportiert werden soll.
 .Example
  Export-Data -Server 'DESKTOP-VUM307Q\SQLEXPRESS' -Database 'Corona'
#>
function Export-Data {
    param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Server,
        [Parameter(Mandatory = $true, Position = 1)][string]$Database
    )
    $FolderName = "View"

    $Username = "ReadingUser"
    $Password = ConvertTo-SecureString "S1cheresJuventusPassw0rt" -AsPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, $Password)
    Write-Verbose "Credentials für $Username erstellt"

    # Daten gruppiert nach Kanton
    $Kantone = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetCanton ORDER BY Kantonname;" -Credential $Credentials
    $Kantone = $Kantone.ItemArray


    if (!(Test-Path $FolderName)) {
        New-Item -itemType Directory -Name $FolderName | Write-Verbose | Out-Null
    }

    Import-Module .\HtmlHelperModule.psm1 -Force
    # Navigation für weitere .html-File generierung schreiben
    Write-Navigation $Kantone

    # Daten über die Schweiz zusammenfassen
    Write-SwissData -Server $Server -Database $Database -Credentials $Credentials -Kantone $Kantone

    # Alle Kantone schreiben
    Write-CantonData -Server $Server -Database $Database -Credentials $Credentials -Kantone $Kantone
}

Write-Verbose "Module ExportData.psm1 erfolgreich importiert"