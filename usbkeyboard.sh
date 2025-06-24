#!/bin/bash

# USB HID Klavye - Eksiksiz Tuş Haritası
# Bu script, tüm temel klavye tuşlarını içerir
# Kullanım: chmod +x usbkeyboard.sh && ./usbkeyboard.sh

# USB HID Tuş Kodları (Hex formatında) - Tam Liste
declare -A KEY_CODES

# Harf tuşları (a-z) - HID Usage ID
KEY_CODES[a]="04"
KEY_CODES[b]="05" 
KEY_CODES[c]="06"
KEY_CODES[d]="07"
KEY_CODES[e]="08"
KEY_CODES[f]="09"
KEY_CODES[g]="0a"
KEY_CODES[h]="0b"
KEY_CODES[i]="0c"
KEY_CODES[j]="0d"
KEY_CODES[k]="0e"
KEY_CODES[l]="0f"
KEY_CODES[m]="10"
KEY_CODES[n]="11"
KEY_CODES[o]="12"  # EKLENMIŞ - Eksik olan 'o' tuşu
KEY_CODES[p]="13"
KEY_CODES[q]="14"
KEY_CODES[r]="15"
KEY_CODES[s]="16"
KEY_CODES[t]="17"
KEY_CODES[u]="18"
KEY_CODES[v]="19"
KEY_CODES[w]="1a"
KEY_CODES[x]="1b"
KEY_CODES[y]="1c"
KEY_CODES[z]="1d"

# Rakam tuşları (1-9, 0)
KEY_CODES[1]="1e"
KEY_CODES[2]="1f"
KEY_CODES[3]="20"
KEY_CODES[4]="21"
KEY_CODES[5]="22"
KEY_CODES[6]="23"
KEY_CODES[7]="24"
KEY_CODES[8]="25"
KEY_CODES[9]="26"
KEY_CODES[0]="27"

# Özel tuşlar
KEY_CODES[enter]="28"
KEY_CODES[escape]="29"
KEY_CODES[backspace]="2a"
KEY_CODES[tab]="2b"
KEY_CODES[space]="2c"
KEY_CODES[minus]="2d"
KEY_CODES[equal]="2e"
KEY_CODES[leftbrace]="2f"
KEY_CODES[rightbrace]="30"
KEY_CODES[backslash]="31"
KEY_CODES[semicolon]="33"
KEY_CODES[apostrophe]="34"
KEY_CODES[grave]="35"
KEY_CODES[comma]="36"
KEY_CODES[dot]="37"
KEY_CODES[slash]="38"
KEY_CODES[capslock]="39"

# F tuşları
KEY_CODES[f1]="3a"
KEY_CODES[f2]="3b"
KEY_CODES[f3]="3c"
KEY_CODES[f4]="3d"
KEY_CODES[f5]="3e"
KEY_CODES[f6]="3f"
KEY_CODES[f7]="40"
KEY_CODES[f8]="41"
KEY_CODES[f9]="42"
KEY_CODES[f10]="43"
KEY_CODES[f11]="44"
KEY_CODES[f12]="45"

# Sistem tuşları
KEY_CODES[printscreen]="46"
KEY_CODES[scrolllock]="47"
KEY_CODES[pause]="48"
KEY_CODES[insert]="49"
KEY_CODES[home]="4a"
KEY_CODES[pageup]="4b"
KEY_CODES[delete]="4c"
KEY_CODES[end]="4d"
KEY_CODES[pagedown]="4e"

# Ok tuşları
KEY_CODES[right]="4f"
KEY_CODES[left]="50"
KEY_CODES[down]="51"
KEY_CODES[up]="52"

# Numpad tuşları
KEY_CODES[numlock]="53"
KEY_CODES[kp_divide]="54"
KEY_CODES[kp_multiply]="55"
KEY_CODES[kp_minus]="56"
KEY_CODES[kp_plus]="57"
KEY_CODES[kp_enter]="58"
KEY_CODES[kp_1]="59"
KEY_CODES[kp_2]="5a"
KEY_CODES[kp_3]="5b"
KEY_CODES[kp_4]="5c"
KEY_CODES[kp_5]="5d"
KEY_CODES[kp_6]="5e"
KEY_CODES[kp_7]="5f"
KEY_CODES[kp_8]="60"
KEY_CODES[kp_9]="61"
KEY_CODES[kp_0]="62"
KEY_CODES[kp_dot]="63"

# Modifier tuşları (Bit maskeleri)
MODIFIER_CTRL_LEFT="01"
MODIFIER_SHIFT_LEFT="02"
MODIFIER_ALT_LEFT="04"
MODIFIER_GUI_LEFT="08"
MODIFIER_CTRL_RIGHT="10"
MODIFIER_SHIFT_RIGHT="20"
MODIFIER_ALT_RIGHT="40"
MODIFIER_GUI_RIGHT="80"

