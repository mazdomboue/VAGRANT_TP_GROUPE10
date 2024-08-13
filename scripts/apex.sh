 echo 'installation du dictionnaire' 

yum -y localinstall https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol7.x86_64.rpm

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
echo 'clone git script de la BD'
git clone https://github.com/mazdomboue/DEV_GRPE10_IBAM.git /BD_SCRIPT.sql




#initialisation des variables d'environnement
# set environment variables

export ORACLE_BASE="/opt/oracle"
export ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
export ORACLE_SID="XE"
export ORACLE_PDB="XEPDB1"
export APEX_HOME="/home/vagrant/apex-latest/apex"
export PATH="\$PATH:\$ORACLE_HOME/bin"


echo 'INSTALLER: Updated APEX extracted to the ORACLE_HOME'


echo 'telecharger derniere version de apex et dezipper

wget https://download.oracle.com/otn_software/apex/apex-latest.zip
unzip apex-latest.zip
rm apex-latest.zip
cd apex

chown -R oracle:oinstall $APEX_HOME
echo 'INSTALLER: APEX tablespaces etendues'

# Install APEX into the PDB Oracle Database
su -l oracle -c "cd $APEX_HOME; sqlplus / as sysdba <<EOF
	alter session set container=$ORACLE_PDB;
        ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
	@apexins.sql SYSAUX SYSAUX TEMP /i/
	exit;
EOF"

echo 'INSTALLER: Oracle APEX Installation completed'

# unlock APEX_PUBLIC_USER
su -l oracle -c "cd $ORACLE_HOME/apex; sqlplus / as sysdba <<EOF
	alter session set container=$ORACLE_PDB;
	alter user APEX_PUBLIC_USER identified by \"${ORACLE_PWD}\" account unlock;
	exit;
EOF"

# Create the APEX Instance Administration user and set the password
su -l oracle -c "sqlplus / as sysdba <<EOF
	alter session set container=$ORACLE_PDB;
	begin
	    apex_util.set_security_group_id( 10 );
	    apex_util.create_user(
	        p_user_name => 'ADMIN',
	        p_email_address => 'your@emailaddress.com',
	        p_web_password => '${ORACLE_PWD}',
	        p_developer_privs => 'ADMIN' );
	    apex_util.set_security_group_id( null );
	    commit;
	end;
	/
	exit;
EOF"

# config APEX REST and set the passwords of APEX_REST_PUBLIC_USER and APEX_LISTENER
su -l oracle -c "cd $ORACLE_HOME/apex; sqlplus / as sysdba <<EOF
        alter session set container=$ORACLE_PDB;
        @apex_rest_config_core.sql $ORACLE_HOME/apex/ ${ORACLE_PWD} ${ORACLE_PWD}
        exit;
EOF"

# Create a network ACE for APEX (this is used when consuming Web services or sending outbound mail)
cat > /tmp/apex-ace.sql << EOF
        alter session set container=$ORACLE_PDB;
        declare
            l_acl_path varchar2(4000);
            l_apex_schema varchar2(100);
        begin
            for c1 in (select schema
                         from sys.dba_registry
                        where comp_id = 'APEX') loop
                l_apex_schema := c1.schema;
            end loop;
            sys.dbms_network_acl_admin.append_host_ace(
                host => '*',
                ace => xs\$ace_type(privilege_list => xs\$name_list('connect'),
                principal_name => l_apex_schema,
                principal_type => xs_acl.ptype_db));
            commit;
        end;
	/
	exit;
EOF
su -l oracle -c "sqlplus / as sysdba @/tmp/apex-ace.sql"
rm -f /tmp/apex-ace.sql

echo 'INSTALLER: Oracle APEX Configuration completed'
