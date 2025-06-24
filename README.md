# log_diario.sh: Script de Auditoria e Monitoramento do Sistema Linux

---

## 📝 Descrição

`log_diario.sh` é um script Bash poderoso e flexível projetado para realizar auditorias e monitoramento diário em sistemas Linux. Ele coleta e apresenta informações cruciais sobre a saúde, segurança e atividades do sistema, permitindo que administradores ou usuários avançados identifiquem rapidamente potenciais problemas ou anomalias.

### O que ele monitora:

* **Instalações e Atualizações:** Verifica pacotes recém-instalados e atualizações pendentes.
* **Rede e IP:** Exibe conexões de rede ativas, endereços IP das interfaces e a tabela de rotas.
* **Segurança:** Audita usuários logados, tentativas de login falhas, serviços que escutam portas, permissões `777` em diretórios importantes e o uso recente de `sudo`.
* **Recursos do Sistema:** Monitora o espaço em disco, uso de memória e carga da CPU.
* **Comandos Personalizados:** Inclui uma seção para comandos de auditoria e verificação específicos do seu ambiente.

---

## 🚀 Como Usar

### Pré-requisitos

* **Sistema Operacional:** Linux (testado em distribuições baseadas em Debian/Ubuntu).
* **Privilégios:** Deve ser executado com `sudo`, pois muitos comandos acessam logs e recursos do sistema que exigem permissões de root.
* **Ferramentas:** Certifique-se de que as seguintes ferramentas estejam instaladas no seu sistema: `apt`, `ss`, `ip`, `ping`, `who`, `tail`, `grep`, `netstat`, `find`, `df`, `free`, `uptime`, `nproc`, `systemctl`, `ps`, `du`, `sudo`.

### Instalação

1.  **Clone o repositório** (ou baixe o arquivo `log_diario.sh`):
    ```bash
    git clone [https://github.com/SeuUsuario/SeuRepositorio.git](https://github.com/SeuUsuario/SeuRepositorio.git)
    cd SeuRepositorio
    ```
2.  **Dê permissões de execução** ao script:
    ```bash
    chmod +x log_diario.sh
    ```

### Execução

* **Monitoramento Geral do Sistema:**
    ```bash
    sudo ./log_diario.sh
    ```
    Isso exibirá o relatório de auditoria diretamente no terminal.

* **Monitoramento de Usuário Específico e Transição de Sessão:**
    ```bash
    sudo ./log_diario.sh <nome_do_usuario>
    ```
    (Exemplo: `sudo ./log_diario.sh lu4825`)

    Após gerar o relatório, o script solicitará a **senha do `<nome_do_usuario>`** e, se correta, fará a transição para a sessão desse usuário no terminal atual.

---

## ⚙️ Configuração de Log

Por padrão, a saída do script é exibida no terminal. Para direcionar a saída para um arquivo de log (útil para automação), você pode editar o script `log_diario.sh` e configurar a variável `LOG_FILE` no início.

1.  Abra o script:
    ```bash
    nano log_diario.sh
    ```
2.  Descomente e ajuste a linha `LOG_FILE` (exemplo):
    ```bash
    # LOG_FILE="/var/log/auditoria_diaria/log_diario_$(date +%Y%m%d_%H%M%S).log"
    # Altere para:
    LOG_FILE="/var/log/auditoria_diaria/log_diario_$(date +%Y%m%d_%H%M%S).log"
    ```
    O script criará o diretório `/var/log/auditoria_diaria` e o arquivo de log automaticamente, e definirá as permissões para que seu usuário possa lê-los.

---

## ⏱️ Automação com `cron`

Para agendar a execução automática diária do `log_diario.sh` (por exemplo, todos os dias às 3:00 da manhã), adicione-o ao crontab do `root`. **Lembre-se de configurar o `LOG_FILE` no script** para que a saída seja salva em um arquivo.

1.  Edite o crontab do `root`:
    ```bash
    sudo crontab -e
    ```
2.  Adicione a seguinte linha no final do arquivo:
    ```cron
    0 3 * * * /path/completo/para/seu/log_diario.sh
    ```
    (Substitua `/path/completo/para/seu/log_diario.sh` pelo caminho real, ex: `/home/usuario/SeuRepositorio/log_diario.sh`)

Após a execução automática, você poderá verificar os relatórios em `/var/log/auditoria_diaria/`.

---

## ⚠️ Pontos de Atenção

* **Permissões `777`:** O script alerta sobre diretórios com permissões `777`. Recomenda-se fortemente a correção dessas permissões para evitar riscos de segurança (ex: `/var/www`). Para corrigir, utilize:
    ```bash
    sudo chown -R seu_usuario:www-data /var/www
    sudo find /var/www -type d -exec chmod 755 {} \;
    sudo find /var/www -type f -exec chmod 644 {} \;
    ```
* **Histórico de `sudo`:** A busca por usos de `sudo` em `/var/log/auth.log` pode gerar mensagens sobre "arquivo binário" devido à rotação de logs. Para uma auditoria mais detalhada, considere explorar `journalctl -u sudo` ou ferramentas de auditoria mais avançadas.
* **Customização:** Sinta-se à vontade para expandir a seção `meus_comandos_diarios()` no script para incluir verificações específicas que sejam relevantes para o seu ambiente.

---

## 🤝 Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests para melhorias, novas funcionalidades ou correções de bugs.

---

## 📄 Licença

[Opcional: Ex: Distribuído sob a Licença MIT. Veja `LICENSE` para mais informações.]
