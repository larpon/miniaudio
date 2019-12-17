# v-miniaudio
Vrap of the excellent [miniaudio](https://github.com/dr-soft/miniaudio) C audio library

Example `main.v`
```
module main

import os
import time

import miniaudio as ma

fn main() {
    os.clear()

    wav_file := os.home_dir()+'Projects/v-pg/miniaudio/test.wav'

    flac_file := os.home_dir()+'Projects/v-pg/miniaudio/test.flac'

    mp3_file := os.home_dir()+'Projects/v-pg/miniaudio/test.mp3'


    println('Loading wav')
    mut a := ma.from(wav_file)
    mut length := int(a.length())

    println('Playing wav '+length.str())
    a.play()
    time.sleep_ms(length)

    println('Playing wav '+length.str())
    a.play()
    time.sleep_ms(length)

    a.free()

    //---
    println('Loading flac')
    mut b := ma.from(flac_file)
    length = int(b.length())

    println('Playing flac '+length.str())
    b.play()

    println('Sleeping flac '+length.str())
    time.sleep_ms(length+1)

    b.free()

    //---
    println('Loading mp3')
    mut c := ma.from(mp3_file)
    length = int(c.length())

    println('Playing mp3 '+length.str())
    c.play()

    println('Sleeping mp3 '+length.str())
    time.sleep_ms(length+1)

    println('Freeing mp3')
    c.free()

}
```

