# HEADER
# Display:     Figure 7.2 Box plot - Change from Baseline by Analysis Timepoint, Visit and Treatment
# White paper: Central Tendency
# Specs:       https://github.com/phuse-org/phuse-scripts/blob/master/whitepapers/specification/
# Output:      https://github.com/phuse-org/phuse-scripts/blob/master/whitepapers/WPCT/outputs_r/
# Contributors: Jeno Pizarro, Kirsten Burdett


#TESTING and QUALIFICATION:
#DEVELOP STAGE
#10-JAN-2016, adapted from WPCT 7.01.R script
#needs ANCOVA p values in table...

### updated 21-June-2017, Kirsten - converted to an R package


# BDS_Box_Chg
# Kirsten Burdett







#' BDS_Box_Chg
#' 
#' Create a boxplot for PhUSE
#' 
#' @export
#' @data  data frame
#' @param treatmentname Which treatment arm variable? e.g."TRTA" #TRTA, TRTP, etc
#' @param useshortnames  Rename Treatment Arms? (if you wish to display shorter names).TRUE OR FALSE
#' @param oldnames Treatment Arms old names .e.g "Xanomeline Low Dose","Xanomeline High Dose"
#' @param newnames Treatment Arms new names .e.g "X-low", "X-High"
#' @param usepopflag subset on a population flag. TRUE OR FALSE
#' @param popflag value "SAFFL"
#' @param testname test or parameter to be analyzed e.g."DIABP"
#' @param yaxislabel labels for y axis
#' @param selectedvisits visit numbers to be analyzed e.g 0,2,4,6,8,12,16,20,24
#' @param perpage how many visits to display per page
#' @param dignum number of digits in table, standard deviation = dignum +1
#' @param inputdirectory set input file directory
#' @param outputdirectory set output file directory
#' @param testfilename accepts CSV or XPT files
#' @param filetype output file type - TIFF or JPEG or PNG
#' @param pixelwidth choose output file size: pixel width
#' @param pixelheight choose output file size: pixel height
#' @param outputfontsize choose output font size
#' @param charttitle Title for the chart
#' @return Figure 7.2 Box plot - Change from Baseline by Analysis Timepoint, Visit and Treatment
#' 
#' @examples 
#' BDS_Box_Chg(treatmentname = "TRTA", useshortnames = TRUE, oldnames = c("Xanomeline Low Dose","Xanomeline High Dose"), newnames = c("X-low", "X-High"), usepopflag = TRUE, popflag = "SAFFL", testname = "DIABP", yaxislabel = "Change in Diastolic Blood Pressure (mmHG)",selectedvisits = c(0,2,4,6,8,12,16,20,24), perpage = 6, dignum = 1, inputdirectory = "R:/StatOpB/CSV/9_GB_PhUSE/phuse-scripts/data/adam/cdisc",outdirectory = "U:/github", testfilename = "advs.xpt",filetype = "PNG", pixelwidth = 1200, pixelheight = 1000, outputfontsize = 16, charttitle = "Box")
#' 
#' @import ggplot2
#' @import tools
#' @import gridExtra
#' @import data.table




