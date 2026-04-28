##### setup #####
# load libraries
## general
library(tidyverse)
library(glue)
library(here)
## data retrieval and preprocessing
library(wordbankr)
library(childesr)
library(quanteda)
library(tmcn)

# load functions
# NOTE: requires scripts folder from https://github.com/mikabr/aoa-pipeline/tree/main/scripts
walk(list.files("scripts", pattern = "*.R$", full.names = TRUE), source)
set.seed(42)

##### data loading #####
target_langs <- c("Dutch",
                  "English (American)", "English (Australian)",
                  "English (British)", "English (Irish)",
                  "German",
                  "Danish", "Norwegian", "Swedish",
                  "Irish",
                  "French (French)", "French (Quebecois)",
                  "Italian",
                  "Spanish (Mexican)", "Spanish (European)",
                  "Spanish (Argentinian)", "Spanish (Peruvian)",
                  "Catalan",
                  "Portuguese (European)",
                  "Croatian", "Czech", "Polish", "Russian",
                  "Turkish",
                  "Hungarian", "Estonian", "Finnish",
                  "Mandarin (Taiwanese)", "Mandarin (Beijing)",
                  "Cantonese",
                  "Hebrew",
                  "Korean",
                  "Japanese")

wb_data <- load_wb_data(target_langs)
uni_lemmas <- map_df(target_langs, extract_uni_lemmas, wb_data)

childes_frequencies <- walk(target_langs, get_token_metrics,
                            list(base = list(compute_count, compute_mlu))) |>
  filter(!is.na(uni_lemma), uni_lemma != "NA") |>
  nest(data = -language) |>
  mutate(data = map(data, transform_counts)) |>
  unnest() |>
  select(language, uni_lemma, tokens, freq, mlu, lexical_category)

write_csv(childes_frequencies, "childes_frequencies.csv")
