#!/usr/bin/env bash
# Register a Samsung certificate (made in Certificate Manager) as a signing profile for the
# Tizen CLI. Needed on Linux, where Certificate Manager often fails to save the password files
# and `tizen package` then fails with "Invalid password".
#
# Run it yourself in a terminal: it asks for the certificate password without echoing it,
# so the password never appears on screen, in shell history, or in any chat log.
#
# Usage: scripts/add-cert-profile.sh [CERT_DIR] [PROFILE_NAME]
set -euo pipefail

CERT_DIR="${1:-$HOME/SamsungCertificate/TVLauncher}"
NAME="${2:-ShelfTV}"
TIZEN="$HOME/tizen-studio/tools/ide/bin/tizen"

for f in author.p12 distributor.p12; do
  [[ -f "$CERT_DIR/$f" ]] || { echo "Missing $CERT_DIR/$f"; exit 1; }
done


read -rsp "Certificate password (the one you chose in Certificate Manager): " P; echo
export P  # openssl and the python step read it from the environment, never from argv
# Check the password against the certificate before saving anything.
if ! openssl pkcs12 -in "$CERT_DIR/author.p12" -passin env:P -noout -legacy 2>/dev/null \
   && ! openssl pkcs12 -in "$CERT_DIR/author.p12" -passin env:P -noout 2>/dev/null; then
  echo "That password does not open author.p12. Nothing was changed."; exit 1
fi

# Re-running replaces this script's own profile. Note: the Tizen CLI rewrites profiles.xml and may
# drop other profiles whose .pwd files are missing; the certificate files themselves are never touched.
"$TIZEN" security-profiles remove -n "$NAME" >/dev/null 2>&1 || true
"$TIZEN" security-profiles add -n "$NAME" \
  -a "$CERT_DIR/author.p12" -p "$P" \
  -d "$CERT_DIR/distributor.p12" -dp "$P" >/dev/null

unset P

# Tizen keeps signing passwords in the desktop keyring (Secret Service), using the
# "<cert>.pwd" path in profiles.xml as the keyring label (no file is written). Without a
# working keyring `tizen package` fails with "Invalid password". See docs/04-launcher.md.
KEYTOOL="$HOME/tizen-studio/tools/certificate-encryptor/secret-tool"
for c in author distributor; do
  if ! "$KEYTOOL" lookup --label "$CERT_DIR/$c.pwd" >/dev/null 2>&1; then
    echo "The $c password isn't in the desktop keyring (Secret Service isn't working)."
    echo "On KDE: enable KWallet's Secret Service and create a 'Classic, blowfish' wallet."
    exit 1
  fi
done
"$TIZEN" security-profiles set-active -n "$NAME" >/dev/null
echo "Profile '$NAME' is ready and active."
