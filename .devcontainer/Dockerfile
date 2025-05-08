# --- Final Stage ---
FROM --platform=linux/amd64 debian:bookworm-slim AS final

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
ARG HOME=/home/${USERNAME}

ENV SHELL=/bin/zsh

# Unikaj ostrzeżeń, przełączając się na tryb noninteractive
ARG DEBIAN_FRONTEND=noninteractive

# Instalacja podstawowych zależności i narzędzi
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    curl \
    wget \
    git \
    unzip \
    xz-utils \
    zip \
    sudo \
    zsh \
    ca-certificates \
    nano \
    build-essential \
    pkg-config \
    # Czyszczenie
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Stwórz użytkownika non-root
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m -s /bin/zsh ${USERNAME} \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

USER ${USERNAME}
WORKDIR ${HOME}