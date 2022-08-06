#!/bin/bash


(crontab -l 2>/dev/null; echo "SHELL=/bin/sh") | crontab -
(crontab -l 2>/dev/null; echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin") | crontab -


## G810 color profileG910 
# (crontab -l 2>/dev/null; echo "@reboot g810-led -p /usr/share/doc/g810-led/examples/sample_profiles/colors") | crontab -

# ## Caffeine stop
# (crontab -l 2>/dev/null; echo "0 * * * * $PWD/jobs/caffeine-stop.sh") | crontab -

# ## Caffeine start
# (crontab -l 2>/dev/null; echo "@reboot $PWD/jobs/caffeine-start.sh") | crontab -
