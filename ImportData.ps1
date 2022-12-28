$Server = 'DESKTOP-VUM307Q\SQLEXPRESS'
$Database = 'Corona'
$File = 'file.csv'


#Invoke-WebRequest https://raw.githubusercontent.com/openZH/covid_19/master/COVID19_Fallzahlen_CH_total_v2.csv -OutFile $File

# Import Anstossen 
# TODO: dedizierter User mit Write-Rechten
$Sql = "EXEC dbo.uspImportCoronaData @CsvPath = '" + $PWD + "\" + $File + "'"

Invoke-Sqlcmd -ServerInstance $Server -Database $Database -Query $Sql | Out-Null

# Lesen mit dediziertem User von View --> nur Read rechte

