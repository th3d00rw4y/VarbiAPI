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
4. `New-Secret -Name <Name of the file> -Path <Path to store the secret> -Username <The API service account username>` You will be prompted to enter the password for the service account.
5. `New-Secret -Name <Name of the API key secret file> -Path <Path to store the secret>` You will once again be prompted to enter a password, which in this case would be the API key.
6. Run `Initialize-SettingsFile`. See /Docs/Initialize-SettingsFile.md for examples.
7. Finally import the module again `Import-Module VarbiAPI -Force`. And you should be good to go!

## Changelog
`VarbiAPI` is currently only maintained by me. I will try to add as many features as possible.
- ## 2022.02.07 - Version: 0.0.1.0
    - Created this repository, first commit.
    - Available but not entirely finished public functions:
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