#!/bin/bash
#
# LICENSE UPL 1.0
#
# Copyright © 1982-2019 Oracle and/or its affiliates. All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl.
#
#    NAME
#      ords.sh
#
#    DESCRIPTION
#      Execute Oracle Rest Data Services installation and configuration
#


#mettr e à jour version java
wget https://download.oracle.com/java/17/archive/jdk-17.0.6_linux-x64_bin.rpm
sudo yum -y install jdk-17.0.6_linux-x64_bin.rpm

 yum install -y polkit

. /home/vagrant/.bashrc 

export ORACLE_PWD=MAZ16juin#
export ORDS_HOME=/home/vagrant/ords

mkdir -p $ORDS_HOME

cp -R /vagrant/ords/*  $ORDS_HOME/

# Configure ORDS
cat > $ORDS_HOME/params/ords_params.properties << EOF
db.hostname=192.168.0.110
db.port=1521
db.servicename=XEPDB1
db.sid=
db.username=APEX_PUBLIC_USER
db.password=MAZ16juin#
migrate.apex.rest=false
plsql.gateway.add=true
rest.services.apex.add=true
rest.services.ords.add=true
schema.tablespace.default=APEX
schema.tablespace.temp=TEMP
standalone.mode=true
standalone.use.https=false
standalone.http.port=8080
standalone.static.path=/home/vagrant/ords/images
standalone.static.images=/home/vagrant/ords/images
user.apex.listener.password=MAZ16juin#
user.apex.restpublic.password=MAZ16juin#
user.public.password=AMAZ16juin#
user.tablespace.default=APEX
user.tablespace.temp=TEMP
sys.user=SYS
sys.password=MAZ16juin#
restEnabledSql.active=false
feature.sdw=false
EOF

cat > $ORDS_HOME/config/ords/standalone/standalone.properties << EOF
jetty.port=8080
standalone.context.path=/ords
standalone.doc.root=${ORDS_HOME}/config/ords/doc_root
standalone.scheme.do.not.prompt=true
standalone.static.context.path=${ORDS_HOME}
standalone.static.path=${ORDS_HOME}/images
EOF


java -jar $ORDS_HOME/ords.war configdir $ORDS_HOME/conf

java -jar $ORDS_HOME/ords.war setup  --parameterFile  $ORDS_HOME/params/ords_params.properties --silent



#java -jar ords.war standalone

echo 'INSTALLER: Oracle Rest Data Services installation completed'

sudo chmod -R  777 /etc/systemd/system/


# mise en place de  ORDS service

cat > /etc/systemd/system/ords.service << EOF
[Unit]
Description=Start Oracle REST Data Services

[Service]
User=vagrant
Type=simple
Restart=always
ExecStart= /usr/bin/java -jar /home/vagrant/ords/ords.war
ExecStop= /usr/bin/java -jar /home/vagrant/ords/ords.war
StandardOutput=syslog
SyslogIdentifier=ords

[Install]
WantedBy=multi-user.target
EOF

sudo yum install -y polkit
sudo systemctl enable --now ords
echo 'INSTALLER: demarage de ORDS'
sudo systemctl start ords


echo ""
echo "INSTALLER: APEX/ORDS Installation Completed";
echo "INSTALLER: You can access APEX by your Host Operating System at following URL:";
echo "acceder à l'application par : http://localhost:8084/ords/r/vagrant/fbhb/home";

echo ""
