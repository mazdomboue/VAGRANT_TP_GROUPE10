echo "******************************************************************************"
echo "Install Oracle RPM." `date`
echo "******************************************************************************"
yum -y localinstall /vagrant/ora21c.rpm
#yum update -y

export ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
export PATH="\$PATH:\$ORACLE_HOME/bin"
echo "******************************************************************************"
echo "Create default database." `date`
echo "******************************************************************************"
/etc/init.d/oracle-xe-21c configure <<EOF
MAZ16juin#
MAZ16juin#
EOF

systemctl enable oracle-xe-21c

echo "repetion de l'operation car peut échouer pour la première fois"


/etc/init.d/oracle-xe-21c configure <<EOF
MAZ16juin#
MAZ16juin#
EOF

systemctl enable oracle-xe-21c

# creation utilisateur vagrant  et droits
#su -l oracle -c 
echo 'INSTALLER: $PATH'
sqlplus / as sysdba <<EOF
	alter session set container=XEPDB1;
	CREATE user VAGRANT identified by VAGRANT;
        grant dba to VAGRANT;
	exit;
EOF

#execution script de base de données
sqlplus / as sysdba <<EOF
	@/home/vagrant/BD_SCRIPT.sql;
	exit;
EOF


echo 'Configuration de base de donnée terminée'

echo 'clone git script de la BD'
   git clone https://github.com/mazdomboue/DEV_GRPE10_IBAM.git /BD_SCRIPT.sql
