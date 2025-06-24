#!/bin/bash

# Basit USB HID Klavye Scripti
# Sadece eksik tuşları ekler, karmaşık yapmaz

# HID Tuş Kodları
declare -A keys
keys[a]=04; keys[b]=05; keys[c]=06; keys[d]=07; keys[e]=08; keys[f]=09
keys[g]=0a; keys[h]=0b; keys[i]=0c; keys[j]=0d; keys[k]=0e; keys[l]=0f
keys[m]=10; keys[n]=11; keys[o]=12; keys[p]=13; keys[q]=14; keys[r]=15
keys[s]=16; keys[t]=17; keys[u]=18; keys[v]=19; keys[w]=1a; keys[x]=1b
keys[y]=1c; keys[z]=1d

keys[1]=1e; keys[2]=1f; keys[3]=20; keys[4]=21; keys[5]=22; keys[6]=23
keys[7]=24; keys[8]=25; keys[9]=26; keys[0]=27

keys[enter]=28; keys[escape]=29; keys[backspace]=2a; keys[tab]=2b
keys[space]=2c; keys[-]=2d; keys[=]=2e; keys[\[]=2f; keys[\]]=30
keys[\\]=31; keys[;]=33; keys[\']=34; keys[\`]=35; keys[,]=36
keys[.]=37; keys[/]=38

keys[f1]=3a; keys[f2]=3b; keys[f3]=3c; keys[f4]=3d; keys[f5]=3e; keys[f6]=3f
keys[f7]=40; keys[f8]=41; keys[f9]=42; keys[f10]=43; keys[f11]=44; keys[f12]=45

keys[right]=4f; keys[left]=50; keys[down]=51; keys[up]=52

# Tuş gönder fonksiyonu
send_key() {
    local key="$1"
    local mod="${2:-00}"
    
    if [[ -n "${keys[$key]}" ]]; then
        local code="${keys[$key]}"
        printf "\\x$mod\\x00\\x$code\\x00\\x00\\x00\\x00\\x00" > /dev/hidg0
        printf "\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00" > /dev/hidg0
    else
        echo "Tuş bulunamadı: $key"
    fi
}

# Metin yaz
type_text() {
    for (( i=0; i<${#1}; i++ )); do
        char="${1:$i:1}"
        case "$char" in
            [A-Z]) 
                lower=$(echo "$char" | tr '[:upper:]' '[:lower:]')
                send_key "$lower" "02"
                ;;
            " ") send_key "space" ;;
            *) send_key "$char" ;;
        esac
        sleep 0.1
    done
}

# Kullanım
case "$1" in
    "key")
        send_key "$2"
        ;;
    "type")
        type_text "$2"
        ;;
    "test")
        echo "o tuşu test:"
        send_key "o"
        ;;
    *)
        echo "Kullanım:"
        echo "$0 key o        # o tuşuna bas"
        echo "$0 type test    # test yaz"
        echo "$0 test         # o tuşunu test et"
        ;;
esac