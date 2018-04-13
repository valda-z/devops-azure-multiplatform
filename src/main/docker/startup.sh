#!/bin/bash
cat >/etc/motd <<EOL 
  _____                               
  /  _  \ __________ _________   ____  
 /  /_\  \\___   /  |  \_  __ \_/ __ \ 
/    |    \/    /|  |  /|  | \/\  ___/ 
\____|__  /_____ \____/ |__|    \___  >
        \/      \/                  \/ 
A P P   S E R V I C E   O N   L I N U X
EOL

cat /etc/motd

/usr/sbin/sshd -D -e -f /etc/ssh/sshd_config

java -Djava.security.egd=file:/dev/./urandom -javaagent:/app/applicationinsights-agent-1.0.9.jar -noverify -jar app.jar
