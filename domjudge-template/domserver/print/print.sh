#!/bin/bash

echo "" > /tmp/printfile
echo "-----------------------------" >>/tmp/printfile
echo "Regional AdaByron 2020 - URJC" >>/tmp/printfile
echo "Equipo: $2 ---- Aula: $3" >>/tmp/printfile
echo "-----------------------------" >>/tmp/printfile
echo "" >>/tmp/printfile
cat $1 >>/tmp/printfile
lp /tmp/printfile
rm /tmp/printfile
