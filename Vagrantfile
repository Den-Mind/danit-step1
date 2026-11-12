# -*- mode: ruby -*-
# vi: set ft=ruby :

# Завантаження змінних середовища з файлу .env якщо він існує
if File.exist?('.env')
  File.readlines('.env').each do |line|
    next if line.start_with?('#') || line.strip.empty?
    key, value = line.chomp.split('=', 2)
    ENV[key] = value
  end
end

# Значення за замовчуванням, якщо .env не знайдено
ENV['DB_HOST'] ||= '192.168.56.10'
ENV['DB_PORT'] ||= '3306'
ENV['DB_NAME'] ||= 'petclinic'
ENV['DB_USER'] ||= 'petclinic_user'
ENV['DB_PASS'] ||= 'petclinic_pass'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-26.04"
  config.vm.box_version = "202606.01.0"

  # Підзавдання I & II: База даних (DB_VM)
  config.vm.define "db_vm" do |db|
    db.vm.network "private_network", ip: ENV['DB_HOST']
    db.vm.hostname = "db-vm"
    
    db.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

    db.vm.provision "shell", path: "provision/db.sh", env: {
      "DB_NAME" => ENV['DB_NAME'],
      "DB_USER" => ENV['DB_USER'],
      "DB_PASS" => ENV['DB_PASS']
    }
  end

  # Підзавдання I & III: Застосунок (APP_VM)
  config.vm.define "app_vm" do |app|
    app.vm.network "private_network", ip: "192.168.56.11"
    app.vm.network "forwarded_port", guest: 8080, host: 8080
    app.vm.hostname = "app-vm"

    app.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 1
    end

     app.vm.provision "shell", path: "provision/app.sh", env: {
     "DB_HOST" => ENV['DB_HOST'],
     "DB_PORT" => ENV['DB_PORT'],
     "DB_NAME" => ENV['DB_NAME'],
     "DB_USER" => ENV['DB_USER'],
     "DB_PASS" => ENV['DB_PASS']
    }
  end
end