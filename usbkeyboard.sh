#!/bin/bash

# Termux USB HID Klavye - Süper Basit
# Sadece o tuşunu ekler

# Tuş kodları
declare -A k
k[a]=04;k[b]=05;k[c]=06;k[d]=07;k[e]=08;k[f]=09;k[g]=0a;k[h]=0b;k[i]=0c;k[j]=0d;k[k]=0e;k[l]=0f;k[m]=10;k[n]=11;k[o]=12;k[p]=13;k[q]=14;k[r]=15;k[s]=16;k[t]=17;k[u]=18;k[v]=19;k[w]=1a;k[x]=1b;k[y]=1c;k[z]=1d
k[1]=1e;k[2]=1f;k[3]=20;k[4]=21;k[5]=22;k[6]=23;k[7]=24;k[8]=25;k[9]=26;k[0]=27
k[enter]=28;k[space]=2c;k[backspace]=2a

# Tek fonksiyon - tuş gönder
s() {
    [[ -n "${k[$1]}" ]] && printf "\\x00\\x00\\x${k[$1]}\\x00\\x00\\x00\\x00\\x00" > /dev/hidg0 && printf "\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00" > /dev/hidg0
}

# Kullan
s "$1"