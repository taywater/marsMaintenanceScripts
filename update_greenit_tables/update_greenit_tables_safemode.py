#This script is a wrapper that executes a few other scripts. It is to be used as a scheduled task
import datetime, os, subprocess, webbrowser, re

#this script is not run in interactive mode, so PYTHONSTARTUP must be loaded
if os.path.isfile(os.envrion['PYTHONSTARTUP']):
	exec(open(os.envrion['PYTHONSTARTUP']).read())
else:
	sys.exit("You do not have a .pythonrc file in your PYTHONSTARTUP environment variable.")

	