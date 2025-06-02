#! /usr/bin/env bash

CONFIG_DIR="$HOME/.config/k9s"
PLUGINS_DIR="$CONFIG_DIR/plugins"
SOURCE=https://raw.githubusercontent.com/derailed/k9s/refs/heads/master/plugins

# hide k9s logo
sed -i"" "s/logoless: false/logoless: true/g" "$CONFIG_DIR/config.yaml"

mkdir -p "$PLUGINS_DIR"

PLUGINS=(
    debug-container
    dive
    external-secrets
    flux
    job-suspend
    remove-finalizers
    watch-events
)

printf '%s\n' "${PLUGINS[@]}" |
    while read -r PLUGIN; do
        wget -O - "$SOURCE/$PLUGIN.yaml" >"$PLUGINS_DIR/$PLUGIN.yaml"
    done

CUSTOM_PLUGINS=(
    https://raw.githubusercontent.com/code11/public-gists/refs/heads/main/k9s/plugins/flux-gitrepo.yaml
)
printf '%s\n' "${CUSTOM_PLUGINS[@]}" |
    while read -r FILE; do
        wget -O - "$FILE" >"$PLUGINS_DIR/${FILE##*/}"
    done

# Patch ridiculously long names that clutter K9S interface
# Flux
yq eval '.plugins.toggle-helmrelease.description = "Toggle HR"' -i "$PLUGINS_DIR/flux.yaml"
yq eval '.plugins.toggle-kustomization.description = "Toggle KS"' -i "$PLUGINS_DIR/flux.yaml"
yq eval '.plugins.get-suspended-helmreleases.description = "Suspended HR"' -i "$PLUGINS_DIR/flux.yaml"
yq eval '.plugins.get-suspended-kustomizations.description = "Suspended KS"' -i "$PLUGINS_DIR/flux.yaml"
# Remove finalizers
yq eval '.plugins.remove_finalizers.description = "Removes finalizers"' -i "$PLUGINS_DIR/remove-finalizers.yaml"

# Add aliases
yq -i '.aliases.git = "gitrepo"' "$CONFIG_DIR/aliases.yaml"

# SKINS
TMP_DIR=$(mktemp -d /tmp/k9s-skins-XXXXXX)
cd $TMP_DIR
git clone --filter=blob:none --no-checkout https://github.com/derailed/k9s.git .
git sparse-checkout init --no-cone
git sparse-checkout set /skins
git checkout

cp -rf skins $CONFIG_DIR
