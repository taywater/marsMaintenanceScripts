#This script is a wrapper that executes a few other scripts. It is to be used as a scheduled task.
import datetime, os, subprocess, webbrowser, re

#Since it's not going to be run in interactive mode, we need to load PYTHONSTARTUP 
if os.path.isfile(os.environ['PYTHONSTARTUP']):
	execfile(os.environ['PYTHONSTARTUP'])
else:
	sys.exit("You don't have a .pythonrc file in your PYTHONSTARTUP environment variable.")

#Note regarding filepath separators: In order to represent a literal '\', we must type \\ (an escaped \)
#However, when specifying file paths that will be read by the R command, we must type \\\\
#Because specifying \\ in the Python script will cause R to see \, and it will choke on the singleton \ just like Python would

###Section 1: Generate execution parameters

###Section 2: Run the R script that will generate the updates for the database
#We'll be calling this R script from within this python script
#We'll be composing a string that will be sent to the command line via a subprocess

current_date = datetime.datetime.now()
datestring = current_date.strftime("%Y%m%dT%H%M")

#The R script that we'll be executing has runtime parameters that we will be setting in this script
#Note: r_script, database, and output_file are wrapped in single quotes because the resultant R command expects them to be string literals
#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
r_script = "'" + re.sub('\\\\', '\\\\\\\\',MAINTENANCEFOLDER) + "\\\\mars_backup\\\\mars_backup.rmd'"
database = "'mars_testing'"
output_file = "'output\\\\" + datestring + "_mars_backup.html" + "'"

#Where is the R executable?
#Note: This filepath is used by Python and CMD.EXE, and thus needs \\ as a separator (CMD.EXE doesn't choke on singleton \)
r_exe = "Rscript.exe"


#Compose the R command that will be passed to r_exe
r_command = "rmarkdown::render(" + r_script + ", params = list(database=" + database + ")" + ", output_file =" + output_file + ")"

#Invoke the R commands to run the script and knit the output
# -e means Rscript.exe is getting the commands from stdin and not from a file
#More info: https://www.rdocumentation.org/packages/utils/versions/3.5.1/topics/Rscript
subprocess.call([r_exe, "-e", r_command])

#Open the output file in your web browser
outputexists = os.path.isfile(MAINTENANCEFOLDER + "\\mars_backup\\" + re.sub('\\\\\\\\', '\\\\', output_file.strip("'")))
if outputexists:
	webbrowser.open(os.path.realpath(MAINTENANCEFOLDER + "\\mars_backup\\" + re.sub('\\\\\\\\', '\\\\', output_file.strip("'"))))
else:
	webbrowser.open(os.path.realpath(MAINTENANCEFOLDER + "\\mars_backup\\backup_error.html"))