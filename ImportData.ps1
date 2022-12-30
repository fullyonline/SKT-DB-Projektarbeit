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
# 1 View: Daten gruppiert nach Kanton

# 1 View: Daten gruppiert nach Datum für gesammte Schweiz
# 1 View: Alle Kantone Alphabetisch --> für Schweizer View verwenden.
