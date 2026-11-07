# `claude` abre pelo Agent Vault quando a VPN, o keyring e o proxy estão ok (ver __agent_vault).
function claude --wraps claude --description 'claude pelo Agent Vault, se disponível'
    __agent_vault claude $argv
end
