Vagrant.configure("2") do |config|
  config.hostmanager.enabled = false                          # Update /etc/hosts with entries from other VMs
  config.hostmanager.manage_host = false                      # Don't update /etc/hosts on the Hypervisor
  config.hostmanager.ignore_private_ip = false
  config.hostmanager.include_offline = false
  config.vm.provision :hostmanager                            # update /etc/hosts during provisioning
  config.vm.define "puppetserver" do |server|
    server.vm.box = "centos/7"                                # base image we use
    server.vm.hostname = "puppetserver.localdomain"           # hostname that's configured within the VM
    # server.vm.network :private_network
    server.vm.network "forwarded_port", guest: 9090, host: 9090
    server.vm.network "forwarded_port", guest: 9100, host: 9100
    server.vm.network "forwarded_port", guest: 80, host: 8080
    server.vm.network "forwarded_port", guest: 8501, host: 8501
    server.vm.network "forwarded_port", guest: 443, host: 8443
    server.vm.provider :vmware_desktop do |vmware|
      vmware.memory = 4096                                    # Ram in MB
      vmware.cpus = 2
      vmware.vmx["displayName"] = "puppetserver"
      vmware.vmx["ethernet0.pcislotnumber"] = "32"
    end
    server.vm.provision "shell", inline: <<-SHELL
      /bin/sed -i '/search.*/d' /etc/resolv.conf
      /bin/sed -i '/^127.0.1.1/d' /etc/hosts
      /bin/grep -Fq "$(/bin/hostname -I)" /etc/hosts || echo "$(/bin/hostname -I) $(/bin/hostname --fqdn) $(/bin/hostname -s) puppet # locally managed" >> /etc/hosts
      /bin/yum install --assumeyes https://yum.puppetlabs.com/puppet7/puppet7-release-el-7.noarch.rpm
      /bin/yum install --assumeyes puppet puppetserver
      source /etc/profile.d/puppet-agent.sh
      echo 'export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"' > /etc/profile.d/path.sh
      /opt/puppetlabs/bin/puppet module install puppet-r10k --environment production
      # /opt/puppetlabs/bin/puppet resource service puppetserver enable=false ensure=stopped
      # rm -rf /etc/puppetlabs/puppet/ssl/* /etc/puppetlabs/puppetserver/ca/*
      # /opt/puppetlabs/bin/puppetserver ca generate --certname puppetserver.localdomain --subject-alt-names puppet.localdomain,puppet,puppetserver,puppetserver.localdomain --ca-client
      /opt/puppetlabs/bin/puppet resource service puppetserver enable=true ensure=running
      /opt/puppetlabs/bin/puppet apply -e 'include r10k'
      /bin/sed -i 's#remote:.*#remote: https://github.com/makenny/makenny-control_repo.git#' /etc/puppetlabs/r10k/r10k.yaml
      /bin/yum install --assumeyes git
      /bin/r10k deploy environment production --puppetfile --verbose --generate-types
      /opt/puppetlabs/bin/puppet agent -t # --server puppetserver.localdomain
      /opt/puppetlabs/bin/puppet agent -t # --server puppetserver.localdomain
    SHELL
  end
  config.vm.define "agentcentos" do |centos|
    centos.vm.box = "centos/7"                                # base image we use
    centos.vm.hostname = "agentcentos.localdomain"            # hostname that's configured within the VM
    centos.vm.network :private_network
    centos.vm.provider :vmware_desktop do |vmware|
      vmware.memory = 1024                                    # Ram in MB
      vmware.cpus = 1
      vmware.vmx["displayName"] = "agentcentos"
      vmware.vmx["ethernet0.pcislotnumber"] = "32"
    end
    centos.vm.provision "shell", inline: <<-SHELL
      sed -i '/search.*/d' /etc/resolv.conf
      sed -i '/127.0.0.1.*centosclient.*centosclient/d' /etc/hosts
      yum install --assumeyes https://yum.puppetlabs.com/puppet7/puppet7-release-el-7.noarch.rpm
      yum install --assumeyes puppet
      source /etc/profile.d/puppet-agent.sh
      echo 'export PATH="/usr/local/bin:/usr/local/sbin:${PATH}"' > /etc/profile.d/path.sh
      puppet agent -t --environment production --server puppetserver.localdomain
      puppet agent -t --environment production --server puppetserver.localdomain
    SHELL
  end
  config.vm.define "agentarch" do |arch|
    arch.vm.box = "generic/arch"                               # base image we use
    arch.vm.hostname = "agentarch.localdomain"                 # hostname that's configured within the VM
    arch.vm.network :private_network
    arch.vm.provider :vmware_desktop do |vmware|
      vmware.memory = 1024                                     # Ram in MB
      vmware.cpus = 1
      vmware.vmx["displayName"] = "agentarch"
      vmware.vmx["ethernet0.pcislotnumber"] = "32"
    end
    arch.vm.provision "shell", inline: <<-SHELL
      sed -i '/search.*/d' /etc/resolv.conf
      sed -i '/127.0.0.1.*archclient.*archclient/g' /etc/hosts
      pacman -S --refresh --sysupgrade --noconfirm puppet --ignore linux,linux-headers,linux-api-headers,linux-firmware
      puppet agent -t --environment production --server puppetserver.localdomain
    SHELL
  end
  config.vm.define "agentubuntu" do |ubuntu|
    ubuntu.vm.box = "generic/ubuntu2004"                       # base image we use
    ubuntu.vm.hostname = "agentubuntu.localdomain"             # hostname that's configured within the VM
    ubuntu.vm.network :private_network
    ubuntu.vm.provider :vmware_desktop do |vmware|
      vmware.memory = 1024                                     # Ram in MB
      vmware.cpus = 1
      vmware.vmx["displayName"] = "agentubuntu"
      vmware.vmx["ethernet0.pcislotnumber"] = "32"
    end
    ubuntu.vm.provision "shell", inline: <<-SHELL
      sed -i '/search.*/d' /etc/resolv.conf
      sed -i '/127.0.0.1.*ubuntuclient.*ubuntuclient/g' /etc/hosts
      wget https://apt.puppet.com/puppet7-release-focal.deb
      export DEBIAN_FRONTEND=noninteractive
      dpkg -i puppet7-release-focal.deb
      rm puppet7-release-focal.deb
      apt-get update
      apt-get install -y puppet-agent
      source /etc/profile.d/puppet-agent.sh
      puppet agent -t --environment production --server puppetserver.localdomain
      puppet agent -t --environment production --server puppetserver.localdomain
    SHELL
  end
end

# https://www.vagrantup.com/docs/virtualbox/configuration.html
# https://github.com/hashicorp/vagrant/wiki/Available-Vagrant-Plugins
# https://app.vagrantup.com/archlinux/boxes/archlinux
# https://www.vagrantup.com/docs/vagrantfile/vagrant_settings.html
