#!/bin/bash

declare -A hid_usage_id=(
    ["0x61"]="0x04" ["0x62"]="0x05" ["0x63"]="0x06" ["0x64"]="0x07" ["0x65"]="0x08"
    ["0x66"]="0x09" ["0x67"]="0x0A" ["0x68"]="0x0B" ["0x69"]="0x0C" ["0x6A"]="0x0D"
    ["0x6B"]="0x0E" ["0x6C"]="0x0F" ["0x6D"]="0x10" ["0x6E"]="0x11" ["0x6F"]="0x12"
    ["0x70"]="0x13" ["0x71"]="0x14" ["0x72"]="0x15" ["0x73"]="0x16" ["0x74"]="0x17"
    ["0x75"]="0x18" ["0x76"]="0x19" ["0x77"]="0x1A" ["0x78"]="0x1B" ["0x79"]="0x1C"
    ["0x7A"]="0x1D" ["0x41"]="0x04" ["0x42"]="0x05" ["0x43"]="0x06" ["0x44"]="0x07"
    ["0x45"]="0x08" ["0x46"]="0x09" ["0x47"]="0x0A" ["0x48"]="0x0B" ["0x49"]="0x0C"
    ["0x4A"]="0x0D" ["0x4B"]="0x0E" ["0x4C"]="0x0F" ["0x4D"]="0x10" ["0x4E"]="0x11"
    ["0x4F"]="0x12" ["0x50"]="0x13" ["0x51"]="0x14" ["0x52"]="0x15" ["0x53"]="0x16"
    ["0x54"]="0x17" ["0x55"]="0x18" ["0x56"]="0x19" ["0x57"]="0x1A" ["0x58"]="0x1B"
    ["0x59"]="0x1C" ["0x5A"]="0x1D" ["0x30"]="0x27" ["0x31"]="0x1E" ["0x32"]="0x1F" ["0x33"]="0x20" ["0x34"]="0x21"
    ["0x35"]="0x22" ["0x36"]="0x23" ["0x37"]="0x24" ["0x38"]="0x25" ["0x39"]="0x26"
)

declare -A escape_to_hid=(
    ["1b"]="0x29"                   # ESC tuşu
    ["1b4f50"]="0x3a"               # F1 tuşu
    ["1b4f51"]="0x3b"               # F2 tuşu
    ["1b4f52"]="0x3c"               # F3 tuşu
    ["1b4f53"]="0x3d"               # F4 tuşu
    ["1b5b31357e"]="0x3e"           # F5 tuşu
    ["1b5b31377e"]="0x3f"           # F6 tuşu
    ["1b5b31387e"]="0x40"           # F7 tuşu
    ["1b5b31397e"]="0x41"           # F8 tuşu
    ["1b5b32307e"]="0x42"           # F9 tuşu
    ["1b5b32317e"]="0x43"           # F10 tuşu
    ["1b5b32337e"]="0x44"           # F11 tuşu
    ["1b5b32347e"]="0x45"           # F12 tuşu
    ["1b5b337e"]="0x4c"             # DEL tuşu
    ["1b5b41"]="0x52"               # Yukarı ok tuşu
    ["1b5b42"]="0x51"               # Aşağı ok tuşu
    ["1b5b43"]="0x4f"               # Sağ ok tuşu
    ["1b5b44"]="0x50"               # Sol ok tuşu
)

# Buffer ile gelen diziyi biriktir
buffer=""
start_time=0
timeout_ms=90  # 90 ms timeout

# showkey -a ile tuş basımlarını izleyin
stdbuf -oL showkey -a | while read -r line; do
    # Hex değerini ayıkla
    hex_value=$(echo $line | awk '{for(i=1;i<=NF;i++) if($i ~ /^0x/) print $i}' | sed 's/0x//')

    if [[ $hex_value == "1b" ]]; then
        # ESC algılandı, buffer başlat ve zamanlayıcıyı sıfırla
        buffer="1b"
        start_time=$(date +%s%3N)  # Şu anki zamanı milisaniye cinsinden al
        echo "Hex value: 0x$hex_value, HID Usage ID: ${escape_to_hid[$buffer]}"
    elif [[ -n $buffer ]]; then
        # Eğer buffer aktifse (ESC basılmışsa), gelen diğer değerleri buffer'a ekle
        buffer+="$hex_value"
        current_time=$(date +%s%3N)

        # Eğer 3. hex değeri 31, 32 veya 33 ise ek byte bekle
        if [[ ${#buffer} -eq 6 && ($hex_value == "31" || $hex_value == "32" || $hex_value == "33") ]]; then
            read -r next_line
            next_hex_value=$(echo $next_line | awk '{for(i=1;i<=NF;i++) if($i ~ /^0x/) print $i}' | sed 's/0x//')
            buffer+="$next_hex_value"
            if [[ $hex_value == "31" || $hex_value == "32" ]]; then
                read -r next_line
                next_hex_value=$(echo $next_line | awk '{for(i=1;i<=NF;i++) if($i ~ /^0x/) print $i}' | sed 's/0x//')
                buffer+="$next_hex_value"
            fi
        fi

        # Zaman aşımı kontrolü
        if (( current_time - start_time > timeout_ms )); then
            # Eğer buffer bir kaçış dizisine eşleşiyorsa işleme al
            if [[ -n ${escape_to_hid[$buffer]} ]]; then
                hid_value=${escape_to_hid[$buffer]}
                echo "Kaçış Dizisi: $buffer, HID Usage ID: $hid_value"

                # HID raporu oluştur (örnek)
                third_byte=$(printf "%02x" $((hid_value & 0xff)))

                echo -ne "\x00\x00\x${third_byte}\x00\x00\x00\x00\x00" > /dev/hidg0
                echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" > /dev/hidg0
            else
                echo "Kaçış Dizisi: $buffer, HID Usage ID: Unknown"
            fi

            # Buffer'ı sıfırla
            buffer=""
        fi
    else
        # Kaçış dizisi değilse, doğrudan harfleri kontrol et
        hid_value=${hid_usage_id["0x$hex_value"]}
        if [[ -n $hid_value ]]; then
            if [[ $hex_value =~ ^[41-5A]$ ]]; then
                echo "Hex value: 0x$hex_value, HID Usage ID: $hid_value (Shifted)"
            else
                echo "Hex value: 0x$hex_value, HID Usage ID: $hid_value"
                                third_byte=$(printf "%02x" $((hid_value & 0xff)))

                echo -ne "\x00\x00\x${third_byte}\x00\x00\x00\x00\x00" > /dev/hidg0
                echo -ne "\x00\x00\x00\x00\x00\x00\x00\x00" > /dev/hidg0
            fi
        else
            echo "Hex value: 0x$hex_value, HID Usage ID: Unknown"
        fi
    fi
    sleep 0.01  # 10 ms bekleme
done
