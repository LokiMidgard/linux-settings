# check if the file is downloadable from https://step.fritz.box/certs/root_ca.crt   and download it to /usr/local/share/ca-certificates as new_root_ca.crt
if curl -fsSL --head --insecure --request GET https://step.fritz.box/certs/root_ca.crt | grep "HTTP/2 200" > /dev/null; then
    echo "Zertifikat https://step.fritz.box/certs/root_ca.crt ist herunterladbar."
    sudo curl -fsSL --insecure -o /usr/local/share/ca-certificates/new_root_ca.crt https://step.fritz.box/certs/root_ca.crt
    # check if the new file is different from the old one
    if ! cmp -s /usr/local/share/ca-certificates/new_root_ca.crt /usr/local/share/ca-certificates/root_ca.crt; then
        echo "Neues Zertifikat unterscheidet sich von /usr/local/share/ca-certificates/root_ca.crt. Zertifikat wird aktualisiert."
        # update the certificate
        sudo cp /usr/local/share/ca-certificates/new_root_ca.crt /usr/local/share/ca-certificates/root_ca.crt
        sudo update-ca-certificates
    else
        echo "Neues Zertifikat ist identisch mit /usr/local/share/ca-certificates/root_ca.crt. Keine Aktualisierung notwendig."
    fi
    # remove the new file
    sudo rm /usr/local/share/ca-certificates/new_root_ca.crt
else
    echo "Zertifikat https://step.fritz.box/certs/root_ca.crt konnte nicht heruntergeladen werden."
fi
