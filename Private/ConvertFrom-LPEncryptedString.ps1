<#
.Synopsis
   Returns the plaintext for an AES-encrypted string from the LastPass vault
.DESCRIPTION
   Uses the decryption key from the user's password to AES decrypt their vault
   entires. Returns the unencrytped string.
.EXAMPLE
   ConvertFrom-LPEncryptedString -String $String
#>
function ConvertFrom-LPEncryptedString
{
    [CmdletBinding()]
    Param(
        # The encrypted string to decrypt
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [String]
        $String
    )

    Begin
    {
        if (!$LPKeys)
        {
            Invoke-LPLogin | Out-Null
        }
        $KeyBytes = $Encoding.GetBytes($LPKeys.GetNetworkCredential().Password)
    }
    Process
    {
        if (($String[0] -eq '!') -and (($String.Length % 16) -eq 1) -and ($String.Length -gt 32))
        {
            Write-Verbose "Decrypting using AES"
            $StringBytes = $Encoding.GetBytes($String)
            $AES = New-Object -TypeName "System.Security.Cryptography.AesManaged"
            $AES.Key = $KeyBytes
            $AES.IV = $StringBytes[1..16]
            $Decryptor = $AES.CreateDecryptor()
            $PlainBytes = $Decryptor.TransformFinalBlock($StringBytes,17,$($StringBytes.Length-17))
            $String = $Encoding.GetString($PlainBytes)
        }

        $String
    }
}