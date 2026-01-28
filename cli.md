```bash
ssh -L 1433:127.0.0.1:1433 user@SEU_SERVIDOR
docker ps --format "table {{.Names}}\t{{.Ports}}