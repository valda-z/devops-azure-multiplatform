FROM anapsix/alpine-java:8_server-jre_unlimited
VOLUME /tmp

EXPOSE 8080

ENV APP_HOME /app

RUN mkdir $APP_HOME
RUN mkdir $APP_HOME/config

ADD javawebapp-1.0-SNAPSHOT.jar $APP_HOME/app.jar

WORKDIR $APP_HOME
RUN bash -c 'touch app.jar'

ENTRYPOINT [ "java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "app.jar" ]
