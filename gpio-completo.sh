#!/bin/bash

# Tabela com os pares de pinos e os respectivos números absolutos das GPIOs
# Formato: "PINO1 ABS1 PINO2 ABS2"
pairs=(
  "3 131 8 91"
  "5 130 10 90"
  "7 50 12 40"
  "11 64 16 25"
  "13 65 18 70"
  "15 68 22 69"
  "19 89 24 87"
  "21 88 26 51"
  "23 86 28 46"
  "27 48 32 45"
  "29 47 36 28"
  "31 42 37 31"
  "33 32 38 27"
  "35 33 40 3"
)

# Função para exportar GPIO se ainda não exportada
export_gpio() {
  if [ ! -d /sys/class/gpio/gpio$1 ]; then
    echo $1 > /sys/class/gpio/export
    sleep 0.1
  fi
}

# Função para configurar direção
set_direction() {
  echo $2 > /sys/class/gpio/gpio$1/direction
}

# Função para escrever valor
write_value() {
  echo $2 > /sys/class/gpio/gpio$1/value
}

# Função para ler valor
read_value() {
  cat /sys/class/gpio/gpio$1/value
}

echo "Iniciando teste de GPIOs conectadas..."
echo

for pair in "${pairs[@]}"; do
  read PIN1 ABS1 PIN2 ABS2 <<< "$pair"

  export_gpio $ABS1
  export_gpio $ABS2

  # Define GPIO ABS1 como saída e ABS2 como entrada
  set_direction $ABS1 out
  set_direction $ABS2 in

  ERR_WRITE=0
  ERR_READ=0

  # Teste com valor 1
  write_value $ABS1 1
  sleep 0.05
  val1=$(read_value $ABS2)
  if [ "$val1" != "1" ]; then
    ERR_READ=1
    ERR_WRITE=1
  fi

  # Teste com valor 0
  write_value $ABS1 0
  sleep 0.05
  val2=$(read_value $ABS2)
  if [ "$val2" != "0" ]; then
    ERR_READ=1
    ERR_WRITE=1
  fi

  # Mensagem de status
  echo -n "Pino $PIN1: "
  if [ $ERR_READ -eq 0 ]; then
    echo -n "Read OK "
  else
    echo -n "Read ERRO "
  fi
  if [ $ERR_WRITE -eq 0 ]; then
    echo "Write OK"
  else
    echo "Write ERRO"
  fi
done
