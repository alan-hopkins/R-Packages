% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BDS_Box_Chg.R
\name{BDS_Box_Chg}
\alias{BDS_Box_Chg}
\title{BDS_Box_Chg}
\usage{
BDS_Box_Chg(treatmentname, useshortnames = c(TRUE, FALSE), oldnames, newnames,
  usepopflag = c(TRUE, FALSE), popflag, testname, yaxislabel, selectedvisits,
  perpage, dignum, inputdirectory, outputdirectory, testfilename,
  filetype = c("PNG", "TIFF", "JPEG"), pixelwidth, pixelheight,
  outputfontsize, charttitle)
}
\arguments{
\item{treatmentname}{Which treatment arm variable? e.g."TRTA" #TRTA, TRTP, etc}

\item{useshortnames}{Rename Treatment Arms? (if you wish to display shorter names).TRUE OR FALSE}

\item{oldnames}{Treatment Arms old names .e.g "Xanomeline Low Dose","Xanomeline High Dose"}

\item{newnames}{Treatment Arms new names .e.g "X-low", "X-High"}

\item{usepopflag}{subset on a population flag. TRUE OR FALSE}

\item{popflag}{value "SAFFL"}

\item{testname}{test or parameter to be analyzed e.g."DIABP"}

\item{yaxislabel}{labels for y axis}

\item{selectedvisits}{visit numbers to be analyzed e.g 0,2,4,6,8,12,16,20,24}

\item{perpage}{how many visits to display per page}

\item{dignum}{number of digits in table, standard deviation = dignum +1}

\item{inputdirectory}{set input file directory}

\item{outputdirectory}{set output file directory}

\item{testfilename}{accepts CSV or XPT files}

\item{filetype}{output file type - TIFF or JPEG or PNG}

\item{pixelwidth}{choose output file size: pixel width}

\item{pixelheight}{choose output file size: pixel height}

\item{outputfontsize}{choose output font size}

\item{charttitle}{Title for the chart}
}
\value{
Figure 7.2 Box plot - Change from Baseline by Analysis Timepoint, Visit and Treatment
}
\description{
Create a boxplot for PhUSE
}
\examples{
BDS_Box_Chg(treatmentname = "TRTA", useshortnames = TRUE, oldnames = c("Xanomeline Low Dose","Xanomeline High Dose"), newnames = c("X-low", "X-High"), usepopflag = TRUE, popflag = "SAFFL", testname = "DIABP", yaxislabel = "Change in Diastolic Blood Pressure (mmHG)",selectedvisits = c(0,2,4,6,8,12,16,20,24), perpage = 6, dignum = 1, inputdirectory = "R:/StatOpB/CSV/9_GB_PhUSE/phuse-scripts/data/adam/cdisc",outdirectory = "U:/github", testfilename = "advs.xpt",filetype = "PNG", pixelwidth = 1200, pixelheight = 1000, outputfontsize = 16, charttitle = "Box")

}

