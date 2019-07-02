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

###Section 1: Generate GIS data file
#Run some arcpy commands that export up-to-date SMP centroids from DataConv
#This script generates an ESRI shapefile containing SMP centroids in the following folder:
# A:\Scripts\Maintenance\update_smp_tables\centroids_folder
#Note: execfile() is depricated in Python 3. We're using Python 2 because that's what's in ArcGIS
#Note: This filepath is used by Python only, and thus needs \\ as a separator
execfile(MAINTENANCEFOLDER + "\\update_smp_tables\\arcpy_centroids_export.py")

#In order to send the GIS output file to the R script, we need to replicate the file naming mechanism from the arcpy script.
#We must round the datestring because it's possible for the arcpy script to take more than 60 seconds to execute
#In which case getting the current datetime at a minute-scale resolution won't get the same number as it did in that script
current_date = datetime.datetime.now()

def roundTime(dt=None, roundTo=60):
   """Round a datetime object to any time lapse in seconds
   dt : datetime.datetime object, default now.
   roundTo : Closest number of seconds to round to, default 1 minute.
   Author: Thierry Husson 2012 - Use it as you want but don't blame me.
   """
   if dt == None : dt = datetime.datetime.now()
   seconds = (dt.replace(tzinfo=None) - dt.min).seconds
   rounding = (seconds+roundTo/2) // roundTo * roundTo
   return dt + datetime.timedelta(0,rounding-seconds,-dt.microsecond)

rounddate = roundTime(current_date, roundTo = 60 * 15) #Round to the nearest 15 minutes
datestring = rounddate.strftime("%Y%m%dT%H%M")

#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
destinationfolder = re.sub('\\\\', '\\\\\\\\',MAINTENANCEFOLDER) + "\\\\update_smp_tables\\\\centroids_folder"

#The is string is wrapped in single quotes because the resultant R command expects it to be a string literal
#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
finalshapefile = "'" + destinationfolder + "\\\\centroids_dem_" + datestring + ".shp" + "'"

###Section 2: Run the R script that will generate the updates for the database
#We'll be calling this R script from within this python script
#We'll be composing a string that will be sent to the command line via a subprocess

#The R script that we'll be executing has runtime parameters that we will be setting in this script
#Note: r_script, database, password, and output_file are wrapped in single quotes because the resultant R command expects them to be string literals
#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
r_script = "'" + re.sub('\\\\', '\\\\\\\\',MAINTENANCEFOLDER) + "\\\\update_smp_tables\\\\update_smp_tables.rmd'"
database = "'mars_testing'"
writeflag = "FALSE"
output_file = "'output\\\\" + datestring + "_update_smp_tables.html" + "'"

#Where is the R executable?
#Note: This filepath is used by Python and CMD.EXE, and thus needs \\ as a separator (CMD.EXE doesn't choke on singleton \)
r_exe = "Rscript.exe"

#Compose the R command that will be passed to r_exe
r_command = "rmarkdown::render(" + r_script + ", params = list(file=" + finalshapefile + ", database=" + database + ", write=" + writeflag + ")" + ", output_file =" + output_file + ")"

print r_command

#Invoke the R commands to run the script and knit the output
# -e means Rscript.exe is getting the commands from stdin and not from a file
#More info: https://www.rdocumentation.org/packages/utils/versions/3.5.1/topics/Rscript
subprocess.call([r_exe, "-e", r_command])

#Open the output file in your web browser
outputexists = os.path.isfile(MAINTENANCEFOLDER + "\\update_smp_tables\\" + re.sub('\\\\\\\\', '\\\\', output_file.strip("'")))
if outputexists:
	webbrowser.open(os.path.realpath(MAINTENANCEFOLDER + "\\update_smp_tables\\" + re.sub('\\\\\\\\', '\\\\', output_file.strip("'"))))
else:
	webbrowser.open(os.path.realpath(MAINTENANCEFOLDER + "\\update_smp_tables\\smp_error.html"))