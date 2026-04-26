#!/bin/bash
set -euo pipefail

RUN_MEDIA=false
RUN_SSL=false
RUN_VUETORRENT=false
RUN_ALL=true

while [[ $# -gt 0 ]]; do
    case "$1" in
        --media|-m)
            RUN_MEDIA=true
            RUN_ALL=false
            shift
            ;;
        --ssl|-s)
            RUN_SSL=true
            RUN_ALL=false
            shift
            ;;
        --vuetorrent|-v)
            RUN_VUETORRENT=true
            RUN_ALL=false
            shift
            ;;
        --all|-a)
            RUN_ALL=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [flags]"
            echo ""
            echo "Flags (combine as needed):"
            echo "  --media, -m      Create media folder structure"
            echo "  --ssl, -s        Setup Jellyfin SSL certificate"
            echo "  --vuetorrent, -v Install VueTorrent WebUI for qBittorrent"
            echo "  --all, -a        Run all steps (default if no flags given)"
            echo "  --help, -h       Show this help"
            exit 0
            ;;
        *)
            echo "Unknown flag: $1"
            echo "Use --help for usage"
            exit 1
            ;;
    esac
done

run_media() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Setting up media folders..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    MEDIA_FOLDERS=(
        "media/downloads"
        "media/movies"
        "media/music"
        "media/shows"
    )

    for folder in "${MEDIA_FOLDERS[@]}"; do
        if [ ! -d "$folder" ]; then
            mkdir -p "$folder"
            echo "  ✓ Created: $folder"
        else
            echo "  ○ Already exists: $folder"
        fi
    done
    echo ""
}

run_ssl() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Jellyfin SSL Certificate Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    SSL_DIR="./config/jellyfin/ssl"
    SSL_CERT="$SSL_DIR/jellyfin.pfx"

    mkdir -p "$SSL_DIR"

    read -p "Do you have an existing .pfx certificate file? (y/n): " has_cert

    if [[ "$has_cert" =~ ^[Yy]$ ]]; then
        echo ""
        echo "  ℹ Please copy your .pfx file to:"
        echo "    $SSL_CERT"
        echo ""
        echo "  Make sure the file is named 'jellyfin.pfx'"
        echo "  inside the ssl folder."
        echo ""
    else
        echo ""
        echo "  Generating a self-signed certificate..."

        read -sp "  Enter a password for the .pfx file: " cert_pass
        echo ""

        openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
            -keyout "$SSL_DIR/jellyfin.key" \
            -out "$SSL_DIR/jellyfin.crt" \
            -subj "/C=BR/ST=Sao Paulo/L=Sao Paulo/O=Jellyfin/CN=jellyfin.local" \
            &>/dev/null

        openssl pkcs12 -export -out "$SSL_CERT" \
            -inkey "$SSL_DIR/jellyfin.key" \
            -in "$SSL_DIR/jellyfin.crt" \
            -passout pass:"$cert_pass" \
            &>/dev/null

        rm -f "$SSL_DIR/jellyfin.key" "$SSL_DIR/jellyfin.crt"

        echo ""
        echo "  ✓ Self-signed certificate created at:"
        echo "    $SSL_CERT"
        echo ""
        echo "  ⚠ Password saved nowhere — remember it."
    fi
    echo ""
}

run_vuetorrent() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  VueTorrent WebUI Setup"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    VUETORRENT_DIR="./config/qbittorrent/vuetorrent"

    if [ -d "$VUETORRENT_DIR/.git" ]; then
        echo "  VueTorrent already cloned. Checking for updates..."
        cd "$VUETORRENT_DIR"
        git pull
        cd - > /dev/null
        echo "  ✓ Updated to latest version"
    else
        echo "  Cloning VueTorrent..."
        rm -rf "$VUETORRENT_DIR"
        git clone --single-branch --branch latest-release \
            https://github.com/VueTorrent/VueTorrent.git "$VUETORRENT_DIR"
        echo "  ✓ VueTorrent cloned to:"
        echo "    $VUETORRENT_DIR"
    fi
    echo ""
}

if $RUN_ALL; then
    RUN_MEDIA=true
    RUN_SSL=true
    RUN_VUETORRENT=true
fi

$RUN_MEDIA && run_media
$RUN_SSL && run_ssl
$RUN_VUETORRENT && run_vuetorrent

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"