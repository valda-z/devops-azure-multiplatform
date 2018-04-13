FROM openjdk
VOLUME /tmp

# ------------------------
# SSH Server support
# ------------------------
RUN apt-get update \
	&& apt-get install -y --no-install-recommends openssh-server \
	&& echo "root:Docker!" | chpasswd

EXPOSE  2222 8080

COPY sshd_config /etc/ssh/

ENV APP_HOME /app

RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/config

COPY devopsdemo-javawebapp-1.0-SNAPSHOT.jar $APP_HOME/app.jar
COPY startup.sh $APP_HOME/startup.sh
RUN chmod 755 /app/startup.sh

COPY AI-Agent.xml $APP_HOME/AI-Agent.xml
COPY applicationinsights-agent-1.0.9.jar $APP_HOME/applicationinsights-agent-1.0.9.jar

WORKDIR $APP_HOME

ENTRYPOINT [ "/bin/bash", "/app/startup.sh" ]
