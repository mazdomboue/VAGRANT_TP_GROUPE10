 echo 'installation du dictionnaire' 

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
echo 'clone git script de la BD'
git clone https://github.com/mazdomboue/DEV_GRPE10_IBAM.git /BD_SCRIPT.sql




#initialisation des variables d'environnement
# set environment variables

export ORACLE_BASE="/opt/oracle"
export ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
export ORACLE_SID="XE"
export ORACLE_PDB="XEPDB1"
export APEX_HOME="/home/oracle/apex"
export PATH="\$PATH:\$ORACLE_HOME/bin"


echo 'INSTALLER: Updated APEX extracted to the ORACLE_HOME'

# Prepare des tables spaces en extension
#su -l oracle -c 
echo 'INSTALLER: $PATH'
sqlplus / as sysdba <<EOF
	ALTER DATABASE DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/system01.dbf' resize 1024m;
	ALTER DATABASE DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/sysaux01.dbf' resize 1024m;
	alter session set container=$ORACLE_PDB;
	CREATE TABLESPACE apex DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/$ORACLE_PDB/apex01.dbf'
        SIZE 300M AUTOEXTEND ON NEXT 1M;
	exit;
EOF

echo 'INSTALLER: APEX tablespaces etendues'

# Install APEX into the PDB Oracle Database
su -l oracle -c "cd $APEX_HOME; sqlplus / as sysdba <<EOF
	alter session set container=$ORACLE_PDB;
        ALTER PROFILE DEFAULT LIMIT PASSWORD_LIFE_TIME UNLIMITED;
	@apexins.sql APEX APEX TEMP /i/
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
