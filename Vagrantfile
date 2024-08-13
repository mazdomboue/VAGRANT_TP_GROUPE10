# Copyright © 2024 Groupe 10 IBAM/M2


# Projet VAGRANT
#    DESCRIPTION
#      Creation de 3 machines virtuelle 
#

# URL et nom de la box à utiliser par vagrant

BOX_NAME = "oraclebase/oracle-7"

 Vagrant.configure("2") do |config|

#SERVEUR BD
       config.vm.define "BD_SERV" do |bd|
  		bd.vm.box = BOX_NAME

                bd.vm.hostname = "BDSERV"
                #Config réseau
		bd.vm.network "private_network", ip: "192.168.0.103"

		#ouverture des ports
  		 bd.vm.network "forwarded_port", guest: 8080, host: 8082

		#Configuration du dossier de synchronisation
		bd.vm.synced_folder "./.vagrant", "/home/vagrant/BD_SERV", type: "rsync"


		bd.vm.provider "virtualbox" do |vb|
		  vb.name = "BD_SERV"
		  vb.memory = "2048"
		  vb.cpus = 2
		  #Configuration de l'inferface graphique
		  vb.gui = true
	     
		
	 	end
		# Provision et mise à jour de Oracle Linux 7 et clone par git du script de la BD
  		bd.vm.provision "shell", path: "scripts/os_update.sh"

		 # Provision installation et sgbd et initialisation de la base de données
  		 bd.vm.provision "shell", path: "scripts/database_init.sh"


        end




#SERVEUR APPLI
       config.vm.define "AP_SERV" do |ap|
  		ap.vm.box = BOX_NAME
                ap.vm.hostname = "APSERV"
                #Config réseau
		ap.vm.network "private_network", ip: "192.168.0.110"

		#ouverture des ports
  		 ap.vm.network "forwarded_port", guest: 8080, host: 8084

		#Configuration du dossier de synchronisation
		ap.vm.synced_folder "./.vagrant", "/home/vagrant/BD_SERV", type: "rsync"


		ap.vm.provider "virtualbox" do |vb|
		  vb.name = "AP_SERV"
		  vb.memory = "2048"
		  vb.cpus = 2
		  #Configuration de l'inferface graphique
		  vb.gui = true
	     
		
	 	end
		 # Provision et mise à jour de Oracle Linux 7
  		 ap.vm.provision "shell", path: "scripts/os_update.sh"

		 # Provision installation du framework oracle apex , deploiement de l'appli avec git
  		ap.vm.provision "shell", path: "scripts/apex.sh"
              
        end




#SERVEUR WEB
       config.vm.define "WEB_SERV" do |wb|
  		wb.vm.box = BOX_NAME

                wb.vm.hostname = "WEBSERV"
                #Config réseau
		wb.vm.network "private_network", ip: "192.168.0.120"

		#ouverture des ports
  		 wb.vm.network "forwarded_port", guest: 8080, host: 8083

		#Configuration du dossier de synchronisation
		wb.vm.synced_folder "./.vagrant", "/home/vagrant/WEB_SERV", type: "rsync"


		wb.vm.provider "virtualbox" do |vb|
		  vb.name = "WEB_SERV"
		  vb.memory = "2048"
		  vb.cpus = 2
		  #Configuration de l'inferface graphique
		  vb.gui = true
	     
		
	 	end
		 # Provision et mise à jour de Oracle Linux 7
  		wb.vm.provision "shell", path: "scripts/os_update.sh"

		 # Provision installation ORDS
  		wb.vm.provision "shell", path: "scripts/ords.sh"

        end





end 











