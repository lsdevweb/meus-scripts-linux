#!/bin/bash

# Este script realiza um log diário de monitoramento e auditoria do sistema.
# Ele foi projetado para ser executado com sudo.
# Pode monitorar o sistema geral ou um usuário específico.

# Variável para armazenar o caminho do arquivo de log, se desejado
# LOG_FILE="/var/log/log_diario_$(date +%Y%m%d_%H%M%S).log" # Exemplo: log em /var/log
LOG_FILE="" # Deixe vazio para imprimir apenas no terminal (padrão)

# --- Função para gravar no log e/ou exibir no terminal ---
log_message() {
    local message="$1"
    echo "$message"
    if [ -n "$LOG_FILE" ]; then
        echo "$message" >> "$LOG_FILE"
    fi
}

# Função para exibir um cabeçalho padronizado
print_header() {
    log_message "================================================"
    log_message "  $1"
    log_message "================================================"
}

# --- Funções de Auditoria e Monitoramento do Sistema ---

# Função: Verificar Instalações e Atualizações
audit_instalacoes_atualizacoes() {
    print_header "Auditoria: Instalações e Atualizações"

    log_message "\n--- Verificando Novas Instalações de Pacotes (apt history - últimas 10) ---"
    sudo grep "install " /var/log/apt/history.log | tail -n 10 || log_message "Nenhuma instalação recente encontrada."

    log_message "\n--- Verificando Atualizações Pendentes (apt list --upgradable) ---"
    sudo apt update 2>/dev/null # Silencia erros de update para focar no "list"
    local upgradable_packages=$(sudo apt list --upgradable 2>/dev/null | grep -v "Listing")
    if [ -n "$upgradable_packages" ]; then
        log_message "$upgradable_packages"
    else
        log_message "Nenhuma atualização pendente."
    fi
}

# Função: Monitoramento de Rede e IP
monitor_rede_ip() {
    print_header "Monitoramento: Rede e IP"

    log_message "\n--- Conexões de Rede Ativas (Sockets Abertos - Sistema Global) ---"
    sudo ss -tuln # tcp, udp, listening, numeric (ports)

    log_message "\n--- Endereços IP das Interfaces de Rede ---"
    ip a | grep -E 'inet\b|link/ether' # Filtra apenas linhas com IP e MAC

    log_message "\n--- Tabela de Rotas de Rede ---"
    ip r

    log_message "\n--- Testando Conectividade Externa (Google DNS - 3x ping) ---"
    ping -c 3 8.8.8.8 || log_message "Falha ao pingar 8.8.8.8. Verifique sua conexão com a internet."
}

# Função: Auditoria de Segurança
audit_seguranca() {
    print_header "Auditoria: Segurança"

    log_message "\n--- Usuários Atualmente Logados ---"
    who

    log_message "\n--- Tentativas de Login Falhas (últimas 20 linhas do auth.log) ---"
    sudo tail -n 20 /var/log/auth.log | grep "Failed password" || log_message "Nenhuma tentativa de login falha recente encontrada."

    log_message "\n--- Verificando Serviços Ativos e Escutando Portas (Top 10) ---"
    sudo netstat -tulnp 2>/dev/null | head -n 10 || log_message "Netstat não disponível ou nenhum serviço escutando."

    log_message "\n--- Checando Permissões '777' em Diretórios Importantes ---"
    sudo find /var/www /tmp /opt -type d -perm 777 -ls 2>/dev/null || log_message "Nenhum diretório com permissão 777 encontrado em /var/www, /tmp, /opt."

    log_message "\n--- Últimos Usos de 'sudo' (Últimas 10 linhas do auth.log) ---"
    sudo grep "COMMAND=" /var/log/auth.log | tail -n 10 || log_message "Nenhum uso recente de sudo encontrado."
}

# Função: Monitoramento de Recursos do Sistema
monitor_recursos_sistema() {
    print_header "Monitoramento: Recursos do Sistema"

    log_message "\n--- Espaço em Disco (Geral) ---"
    df -h

    log_message "\n--- Uso de Memória ---"
    free -h

    log_message "\n--- Carga do Sistema e CPUs ---"
    uptime
    nproc
}

