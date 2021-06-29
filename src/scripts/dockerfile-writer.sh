#!/bin/bash 
###################JAR###########################################
write_dockerfile_jar(){
cat >~/Dockerfile <<EOF
#This file was writted by marvelorb in dockerfile-writer.sh
# add the fat jar file to the base image:
FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine as builder
ARG JAR_FILE=target/*.jar
COPY \${JAR_FILE} application.jar
# extract the layers of the artifact:
RUN java -Djarmode=layertools -jar application.jar extract
# copy the extracted folders to add the corresponding Docker layers
FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine
RUN mkdir /app & mkdir -p /tmp/fusion/auditor && addgroup -S fusion && adduser -S fusion -G fusion
COPY --from=builder dependencies/ /app
COPY --from=builder snapshot-dependencies/ /app
COPY --from=builder internal-dependencies/ /app
COPY --from=builder spring-boot-loader/ /app
COPY --from=builder application/ /app
RUN chown -R fusion:fusion /app && chmod -R 777 /app
RUN chown -R fusion:fusion /tmp/fusion && chmod -R 777 /tmp/fusion
# ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
CMD ["/bin/sh", "-c", "java -cp /app -Dspring.profiles.active=\${SPRING_PROFILE_ACTIVE} org.springframework.boot.loader.JarLauncher \${JAVA_OPTS}"]
EOF
echo "Done"
}
###################UI###########################################
write_dockerfile_ui(){
echo "NOT IMPLEMENTED JET"
exit 1
}

#################INIT###########################################
echo "INIT writing dockerfile"
case $TYPE in
jar)
	write_dockerfile_jar 
	;;

ui)
	write_dockerfile_ui 
 	;;

*)
	echo "Input parameter not set"
	echo "Valid options:"
	echo "dockerfile-writer.sh [jar|ui] "
	exit 1
  ;;
esac