BDS_Box_Chg<-function(treatmentname,useshortnames = c(TRUE,FALSE),oldnames,newnames,
                       usepopflag = c(TRUE,FALSE),popflag,testname,yaxislabel,selectedvisits,
                       perpage,dignum,inputdirectory,outputdirectory,
                       testfilename,filetype = c("PNG","TIFF","JPEG"),pixelwidth,pixelheight,
                       outputfontsize,charttitle) {

  
  
  #Read in DATASET
  if (file_ext(testfilename) == "csv") {
    testresultsread <- read.csv(file.path(inputdirectory,testfilename))
  } else {
    testresultsread <-
      Hmisc::sasxport.get(file.path(inputdirectory,testfilename), lowernames = FALSE)
  }
  
  #buildtable function to be called later, summarize data to enable creation of accompanying datatable
  buildtable <- function(avalue, dfname, by1, by2, dignum){
    byvarslist <- c(by1,by2)
    summary <- eval(dfname)[,list(
      n = .N,
      mean = round(mean(eval(avalue), na.rm = TRUE), digits=dignum),
      sd = round(sd(eval(avalue), na.rm = TRUE), digits=dignum+1),
      min = round(min(eval(avalue), na.rm = TRUE), digits=dignum),
      q1 = round(quantile(eval(avalue), .25, na.rm = TRUE), digits=dignum),
      mediam = round(median(eval(avalue), na.rm = TRUE), digits=dignum),
      q3 = round(quantile(eval(avalue), .75, na.rm = TRUE), digits = dignum),
      max = round(max(eval(avalue), na.rm = TRUE), digits = dignum)
    ), 
    by = byvarslist]
    
    return(summary)
  }
  
  #SELECT VARIABLES (examples in parenthesis): TREATMENT (TRTP, TRTA), PARAMCD (LBTESTCD)
  #colnames(testresults)[names(testresults) == "OLD VARIABLE"] <- "NEW VARIABLE"
  
  colnames(testresultsread)[names(testresultsread) == treatmentname] <- "TREATMENT"
  
  colnames(testresultsread)[names(testresultsread) == popflag] <- "FLAG" #select population flag to subset on such as SAFFL or ITTFL
  
  if (useshortnames == TRUE){
    for(i in 1:length(oldnames)) {
      testresultsread$TREATMENT <- ifelse(testresultsread$TREATMENT == oldnames[i], as.character(newnames[i]), as.character(testresultsread$TREATMENT))
    }
  }
  
  #determine number of pages needed
  initial <- 1
  visitsplits <- ceiling((length(selectedvisits)/perpage))
  #for each needed page, subset selected visits by number per page
  for(i in 1:visitsplits) {
    
    #subset on test, visits, population to be analyzed
    if (usepopflag == TRUE){
      testresults <- subset(testresultsread, PARAMCD == testname & AVISITN %in% selectedvisits[(initial):
                                                                                                 (ifelse(perpage*i>length(selectedvisits),length(selectedvisits),perpage*i))] 
                            & FLAG == "Y")
      
    } else {
      testresults <- subset(testresultsread, PARAMCD == testname & AVISITN %in% selectedvisits[(initial):(perpage*i)])  
    }
    initial <- initial + perpage
    testresults<- data.table(testresults)
    
    #setkey for speed gains when summarizing
    setkey(testresults, USUBJID, TREATMENT, AVISITN)
    
    #specify plot
    p <- ggplot(testresults, aes(factor(AVISITN), fill = TREATMENT, CHG))
    # add notch, axis labels, legend, text size
    p1 <- p + geom_boxplot(notch = TRUE) + xlab("Visit Number") + ylab(yaxislabel) + theme(legend.position="bottom", legend.title=element_blank(), 
                                                                                           text = element_text(size = outputfontsize),
                                                                                           axis.text.x  = element_text(size=outputfontsize),
                                                                                           axis.text.y = element_text(size=outputfontsize)) +ggtitle(charttitle) 
    # add mean points
    p2 <- p1 + stat_summary(fun.y=mean, colour="dark red", geom="point", position=position_dodge(width=0.75))
    
    # horizontal line at 0
    p3 <- p2 + geom_hline(yintercept = 0, colour = "red")
    
    #call summary table function
    summary <- buildtable(avalue = quote(CHG), dfname= quote(testresults), by1 = "AVISITN", by2 = "TREATMENT", dignum)[order(AVISITN, TREATMENT)]
    table_summary <- data.frame(t(summary))           
    
    t1theme <- ttheme_default(core = list(fg_params = list (fontsize = outputfontsize)))
    t1 <- tableGrob(table_summary, theme = t1theme, cols = NULL) 
    
    if (filetype == "TIFF"){
      #Output to TIFF
      tiff(file.path(outputdirectory,paste("plot",i,".TIFF",sep = "" )), width = pixelwidth, height = pixelheight, units = "px", pointsize = 12)
      grid.arrange(p3, t1, ncol = 1)
      dev.off()
    }
    if (filetype == "JPEG") { 
      # Optionally, use JPEG
      jpeg(file.path(outputdirectory,paste("plot",i,".JPEG",sep = "" )), width = pixelwidth, height = pixelheight, units = "px", pointsize = 12)
      grid.arrange(p3, t1, ncol = 1)
      dev.off()
    }
    if (filetype == "PNG") { 
      # Optionally, use PNG
      png(file.path(outputdirectory,paste("plot",i,".PNG",sep = "" )), width = pixelwidth, height = pixelheight, units = "px", pointsize = 12)
      grid.arrange(p3, t1, ncol = 1)
      dev.off()
    }
    
  }}
  