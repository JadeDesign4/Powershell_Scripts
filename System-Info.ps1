# Hw to get system information using PowerShell

Write-Output ""
Write-Output "------Os Information------"
Get-WmiObject -Class Win32_OperatingSystem

Write-Output "------Processor Information------"
Write-Output ""
Get-WmiObject -Class Win32_Processor

Write-Output "------DiskDrive Info------"
Write-Output ""
Get-WmiObject -Class Win32_DiskDrive

Write-Output "------LogicalDisk Info------"
Write-Output ""
Get-WmiObject -Class Win32_LogicalDisk