# HID gadget cihazını kontrol et
check_hid_device() {
    if [ ! -c "/dev/hidg0" ]; then
        echo "Hata: /dev/hidg0 bulunamadı!"
        echo "USB HID gadget'ı etkinleştirin:"
        echo "modprobe libcomposite"
        echo "cd /sys/kernel/config/usb_gadget/"
        echo "mkdir -p g1/functions/hid.usb0"
        echo "echo 1 > g1/functions/hid.usb0/protocol"
        echo "echo 1 > g1/functions/hid.usb0/subclass"
        echo "echo 8 > g1/functions/hid.usb0/report_length"
        return 1
    fi
    return 0
}

# Karakteri tuş koduna çevir
char_to_key() {
    local char="$1"
    case "$char" in
        " ") echo "space" ;;
        "-") echo "minus" ;;
        "=") echo "equal" ;;
        "[") echo "leftbrace" ;;
        "]") echo "rightbrace" ;;
        "\\") echo "backslash" ;;
        ";") echo "semicolon" ;;
        "'") echo "apostrophe" ;;
        "\`") echo "grave" ;;
        ",") echo "comma" ;;
        ".") echo "dot" ;;
        "/") echo "slash" ;;
        *) echo "$char" ;;
    esac
}

# Tuş gönderme fonksiyonu
send_key() {
    local key="$1"
    local modifier="${2:-00}"
    
    # HID cihazını kontrol et
    if ! check_hid_device; then
        return 1
    fi
    
    # Karakteri tuş koduna çevir
    local keyname=$(char_to_key "$key")
    
    if [ -n "${KEY_CODES[$keyname]}" ]; then
        local keycode="${KEY_CODES[$keyname]}"
        echo "Gönderiliyor: $key -> $keyname (0x$keycode)"
        
        # USB HID raporu gönder: Modifier(1byte) + Reserved(1byte) + Key1(1byte) + Key2-6(5bytes)
        printf "\\x$modifier\\x00\\x$keycode\\x00\\x00\\x00\\x00\\x00" > /dev/hidg0
        sleep 0.05
        
        # Tuşu bırak (tüm sıfır)
        printf "\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00" > /dev/hidg0
        sleep 0.05
    else
        echo "Hata: '$key' tuşu tanımlı değil!"
        echo "Aranan: $keyname"
        return 1
    fi
}

# Metin yazma fonksiyonu
type_text() {
    local text="$1"
    echo "Yazılıyor: $text"
    
    for (( i=0; i<${#text}; i++ )); do
        local char="${text:$i:1}"
        local lower_char=$(echo "$char" | tr '[:upper:]' '[:lower:]')
        
        # Shift gerektiren karakterler
        case "$char" in
            [A-Z])
                send_key "$lower_char" "$MODIFIER_SHIFT_LEFT"
                ;;
            "!")
                send_key "1" "$MODIFIER_SHIFT_LEFT"
                ;;
            "@")
                send_key "2" "$MODIFIER_SHIFT_LEFT"
                ;;
            "#")
                send_key "3" "$MODIFIER_SHIFT_LEFT"
                ;;
            "$")
                send_key "4" "$MODIFIER_SHIFT_LEFT"
                ;;
            "%")
                send_key "5" "$MODIFIER_SHIFT_LEFT"
                ;;
            "^")
                send_key "6" "$MODIFIER_SHIFT_LEFT"
                ;;
            "&")
                send_key "7" "$MODIFIER_SHIFT_LEFT"
                ;;
            "*")
                send_key "8" "$MODIFIER_SHIFT_LEFT"
                ;;
            "(")
                send_key "9" "$MODIFIER_SHIFT_LEFT"
                ;;
            ")")
                send_key "0" "$MODIFIER_SHIFT_LEFT"
                ;;
            "_")
                send_key "-" "$MODIFIER_SHIFT_LEFT"
                ;;
            "+")
                send_key "=" "$MODIFIER_SHIFT_LEFT"
                ;;
            "{")
                send_key "[" "$MODIFIER_SHIFT_LEFT"
                ;;
            "}")
                send_key "]" "$MODIFIER_SHIFT_LEFT"
                ;;
            "|")
                send_key "\\" "$MODIFIER_SHIFT_LEFT"
                ;;
            ":")
                send_key ";" "$MODIFIER_SHIFT_LEFT"
                ;;
            "\"")
                send_key "'" "$MODIFIER_SHIFT_LEFT"
                ;;
            "<")
                send_key "," "$MODIFIER_SHIFT_LEFT"
                ;;
            ">")
                send_key "." "$MODIFIER_SHIFT_LEFT"
                ;;
            "?")
                send_key "/" "$MODIFIER_SHIFT_LEFT"
                ;;
            "~")
                send_key "\`" "$MODIFIER_SHIFT_LEFT"
                ;;
            *)
                # Normal karakter
                send_key "$char"
                ;;
        esac
        sleep 0.1  # Tuşlar arası bekle
    done
}

