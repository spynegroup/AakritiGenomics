
library(dplyr)
library(readr)
library(stringr)


map <- read_tsv("Mapping.tsv", col_types = cols())


colnames(map)[c(1,2,10,12)] <- c("STUDYID", "SUBJECTID", "TIMEHOURS", "CEL")


cel_to_meta <- map %>%
  mutate(Key = paste(STUDYID, SUBJECTID, TIMEHOURS, sep = "|")) %>%
  select(CEL, Key)

cel_dict <- setNames(cel_to_meta$Key, cel_to_meta$CEL)
expr <- read_tsv("Expression.tsv", col_types = cols())
genes <- expr$FEATUREID

study_list <- unique(map$STUDYID)


for (study in study_list) {
  
  study_list_data <- list()  
  
  subjects <- unique(map$SUBJECTID[map$STUDYID == study])
  
  for (subject in subjects) {
    
    times <- unique(map$TIMEHOURS[map$STUDYID == study & map$SUBJECTID == subject])
    times <- sort(times)
    
    expr_matrix <- matrix(NA, nrow = length(genes), ncol = length(times))
    rownames(expr_matrix) <- genes
    colnames(expr_matrix) <- times
    
    
    for (j in 2:ncol(expr)) {  
      
      cel <- colnames(expr)[j]
      
      if (cel %in% names(cel_dict)) {
        meta_parts <- unlist(strsplit(cel_dict[[cel]], "\\|"))
        if (meta_parts[1] == study && meta_parts[2] == subject) {
          time_hours <- meta_parts[3]
          time_col <- which(times == time_hours)
          
          expr_vals <- expr[[j]]
          expr_matrix[, time_col] <- expr_vals
        }
      }
    }
    

    subject_data <- data.frame(FEATUREID = genes, expr_matrix)
    
    study_list_data[[as.character(subject)]] <- subject_data
  }
  

  save(study_list_data, file = paste0("Study_", study, ".RData"))
}

cat("RData files ccreated")