# VarbiAPI
<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
    * [Built With](#built-with)
* [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Installation](#installation)
* [Usage](#usage)
* [Changelog](#Changelog)
* [Roadmap](#roadmap)
* [License](/License)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project
This module was created to make user provisioning to the Varbi system as easy as possible.
It was also created in a way that other organizations can utilize it.

### Built With
* [Powershell](https://docs.microsoft.com/en-us/powershell/)
* [VSCode](https://code.visualstudio.com/)
* [Varbi API documentation](https://api.varbi.com/)

<!-- GETTING STARTED -->
## Getting Started
There are a few steps you need to complete before you can start using the cmdlets in this module.
Please make sure you've followed each one.

### Prerequisites
* Powershell 5.1
* Licensed version of Varbi to get access to the API.
* API key and a service account provided by the vendor.

### Installation
1. Start a powershell session with the account that will be running the tasks. This is because when doing steps 4 & 5, the credential files will only be readable by the very same account that created them.
2. `Install-Module -Name VarbiAPI`
3. `Import-Module -Name VarbiAPI`. You will get a warning saying that there is no settings file present, but let's skip this for now.
4. `New-Secret` See [New-Secret.md](/Resources/SecretClixml/Docs/New-Secret.md) for examples.
5. Run `Initialize-SettingsFile`. See [Initialize-SettingsFile.md](Docs/Initialize-SettingsFile.md) for examples.
6. Finally import the module again `Import-Module VarbiAPI -Force`. And you should be good to go!

## Changelog
`VarbiAPI` is currently only maintained by me. I will try to add as many features as possible.
- ## 2022.03.03 - Version: 0.0.1.4
    - New public cmdlets:
        - [x] [Clear-VarbiUser](Docs/Clear-VarbiUser.md)
    - New private functions:
        - `Get-SyncData`
            - Handles data sent from `Sync-VarbiFromADGroup` and returns a structured object with information on what needs to be done regarding the synchronization.
        - `Write-CMTLog`
            - Writes logs from `Sync-VarbiFromADGroup` in a format that [CMTrace](https://www.microsoft.com/en-us/download/details.aspx?id=50012) reads really well.
        - `Write-StartEndLog`
            - Writes starting and ending point in the log file
    - Various edits to `Sync-VarbiFromADGroup`, `Update-VarbiUser` and `Format-APICall`
- ## 2022.02.28 - Version: 0.0.1.3
    - New public cmdlets:
        - [x] [Sync-VarbiFromADGroup](Docs/Sync-VarbiFromADGroup.md)
    - New private functions:
        - `Compare-Object`
            - A proxy function for the built-in Compare-Object cmdlet, created by [DBremen](https://github.com/DBremen)
    - Various fixes in cmdlets and functions.
- ## 2022.02.22 - Version: 0.0.1.2
    - New public cmdlets:
        - [x] [Update-VarbiUser](Docs/Update-VarbiUser.md)
        - [x] [Disable-VarbiUser](Docs/Disable-VarbiUser.md)
        - [x] [Enable-VarbiUser](Docs/Enable-VarbiUser.md)
    - New private functions:
        - `ConvertFrom-ADObject`
            - Converts an AD user object into json prepared object with all the right properties.
    - New nested module:
        - [x] [SecretClixml](/Resources/SecretClixml/)
            - Used to encrypt and store the API key aswell as retrieving it.
- ## 2022.02.17 - Version: 0.0.1.1
    - New public cmdlets:
        - [x] [Initialize-SettingsFile](Docs/Initialize-SettingsFile.md)
    - New private functions:
        - `Get-FilePath`
            - Used in conjunction with `Initialize-SettingsFile` to prompt user for storing settings file and loading credential file.
        - `Format-UsedParameter`
            - Takes data and formats it accordingly
        - `Format-APICall`
            - Formats all properties into a splatted object to be used by `Invoke-VarbiAPI`
- ## 2022.02.07 - Version: 0.0.1.0
    - Created this repository, first commit.
    - Available but not entirely finished public cmdlets:
        - [x] [Get-VarbiUser](Docs/Get-VarbiUser.md)
        - [x] [New-VarbiUser](Docs/New-VarbiUser.md)
    - Kind of finished private functions:
        - `Invoke-VarbiAPI`
            - Sort of the heart of it all. Every public function calls this one with it's formatted request string.
        - `Get-EncryptedAPIKey`
            - Retrieves the encrypted API key. Needs to be run under the same context as when it was stored.

<!-- USAGE EXAMPLES -->
## Usage

[See cmdlet docs](/Docs/)

<!-- ROADMAP -->
## Roadmap

 - [x] Adding compability for working with datasource
 - [x] Improve error message handling

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements
[Varbi](https://varbi.com) for great API documentation.