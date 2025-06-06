library(dplyr)
library(readr)
library(stringr)

# Set working directory
#setwd("C:\\Users\\sapta\\Documents\\GitHub\\AakritiGenomics")

# Read mapping file
map <- readr::read_tsv("assets\\RVDCdataset\\Clinical\\ViralChallenge_training_CLINICAL.tsv", col_types = cols())

# Convert TIMEHOURS to integer
map <- map %>%
  mutate(TIMEHOURS = as.integer(TIMEHOURS))

# Build CEL-to-Metadata dictionary
cel_to_meta <- map %>%
  mutate(Key = paste(STUDYID, SUBJECTID, TIMEHOURS, sep = "|")) %>%
  select(CEL, Key)

cel_dict <- setNames(cel_to_meta$Key, cel_to_meta$CEL)

# Read expression data
expr <- read_tsv("assets\\RVDCdataset\\Expression\\ViralChallenge_training_EXPRESSION_RMA.tsv", col_types = cols())

genes <- expr$FEATUREID
study_list <- unique(map$STUDYID)

# Loop over studies
for (study in study_list) {
  
  study_list_data <- list()  
  subjects <- unique(map$SUBJECTID[map$STUDYID == study])
  
  for (subject in subjects) {
    
    times <- sort(unique(map$TIMEHOURS[map$STUDYID == study & map$SUBJECTID == subject]))
    
    expr_matrix <- matrix(NA, nrow = length(times), ncol = length(genes))
    rownames(expr_matrix) <- times
    colnames(expr_matrix) <- genes
    
    for (j in 2:ncol(expr)) {  
      cel <- colnames(expr)[j]
      
      if (cel %in% names(cel_dict)) {
        meta_parts <- unlist(strsplit(cel_dict[[cel]], "\\|"))
        if (meta_parts[1] == study && meta_parts[2] == subject) {
          time_hours <- as.integer(meta_parts[3])
          time_row <- which(times == time_hours)
          
          expr_vals <- expr[[j]]
          expr_matrix[time_row, ] <- expr_vals
        }
      }
    }
    
    subject_data <- as.data.frame(expr_matrix)
    subject_data <- cbind(Time = times, subject_data)
    rownames(subject_data) <- NULL

    study_list_data[[as.character(subject)]] <- subject_data
  }
  
  save(study_list_data, file = paste0("Study_", study, ".RData"))
}

cat("RData files created\n")

