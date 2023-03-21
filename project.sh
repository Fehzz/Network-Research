#!/bin/bash
												# Lines 4-10 contain variables used to style the script. 
style_function() {										# They can be edited and subsituted into the code accordingly, or removed altogether. 
bold=$(tput bold)										# Credit to the author of this borrowed code: https://it-delinquent.medium.com/coloured-bash-output-using-tput-cda72b04a918 
underline=$(tput smul)
error=$(tput setaf 160)
green=$(tput setaf 2)
folder=$(tput setaf 125)
target=$(tput setaf 214)
reset=$(tput sgr0)
}



installer_function() {										# Step 1: This function will install the necessary applications. If they are already installed, they will not be installed again. 					
	
	echo 'Checking for installed applications... '			
	find_nipe=$(find ~ -type f -name nipe.pl | wc -l) 					# Search for "nipe.pl" across all directories. If found, nipe is installed. Hence, it will NOT be installed again. 
	nipe_full_path=$(find ~ -type f -name nipe.pl)						# The directory where nipe.pl is installed is given in the output of this command.
	nipe_directory=$(dirname $nipe_full_path)						# The script needs to remove "nipe.pl" from the full directory path so that it can move into that directory and execute nipe.
												# The script will automatically switch to this directory to execute nipe when necessary.
												# dirname is used to isolate the nipe directory path in your system. CREDIT: https://www.geeksforgeeks.org/dirname-command-in-linux-with-examples/

												# $find_nipe is the variable that stores the command used to search for nipe.pl, in order to verify that nipe is installed.
												# Nipe will be used to anonymize browsing.
if [ $find_nipe == 0 ] 										# If nipe.pl is not found, the output of the command stored in $find_nipe = 0, hence it will be installed. 
then 
	echo "Installing Nipe..." 								# Nipe is crucial for this script. It uses TOR as a default gateway to make the user anonymous. 
   
	sudo apt-get -y install tor
	sudo apt-get -y install cpanminus
	git clone https://github.com/htrgouvea/nipe && cd nipe  				# Nipe repository is cloned from Github to your local machine (&&) AND you will be redirected to the Nipe directory. 
	sudo cpanm --installdeps . 								# As of 13 March 2023: Necessary dependencies are installed to ensure nipe functions smoothly. 
	sudo perl nipe.pl install 								# This command must be installed as root, so sudo is required.
	cd $nipe_directory && sudo perl nipe.pl restart						# Nipe is started. Restarting nipe off that bat helps to minimise connection errors, so the script runs smoothly.
	
	echo 'Nipe has been installed successfully. Starting nipe... ' 
else      
	echo 'Nipe is already installed on your machine, we can proceed.' 								 
	echo 'Starting nipe..'									# If Nipe already exists, it will not be installed. The user is notified.
	cd $nipe_directory
	sudo perl nipe.pl restart								# The script will automatically navigate to the nipe directory, so that Nipe can be executed smoothly. 
fi   


find_geoip=$(which geoiplookup | grep /usr/bin/geoiplookup | wc -l) 				# This command is used to search your machine to verify if geoiplookup is installed.
												# $find_geoip is the variable that stores the command used to search for geoiplookup. 
												# geoiplookup shows you the country your IP Address corresponds to. 															
if [ $find_geoip != 1 ] 									# If geoiplookup is not installed, the script will install it for you.     
then												
	echo 'Installing geoip-bin...'
	sudo apt-get install -y geoip-bin
	echo 'geoiplookup has been installed successfully.'
else												# If geoiplookup already exists, it will not be installed. The user is notified.
	echo 'geoiplookup is already installed on your machine, we can proceed.' 			

fi 

find_sshpass=$(which sshpass | grep /usr/bin/sshpass | wc -l)					# This command is used to search your machine to verify if sshpass is installed.
												# $find_sshpass is the variable that stores the command used to search for sshpass. 
if [ $find_sshpass != 1 ] 									# If sshpass is not installed, the script will run the command to install it for you.
then
	echo 'Installing sshpass'
	sudo apt-get install -y sshpass
	echo 'sshpass has been installed successfully.'   
else												# If sshpass already exists, it will not be installed. The user is notified.
	echo 'sshpass is already installed on your machine, we can proceed.' 							
fi 

}




												# Check performed to determine if our network connection is anonymous. The script will be suspended otherwise.
