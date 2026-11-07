# Roda o comando dentro do Agent Vault quando dá: VPN Azuos (wt0) de pé, token de sessão no keyring e
# proxy do ops respondendo. Senão, roda direto e avisa o motivo. Usado pelas funções `claude` e `ai-memory`.
function __agent_vault --description 'Roda o comando pelo proxy do Agent Vault, se disponível'
    set -l proxy 100.85.128.74:17323
    set -l sessao
    set -l motivo
    if set -q INFISICAL_AGENT_VAULT_SESSION_TOKEN
        # Já dentro de um `agent-vault run`: não abre outro.
        command $argv
        return
    else if not ip link show wt0 >/dev/null 2>&1
        set motivo 'VPN Azuos (wt0) desconectada'
    else if not set sessao (secret-tool lookup service infisical-agent-vault account claude-code 2>/dev/null)
        set motivo 'sem token de sessão no keyring'
    else if not timeout 2 bash -c "echo > /dev/tcp/"(string replace : / $proxy) 2>/dev/null
        set motivo "proxy $proxy fora do ar"
    end

    if test -n "$motivo"
        echo "agent-vault: $motivo, abrindo sem ele" >&2
        command $argv
        return
    end

    INFISICAL_AGENT_VAULT_SESSION_TOKEN=$sessao infisical agent-vault run --proxy $proxy \
        --no-proxy api.anthropic.com,claude.ai,statsig.anthropic.com,sentry.io \
        -- (command -s $argv[1]) $argv[2..]
end
