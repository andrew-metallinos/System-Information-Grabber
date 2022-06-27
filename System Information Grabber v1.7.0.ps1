 <#
    .SYNOPSIS

        This function can be used to find the basic
        information of a PC device. Once generated
        the information can be emailed to a desired
        address as a .txt attachment.

        Some information will not be included in the
        .txt file due to security concerns.


    .PARAMETERS

        $PATH
            Pathway used where all files will be temporarily stored.
        
        $FROM
            The email address that will be sending the email.

        $PASS
            The password for the email address used above.

        $TO
            Recipient address.

        $SUBJECT
            Subject of the email.

        $BODY
            Body of the email.

        $ATTACH
            File name to attach to email.
        
        $SMTP_SERVER
            SMTP server address.
        
        $SMTP_PORT
            SMTP port number.
#>



Write-Host "


    ███╗░░░███╗███████╗████████╗░█████╗░██╗░░░░░██╗░░░░░██╗███╗░░██╗░█████╗░░██████╗  ████████╗███████╗░█████╗░██╗░░██╗
    ████╗░████║██╔════╝╚══██╔══╝██╔══██╗██║░░░░░██║░░░░░██║████╗░██║██╔══██╗██╔════╝  ╚══██╔══╝██╔════╝██╔══██╗██║░░██║
    ██╔████╔██║█████╗░░░░░██║░░░███████║██║░░░░░██║░░░░░██║██╔██╗██║██║░░██║╚█████╗░  ░░░██║░░░█████╗░░██║░░╚═╝███████║
    ██║╚██╔╝██║██╔══╝░░░░░██║░░░██╔══██║██║░░░░░██║░░░░░██║██║╚████║██║░░██║░╚═══██╗  ░░░██║░░░██╔══╝░░██║░░██╗██╔══██║
    ██║░╚═╝░██║███████╗░░░██║░░░██║░░██║███████╗███████╗██║██║░╚███║╚█████╔╝██████╔╝  ░░░██║░░░███████╗╚█████╔╝██║░░██║
    ╚═╝░░░░░╚═╝╚══════╝░░░╚═╝░░░╚═╝░░╚═╝╚══════╝╚══════╝╚═╝╚═╝░░╚══╝░╚════╝░╚═════╝░  ░░░╚═╝░░░╚══════╝░╚════╝░╚═╝░░╚═╝


    Title: System Information Grabber
    Author: Andrew Metallinos <andrew@metallinostech.com.au>
    Creation Date: 24/04/2022
    Revision Date: 27/06/2022
    Version: 1.7.0

========================================
"



#Open script in Administrator mode
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}



Write-Host "The users/domain/workgroup details are below:"
Get-ComputerInfo | Format-List -Property @{n="*Owner";e={$_.WindowsRegisteredOwner}},
                                         @{n="Username";e={$_.CsUserName}},
                                         @{n="Workgroup";e={$_.CsWorkgroup}},
                                         @{n="Domain";e={$_.CsDomain}},
                                         @{n="Keyboard Layout";e={$_.KeyboardLayout}},
                                         @{n="Time-Zone";e={$_.TimeZone}},
                                         @{n="Local Date/Time";e={$_.OsLocalDateTime}}
"
----------------------------------------
"
Write-Host "The OS details are below:"
Get-ComputerInfo | Format-List -Property @{n="Edition";e={$_.OsName}},
                                         @{n="Windows Version";e={$_.WindowsVersion}},
                                         @{n="Architecture";e={$_.OsArchitecture}},
                                         @{n="OS Build";e={$_.OsBuildNumber}},
                                         @{n="OS Version";e={$_.OsVersion}},
                                         @{n="*Serial Number";e={$_.OsSerialNumber}}
Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DisplayVersion |
                    Format-List -Property @{n="Display Version";e={$_.DisplayVersion}}
"
----------------------------------------
"
Write-Host "The CS details are below:"
Get-ComputerInfo | Format-List -Property @{n="Memory (GB)";;e={[math]::Round($_.CsTotalPhysicalMemory/1GB,1)}},
                                         @{n="Model";e={$_.CsModel}},
                                         @{n="Manufacturer";e={$_.CsManufacturer}},
                                         @{n="Processors";e={$_.CsProcessors}},
                                         @{n="Network Adapters";e={$_.CsNetworkAdapters}}
