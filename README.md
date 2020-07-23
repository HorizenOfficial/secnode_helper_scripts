Collection of useful scripts helping with secure nodes
===================

**secnode_force_ipv6.sh**

If you're running the [secnodetracker](https://github.com/HorizenOfficial/secnodetracker) in a IPv4/IPv6 dual stack environment and want to connect via IPv6, the most reliable way is to add IPv6 entries for the tracking server domains to your hosts file.
This script can be run as a cron job and will add the needed entries to `/etc/hosts` automatically and will keep the server list up to date.
>**To run it via anacron**
1. install the needed dependencies:
 ```
 sudo apt-get update && sudo apt-get install curl dnsutils jq
 ```
2. download the script and make it executable: 
```
curl -L https://github.com/HorizenOfficial/secnode_helper_scripts/raw/master/secnode_force_ipv6.sh -o secnode_force_ipv6.sh && chmod +x secnode_force_ipv6.sh
```
3. create a symbolic link to `/etc/cron.weekly`:
```
sudo ln -s $(pwd)/secnode_force_ipv6.sh /etc/cron.weekly/secnode_force_ipv6
```
