setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("_master.R")

# ── Teste rápido de leitura dos 3 inputs ──────────────────────

# IPCA
ipca <- readxl::read_xlsx(file.path(pasta_input, "ipca_sidra_1737.xlsx"))
names(ipca) <- c("data", "mes", "valor")
ipca$data <- as.Date(ipca$data)
ipca <- ipca %>%
  filter(!is.na(data), !is.na(valor),
         data >= DATA_INICIAL, data <= DATA_FINAL) %>%
  mutate(data = as.Date(format(data, "%Y-%m-01")))
cat("IPCA:", nrow(ipca), "obs |", format(min(ipca$data)), "a", format(max(ipca$data)), "\n")

# Câmbio
cambio_raw <- read.csv2(file.path(pasta_input, "cambio_sgs_3698.csv"),
                        quote = "\"", stringsAsFactors = FALSE)
names(cambio_raw) <- c("data", "valor")
cambio_raw$data  <- as.Date(cambio_raw$data, format = "%d/%m/%Y")
cambio_raw$valor <- as.numeric(gsub(",", ".", cambio_raw$valor))
cambio <- cambio_raw %>% filter(data >= DATA_INICIAL, data <= DATA_FINAL)
cat("Câmbio:", nrow(cambio), "obs |", format(min(cambio$data)), "a", format(max(cambio$data)), "\n")

# Selic
selic_raw <- read.csv2(file.path(pasta_input, "selic_sgs_432.csv"),
                       stringsAsFactors = FALSE)
names(selic_raw) <- c("data", "valor")
selic_raw$data  <- as.Date(selic_raw$data, format = "%d/%m/%Y")
selic_raw$valor <- as.numeric(gsub(",", ".", selic_raw$valor))
selic_raw <- selic_raw %>% filter(!is.na(data), !is.na(valor))
selic_raw$mes <- format(selic_raw$data, "%Y-%m-01")
selic <- selic_raw %>%
  group_by(mes) %>%
  summarise(valor = last(valor), .groups = "drop") %>%
  mutate(data = as.Date(mes)) %>%
  filter(data >= DATA_INICIAL, data <= DATA_FINAL) %>%
  dplyr::select(data, valor)
cat("Selic:", nrow(selic), "obs |", format(min(selic$data)), "a", format(max(selic$data)), "\n")

# ── Plot rápido ───────────────────────────────────────────────
par(mfrow = c(3, 1), mar = c(3, 4, 2, 1))
plot(ipca$data, log(ipca$valor), type = "l", col = "#1f4e79",
     main = "log(IPCA-índice)", ylab = "")
plot(cambio$data, log(cambio$valor), type = "l", col = "#1f4e79",
     main = "log(Câmbio R$/US$)", ylab = "")
plot(selic$data, selic$valor, type = "l", col = "#1f4e79",
     main = "Selic meta (% a.a.)", ylab = "")

cat("\n✓ Todos os inputs lidos com sucesso.\n")

# ── Base alinhada ─────────────────────────────────────────────

df <- Reduce(function(a, b) merge(a, b, by = "data", all = FALSE),
             list(
               data.frame(data = ipca$data,   ipca_indice = ipca$valor),
               data.frame(data = cambio$data,  cambio      = cambio$valor),
               data.frame(data = selic$data,   selic       = selic$valor)
             ))
