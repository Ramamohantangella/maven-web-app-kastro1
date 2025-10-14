# Use the official Tomcat base image
FROM tomcat:9.0

# Expose port 8080 to the outside world
EXPOSE 9099

# Copy the war file to the webapps directory of Tomcat
COPY Application.war /usr/local/tomcat/webapps/


