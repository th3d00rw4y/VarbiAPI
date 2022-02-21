---
external help file: SecretClixml-help.xml
Module Name: SecretClixml
online version:
schema: 2.0.0
---

# Get-Secret

## SYNOPSIS
Retrieves a saved secret.

## SYNTAX

```
Get-Secret [[-LiteralPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will retrieve a previously saved secret.
Note that the secret will only be readable by the user whom saved it and on the same computer it was saved.

## EXAMPLES

### EXAMPLE 1
```powershell
$Secret = Get-Secret -Path "C:\Secrets\TestAPI_USERNAME-COMPUTERNAME.crd"
```

## PARAMETERS

### -LiteralPath
Path to secrets file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Simon Mellergård | It-avdelningen, Värnamo kommun

## RELATED LINKS
