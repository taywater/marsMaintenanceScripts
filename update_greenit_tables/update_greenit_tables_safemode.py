#This script is a wrapper that executes a few other scripts. It is to be used as a scheduled task
import datetime, os, subprocess, webbrowser, re

#this script is not run in interactive mode, so PYTHONSTARTUP must be loaded
if os.path.isfile(os.environ['PYTHONSTARTUP']):
	exec(open(os.environ['PYTHONSTARTUP']).read())
else:
	sys.exit("You do not have a .pythonrc file in your PYTHONSTARTUP environment variable.")

#Note regarding filepath separators: In order to represent a literal '\', we must type \\ (an escaped \)
#However, when specifying file paths that will be read by the R command, we must type \\\\
#Because specifying \\ in the Python script will cause R to see \, and it will choke on the singleton \ just like Python would

###Section 1: Run the R script that will generate the updates for the database
#We'll be calling this R script from within this python script
#We'll be composing a string that will be sent to the command line via a subprocess

#Date srting for filenames
current_date = datetime.datetime.now()
datestring = current_date.strftime("%Y%m%d%T%H%M")

#The R script that we'll be executing has runtime parameters that we will be setting in this script
#Note: r_script, database, password, and output_file are wrapped in single quotes because the resultant R command expects them to be string literals
#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
r_script = "'" + re.sub('\\\\', '\\\\\\\\',MAINTENANCEFOLDER) + "\\\\update_greenit_tables\\\\update_greenit_tables.rmd'"
database = "'mars_data'"
writeflag = "FALSE"
output_file = "'output\\\\" + datestring + "_update_greenit_tables.html" + "'"

#Where is the R executable?
#Note: This filepath will be used by Python and CMD.EXE, and thus needs \\ as separator (CMDE.EXE doesn't choke on singleton \)
r_exe = "Rscript.exe"

#Compoes the R command that will be passed to r_exe
r_command = "rmarkdown::render(" + rscript + ", params = list(database=" + database +", write=" + writeflag + ")" + ", output_file=" + output_file + ")"

print (r_command)

#Invoke the R commands to run the script and knit the output
# -e means Rscript.exe is gettign the commands from stdin and not from a file
#More info: https://www.rdocumentation.org/packages/utils/versions/3.5.1/topics/Rscript
subprocess.call([r_exe, "-e", r_command])

#Open the output file in your web browser
outputexists = os.path.isfile(MAINTENANCEFOLDER + "\\update_greenit_tables\\" + re.sub('\\\\\\\\', '\\\\', output_file.strip("'")))
if outputexists:
  webbrowser.open(os.path.realpath(MAINTENANCEFOLDER + "\\update_greenit_tables\\" + re.sub('\\\\\\\\', '\\\\', output_file.strip("'"))))
else:
  webbrowser.open(os.path.realpath(MAINTENANCEFOLDER + "\\update_greenit_tables\\smp_error.html"))