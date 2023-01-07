# Die nachfolgende Zeile muss mit Administratorenrechten installiert werden!
# Install-Module -Name SqlServer -AllowClobber

# $Server = 'DESKTOP-EJV4955\SQLEXPRESS'
$Server = 'DESKTOP-VUM307Q\SQLEXPRESS'
$Database = 'Corona'
$File = 'file.csv'

# Download der Daten
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

# Lesen mit dediziertem User von View --> nur Read rechte
$Username = "ReadingUser"
$Password = ConvertTo-SecureString "S1cheresJuventusPassw0rt" -AsPlainText -Force
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList ($Username, $Password)
Write-Verbose "Credentials für $Username erstellt"

# Daten gruppiert nach Kanton
$Kantone = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetCanton ORDER BY Kantonname;" -Credential $Credentials
$Kantone = $Kantone.ItemArray

Import-Module .\HtmlHelperModule.psm1 -Force
# Navigation für weitere .html-File generierung schreiben
Write-Navigation $Kantone

# Daten über die Schweiz zusammenfassen
Write-SwissData -Server $Server -Database $Database -Credentials $Credentials -Kantone $Kantone -Verbose

# Alle Kantone schreiben
Write-CantonData -Server $Server -Database $Database -Credentials $Credentials -Kantone $Kantone

