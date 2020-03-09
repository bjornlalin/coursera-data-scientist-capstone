#
# Build model and store it into two files (for unigrams and ngrams)
#

library(dplyr)
library(stringi)
library(stringr)
library(data.table)
library(quanteda)

setwd("/Users/mooc/Documents/coursera-data-scientist/10-capstone-project/model")

# Load training data
lines_blogs <- readLines("../data/final/en_US/en_US.blogs.txt", encoding = "UTF8")
lines_news <- readLines("../data/final/en_US/en_US.news.txt", encoding = "UTF8")
lines_twitter <- readLines("../data/final/en_US/en_US.twitter.txt", encoding = "UTF8")

# generate a random sample and merge into a unified dataset
fraction <- 0.02
sample_blogs <- sample(lines_blogs, length(lines_blogs) * fraction)
sample_news <- sample(lines_news, length(lines_news) * fraction)
sample_twitter <- sample(lines_twitter, length(lines_twitter) * fraction)
sample <- c(sample_blogs, sample_news, sample_twitter)

# Convert to a data frame to make it easier to apply string operations using dplyr
df.sample <- data.frame(sample, sapply(sample, function(line) stri_count_words(line)), row.names = NULL)
colnames(df.sample) = c('text', 'nwords')

# Make all text to lower, only keep alphanumerics, remove extranous whitespace
df.sample <- df.sample %>%
  mutate(text = tolower(text)) %>%
  mutate(text = str_replace_all(text, "[0-9]+", "")) %>%
  mutate(text = str_replace_all(text, "[^a-z0-9 ]+", "")) %>%
  mutate(text = str_replace_all(text, " +", " ")) %>%
  mutate(text = str_replace_all(text, "^ +", "")) %>%
  mutate(text = str_replace_all(text, " +$", ""))

# This generation of a data structure to use for the project using data.table and quanteda
# was inspired by a question on the quanteda website:
#
# https://github.com/quanteda/quanteda/issues/923
#

unigrams.data.table <- function(corpus) {
  dfm_unigrams <- dfm(corpus)
  dt_unigrams <- data.table(unigram = featnames(dfm_unigrams), keep.rownames = F, stringsAsFactors = F)
  dt_unigrams[, frequency := colSums(dfm_unigrams)]
  
  return (dt_unigrams)
}

ngrams.data.table <- function(corpus, min=2, max=4) {
  # Generate all requested ngrams
  tokens_ngrams <- tokens_ngrams(corpus, n = min:max)
  
  # Convert to a Document-Feature-Matrix
  dfm_ngrams <- dfm(tokens_ngrams)
  
  # Generate a data table with h|w (base, prediction) and information needed to calculate
  dt_ngrams <- data.table(ngram = featnames(dfm_ngrams), keep.rownames = F, stringsAsFactors = F)
  dt_ngrams[, base := strsplit(ngram, "_[^_]+$")[[1]], by = ngram]
  dt_ngrams[, prediction := tstrsplit(ngram, paste(base, "_", sep = ""), fill = '_', 
                                      fixed = T, keep=2)[[1]], by = ngram]
  dt_ngrams[, ngramsize := length(strsplit(ngram, "_")[[1]]), by = ngram]
  dt_ngrams[, frequency := colSums(dfm_ngrams)]
  # We don't need this anymore
  dt_ngrams[, ngram := NULL]

  return (dt_ngrams)
}

# Tokenize the data using quanteda
corpus <- tokens(df.sample$text, what = "word",
                 remove_numbers = T, 
                 remove_punct = T, 
                 remove_symbols = T, 
                 remove_separators = T,
                 split_hyphens = T, 
                 remove_url = T)

# Generate the unigrams and ngrams
unigram_model = unigrams.data.table(corpus)
ngram_model = ngrams.data.table(corpus)

fwrite(unigram_model, "../final/app/data/model.unigrams.csv")
fwrite(ngram_model, "../final/app/data/model.ngrams.csv")
