#!/bin/bash 
##CONFIG
path="$HOME"
fileName="Dockerfile"
###################JAR###########################################
write_file(){
cat > "$path/$fileName" <<EOF
#This file was writted by marvelorb in dockerfile-writer.sh
# add the fat jar file to the base image:

FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine as builder
COPY app.jar application.jar

# extract the layers of the artifact:
RUN mkdir dependencies snapshot-dependencies internal-dependencies spring-boot-loader application
RUN java -Djarmode=layertools -jar application.jar extract

# copy the extracted folders to add the corresponding Docker layers
FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine
RUN mkdir -p /home/tomcat  && addgroup -S scope && adduser -S scope -G scope

COPY --from=builder dependencies/ /home/tomcat
COPY --from=builder snapshot-dependencies/ /home/tomcat
COPY --from=builder internal-dependencies/ /home/tomcat
COPY --from=builder spring-boot-loader/ /home/tomcat
COPY --from=builder application/ /home/tomcat
RUN chown -R scope:scope /home/tomcat && chmod -R 777 /home/tomcat && ls -la /home/tomcat
USER scope
ENTRYPOINT ["/bin/sh", "-c", "java \${JAVA_APP_OPTS} -cp /home/tomcat org.springframework.boot.loader.JarLauncher "]

EOF
echo "Done"
}

#################INIT###########################################
echo "INIT writing  ${path}/${fileName} "
write_file 

