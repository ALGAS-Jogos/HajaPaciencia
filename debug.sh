#!/bin/bash

zip -r "temp.zip" *
mv temp.zip $RANDOM.love
kdeconnect-cli --share *.love -n LeonnaNCel
sleep 2
rm *.love
