<#
.SYNOPSIS
Registers a watcher for the folder specified in the parameter $Directory. This directory is then watched
for new files, which then are moved as specified in the $Configuration HashTable

.PARAMETER Directory
The directory to watch for new files

.PARAMETER Configuration
A HashTable containing the information which file name pattern should be moved to which folder

.EXAMPLE
Set-DownloadWatcher -Directory C:\Users\Me\Downloads -Configuration @{ 
        abc = "D:\dir\files";
        bcd = "D:\dir\morefiles"
    }
#>
function Set-DownloadWatcher {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        $Directory,

        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        $ConfigFile,

        [Parameter(Mandatory = $false)]
        $IncludeSubDirs=$false
    )

    process {
        # Get the configuration from the supplied JSON file
        $configuration = @{}
        $tmp = Get-Content $ConfigFile | ConvertFrom-Json

        # ..and convert it to a HashTable to work with later
        $tmp.psobject.properties | ForEach-Object { $configuration[$_.Name] = $_.Value }

        # Wrap the data that should be passed to the callback function
        $messageData = @{
            fileToPathMapping = $configuration
        }

        $watcher = New-Object IO.FileSystemWatcher $Directory -Property @{ 
            IncludeSubdirectories = $IncludeSubDirs
            NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
        }
        
        try {
            # The ErrorAction is important here - if not set, the default error handling strategy ("Continue") would apply
            # and therefore, an ugly error would be visible in the console
            # s.a. https://blogs.technet.microsoft.com/heyscriptingguy/2015/09/16/understanding-non-terminating-errors-in-powershell/
            Unregister-Event -SourceIdentifier FileCreated -ErrorAction Stop
        }
        catch [System.ArgumentException] {
            Write-Host "Could not remove subscription." -BackgroundColor "Magenta"
        }

        Register-ObjectEvent $watcher Created -SourceIdentifier FileCreated -MessageData $messageData -Action {
            Write-Host "Captured new event!"
            
            $path = $Event.SourceEventArgs.FullPath
            $name = $Event.SourceEventArgs.Name
            $changeType = $Event.SourceEventArgs.ChangeType
            $timeStamp = $Event.TimeGenerated
            Write-Host "The file '$name' was $changeType at $timeStamp"
        
            $Event.MessageData.fileToPathMapping.GetEnumerator() | ForEach-Object {
                if ($name -match $_.key) {
                    Write-Host "Found match: '$name' contains" $_.key". Moving it to " $_.value -BackgroundColor "Cyan"
                    # TODO: Check if destination exists and is a path
                    Move-Item -Path $path -Destination $_.value
                    break
                }
            }
        }
    }
}

Export-ModuleMember -Function Set-DownloadWatcher