anonymous_function() {
	
echo 'Checking if we are anonymous on the internet...' 
myIP=$(curl -s ifconfig.io)									# curl is used to fetch your IP Address from ifconfig.me. The "-s" flag is used to silence irrelevant info. 
mycountry=$(geoiplookup $myIP | awk '{print $5}') 						# geoiplookup is used here to match our IP Address to its corresponding country. To determine anonymity.

if [ mycountry != Singapore ]  									# If your corresponding country is not Singapore, you are considered anonymous on the internet and the script will proceed as intended.
then 
	echo "You are ${bold}anonymous${reset}. Your spoofed country is: ${green}$mycountry${reset}" 
else
	echo "${error}WARNING${reset}: You are not anonymous, your identity is exposed, the script will be suspended immediately."
	exit 1 											# In the case you're not anonymous, the exit command will suspend the script. CREDIT: How to exit bash script: https://linuxhint.com/exit-bash-script/
fi 
}


target_function() {
												# Function allows user to specify a domain/IP to scan. Input stored into variable: $yourtarget. 

	echo 'Specify a domain or IP address that you want to scan.' 
read yourtarget 										# You are required to specify the domain you want to scan, your result is saved as a variable: yourtarget. 
	echo "You have specified ${target}$yourtarget${reset} as your target." 
	echo 'Connecting to remote server via SSH..' 
          

     
uptime_result=$(sshpass -p tc ssh tc@192.168.223.129 uptime)
echo "Uptime: '$uptime_result'."								# SSH into the remote-server. In this script, I have set a virtual Ubuntu within my LAN network as a designated remote server.  
												# The SSH credentials can be changed to suit the user's environment.


nmap_folder=$(test -d /home/nmap_results)
whois_folder=$(test -d /home/whois_results)

if    
	[ "$nmap_folder" = false ] 								# Quotation marks needed because the test command does not produce a terminal output. Syntax error will occur otherwise.       
then
	echo 'You do not currently have designated directory to store your nmap results. Creating a directory now at /home/nmap_results' 
	mkdir nmap_results /home
else
	echo 'A directory has been prepared for your nmap results at /home/nmap_results.txt'
fi

if 
	[ "$whois_folder" = false ] 								# Quotation marks needed because the test command does not produce a terminal output. Syntax error will occur otherwise.        
then
	echo 'You do not currently have designated directory to store your whois results. Creating a directory now at /home/whois_results' 
	mkdir whois_results /home
else
	echo 'A directory has been prepared for your whois results at /home/whois_results.txt'
fi
}





															


timecheck=$(timedatectl | head -n1)                 						# Credit to https://www.cyberciti.biz/faq/linux-display-date-and-time/ for the timedatectl command. Time recorded for logging. 
ng log. 
execute_remote_control_function() {
style_function 
installer_function
anonymous_function
target_function


cd /var/log && sudo touch remote_control.log							# The script will move to the /var/log directory in order to create a log file for auditing purposes.
sudo chmod 777 remote_control.log								# The script will change privilege of the file so that it can be written over by the script. 
cd /home && sudo touch nmap_results.txt && sudo touch whois_results.txt 			# The script will move into the /home folder of your machine, and create two files that record the nmap and whois scan results.
sudo chmod 777 nmap_results.txt whois_results.txt						# The script will change privilege of the file so that it can be written over by the script. 	
																					 
															
sshpass -p tc ssh tc@192.168.223.129 whois "$yourtarget" > /home/whois_results.txt		# Credit to the author who details the use of the sshpass command: https://levelup.gitconnected.com/execute-commands-on-remote-machines-using-sshpass-1f9bc4452e15
sshpass -p tc ssh tc@192.168.223.129 nmap -F "$yourtarget" > /home/nmap_results.txt		# A FAST scan is executed here for the purpose of this script. 
																					
	
	
	
	
	echo "$timecheck: Nmap Data has been logged for $yourtarget" >> /var/log/remote_control.log 	# Audit Entry for Nmap done on your target with time and date.
	echo "$timecheck: whois Data has been logged for $yourtarget" >> /var/log/remote_control.log 	# Audit Entry for Whois done on your target with time and date.
	echo "Your nmap data has been saved at ${folder}/home/nmap_results.txt${reset}" 
	echo "Your whois data has been saved at ${folder}/home/whois_results.txt${reset}" 

	echo 'A log file has been created in the following directory for auditing purposes: /var/log/remote_control.log'

}      

execute_remote_control_function									# The main function is executed here, within which all other functions are nested. 

