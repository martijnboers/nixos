#!/usr/bin/env -S nix shell nixpkgs#coreutils nixpkgs#bundix nixpkgs#nix-prefetch-github nixpkgs#jq nixpkgs-unstable#yarn-berry_4.yarn-berry-fetcher -c bash

set -e

cd "$(dirname "$0")"  # cd to the script's directory

echo "Retrieving latest glitch-soc/mastodon commit..."
commit="$(curl -SsL 'https://api.github.com/repos/glitch-soc/mastodon/branches/main')"
rev="$(jq -r '.commit.sha' <<<"$commit")"
echo "Latest commit is $rev."

echo
echo "Prefetching glitch-soc/mastodon source..."
hash="$(nix-prefetch-github glitch-soc mastodon --rev $rev | jq -r '.hash')"
echo "Source hash is $hash."

echo
echo "Building source derivation..."
srcdir="$(nix build --no-link --print-out-paths --no-warn-dirty ../..#glitch-soc-source)"
echo "Source derivation is $srcdir."

echo
echo "Generating gemset.nix using built source derivation..."
rm -f gemset.nix
bundix --quiet --lockfile $srcdir/Gemfile.lock --gemfile $srcdir/Gemfile

echo
echo "Generating missing yarn hashes file..."
rm -f missing-hashes.json
yarn-berry-fetcher missing-hashes $srcdir/yarn.lock 2>/dev/null > missing-hashes.json

echo
echo "Prefetching yarn deps..."
yarn_hash="$(yarn-berry-fetcher prefetch "$srcdir/yarn.lock" ./missing-hashes.json 2>/dev/null)"

echo
echo "Generating version_data.nix..."
cat > version_data.nix << EOF
# This file was generated with update.sh.
{
  rev = "$rev";
  hash = "$hash";
  yarnHash = "$yarn_hash";
}
EOF

echo
echo "Done."
