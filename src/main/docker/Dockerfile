FROM anapsix/alpine-java:8_server-jre_unlimited
VOLUME /tmp

EXPOSE 8080

ENV APP_HOME /app

RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/config

ADD devopsdemo-javawebapp-1.0-SNAPSHOT.jar $APP_HOME/app.jar

ADD AI-Agent.xml $APP_HOME/AI-Agent.xml
ADD applicationinsights-agent-1.0.9.jar $APP_HOME/applicationinsights-agent-1.0.9.jar

WORKDIR $APP_HOME
RUN bash -c 'touch app.jar'

ENTRYPOINT [ "java", "-Djava.security.egd=file:/dev/./urandom", "-javaagent:/app/applicationinsights-agent-1.0.9.jar", "-noverify", "-jar", "app.jar" ]
