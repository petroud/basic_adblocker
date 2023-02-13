#!/bin/bash
# You are NOT allowed to change the files' names!
domainNames="domainNames.txt"
domainNames2="domainNames2.txt"
IPAddressesSame="IPAddressesSame.txt"
IPAddressesDifferent="IPAddressesDifferent.txt"
adblockRules="adblockRules"
tmpSame="tmp_same_f"
tmpDiff="tmp_diff_f"

function adBlock() {
    if [ "$EUID" -ne 0 ];then
        printf "Please run as root.\n"
        exit 1
    fi
    if [ "$1" = "-domains"  ]; then
        # Find different and same domains in ‘domainNames.txt’ and ‘domainsNames2.txt’ files 
	# and write them in “IPAddressesDifferent.txt and IPAddressesSame.txt" respectively
    
        #Construct different and same files
        grep -Fxf $domainNames $domainNames2 > $tmpSame
        grep -Fxvf $tmpSame $domainNames > $tmpDiff
        grep -Fxvf $tmpSame $domainNames2 >> $tmpDiff

        echo "Now running dns lookup process...This might take some time, be patient"
        
        #Lookup the domain names from each file
        dig +short -f $tmpSame | grep '^[.0-9]*$' > $IPAddressesSame
        dig +short -f $tmpDiff | grep '^[.0-9]*$' > $IPAddressesDifferent

        rm tmp_*
        #Remove duplicate IPs
        awk '!seen[$0]++' $IPAddressesSame > tmp && mv tmp $IPAddressesSame      
        awk '!seen[$0]++' $IPAddressesDifferent > tmp && mv tmp $IPAddressesDifferent        
        echo "Lookup completed! IP Host files updated."       
            
    elif [ "$1" = "-ipssame"  ]; then
        # Configure the DROP adblock rule based on the IP addresses of $IPAddressesSame file.
        # DROP will cause a timeout
        echo "Configuring DROP rules for IPAddressesSame.txt..."

        while IFS= read -r line
        do 
            echo "DROP configuration for IP: "$line
            iptables -A INPUT -s $line -j DROP
        done < $IPAddressesSame

        echo "Rules configured succesfully" 

    elif [ "$1" = "-ipsdiff"  ]; then
        # Configure the REJECT adblock rule based on the IP addresses of $IPAddressesDifferent file.
        # REJECT will causes unreachable error
        echo "Configuring REJETCT rules for IPAddressesDiff.txt..."
        
        while IFS= read -r line
        do 
            echo "REJECT configuration for IP: "$line
            iptables -A INPUT -s $line -j REJECT
        done < $IPAddressesDifferent

        echo "Rules configured succesfully" 
        
    elif [ "$1" = "-save"  ]; then
        
        echo "Writing rules..."
        iptables-save > $adblockRules
        echo "Rules written in file "$adblockRules
        
    elif [ "$1" = "-load"  ]; then
        # Load rules from $adblockRules file.
        echo "Loading rules from file "$adblockRules
        iptables-restore < $adblockRules
        echo "Rules loaded"

        
    elif [ "$1" = "-reset"  ]; then
        # Reset rules to default settings (i.e. accept all).
        echo "Reseting firewall rules..."
        iptables -F INPUT
        iptables -F OUTPUT
        iptables -F FORWARD
        echo "Reset completed"
        
    elif [ "$1" = "-list"  ]; then
        # List current rules.
        iptables -S
        
    elif [ "$1" = "-help"  ]; then
        printf "This script is responsible for creating a simple adblock mechanism. It rejects connections from specific domain names or IP addresses using iptables.\n\n"
        printf "Usage: $0  [OPTION]\n\n"
        printf "Options:\n\n"
        printf "  -domains\t  Configure adblock rules based on the domain names of '$domainNames' file.\n"
        printf "  -ipssame\t\t  Configure the DROP adblock rule based on the IP addresses of $IPAddressesSame file.\n"
	printf "  -ipsdiff\t\t  Configure the DROP adblock rule based on the IP addresses of $IPAddressesDifferent file.\n"
        printf "  -save\t\t  Save rules to '$adblockRules' file.\n"
        printf "  -load\t\t  Load rules from '$adblockRules' file.\n"
        printf "  -list\t\t  List current rules.\n"
        printf "  -reset\t  Reset rules to default settings (i.e. accept all).\n"
        printf "  -help\t\t  Display this help and exit.\n"
        exit 0
    else
        printf "Wrong argument. Exiting...\n"
        exit 1
    fi
}

adBlock $1
exit 0
