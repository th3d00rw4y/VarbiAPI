---
external help file: SecretClixml-help.xml
Module Name: SecretClixml
online version:
schema: 2.0.0
---

# New-Secret

## SYNOPSIS
Saves a secret into a XML file.

## SYNTAX

```
New-Secret [-Name] <String> [-Path] <String> [[-Username] <String>] [-Secret] <SecureString> [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This CMDlet will save either a PSCredential (username and password) or just a SecureString into an encrypted cliXML file.
The exported cliXML file will only be readable on the very same computer it was generated on and by the user doing the export.

## EXAMPLES

### EXAMPLE 1
```powershell
# This example will save the cliXML file to C:\TMP\Secrets.
New-Secret -Name "MyServiceAccountSecret" -Path "C:\TMP\Secrets" -Username "MyServiceAccount"
# The file will be named "MyServiceAccountSecret.crd" and contain both the username and an encrypted string of the secret.
```

### EXAMPLE 2
```powershell
# This example will save the cliXML file to C:\TMP\Secrets.
New-Secret -Name 'MySecretAPIKey' -Path "C:\TMP\Secrets"
# The file will be named "MySecretAPIKey.crd" and contain only an encrypted string of the secret.
```

## PARAMETERS

### -Name
String provided here will be used to name the file.
The filename will also be given the current user- and computer name running the action.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Where the encrypted cliXML file will be stored.
If the directory does not exist, it will be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Username
Username to be used in conjunction with the secret.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Secret
The actual secret.
Saved into a SecureString and masked in the console.

```yaml
Type: SecureString
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Simon Mellergård | IT-avdelningen, Värnamo kommun

## RELATED LINKS
