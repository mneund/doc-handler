# Doc-Handler

This is a simple tool I wrote for myself, which is capable of covering the following scenario:

I have quite a lot of files, which have to be downloaded to my PC from time to time. Some bank statements, invoices or other stuff, that has a predefined target folder somewhere on my system. Point is, I'm not really keen on either first downloading them to my default folder and sorting them afterwards, nor on navigating to the target directory for each single download. Therefore, this `psm` can do the following:

It reads a configuration from an configuration file in JSON format, observes the directory you tell him, and then moves incoming files according to the configuration.

## Example

```
config.json
{
    "bank1": "D:\\files\\bank1",
    "bank2": "D:\\files\\bank2",
    "telekom": "D:\\files\\mobilfunk"
}
```

```
Set-DownloadWatcher -Directory C:\Users\myself\Downloads -ConfigFile config.json
```

will move all files with the substring "bank1" to the specified folder automatically.

## Running Tests

For being able to run the tests, please ensure to run

```
Install-Module -Name Pester -Force -SkipPublisherCheck
```

first.