#!/bin/bash 
##CONFIG

fileName="layers.xml"
###################JAR###########################################
write_file(){
cat > "$path/$fileName" <<EOF
<layers xmlns="http://www.springframework.org/schema/boot/layers"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://www.springframework.org/schema/boot/layers
                     https://www.springframework.org/schema/boot/layers/layers-2.4.xsd">
    <application>
        <into layer="spring-boot-loader">
            <include>org/springframework/boot/loader/**</include>
        </into>
        <into layer="application" />
    </application>
    <dependencies>
        <into layer="internal-dependencies">
            <include>com.scoperetail.*:*:*</include>
        </into>
        <into layer="snapshot-dependencies">
            <include>*:*:*SNAPSHOT</include>
        </into>
        <into layer="dependencies" />
    </dependencies>
    <layerOrder>
        <layer>dependencies</layer>
        <layer>spring-boot-loader</layer>
        <layer>internal-dependencies</layer>
        <layer>snapshot-dependencies</layer>
        <layer>application</layer>
    </layerOrder>
</layers>
EOF
echo "Done"
}

#################INIT###########################################
path="$HOME/project/src/main/resources"
echo "INIT writing  ${path}/${fileName} "
write_file
