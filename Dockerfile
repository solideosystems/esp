FROM tomcat:8.5-jre11-openjdk-slim

ADD "./target/esp-admin-0.1.0" "/usr/local/tomcat/webapps/ROOT"

COPY "./esp.mv.db" "/usr/local/tomcat"

COPY "./esp.trace.db" "/usr/local/tomcat"


VOLUME ["./target/esp-admin-0.1.0", "/usr/local/tomcat"]