# Tuş kombinasyonu gönderme
send_combo() {
    local modifier="$1"
    local key="$2"
    echo "Kombinasyon: Modifier(0x$modifier) + $key"
    send_key "$key" "$modifier"
}

# Test fonksiyonları
test_all_letters() {
    echo "Tüm harfler test ediliyor..."
    for letter in {a..z}; do
        echo "Test: $letter"
        send_key "$letter"
        sleep 0.3
    done
    echo "Harf testi tamamlandı!"
}

test_numbers() {
    echo "Rakam testi..."
    for num in {0..9}; do
        send_key "$num"
        sleep 0.2
    done
}

test_special_keys() {
    echo "Özel tuş testi..."
    local special_keys=(space enter tab backspace escape)
    for key in "${special_keys[@]}"; do
        echo "Test: $key"
        send_key "$key"
        sleep 0.5
    done
}

# Eksik tuşları kontrol et
check_missing_keys() {
    echo "=== USB HID Klavye Tuş Haritası Kontrolü ==="
    local all_letters="abcdefghijklmnopqrstuvwxyz"
    local missing_keys=""
    
    for (( i=0; i<${#all_letters}; i++ )); do
        local letter="${all_letters:$i:1}"
        if [ -z "${KEY_CODES[$letter]}" ]; then
            missing_keys="$missing_keys$letter "
        fi
    done
    
    if [ -n "$missing_keys" ]; then
        echo "❌ Eksik tuşlar: $missing_keys"
    else
        echo "✅ Tüm harfler tanımlı!"
        echo "✅ Özellikle 'o' tuşu: 0x${KEY_CODES[o]}"
    fi
    
    echo "📊 Toplam tanımlı tuş: ${#KEY_CODES[@]}"
    echo "🔤 Harf tuşları: a-z (26 adet)"
    echo "🔢 Rakam tuşları: 0-9 (10 adet)"
    echo "⚙️  F tuşları: F1-F12 (12 adet)"
    echo "🎮 Özel tuşlar: Enter, Space, Tab, vb."
}

# Ana menü
show_menu() {
    echo ""
    echo "=== USB HID Klavye Kontrol Paneli ==="
    echo "1. Tek tuş gönder"
    echo "2. Metin yaz"
    echo "3. Tuş kombinasyonu (Ctrl+C, Alt+Tab vb.)"
    echo "4. Tüm harfleri test et"
    echo "5. Rakamları test et"
    echo "6. Özel tuşları test et"
    echo "7. Tuş haritasını kontrol et"
    echo "8. Çıkış"
    echo ""
}

# Ana program
main() {
    echo "🎹 USB HID Klavye Scripti Başlatıldı"
    check_hid_device || exit 1
    
    while true; do
        show_menu
        read -p "Seçiminiz (1-8): " choice
        
        case $choice in
            1)
                read -p "Gönderilecek tuş: " key
                send_key "$key"
                ;;
            2)
                read -p "Yazılacak metin: " text
                type_text "$text"
                ;;
            3)
                echo "Modifier seçin:"
                echo "1. Ctrl+Key"
                echo "2. Alt+Key" 
                echo "3. Shift+Key"
                read -p "Modifier (1-3): " mod_choice
                read -p "Tuş: " key
                
                case $mod_choice in
                    1) send_combo "$MODIFIER_CTRL_LEFT" "$key" ;;
                    2) send_combo "$MODIFIER_ALT_LEFT" "$key" ;;
                    3) send_combo "$MODIFIER_SHIFT_LEFT" "$key" ;;
                    *) echo "Geçersiz seçim!" ;;
                esac
                ;;
            4)
                test_all_letters
                ;;
            5)
                test_numbers
                ;;
            6)
                test_special_keys
                ;;
            7)
                check_missing_keys
                ;;
            8)
                echo "Çıkılıyor..."
                exit 0
                ;;
            *)
                echo "Geçersiz seçim!"
                ;;
        esac
        
        read -p "Devam etmek için Enter'a basın..."
    done
}

# Script doğrudan çalıştırıldığında
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    # Parametre ile çalıştırma
    case "${1:-}" in
        "check")
            check_missing_keys
            ;;
        "test")
            test_all_letters
            ;;
        "type")
            shift
            type_text "$*"
            ;;
        "key")
            send_key "$2"
            ;;
        *)
            main
            ;;
    esac
fi