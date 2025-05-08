#!/bin/bash
set -e

echo "Rozpoczynanie skryptu post-attach dla Node.js/React..."

# Aktywacja nvm dla bieżącej sesji powłoki, jeśli nie zostało to zrobione przez pliki rc powłoki
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck source=/dev/null
    \. "$NVM_DIR/nvm.sh"
fi

# Wyświetlenie wersji Node/npm
echo "Bieżąca wersja Node.js: $(node -v || echo 'nie zainstalowano')"
echo "Bieżąca wersja npm: $(npm -v || echo 'nie zainstalowano')"

# Możesz tu dodać polecenia, które chcesz uruchomić za każdym razem, np. start serwera deweloperskiego,
# ale zazwyczaj robi się to ręcznie w terminalu VS Code.
# Przykład:
# WORKSPACE_ROOT="/workspaces/$(basename "$PWD")"
# if [ -f "${WORKSPACE_ROOT}/package.json" ]; then
#   echo "Aby uruchomić aplikację, możesz użyć: npm start (w ${WORKSPACE_ROOT})"
# fi

echo "Skrypt post-attach zakończony. Środowisko Node.js/React jest gotowe."