# `ai-memory run claude-azuos` / `ai-memory run codex-azuos`: abre o agente na conta da Azuos.
# Troca o nome pelo harness real com --env da pasta de config, que o ai-memory repassa ao
# agente e usa para achar sessões, hooks e MCP daquela conta. O resto vai direto ao binário.
# O `run` passa pelo Agent Vault quando a VPN, o keyring e o proxy estão ok (ver __agent_vault).
function ai-memory --wraps ai-memory --description 'ai-memory com os launchers *-azuos e o Agent Vault'
    if test "$argv[1]" != run
        command ai-memory $argv
        return
    end

    set -l args
    for a in $argv
        switch $a
            case claude-azuos
                set -a args --env CLAUDE_CONFIG_DIR=$HOME/.claude-azuos claude
            case codex-azuos
                set -a args --env CODEX_HOME=$HOME/.codex-azuos codex
            case '*'
                set -a args $a
        end
    end
    __agent_vault ai-memory $args
end
