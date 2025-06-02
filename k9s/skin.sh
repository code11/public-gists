#! /usr/bin/env bash

CONFIG_DIR="$HOME/.config/k9s"
SKINS_DIR="$CONFIG_DIR/skins"

THEME=$(find $SKINS_DIR -type f -name "*.yaml" | xargs -I {} basename {} | sort -r | fzf)

yq -i ".k9s.ui.skin = \"${THEME%.*}\"" "$CONFIG_DIR/config.yaml"

