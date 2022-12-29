$Server = 'DESKTOP-EJV4955\SQLEXPRESS'
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

