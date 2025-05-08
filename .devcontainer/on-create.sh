#!/bin/bash
set -e # Natychmiastowe zakończenie w przypadku błędu

echo "Rozpoczynanie skryptu on-create dla Node.js/React..."

# Zapewnienie dostępności USERNAME i USER_HOME
USERNAME="${USERNAME:-$(whoami)}"
USER_HOME="/home/$USERNAME"

# Aktywacja nvm (Node Version Manager), jeśli został zainstalowany przez funkcję Node.js
# To zapewnia, że polecenia nvm, node, npm są dostępne w tym skrypcie.
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    \. "$NVM_DIR/nvm.sh"
    echo "NVM załadowany."
else
    echo "Ostrzeżenie: Skrypt nvm.sh nie został znaleziony w $NVM_DIR."
fi

# Sprawdzenie wersji Node i npm
echo "Wersja Node.js po załadowaniu NVM:"
node -v || echo "Polecenie 'node' nie znalezione."
echo "Wersja npm:"
npm -v || echo "Polecenie 'npm' nie znalezione."

# Instalacja Oh My Zsh (jeśli nie istnieje)
if [ ! -d "$USER_HOME/.oh-my-zsh" ]; then
    echo "Instalowanie Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    echo "Oh My Zsh jest już zainstalowany."
fi

# Instalacja motywu Powerlevel10k dla Oh My Zsh (jeśli nie istnieje)
P10K_DIR="$USER_HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
    echo "Instalowanie motywu Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
    echo "Motyw Powerlevel10k jest już zainstalowany."
fi

# Klonowanie dotfiles (twoje repozytorium)
DOTFILES_REPO_URL="https://github.com/jmcjm/dotfiles-devcontainers.git"
DOTFILES_DIR="$USER_HOME/dotfiles-devcontainers"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Klonowanie dotfiles z $DOTFILES_REPO_URL..."
    git clone "$DOTFILES_REPO_URL" "$DOTFILES_DIR"
else
    echo "Katalog dotfiles już istnieje. Pobieranie najnowszych zmian..."
    (cd "$DOTFILES_DIR" && git pull)
fi

# Tworzenie linków symbolicznych dla plików konfiguracyjnych
echo "Konfigurowanie Zsh, Oh My Zsh i nano..."

# Link dla .zshrc
# Oh My Zsh tworzy plik .zshrc. Zastąpimy go linkiem symbolicznym.
if [ -f "$USER_HOME/.zshrc" ] && ! [ -L "$USER_HOME/.zshrc" ]; then
    echo "Tworzenie kopii zapasowej istniejącego .zshrc do .zshrc.pre-dotfiles"
    mv "$USER_HOME/.zshrc" "$USER_HOME/.zshrc.pre-dotfiles"
fi
# Usuń, jeśli istnieje niepoprawny link symboliczny
if [ -L "$USER_HOME/.zshrc" ] && [ "$(readlink "$USER_HOME/.zshrc")" != "$DOTFILES_DIR/zshrc" ]; then
    rm "$USER_HOME/.zshrc"
fi
# Utwórz link symboliczny
if [ ! -L "$USER_HOME/.zshrc" ]; then
    echo "Tworzenie linku symbolicznego dla .zshrc..."
    ln -sf "$DOTFILES_DIR/zshrc" "$USER_HOME/.zshrc"
else
    echo "Link symboliczny .zshrc już istnieje."
fi

# Link dla .p10k.zsh
if [ -f "$USER_HOME/.p10k.zsh" ] && ! [ -L "$USER_HOME/.p10k.zsh" ]; then
    echo "Tworzenie kopii zapasowej istniejącego .p10k.zsh do .p10k.zsh.pre-dotfiles"
    mv "$USER_HOME/.p10k.zsh" "$USER_HOME/.p10k.zsh.pre-dotfiles"
fi
if [ -L "$USER_HOME/.p10k.zsh" ] && [ "$(readlink "$USER_HOME/.p10k.zsh")" != "$DOTFILES_DIR/p10k.zsh" ]; then
    rm "$USER_HOME/.p10k.zsh"
fi
if [ ! -L "$USER_HOME/.p10k.zsh" ]; then
    echo "Tworzenie linku symbolicznego dla .p10k.zsh..."
    ln -sf "$DOTFILES_DIR/p10k.zsh" "$USER_HOME/.p10k.zsh"
else
    echo "Link symboliczny .p10k.zsh już istnieje."
fi

# Link dla konfiguracji nano (.nanorc)
if [ -f "$USER_HOME/.nanorc" ] && ! [ -L "$USER_HOME/.nanorc" ]; then
    echo "Tworzenie kopii zapasowej istniejącego .nanorc do .nanorc.pre-dotfiles"
    mv "$USER_HOME/.nanorc" "$USER_HOME/.nanorc.pre-dotfiles"
fi
if [ -L "$USER_HOME/.nanorc" ] && [ "$(readlink "$USER_HOME/.nanorc")" != "$DOTFILES_DIR/nanorc" ]; then
    rm "$USER_HOME/.nanorc"
fi
mkdir -p "$USER_HOME/.config/nano" # Alternatywna lokalizacja konfiguracji nano
if [ ! -L "$USER_HOME/.nanorc" ]; then
    echo "Tworzenie linku symbolicznego dla .nanorc..."
    ln -sf "$DOTFILES_DIR/nanorc" "$USER_HOME/.nanorc"
else
    echo "Link symboliczny .nanorc już istnieje."
fi

# Pobieranie pfetch
if [ ! -f "$USER_HOME/pfetch" ]; then
    echo "Pobieranie pfetch..."
    curl -sS https://raw.githubusercontent.com/dylanaraps/pfetch/master/pfetch > "$USER_HOME/pfetch"
    chmod +x "$USER_HOME/pfetch"
else
    echo "pfetch już istnieje."
fi

# Animacja onboardingu
if command -v task &> /dev/null && [ -f "${WORKSPACE_ROOT}/Taskfile.yml" ]; then
    echo "Uruchamianie animacji onboardingu..."
    export TERM=xterm-256color
    cd "${WORKSPACE_ROOT}"
    task onboarding | while IFS= read -r line; do
        for (( i=0; i<${#line}; i++ )); do
            echo -n "${line:$i:1}"
            sleep 0.003
        done
        echo
    done
else
    echo "Polecenie 'task' lub plik Taskfile.yml nie został znaleziony w ${WORKSPACE_ROOT}. Pomijanie animacji onboardingu."
fi

echo "Skrypt on-create dla Node.js/React zakończony."