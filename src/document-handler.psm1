<#
.SYNOPSIS
Registers a watcher for the folder specified in the parameter $Directory. This directory is then watched
for new files, which then are moved as specified in the $Configuration HashTable

.PARAMETER Directory
The directory to watch for new files

.PARAMETER Configuration
A HashTable containing the information which file name pattern should be moved to which folder

.EXAMPLE
Set-DownloadWatcher -Directory C:\Users\max\Downloads
#>
function Set-DownloadWatcher {
    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $true)]
        $Directory,

        [Parameter(Mandatory = $true)]
        $Configuration
    )

    process {
        # Wrap the data that should be passed to the callback function
        $messageData = @{
            hashtable = $Configuration
        }

        $watcher = New-Object IO.FileSystemWatcher $Directory -Property @{ 
            IncludeSubdirectories = $false
            NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
        }
        
        try {
            Unregister-Event -SourceIdentifier FileCreated
        }
        catch [System.ArgumentException] {
            Write-Host "Could not remove subscription." -BackgroundColor "Green"
        }

        Register-ObjectEvent $watcher Created -SourceIdentifier FileCreated -MessageData $messageData -Action {
            Write-Host "Captured new event!"
            
            $path = $Event.SourceEventArgs.FullPath
            $name = $Event.SourceEventArgs.Name
            $changeType = $Event.SourceEventArgs.ChangeType
            $timeStamp = $Event.TimeGenerated
            Write-Host "The file '$name' was $changeType at $timeStamp"
        
            $Event.MessageData.hashtable.GetEnumerator() | ForEach-Object {
                if ($name -match $_.key) {
                    Write-Host "Found match: '$name' contains" $_.key -BackgroundColor "Blue"
                    Move-Item -Path $path -Destination $_.value
                    break
                }
            }
        }
    }
}

Export-ModuleMember -Function Set-DownloadWatcher