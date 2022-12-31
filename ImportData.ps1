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
$Kantone = Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query "SELECT * FROM usvGetCanton;" -Credential $Credentials -QueryTimeout 120

$Navigation = '<div style="display: flex; flex-direction: row; flex-wrap: wrap; justify-content: center;">' + "`n"
Foreach ($Kanton in $Kantone) {
    $Navigation += '<a style= "margin: 0.5rem;" href="' + $Kanton.Item(0) + '.html">' + $Kanton.Item(0) + '</a>' + "`n"
}
$Navigation += '<a style= "margin: 0.5rem;" href="Schweiz.html">Gesammte Schweiz</a>' + "`n"
$Navigation += '</div>'

Write-Host $Navigation

# 1 View: Daten gruppiert nach Datum für gesammte Schweiz
# 1 View: Alle Kantone Alphabetisch --> für Schweizer View verwenden.

