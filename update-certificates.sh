# check if running as root, if not become root
if [ "$(id -u)" -ne 0 ]; then
    echo "Not running as root, trying to become root..."
    exec sudo "$0" "$@"
    exit 0
fi

# check if the file is downloadable from https://step.fritz.box/certs/root_ca.crt   and download it to /usr/local/share/ca-certificates as new_root_ca.crt
if curl -s --head  --request GET https://step.fritz.box/certs/root_ca.crt | grep "200 OK" > /dev/null; then
    echo "File is downloadable"
    curl -o /usr/local/share/ca-certificates/new_root_ca.crt https://step.fritz.box/certs/root_ca.crt
    # check if the new file is different from the old one
    if ! cmp -s /usr/local/share/ca-certificates/new_root_ca.crt /usr/local/share/ca-certificates/root_ca.crt; then
        echo "File is different"
        # update the certificate
        cp /usr/local/share/ca-certificates/new_root_ca.crt /usr/local/share/ca-certificates/root_ca.crt
        update-ca-certificates
    else
        echo "File is the same"
    fi
    # remove the new file
    rm /usr/local/share/ca-certificates/new_root_ca.crt
else
    echo "File is not downloadable"
fi
