Import-Module -Name ..\src\document-handler.psm1 -Force

Remove-Item -Path C:\Users\max\Downloads\test -Recurse
New-Item -ItemType Directory -Path C:\Users\max\Downloads\test
New-Item -ItemType Directory -Path C:\Users\max\Downloads\test\a
New-Item -ItemType Directory -Path C:\Users\max\Downloads\test\b

Set-DownloadWatcher

Describe "Watcher moves files according to configuration" {

    Context "If new file matches pattern" {

        It "Moves to specified folder" {
            New-Item -ItemType File -Path C:\Users\max\Downloads\test -Name "testfile"
            $files = Get-ChildItem -Path C:\Users\max\Downloads\test\a
            $files.Count | Should Be 0
        }

        It "Moves to specified folder" {
            New-Item -ItemType File -Path C:\Users\max\Downloads\test -Name "testabcjhdsgz"

            $files = Get-ChildItem -Path C:\Users\max\Downloads\test\a
            Write-Host $files | Out-String
            $files.Count | Should Be 1
        }

    }

}