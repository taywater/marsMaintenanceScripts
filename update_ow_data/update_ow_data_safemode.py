#This script is a wrapper that executes a few other scripts. It is to be used as a scheduled task.
import datetime, os, subprocess, webbrowser

#Note: A:\ is \\pwdoows\oows\Watershed Sciences\GSI Monitoring\07 Databases and Tracking Spreadsheets\13 MARS Analysis Database
#It's mapped to a drive letter because certain Windows services can't handle non letter-mapped paths

#Note regarding filepath separators: In order to represent a literal '\', we must type \\ (an escaped \)
#However, when specifying file paths that will be read by the R command, we must type \\\\
#Because specifying \\ in the Python script will cause R to see \, and it will choke on the singleton \ just like Python would

###Section 1: Set execution parameters
#Date string for filenames.
current_date = datetime.datetime.now()
datestring = current_date.strftime("%Y%m%dT%H%M")

###Section 2: Run the R script that will generate the updates for the database
#We'll be calling this R script from within this python script
#We'll be composing a string that will be sent to the command line via a subprocess

#The R script that we'll be executing has runtime parameters that we will be setting in this script
#Note: r_script, database, and output_file are wrapped in single quotes because the resultant R command expects them to be string literals
#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
r_script = "'A:\\\\Scripts\\\\Maintenance\\\\update_ow_data\\\\update_ow_data.rmd'"
database = "'mars_testing'"
writeflag = "FALSE"
output_file = "'output\\\\" + datestring + "_update_ow_data.html" + "'"

#Where is the R executable?
#Note: This filepath is used by Python and CMD.EXE, and thus needs \\ as a separator (CMD.EXE doesn't choke on singleton \)
r_exe = "Rscript.exe"

#Compose the R command that will be passed to r_exe
r_command = "rmarkdown::render(" + r_script + ", params = list(database=" + database + ", write=" + writeflag + ")" + ", output_file =" + output_file + ")"

#Invoke the R commands to run the script and knit the output
# -e means Rscript.exe is getting the commands from stdin and not from a file
#More info: https://www.rdocumentation.org/packages/utils/versions/3.5.1/topics/Rscript
subprocess.call([r_exe, "-e", r_command])

#Open the output file in your web browser
webbrowser.open(os.path.realpath('A:\\Scripts\\Maintenance\\update_ow_data\\' + output_file.strip("'")))