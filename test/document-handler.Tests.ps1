Import-Module -Name $PSScriptRoot\..\src\document-handler.psm1 -Force

$TestDir = $PSScriptRoot+"\tmp"

Describe "Watcher moves files according to configuration" {

    BeforeEach {
        if (Test-Path $TestDir) {
            Remove-Item -Path $TestDir -Recurse
        }
        New-Item -ItemType Directory -Path $TestDir
        New-Item -ItemType Directory -Path $TestDir\a
        New-Item -ItemType Directory -Path $TestDir\b

        Set-DownloadWatcher -Directory $TestDir -ConfigFile $PSScriptRoot\testconfig.json
    }

    AfterEach {
        Remove-Item -Path $TestDir -Recurse
    }

    Context "If new file does not match any pattern" {

        It "Is not moved" {
            # 'testfile' does not have a matching pattern in configuration 
            New-Item -ItemType File -Path $TestDir -Name "testfile"

            # Timeout is needed to make sure the file has been moved in between
            Start-Sleep 1

            $filesInA = Get-ChildItem -Path $TestDir\a -File
            $filesInA.Count | Should Be 0

            $filesInB = Get-ChildItem -Path $TestDir\b -File
            $filesInB.Count | Should Be 0

            $files = Get-ChildItem -Path $TestDir -File
            $files.Count | Should Be 1
        }

    }

    Context "If new file matches pattern" {

        It "Is moved to the configured target folder" {
            # Matches pattern 'abc'
            New-Item -ItemType File -Path $TestDir -Name "testabcjhdsgz"

            Start-Sleep 1

            $filesInA = Get-ChildItem -Path $TestDir\a -File
            $filesInA.Count | Should Be 1

            $filesInB = Get-ChildItem -Path $TestDir\b -File
            $filesInB.Count | Should Be 0

            $files = Get-ChildItem -Path $TestDir -File
            $files.Count | Should Be 0
        }

    }

    Context "If new file matches multiple patterns" {

        It "Is moved to the first configured target folder" {
            # Matches pattern 'abc' and 'bcd'
            New-Item -ItemType File -Path $TestDir -Name "tbcdestabcjhdsgz"

            Start-Sleep 1

            $filesInA = Get-ChildItem -Path $TestDir\a -File
            $filesInA.Count | Should Be 1

            $filesInB = Get-ChildItem -Path $TestDir\b -File
            $filesInB.Count | Should Be 0

            $files = Get-ChildItem -Path $TestDir -File
            $files.Count | Should Be 0
        }

    }

}

Describe "Watcher also watches subdirectories if specified" {

    BeforeEach {
        if (Test-Path $TestDir) {
            Remove-Item -Path $TestDir -Recurse
        }
        New-Item -ItemType Directory -Path $TestDir
        New-Item -ItemType Directory -Path $TestDir\a
        New-Item -ItemType Directory -Path $TestDir\b

        Set-DownloadWatcher -Directory $TestDir -Configuration @{ 
            abc = $TestDir+"\a";
            bcd = $TestDir+"\b"
        } -IncludeSubDirs $true
    }

    AfterEach {
        Remove-Item -Path $TestDir -Recurse
    }

    Context "If file in subdir does match a pattern" {

        It "Is moved" {
            # 'testfile' does not have a matching pattern in configuration
            $testSubDir = $TestDir+"\subdir"
            New-Item -ItemType Directory -Path $testSubDir
            New-Item -ItemType File -Path $testSubDir -Name "testbcdfileInSubDir"

            # Timeout is needed to make sure the file has been moved in between
            Start-Sleep 1

            $filesInA = Get-ChildItem -Path $TestDir\a -File
            $filesInA.Count | Should Be 0

            $filesInB = Get-ChildItem -Path $TestDir\b -File
            $filesInB.Count | Should Be 1

            $files = Get-ChildItem -Path $testSubDir -File
            $files.Count | Should Be 0
        }

    }

}