"
----------------------------------------
"

Write-Host "The disk space details are below:
"
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Format-Table -Property @{n="Drive";e={$_.DeviceID}},
                                                                                            @{n="Volume Name";e={$_.VolumeName}},
                                                                                            @{n="Size (GB)";e={[math]::Round($_.Size/1GB,1)}},
                                                                                            @{n="Free (GB)";e={[math]::Round($_.FreeSpace/1GB,1)}}
"
----------------------------------------
"
Write-Host "The BIOS details are below:"
Get-ComputerInfo | Format-List -Property @{n="Manufacturer";e={$_.BiosManufacturer}},
                                         @{n="Version";e={$_.BiosVersion}},
                                         @{n="Frimware Type";e={$_.BiosFirmwareType}},
                                         @{n="Release Date";e={$_.BiosReleaseDate}}

Get-Tpm | Format-List -Property @{n="Is TPM Present?";e={$_.TpmPresent}},
                                @{n="Is TPM Enabled?";e={$_.TpmEnabled}}
"
----------------------------------------
"
Write-Host "The printer details are below:
"
Get-WMIObject -Class Win32_Printer | Format-Table -Property @{n="Name";e={$_.Name}},
                                                            @{n="State";e={$_.PrinterState}},
                                                            @{n="Status";e={$_.PrinterStatus}},
                                                            @{n="Location";e={$_.Location}}
"
----------------------------------------
"
Write-Host "The details of all installed programs are below:
"
Get-WmiObject -Class Win32_Product | Sort -Property Name | Format-Table -Property Name,
                                                                                  Version,
                                                                                  Vendor
"
----------------------------------------
"
Write-Host "The details of the device's port number & IP Configuration is below: (this will not be sent in the .txt file)"
Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\'-name portnumber |
                         Format-List -Property @{n="Port Number";e={$_.PortNumber}}

Get-NetIPConfiguration | Format-List -Property @{n="Alias";e={$_.InterfaceAlias}},
                                               @{n="Description";e={$_.InterfaceDescription}},
                                               @{n="Index";e={$_.InterfaceIndex}},
                                               @{n="IPv4 Address";e={$_.IPv4Address}}
"
========================================
"



#Beeps
[System.Console]::beep(262, 500)
[System.Console]::beep(262, 500)



# Prompt to send email 
$TO = Read-Host -Prompt "Enter in an email address you would like to send
all of the above information to and then press ENTER"
"`n`n"
# Who's PC is this?
$PC_USER = Read-Host -Prompt "Enter in a short description of who uses this PC or the purpose of this PC and then press ENTER"


# All the files will be saved in this directory
$PATH = "C:\SystemInformationGrabber"
mkdir $PATH
cd $PATH

Get-ComputerInfo | Format-List -Property @{n="Username";e={$_.CsUserName}},
                                         @{n="Workgroup";e={$_.CsWorkgroup}},
                                         @{n="Domain";e={$_.CsDomain}},
                                         @{n="Keyboard Layout";e={$_.KeyboardLayout}},
                                         @{n="Time-Zone";e={$_.TimeZone}},
                                         @{n="Local Date/Time";e={$_.OsLocalDateTime}} |
                                         Out-File systeminfo1.txt -Encoding utf8

Get-ComputerInfo | Format-List -Property @{n="Edition";e={$_.OsName}},
                                         @{n="Windows Version";e={$_.WindowsVersion}},
                                         @{n="Architecture";e={$_.OsArchitecture}},
                                         @{n="OS Build";e={$_.OsBuildNumber}},
                                         @{n="OS Version";e={$_.OsVersion}} |
                                         Out-File systeminfo2a.txt -Encoding utf8

Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name DisplayVersion |
                   Format-List -Property @{n="Display Version";e={$_.DisplayVersion}} |
                   Out-File systeminfo2b.txt -Encoding utf8

