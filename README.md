# Network-Research
# Project Remote Control (Bash Automation)

# Mission: Communicating with a remote server and executing automatic tasks anonymously.
# Strategy: Creating automation that would let cyber units execute commands on their local devices but would be executed by the remote server.

# The script performs nmap and whois scans on a specified target. 
# The script will SSH via sshpass into a known remote server, from which it will execute these commands.
# Details of the remote server are shown to the user, through the Uptime command. 
# Results of the scans are saved back onto the local server. The script will create files within a specified directory for the scan results to be stored in. The file path can be changed by another user to suit their preferences.

# A log is created in /var/log directory to log the time and the nature of the scan. 

# The script is styled with borrowed code from the author at : https://it-delinquent.medium.com/coloured-bash-output-using-tput-cda72b04a918. 

# Other credits are listed in the .pdf Report. 