# --- Função de Monitoramento Específico do Usuário ---
monitor_usuario_especifico() {
    local USUARIO_ALVO="$1"

    if [ -z "$USUARIO_ALVO" ]; then
        log_message "Erro: Nenhum usuário especificado para monitoramento."
        log_message "Uso: $0 [nome_do_usuario_para_monitorar]"
        return 1
    fi

    print_header "Monitoramento do Usuário: $USUARIO_ALVO"

    # Verifica se o diretório home do usuário existe
    if [ ! -d "/home/$USUARIO_ALVO" ]; then
        log_message "Diretório home de '$USUARIO_ALVO' não encontrado. Verifique se o usuário existe ou o caminho."
        return 1
    fi

    # Executa comandos no contexto do usuário alvo
    sudo -u "$USUARIO_ALVO" /bin/bash -l -c "
        printf '\n--- Diretorio atual (como $USUARIO_ALVO): %s\n' \"\$(pwd)\"

        printf '\n--- Últimos Comandos de $USUARIO_ALVO (Últimas 20) ---\n'
        if [ -f \"/home/$USUARIO_ALVO/.bash_history\" ]; then
            tail -n 20 \"/home/$USUARIO_ALVO/.bash_history\"
        else
            printf 'Arquivo .bash_history não encontrado ou sem permissão.\n'
        fi

        printf '\n--- Uso de Disco do Diretorio Home de $USUARIO_ALVO ---\n'
        du -sh \"/home/$USUARIO_ALVO\"

        printf '\n--- Processos do Usuário $USUARIO_ALVO (Top 5 por uso de CPU) ---\n'
        ps -u $USUARIO_ALVO -o pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 6
    "
}

# --- Meus Comandos Diários Personalizados (Auditoria/Verificação) ---
meus_comandos_diarios() {
    print_header "Meus Comandos Diários Automatizados"

    log_message "\n--- Listando arquivos recentes em /tmp (últimos 5) ---"
    ls -lht /tmp | head -n 6 || log_message "Nenhum arquivo recente em /tmp."

    log_message "\n--- Verificando status do serviço Apache2 (se instalado) ---"
    systemctl status apache2.service 2>/dev/null | head -n 5 || log_message "Serviço Apache2 não encontrado ou não está rodando."

    # Adicione mais comandos de auditoria/verificação que você executa diariamente
    # log_message "\n--- Hash MD5 do arquivo de configuração do Nginx ---"
    # sudo md5sum /etc/nginx/nginx.conf 2>/dev/null || log_message "Arquivo nginx.conf não encontrado."
}

# --- Lógica Principal do Script ---

# Verifica se o script está sendo executado com sudo.
if [ "$EUID" -ne 0 ]; then
    echo "Este script precisa ser executado com sudo."
    echo "Por favor, execute: sudo ./log_diario.sh [nome_do_usuario_para_monitorar]"
    exit 1
fi

# Inicializa o arquivo de log se LOG_FILE não estiver vazio
if [ -n "$LOG_FILE" ]; then
    echo "Iniciando Log Diário em: $LOG_FILE"
    echo "Log iniciado em: $(date)" > "$LOG_FILE"
fi

log_message "Iniciando Log Diário do Sistema - $(date)"

# Chamada das funções principais de auditoria e monitoramento
audit_instalacoes_atualizacoes
monitor_rede_ip
audit_seguranca
monitor_recursos_sistema
meus_comandos_diarios

# Variável para armazenar o usuário alvo, se passado como argumento
USUARIO_PARA_LOGAR="$1"

# Verifica se um nome de usuário foi passado como argumento
if [ -n "$USUARIO_PARA_LOGAR" ]; then
    monitor_usuario_especifico "$USUARIO_PARA_LOGAR"
    log_message "\nLog Diário Concluído! - $(date)"
    log_message "================================================"
    log_message "\nTransicionando para a sessão de '$USUARIO_PARA_LOGAR'..."
    # Tenta fazer a transição para o usuário especificado
    exec su - "$USUARIO_PARA_LOGAR"
else
    log_message "\n--- Nenhum usuário específico para monitorar foi fornecido como argumento. ---"
    log_message "Para incluir o monitoramento de um usuário e logar nele, execute: sudo ./log_diario.sh <nome_do_usuario>"
    log_message "\nLog Diário Concluído! - $(date)"
    log_message "================================================"
fi

# Note: O script não chegará aqui se 'exec su -' for bem-sucedido.
# Se não houver argumento de usuário, ele simplesmente termina.
