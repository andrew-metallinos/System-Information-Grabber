 <#
    .SYNOPSIS

        This function can be used to find the basic
        information of a PC device. Once generated
        the information can be emailed to a desired
        address as a .txt attachment.


    .PARAMETERS

        $PATH
            Pathway used where all files will be temporarily stored.
        
        $FROM
            The email address that will be sending the email.

        $PASS
            The password for the email address used above.

        $TO
            Recipient address.

        $PC_NAME
            Name of the device the script runs on.

        $SUBJECT
            Subject of the email.

        $BODY
            Body of the email.

        $ATTACH
            File name to attach to email.


    .NOTES

        Ensure that Less Secure Apps has been turned
        on for the email account being used to send
        the .txt file.
#>



Write-Host "

    ███████╗██████╗░░██████╗░███████╗  ██╗████████╗
    ██╔════╝██╔══██╗██╔════╝░██╔════╝  ██║╚══██╔══╝
    █████╗░░██║░░██║██║░░██╗░█████╗░░  ██║░░░██║░░░
    ██╔══╝░░██║░░██║██║░░╚██╗██╔══╝░░  ██║░░░██║░░░
    ███████╗██████╔╝╚██████╔╝███████╗  ██║░░░██║░░░
    ╚══════╝╚═════╝░░╚═════╝░╚══════╝  ╚═╝░░░╚═╝░░░

    ░██████╗░█████╗░██╗░░░░░██╗░░░██╗████████╗██╗░█████╗░███╗░░██╗░██████╗
    ██╔════╝██╔══██╗██║░░░░░██║░░░██║╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
    ╚█████╗░██║░░██║██║░░░░░██║░░░██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
    ░╚═══██╗██║░░██║██║░░░░░██║░░░██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
    ██████╔╝╚█████╔╝███████╗╚██████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
    ╚═════╝░░╚════╝░╚══════╝░╚═════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


    Title: System Information Grabber
    Author: Andrew Metallinos <andrew@metallinostech.com.au>
    Creation Date: 24/04/2022
    Revision Date: 25/04/2022
    Version: 1.0.0

========================================
"



Write-Host "The users/domain/workgroup details are below:"
Get-ComputerInfo WindowsRegisteredOwner, CsUserName, CsWorkgroup, CsDomain, KeyboardLayout, TimeZone, OsLocalDateTime
        "`n----------------------------------------`n"
Write-Host "The OS details are below: `n"
Get-ComputerInfo OsName, OsArchitecture, OsBuildNumber, OsVersion, OsSerialNumber
        "`n----------------------------------------`n"
Write-Host "The CS details are below: `n"
Get-ComputerInfo CsTotalPhysicalMemory, CsModel, CsManufacturer, CsProcessors, CsNetworkAdapters
        "`n----------------------------------------`n"
Write-Host "The disk space details are below: `n"
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |Measure-Object -Property FreeSpace,Size -Sum |Select-Object -Property Property,Sum
        "`n----------------------------------------`n"
Write-Host "The BIOS details are below: `n"
Get-ComputerInfo BiosManufacturer, BiosVersion
        "`n========================================================================================================================`n"



# Prompt to send email
$TO = Read-Host -Prompt "Enter in an email address you would like to send
all of the above information to and then press ENTER"



# All the files will be saved in this directory
$PATH = "C:\SystemInformationGrabber"
mkdir $PATH
cd $PATH

Get-ComputerInfo WindowsRegisteredOwner, CsUserName, CsWorkgroup, CsDomain, KeyboardLayout, TimeZone, OsLocalDateTime | Out-File systeminfo1.txt -Encoding utf8
Get-ComputerInfo OsName, OsArchitecture, OsBuildNumber, OsVersion, OsSerialNumber | Out-File systeminfo2.txt -Encoding utf8
Get-ComputerInfo CsTotalPhysicalMemory, CsModel, CsManufacturer, CsProcessors, CsNetworkAdapters | Out-File systeminfo3.txt -Encoding utf8
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |Measure-Object -Property FreeSpace,Size -Sum |Select-Object -Property Property,Sum | Out-File systeminfo4.txt -Encoding utf8
Get-ComputerInfo BiosManufacturer, BiosVersion | Out-File systeminfo5.txt -Encoding utf8

Add-Content SystemInformationGrabber.txt -Value "System Information Grabber for the device: $env:computername

----------------------------------------


The users/domain/workgroup details are below:
"
Get-Content systeminfo1.txt | Add-Content SystemInformationGrabber.txt
Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The OS details are below:"
Get-Content systeminfo2.txt | Add-Content SystemInformationGrabber.txt
Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The CS details are below:"
Get-Content systeminfo3.txt | Add-Content SystemInformationGrabber.txt
Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The disk space details are below:"
Get-Content systeminfo4.txt | Add-Content SystemInformationGrabber.txt
Add-Content SystemInformationGrabber.txt -Value "----------------------------------------

The BIOS details are below:"
Get-Content systeminfo5.txt | Add-Content SystemInformationGrabber.txt
Add-Content SystemInformationGrabber.txt -Value "========================================
END OF FILE
========================================"



# Email output file
$FROM = "script.runner.aus@gmail.com"
$PASS = "uncanny8daddy4chicago"
$PC_NAME = "$env:computername"
$SUBJECT = "System Information Grabber - " + $PC_NAME
$BODY = "Hi there,

All system information for " + $PC_NAME + " is attached as a .txt file to this email.

"
$ATTACH = "SystemInformationGrabber.txt"

Send-MailMessage -SmtpServer "smtp.gmail.com" -Port 587 -From ${FROM} -to ${TO} -Subject ${SUBJECT} -Body ${BODY} -Attachment ${ATTACH} -Priority High -UseSsl -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ${FROM}, (ConvertTo-SecureString -String ${PASS} -AsPlainText -force))



# Prompt to clear tracks
Read-Host -Prompt "
----------------------------------------

Press Enter to close this window & to remove all tracks"



# Clear tracks
rm *.xml
rm *.txt
cd ..
rm SystemInformationGrabber