Get-ComputerInfo | Format-List -Property @{n="Memory (GB)";;e={[math]::Round($_.CsTotalPhysicalMemory/1GB,1)}},
                                         @{n="Model";e={$_.CsModel}},
                                         @{n="Manufacturer";e={$_.CsManufacturer}},
                                         @{n="Processors";e={$_.CsProcessors}},
                                         @{n="Network Adapters";e={$_.CsNetworkAdapters}} | 
                                         Out-File systeminfo3.txt -Encoding utf8

Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" | Format-Table -Property @{n="Drive";e={$_.DeviceID}},
                                                                                            @{n="Volume Name";e={$_.VolumeName}},
                                                                                            @{n="Size (GB)";e={[math]::Round($_.Size/1GB,1)}},
                                                                                            @{n="Free (GB)";e={[math]::Round($_.FreeSpace/1GB,1)}} |
                                                                                            Out-File systeminfo4.txt -Encoding utf8

Get-ComputerInfo | Format-List -Property @{n="Manufacturer";e={$_.BiosManufacturer}},
                                         @{n="Version";e={$_.BiosVersion}},
                                         @{n="Frimware Type";e={$_.BiosFirmwareType}},
                                         @{n="Release Date";e={$_.BiosReleaseDate}} |
                                         Out-File systeminfo5a.txt -Encoding utf8

Get-Tpm | Format-List -Property @{n="Is TPM Present?";e={$_.TpmPresent}},
                                @{n="Is TPM Enabled?";e={$_.TpmEnabled}} |
                                Out-File systeminfo5b.txt -Encoding utf8

Get-WMIObject -Class Win32_Printer | Format-Table -Property @{n="Name";e={$_.Name}},
                                                            @{n="State";e={$_.PrinterState}},
                                                            @{n="Status";e={$_.PrinterStatus}},
                                                            @{n="Location";e={$_.Location}} |
                                                            Out-File systeminfo6.txt -Encoding utf8

Get-WmiObject -Class Win32_Product | Sort -Property Name | Format-Table -Property Name,
                                                                                  Version,
                                                                                  Vendor |
                                                                                  Out-File systeminfo7.txt -Encoding utf8



Add-Content SystemInformationGrabber.txt -Value "System Information Grabber v1.7.0
PC Name: $env:computername
User's Name: $PC_USER

----------------------------------------


The users/domain/workgroup details are below:
"
Get-Content systeminfo1.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The OS details are below:"
Get-Content systeminfo2a.txt |
Add-Content SystemInformationGrabber.txt
Get-Content systeminfo2b.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The CS details are below:"
Get-Content systeminfo3.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The disk space details are below:"
Get-Content systeminfo4.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The BIOS details are below:"
Get-Content systeminfo5a.txt |
Add-Content SystemInformationGrabber.txt
Get-Content systeminfo5b.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The printer details are below:"
Get-Content systeminfo6.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The details of all installed programs are below:"
Get-Content systeminfo7.txt |
Add-Content SystemInformationGrabber.txt

Add-Content SystemInformationGrabber.txt -Value "========================================
END OF FILE
========================================"



# Email output file
$FROM = ""
$PASS = ""
$CRED = (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ${FROM}, (ConvertTo-SecureString -String ${PASS} -AsPlainText -force))

$SMTP_SERVER = ""
$SMTP_PORT = ""

$SUBJECT = "System Information Grabber v1.7.0 - " + $env:computername + " ($PC_USER)"
$BODY = "Hi there,

All system information for " + $env:computername + " ($PC_USER)" + " is attached as a .txt file to this email.

"
$ATTACH = "SystemInformationGrabber.txt"

Send-MailMessage -From ${FROM} -To ${TO} -Subject ${SUBJECT} -Body ${BODY} -Attachments ${ATTACH} -SmtpServer ${SMTP_SERVER} -Port ${SMTP_PORT} -Priority High -Credential ${CRED}



#Beeps
[System.Console]::beep(262, 500) 
[System.Console]::beep(262, 500) 



# Prompt to clear tracks
Read-Host -Prompt "
========================================

Press Enter to close this window & to remove all tracks"



# Clear tracks
rm *.xml
rm *.txt
cd ..
rm SystemInformationGrabber
