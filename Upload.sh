#!/bin/bash

#Lists and chooses highest port, most likely to be Leonardo
config="/home/eden/Paths.json"

TEST_SUITE_LOC="$( jq -r '.TestSuiteLoc' "$config" )"
ARDUINO_HEX="$( jq -r '.ArduinoLeonardoHex' "$config" )"

RESET_SCRIPT="$( jq -r '.ResetLeonardoScript' "$config" )"

HEX_PATH="$TEST_SUITE_LOC"/"$ARDUINO_HEX"

summary_file="$( jq -r '.SetupSummaryFile' "$config" )"


summary="
***********************************************
              NFC Upload Summary:
***********************************************
"
print_summary(){
while IFS= read -r line
do
   echo "$line"
done < <(printf '%s\n' "$summary")
}

print_succeed_or_fail(){
    if [ $? -eq "0" ]
    then
        result="$( echo  ${FUNCNAME[1]} "- Success ✅")"
        echo "$result"
        newline=$'\n'
        summary="$summary${newline}$result"

    else
       
        result="$( echo  ${FUNCNAME[1]} "- Failed ❌")"
        echo "$result"
        newline=$'\n'
        summary="$summary${newline}$result"
    fi
}

list_paths(){
for sysdevpath in $(find /sys/bus/usb/devices/usb*/ -name dev); do
    (
        syspath="${sysdevpath%/dev}"
        devname="$(udevadm info -q name -p $syspath)"
        [[ "$devname" == "bus/"* ]] && exit
        eval "$(udevadm info -q property --export -p $syspath)"
        [[ -z "$ID_SERIAL" ]] && exit
        result="$(echo "$ID_SERIAL" | grep "Arduino")"
        [[ -z "$result" ]] && exit
        #echo $result

        Port="/dev/$devname"
        new_port="$(echo $Port | grep "/dev/ttyACM")"
        [[ -z "$new_port" ]] && exit

        echo $new_port
        #echo $Port
    )
done

}

find_leonardo_port(){
    port="$(list_paths)"
    [[ -z "$port" ]] && print_succeed_or_fail && echo "Arduino port not found" && exit 1
}

reset_port(){
sudo -u eden "$TEST_SUITE_LOC"/"$RESET_SCRIPT"  "$port"
print_succeed_or_fail
}


upload_to_leonardo(){
/usr/bin/avrdude -C /etc/avrdude.conf -v -patmega32u4 -cavr109 -P "$port" -b57600 -D -Uflash:w:"$HEX_PATH":i
print_succeed_or_fail
}

list_paths
find_leonardo_port

reset_port
sleep 1

list_paths
find_leonardo_port
upload_to_leonardo

print_summary >> "$summary_file"

