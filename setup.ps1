# input
$serverName=$args[0]
$userName=$args[1]
$hostAddr=$args[2]
$hostPort=$args[3]
echo "Your Args: $serverName $userName $hostAddr $hostPort"

# windows dirs
$key_fp="$HOME\.ssh\id_rsa-remote-ssh"

if (!(Test-Path $key_fp)) {
  echo "Generating SSH key. Press Enter multiple times"
  New-Item -ItemType Directory -Force -Path "$HOME\.ssh"
  ssh-keygen -t rsa -b 4096 -f $key_fp
} else {
  echo "Using exist SSH-key..."
}

$conf = @"
Host $serverName
 User $userName
 HostName $hostAddr
 Port $hostPort
 IdentityFile $key_fp
"@

$conf_fp="$HOME\.ssh\config"

if (!(Test-Path $conf_fp)) {
  New-Item -ItemType File -Force -Path $conf_fp
  Set-Content -Force -Path $conf_fp -Value $conf
} else {
  Add-Content -Force -Path $conf_fp -Value $conf
}

$USER_AT_HOST="$userName@$hostAddr"
$PUBKEYPATH="$key_fp.pub"

# DBG:
# echo $conf
# echo $USER_AT_HOST $PUBKEYPATH
# ssh -p $hostPort $USER_AT_HOST


$pubKey=(Get-Content "$PUBKEYPATH" | Out-String);
  ssh -p "$hostPort" "$USER_AT_HOST" "
    mkdir -p ~/.ssh && chmod 700 ~/.ssh &&
    echo '${pubKey}' >> ~/.ssh/authorized_keys &&
    chmod 600 ~/.ssh/authorized_keys"
  
