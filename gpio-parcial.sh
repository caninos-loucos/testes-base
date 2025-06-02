#!/bin/bash

# Lista de pares: PINO GPIO
# Testa cada GPIO individualmente como output
pins_and_gpios=(
  "3 131"
  "8 91"
  "5 130"
  "10 90"
  "7 50"
  "12 40"
  "11 64"
  "16 25"
  "13 65"
  "18 70"
  "15 68"
  "22 69"
  "19 89"
  "24 87"
  "21 88"
  "26 51"
  "23 86"
  "28 46"
  "27 48"
  "32 45"
  "29 47"
  "36 28"
  "31 42"
  "37 31"
  "33 32"
  "38 27"
  "35 33"
  "40 3"
)

for pair in "${pins_and_gpios[@]}"; do
  read PIN GPIO <<< "$pair"

  echo "Testando Pino $PIN (GPIO $GPIO)..."

  if [ ! -d /sys/class/gpio/gpio$GPIO ]; then
    echo $GPIO > /sys/class/gpio/export
    sleep 0.1
  fi

  echo out > /sys/class/gpio/gpio$GPIO/direction
  echo 1 > /sys/class/gpio/gpio$GPIO/value
  val1=$(cat /sys/class/gpio/gpio$GPIO/value)

  echo 0 > /sys/class/gpio/gpio$GPIO/value
  val0=$(cat /sys/class/gpio/gpio$GPIO/value)

  if [[ "$val1" == "1" && "$val0" == "0" ]]; then
    echo "Pino $PIN: Write/Read OK"
  else
    echo "Pino $PIN: Write/Read ERRO"
  fi
done
