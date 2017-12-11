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
        [Parameter(Mandatory=$false)]
        $Directory = "C:\Users\max\Downloads\test",

        [Parameter(Mandatory=$false)]
        $Configuration = @{ 
            abc = "C:\Users\max\Downloads\test\a";
            bcd = "C:\Users\max\Downloads\test\b"
        }
    )

    process {
        # Wrap the data that should be passed to the callback function
        $messageData = @{
            hashtable = $Configuration;
            something = "abcsdasdfsaf"
        }

        $watcher = New-Object IO.FileSystemWatcher $Directory -Property @{ 
            IncludeSubdirectories = $false
            NotifyFilter          = [IO.NotifyFilters]'FileName, LastWrite'
        }

        # Unregister any existing event subscriptions
        Unregister-Event -SourceIdentifier FileCreated

        Register-ObjectEvent $watcher Created -SourceIdentifier FileCreated -MessageData $messageData -Action {
            Write-Host "Captured new event!"
            
            $path = $Event.SourceEventArgs.FullPath
            $name = $Event.SourceEventArgs.Name
        
            $Event.MessageData.hashtable.GetEnumerator() | ForEach-Object {
                Write-Host "---->" $_.key
                Write-Host "---->" $_.value
                if ($name -match $_.key) {
                    Write-Host "Found match - '$name' contains $_.key"
                    Move-Item -Path $path -Destination $_.value
                }
            }
        
            $changeType = $Event.SourceEventArgs.ChangeType
            $timeStamp = $Event.TimeGenerated
            Write-Host "The file '$name' was $changeType at $timeStamp"
            Write-Host $path
            #Move-Item $path -Destination $destination -Force -Verbose
        }
    }
}

Export-ModuleMember -Function Set-DownloadWatcher