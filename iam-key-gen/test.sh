export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-11.0.15.0.9-2.el7_9.x86_64
$JAVA_HOME/bin/java -jar  target/json-web-key-generator-0.9-SNAPSHOT-jar-with-dependencies.jar -t RSA -s 1024 -S -i rsa1

