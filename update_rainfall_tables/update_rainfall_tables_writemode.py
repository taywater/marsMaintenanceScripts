#This script is a wrapper that executes a few other scripts. It is to be used as a scheduled task.
import datetime, os, subprocess, webbrowser, shutil, re, zipfile

#Note: A:\ is \\pwdoows\oows\Watershed Sciences\GSI Monitoring\07 Databases and Tracking Spreadsheets\13 MARS Analysis Database
#It's mapped to a drive letter because certain Windows services can't handle non letter-mapped paths

#Note regarding filepath separators: In order to represent a literal '\', we must type \\ (an escaped \)
#However, when specifying file paths that will be read by the R command, we must type \\\\
#Because specifying \\ in the Python script will cause R to see \, and it will choke on the singleton \ just like Python would

###Section 1: Grab and unzip the rain gage database
###We'll be copying and unzipping the H&H database 
#Where are the databases located?
hhdb = "\\\\pwdoows\\OOWS\\Modeling\\Data\\H&H Databases\\PWD Raingauge\\CSORain2010.zip"
localdir = os.path.expanduser("~") + "\\Documents"
localzip = localdir + "\\" + "CSORain2010.zip"

#Copy the H&H DB to our home directory
print("Copying H&H rainfall DB to local directory")
shutil.copyfile(hhdb, localzip)

#Unzip the zipped file
#Note: extractall() is depricated in Python 3. We're using Python 2 because that's what's in ArcGIS
#Note: This filepath is used by Python only, and thus needs \\ as a separator
print("Unzipping rainfall DB")
localzipobject = zipfile.ZipFile(localzip, 'r')
localzipobject.extractall(localdir)

#After unzipping, the db is here
localdb = os.path.expanduser("~") + "\\Documents\\CSORain2010\\CSORain2010.mdb"

#We need the \\ in localdb to be \\\\ to pass it to R
#We have to do this in a second step because os.path.expanduser(~) will always return \\
#We will use a regular expression to turn \\ into \\\\. The regular expression to identify a literal \\ is \\\\
#This is very dumb
localdb = re.sub('\\\\', '\\\\\\\\', localdb)
print(localdb)


#In order to send the GIS output file to the R script, we need to replicate the file naming mechanism from the arcpy script.
current_date = datetime.datetime.now()
datestring = current_date.strftime("%Y%m%dT%H%M")

###Section 3: Run the R script that will generate the updates for the database
#We'll be calling this R script from within this python script
#We'll be composing a string that will be sent to the command line via a subprocess

#The R script that we'll be executing has runtime parameters that we will be setting in this script
#Note: r_script, database, and output_file are wrapped in single quotes because the resultant R command expects them to be string literals
#Note: This filepath is echoed by Python and interpreted by R, so we need \\\\ as a separator
r_script = "'A:\\\\Scripts\\\\Maintenance\\\\update_rainfall_tables\\\\update_rainfall_tables.rmd'"
database = "'mars_testing'"
writeflag = "TRUE"
output_file = "'output\\\\" + datestring + "_update_rainfall_tables.html" + "'"

#Where is the R executable?
#Note: This filepath is used by Python and CMD.EXE, and thus needs \\ as a separator (CMD.EXE doesn't choke on singleton \)
r_exe = "Rscript.exe"

#Compose the R command that will be passed to r_exe
r_command = "rmarkdown::render(" + r_script + ", params = list(gagedb='" + localdb + "', database=" + database + ", write=" + writeflag + ")" + ", output_file =" + output_file + ")"

print(r_command)

#Invoke the R commands to run the script and knit the output
# -e means Rscript.exe is getting the commands from stdin and not from a file
#More info: https://www.rdocumentation.org/packages/utils/versions/3.5.1/topics/Rscript
subprocess.call([r_exe, "-e", r_command])

#Open the output file in your web browser
outputexists = os.path.isfile('A:\\Scripts\\Maintenance\\update_rainfall_tables\\' + output_file.strip("'"))
if outputexists:
    webbrowser.open(os.path.realpath('A:\\Scripts\\Maintenance\\update_rainfall_tables\\' + output_file.strip("'")))
else:
    webbrowser.open(os.path.realpath("A:\\Scripts\\Maintenance\\update_rainfall_tables\\rainfall_error.html"))