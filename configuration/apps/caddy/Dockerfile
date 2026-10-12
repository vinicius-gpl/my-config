# Caddy com o plugin de DNS da Cloudflare (desafio ACME DNS-01).
# Necessário para emitir certificados de hosts que resolvem para o IP da VPN
# e, portanto, não são alcançáveis pela Let's Encrypt via HTTP.
FROM caddy:2.9-builder AS builder
RUN xcaddy build --with github.com/caddy-dns/cloudflare

FROM caddy:2.9
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
