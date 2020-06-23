#pkg
library(data.table)

#get list of folders
grep("word", list.files("./input_data/"), value = T)[1]

#get list of files
list.files(paste0("./input_data/", 
                  grep("word", list.files("./input_data/"), value = T)[1]))

#read in data 
read.delim(
  paste0(
    paste0("./input_data/", 
           grep("word", list.files("./input_data/"), value = T)[1]),"/",
    list.files(paste0("./input_data/", 
                      grep("word", list.files("./input_data/"), value = T)[1]))[1]
  ), header = F
)

#set up txt var
txt <- as.character(NA)

#set up final dt
final <- data.table()

#looooooop
for(i in grep("word", list.files("./input_data/"), value = T)[c(17:23,2,3)]) {
  print(i)
  for(j in grep(".txt", list.files(paste0("./input_data/", i)), value = T)){
    print(j)
    txt <- read.delim(
      paste0("./input_data/", 
             i,"/",j
      ), header = F, stringsAsFactors = F
    )
    final <- rbind(final, data.table(Initials = rep("GC", nrow(txt)), 
                                     Folder = rep(i, nrow(txt)),
                                     File = rep(j, nrow(txt)),
                                     `Subject Number` = rep(gsub(".txt","",j), nrow(txt)),
                                     `Start Date` = rep("",nrow(txt)),
                                     `Completion Date` = rep("",nrow(txt)),
                                     Cue = as.vector(txt),
                                     Answer = rep("", nrow(txt))
    )
    )
  }
}

colnames(final)[7] <- "Cue"

View(final)

fwrite(final, "./input_data/gc_ALL_DATA.csv", sep = ",", quote = F)