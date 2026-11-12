#!/bin/bash
set -e

APP_USER="springapp"
APP_DIR="/home/${APP_USER}"
PROJECT_DIR="${APP_DIR}/spring-petclinic"

echo ">>> Installing Java JDK 17, Git and priorities..."
sudo apt-get update
sudo apt-get install -y openjdk-17-jdk git curl

echo ">>> Create unroot user ${APP_USER}..."
if ! id "${APP_USER}" &>/dev/null; then
    sudo useradd -m -s /bin/bash "${APP_USER}"
fi

echo ">>> Cloning repo Spring PetClinic..."
if [ ! -d "${PROJECT_DIR}" ]; then
    sudo -u "${APP_USER}" git clone https://github.com/Den-Mind/danit-step1.git "${PROJECT_DIR}"
else
    cd "${PROJECT_DIR}"
    sudo -u "${APP_USER}" git pull
fi

echo ">>> Building app with Maven Wrapper (testing and packaging)..."
cd "${PROJECT_DIR}/PetClinic"
sudo -u "${APP_USER}" chmod +x mvnw
sudo -u "${APP_USER}" ./mvnw clean package -DskipTests

echo ">>> Search and coping JAR-file..."
JAR_FILE=$(find "${PROJECT_DIR}/PetClinic/target" -name "spring-petclinic-*.jar" | head -n 1)
if [ -z "$JAR_FILE" ]; then
    echo "Error: JAR-file not found!"
    exit 1
fi

sudo cp "$JAR_FILE" "${APP_DIR}/spring-petclinic.jar"
sudo chown "${APP_USER}:${APP_USER}" "${APP_DIR}/spring-petclinic.jar"

echo ">>> Creating Systemd service for auto-start..."
sudo tee /etc/systemd/system/petclinic.service > /dev/null <<EOF
[Unit]
    Description=Spring PetClinic Application
    After=network.target mysql.service

[Service]
    User=${APP_USER}
    WorkingDirectory=${APP_DIR}
    ExecStart=/usr/bin/java -jar ${APP_DIR}/spring-petclinic.jar \
        --spring.profiles.active=mysql \
        --spring.datasource.url=jdbc:mysql://${DB_HOST}:${DB_PORT}/${DB_NAME}?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true \
        --spring.datasource.username=${DB_USER} \
        --spring.datasource.password=${DB_PASS}
SuccessExitStatus=143
Restart=always
RestartSec=10

[Install]
    WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable petclinic
sudo systemctl restart petclinic

echo ">>> App Spring PetClinic successfully deployed and running!"