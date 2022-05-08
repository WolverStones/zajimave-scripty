# Zjištění aktuálního času v patřičném textovém formátu
$cas = Get-Date -Format "dddd dd.MM. yyyy HH:mm:ss"

# Zjištění informací o počítači a operačním systému pomocí API Common Information Model (CIM)
$pc = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Manufacturer, Model, Name, PCSystemType, UserName
$os = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object LastBootUpTime, Manufacturer, Name
$casstartu = $os.LastBootUpTime.ToString("dddd dd.MM. yyyy HH:mm:ss")

# Rozklíčování čísleného kódu typu počítače
$typPocitace = $pc.PCSystemType
if($typPocitace -eq 0){ $typPocitace = "neznámý" }
if($typPocitace -eq 1){ $typPocitace = "desktop" }
if($typPocitace -eq 2){ $typPocitace = "laptop/tablet" }
if($typPocitace -eq 3){ $typPocitace = "desktop" }
if($typPocitace -eq 4){ $typPocitace = "server" }
if($typPocitace -eq 5){ $typPocitace = "server" }
if($typPocitace -eq 6){ $typPocitace = "spotřebič/IoT" }
if($typPocitace -eq 7){ $typPocitace = "superpočítač" }
if($typPocitace -eq 8){ $typPocitace = "centrální mozek lidstva" }

# Zjištění údajů o síťových adaptérech, profilech a konfiguracích/IP
$adaptery = Get-NetAdapter | Select-Object Name, InterfaceDescription, LinkSpeed, Status | Where-Object Status -eq "Up"
$profily = Get-NetConnectionProfile | Select-Object Name, InterfaceAlias, IPv4Connectivity
$site = Get-NetIPConfiguration | Select-Object InterfaceAlias, IPv4Address

# Vytvoření HTML s aktivními síťovými adaptéry
$html = "<h3>Aktivní síťové adaptéry:</h3><ul>"
foreach($adapter in $adaptery){
    $html += "<li>$($adapter.Name) ($($adapter.InterfaceDescription)), linková rychlost $($adapter.LinkSpeed)</li>" 
}

# Vytvoření HTML s aktivními síťovými profily (IPv4)
$html += "</ul><h3>Aktivní síťové profily:</h3><ul>"
foreach($profil in $profily){
    $typ = $profil.IPv4Connectivity
    if($profil.IPv4Connectivity -eq "LocalNetwork"){ $typ = "LAN"}
    if($profil.IPv4Connectivity -eq "Internet"){$typ = "internetu"}
    $html += "<li>$($profil.Name) ($($profil.InterfaceAlias)) připojeno do $typ</li>"
}

# Vytvoření HTML s IP adresami (IPv4)
$html += "</ul><h3>IPv4 adresy:</h3><ul>"
foreach ($sit in $site){
    $html += "<li>$($sit.InterfaceAlias): $(-join($sit.IPv4Address))</li>"  
}

# Kompletace HTML poštovní zprávy
$html = "
<h2>Haló, šéfe, nějaký loupežník se nám přihlásil k počítači!</h2>
<b>Čas události:</b> $cas<br>
<b>Přihlášený uživatel:</b> $($pc.UserName)<br>
<b>Počítač:</b> $($env:COMPUTERNAME), $($pc.Manufacturer) $($pc.Model) ($typPocitace)<br>
<b>Operační systém:</b> $($os.Manufacturer) $($os.Name.split("|")[0])<br><br>
<b>Čas posledního studeného startu PC:</b> $casstartu<br>" + $html

# Nastavení SMTP serveru pro GOOGLE
$smtp = "smtp.gmail.com"
$port = 587
$login = "uzivatel@gmail.com"
$heslo = ConvertTo-SecureString "heslo" -AsPlainText –Force
$odesilatel = "odesilatel@gmail.com"
$prijemce = "prijemce@gmail.com"
$autentizace = New-Object System.Management.Automation.PSCredential($login, $heslo) 
$kodovani = [System.Text.Encoding]::UTF8
$predmet = "Spuštění počítače $env:COMPUTERNAME"

Send-MailMessage -From $odesilatel -To $prijemce -SmtpServer $smtp -BodyAsHtml -Body $html -Subject $predmet -Credential $autentizace -Port $port -UseSsl -Encoding $kodovani