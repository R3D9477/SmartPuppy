#!/bin/bash

# PATH TO TARGET ROOT FS ON SD-CARD
ROOTFS_PATH="/media/$USER/rootfs"
# GOOGLE ACC (WITHOUT @DOMAIN)
PUPPY_SRC_GMAIL_ACC=""
# GOOGLE APPLICATION KEY (16-chars)
PUPPY_SRC_GMAIL_KEY=""
# DESTINATION EMAIL (INCLUDE @DOMAIN)
PUPPY_DST_EMAIL=""
# OPEN AI API KEY
PUPPY_OPENAI_API_KEY=""
# OPEN AI SYSTEM PROMPT
PUPPY_OPENAI_SYSTEM_PROMPT="If you see any cat, send back a two sentence narration detailing what it's doing as if you are David Attenborough."
# OPEN AI VOICE OF SPEECH
PUPPY_OPENAI_SPEECH_VOICE="echo"
# SPEECH GENERATOR: "openai" or "pyttsx3"
PUPPY_SPEECH_GENERATOR="openai"
# FIRST WIFI SSID
PUPPY_WIFI1_SSID=""
# FIRST WIFI PASS
PUPPY_WIFI1_PASS=""
# SECOND WIFI SSID
PUPPY_WIFI2_SSID=""
# SECOND WIFI PASS
PUPPY_WIFI2_PASS=""
# MOVEMENT DETECTION GPIO PIN
PUPPY_WOOF_PIN=4
# PUPPY TIME ZONE
PUPPY_TIME_ZONE="Europe/Warsaw"
# PUPPY VIDEO STORAGE MAX SIZE (MB)
PUPPY_VIDEO_STORAGE_MAX_SIZE_MB=5000
# PUPPY: MAKE SHOTS
PUPPY_SHOTS_COUNT=3
# PUPPY: MAKE VIDEOS
PUPPY_VIDEO_COUNT=3
# PUPPY: MAKE VIDEOS
PUPPY_VIDEO_DURATION_MS=15000
# PUPPY: ROTATE CAMERA
PUPPY_CAMERA_ROTATION=180

#==================================================================================================

sudo apt update
sudo apt install qemu-user-static -y
sudo cp /usr/bin/qemu-arm-static ${ROOTFS_PATH}/usr/bin/
sudo mount -t proc /proc ${ROOTFS_PATH}/proc

#--------------------------------------------------------------------------------------------------

sudo mkdir -p ${ROOTFS_PATH}/root/.mutt

sudo tee ${ROOTFS_PATH}/root/.mutt/muttrc > /dev/null <<EOT
set from="${PUPPY_SRC_GMAIL_ACC}@gmail.com"
set realname="Puppy"
set smtp_url="smtps://${PUPPY_SRC_GMAIL_ACC}@smtp.gmail.com"
set smtp_pass="${PUPPY_SRC_GMAIL_KEY}"
EOT

sudo chroot ${ROOTFS_PATH} bash -c "echo 'This is test WOOF from Puppy' | mutt -s 'Puppy test' ${PUPPY_DST_EMAIL}"

#--------------------------------------------------------------------------------------------------

sudo mkdir -p ${ROOTFS_PATH}/puppy

echo "export PUPPY_DST_EMAIL=\"${PUPPY_DST_EMAIL}\""                        | sudo tee    ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_OPENAI_API_KEY=\"${PUPPY_OPENAI_API_KEY}\""              | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_OPENAI_SYSTEM_PROMPT=\"${PUPPY_OPENAI_SYSTEM_PROMPT}\""  | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_OPENAI_SPEECH_VOICE=\"${PUPPY_OPENAI_SPEECH_VOICE}\""    | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_SPEECH_GENERATOR=\"${PUPPY_SPEECH_GENERATOR}\""          | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_WIFI1_SSID=\"${PUPPY_WIFI1_SSID}\""                      | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_WIFI1_PASS=\"${PUPPY_WIFI1_PASS}\""                      | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_WIFI2_SSID=\"${PUPPY_WIFI2_SSID}\""                      | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_WIFI2_PASS=\"${PUPPY_WIFI2_PASS}\""                      | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_WOOF_PIN=\"${PUPPY_WOOF_PIN}\""                          | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_TIME_ZONE=\"${PUPPY_TIME_ZONE}\""                        | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_SHOTS_COUNT=\"${PUPPY_SHOTS_COUNT}\""                    | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_VIDEO_COUNT=\"${PUPPY_VIDEO_COUNT}\""                    | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_VIDEO_DURATION_MS=\"${PUPPY_VIDEO_DURATION_MS}\""        | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh
echo "export PUPPY_CAMERA_ROTATION=\"${PUPPY_CAMERA_ROTATION}\""            | sudo tee -a ${ROOTFS_PATH}/puppy/puppy_env.sh

sudo cp *.py ${ROOTFS_PATH}/puppy/
sudo cp *.sh ${ROOTFS_PATH}/puppy/
sudo chroot ${ROOTFS_PATH} bash -c "chmod +x /puppy/*.sh"

sudo mkdir -p ${ROOTFS_PATH}/etc/systemd/system
sudo cp *.service ${ROOTFS_PATH}/etc/systemd/system/
sudo chroot ${ROOTFS_PATH} systemctl enable puppy

#--------------------------------------------------------------------------------------------------

sudo chroot ${ROOTFS_PATH} update && upgrade -y
sudo chroot ${ROOTFS_PATH} apt install mutt libcap-dev ffmpeg libsm6 libxext6 espeak python3-full pip python3-dev -y
sudo chroot ${ROOTFS_PATH} apt --fix-broken install -y
sudo chroot ${ROOTFS_PATH} sudo dpkg --configure -a

sudo rm ${ROOTFS_PATH}/usr/lib/python3.*/EXTERNALLY-MANAGED
sudo chroot ${ROOTFS_PATH} pip install Pillow openai opencv-python elevenlabs python-dotenv torch torchvision exif langchain-core langchain-openai pyttsx3

#--------------------------------------------------------------------------------------------------

sudo umount ${ROOTFS_PATH}/proc
