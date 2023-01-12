# Die nachfolgende Zeile muss mit Administratorenrechten installiert werden!
# Install-Module -Name SqlServer -AllowClobber

# $Server = 'DESKTOP-EJV4955\SQLEXPRESS'
$Server = 'DESKTOP-VUM307Q\SQLEXPRESS'
$Database = 'Corona'

# Import
Import-Module .\ImportData.psm1 -Force
Import-Data -Server $Server -Database $Database # -Verbose


# Export
Import-Module .\ExportData.psm1 -Force
Export-Data -Server $Server -Database $Database # -Verbose

# Browser starten
Invoke-Item "View\schweiz.html" # ist immer vorhanden