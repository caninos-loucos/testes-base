#!/bin/bash

set -e

function stop_if_no() {
    read -rp "$1 (s/n): " resp
    if [[ "$resp" != "s" ]]; then
        echo "Teste interrompido."
        exit 1
    fi
}

echo "Testando HDMI"
xrandr -s 640x480
sleep 5
xrandr -s 1920x1080
stop_if_no "A resolução mudou?"

echo "Testando áudio HDMI"
speaker-test -t pink -l 0 > /dev/null 2>&1 & sleep 5; kill $! > /dev/null 2>&1

echo "Testando saída de áudio, coloque o fone e pressione enter"
pulseaudio --start >/dev/null 2>&1
read -r
pacmd set-default-sink 1
speaker-test -t pink -l 0 > /dev/null 2>&1 & sleep 5; kill $! > /dev/null 2>&1
pacmd set-default-sink 0

stop_if_no "Ambos áudios funcionaram?"

echo "Salvando estado do armazenamento"
lsblk > /tmp/lsblk_before.txt

echo "Coloque um cartão SD e pressione enter"
read -r
lsblk > /tmp/lsblk_after.txt

if diff /tmp/lsblk_before.txt /tmp/lsblk_after.txt > /dev/null; then
    echo "Erro de cartão SD"
    exit 1
fi

echo "Testando microfone, pressione enter e faça algum barulho"
read -r
arecord -d 5 record.wav > /dev/null 2>&1

echo "Reproduzindo áudio do microfone"
aplay record.wav > /dev/null 2>&1
rm record.wav

stop_if_no "Você ouviu sua gravação?"

echo "Testando LEDs programáveis"
sudo chmod 777 /sys/class/leds/led1/trigger
sudo chmod 777 /sys/class/leds/led2/trigger
echo heartbeat | sudo tee /sys/class/leds/led1/trigger
echo default-on | sudo tee /sys/class/leds/led2/trigger

stop_if_no "O LED verde está piscando e o azul aceso?"

echo default-on | sudo tee /sys/class/leds/led1/trigger
echo heartbeat | sudo tee /sys/class/leds/led2/trigger


echo "Testando bluetooth, certifique-se que existe um dispositivo bluetooth próximo à placa e pressione enter"
read -r
bt_devices=$(sudo hcitool scan | tail -n +2)

if [[ -z "$bt_devices" ]]; then
    echo "Erro no bluetooth"
    exit 1
fi

echo "Testando conexão Wi-Fi"
echo "1) Conectar à rede padrão (SSID: Citi 6)"
echo "2) Conectar a outra rede"
read -rp "Escolha uma opção (1/2): " wifi_option

if [[ "$wifi_option" == "1" ]]; then
    ssid="Citi 6"
    password="1cbe991a14"
elif [[ "$wifi_option" == "2" ]]; then
    read -rp "Digite o SSID da rede Wi-Fi: " ssid
    read -rsp "Digite a senha da rede Wi-Fi: " password
    echo
else
    echo "Opção inválida."
    exit 1
fi

if ! sudo nmcli dev wifi connect "$ssid" password "$password"; then
    echo "Erro ao conectar ao Wi-Fi"
    exit 1
fi

if ! ping -c 5 8.8.8.8 > /dev/null; then
    echo "Erro no Wi-Fi"
    exit 1
fi


if ! ping -c 5 8.8.8.8 > /dev/null; then
    echo "Erro no Wi-Fi"
    sudo nmcli con down id "Citi 6"
    exit 1
fi
sudo nmcli con down id "$ssid"

echo "Conecte um cabo de rede e pressione enter"
read -r
sleep 3
if ! ping -c 5 8.8.8.8 > /dev/null; then
    echo "Erro no Ethernet"
    exit 1
fi

echo "Todos os testes foram concluídos com sucesso."
