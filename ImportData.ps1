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
#Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Sql | Out-Null
$Kantone = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetCanton ORDER BY Kantonname;" -Credential $Credentials
$Kantone = $Kantone.ItemArray

Import-Module .\HtmlHelperModule.psm1 -Force
# Navigation für weitere .html-File generierung schreiben
Write-Navigation $Kantone

# Daten über die Schweiz zusammenfassen
Write-SwissData -Server $Server -Database $Database -Credentials $Credentials -Kantone $Kantone

# Alle Kantone schreiben


