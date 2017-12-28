Import-Module -Name $PSScriptRoot\..\src\document-handler.psm1 -Force

$TestDir = $PSScriptRoot+"\tmp"

Describe "Watcher also watches subdirectories if specified" {

    BeforeEach {
        if (Test-Path $TestDir) {
            Remove-Item -Path $TestDir -Recurse
        }
        New-Item -ItemType Directory -Path $TestDir
        New-Item -ItemType Directory -Path $TestDir\a
        New-Item -ItemType Directory -Path $TestDir\b

        Add-DirectoryOberserver -Directory $TestDir -ConfigFile $PSScriptRoot\testconfig.json -IncludeSubDirs $true
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