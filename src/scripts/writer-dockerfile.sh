#!/bin/bash 
##CONFIG
path="$HOME"
fileName="Dockerfile"

###################JAR###########################################
write_file(){
cat > "$path/$fileName" <<EOF
#This file was writted by marvelorb in dockerfile-writer.sh
# add the fat jar file to the base image:

FROM openjdk:11.0.14.1-jre-slim-buster as builder
COPY app.jar application.jar

# extract the layers of the artifact:
RUN mkdir dependencies snapshot-dependencies internal-dependencies spring-boot-loader application
RUN java -Djarmode=layertools -jar application.jar extract

# copy the extracted folders to add the corresponding Docker layers
FROM openjdk:11.0.14.1-jre-slim-buster

RUN apt-get update -y
RUN apt-get dist-upgrade -y

RUN mkdir -p /home/tomcat/dp  && addgroup scope && useradd scope -g scope

COPY dependency.jar /home/tomcat/dp/

COPY --from=builder dependencies/ /home/tomcat
COPY --from=builder snapshot-dependencies/ /home/tomcat
COPY --from=builder internal-dependencies/ /home/tomcat
COPY --from=builder spring-boot-loader/ /home/tomcat
COPY --from=builder application/ /home/tomcat
RUN chown -R scope:scope /home/tomcat && chmod -R 777 /home/tomcat && ls -la /home/tomcat
USER scope
ENTRYPOINT ["/bin/sh", "-c", "java -jar /home/tomcat/dp/dependency.jar && java \${JAVA_APP_OPTS} -cp /home/tomcat org.springframework.boot.loader.JarLauncher "]

EOF
echo "Done"
}

#################INIT###########################################
echo "INIT writing  ${path}/${fileName} "
write_file 

