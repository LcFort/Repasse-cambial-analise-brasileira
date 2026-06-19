# ---------- Trabalho II de Macroeconometria ----------
## Aluno: Guilherme Santos de Carvalho e Lucas Fortuna Arantes Junqueira
## Objetivo: Facilitar a inicialização do código de maneira central
## Maio, 2026
# ---------- Professora Susan Schommer ----------

# ============================================================
# Diretório raiz do projeto
# ============================================================
# Detecta automaticamente a partir do diretório do script
# Caso falhe, defina manualmente abaixo

if (exists("pasta_central") == FALSE) {
  # Tenta detectar via rstudioapi se disponível
  if (requireNamespace("rstudioapi", quietly = TRUE) &&
      rstudioapi::isAvailable()) {
    pasta_central <- dirname(dirname(
      rstudioapi::getActiveDocumentContext()$path
    ))
  } else {
    # Fallback: diretório atual sobe um nível
    pasta_central <- dirname(getwd())
  }
}

# Cria caminhos das pastas subjacentes
pasta_code   <- file.path(pasta_central, "code")
pasta_input  <- file.path(pasta_central, "input")
pasta_output <- file.path(pasta_central, "output")
pasta_tmp    <- file.path(pasta_central, "tmp")
pasta_misc   <- file.path(pasta_central, "misc")

# Cria pastas de saída se não existirem
for (p in c(pasta_output, pasta_tmp)) {
  if (!dir.exists(p)) dir.create(p, recursive = TRUE)
}

# ============================================================
# Pacotes
# ============================================================
libs <- c(
  "dplyr", "readxl", "ggplot2", "knitr",  # dados e visualização
  "urca", "vars", "tseries",              # VAR, VECM, ADF, Johansen
  "forecast",                              # auto.arima (opcional)
  "lmtest",                                 # coeftest
  "tinytex"
)

quiet_load <- function(pkg) {
  ok <- suppressPackageStartupMessages(
    require(pkg, character.only = TRUE, quietly = TRUE,
            warn.conflicts = FALSE)
  )
  if (!ok) {
    message("Instalando pacote '", pkg, "'...")
    install.packages(pkg, quiet = TRUE)
    ok <- suppressPackageStartupMessages(
      require(pkg, character.only = TRUE, quietly = TRUE,
              warn.conflicts = FALSE)
    )
  }
  if (!ok) message("Pacote '", pkg, "' falhou ao carregar.")
  invisible(ok)
}
#remove.packages("tinytex")
#install.packages("tinytex", repos = "https://cloud.r-project.org")
#tinytex::install_tinytex(bundle = "TinyTeX")
lapply(libs, quiet_load)

# ============================================================
# Parâmetros do trabalho
# ============================================================
DATA_INICIAL <- as.Date("2003-01-01")
DATA_FINAL   <- as.Date("2025-12-01")

# Ordenação Cholesky — item 5 do enunciado
# Câmbio reage primeiro (mercado financeiro); IPCA reage com
# defasagem (pass-through gradual); Selic reage por último (Copom)
ORDEM_ECON <- c("log_cambio", "log_ipca_indice", "selic")
ORDEM_CONT <- c("selic", "log_ipca_indice", "log_cambio")

HORIZONTE_IR <- 24   # meses para impulso-resposta
N_BOOT       <- 500  # replicações bootstrap para bandas de IR

cat("✓ _master.R carregado | Raiz:", pasta_central, "\n")
