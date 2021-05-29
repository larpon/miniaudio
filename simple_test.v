module main

import os
import math
import time

import miniaudio as ma

fn test_audio(){
	basedir := os.real_path( os.dir(@FILE) )
    wav_file := os.join_path( basedir, 'assets', 'audio.wav')
    flac_file := os.join_path( basedir, 'assets', 'audio.flac')
    mp3_file := os.join_path( basedir, 'assets', 'audio.mp3')

    mut s1 := ma.sound(wav_file)
    mut s2 := ma.sound(flac_file)
    mut s3 := ma.sound(mp3_file)

    mut d := ma.device()
    // d.volume(0.5) // Set (master) volume for device

    d.add('sound id 1',s1)
    d.add('sound id 2',s2)
    d.add('sound id 3',s3)

    s1.play()
    time.sleep(50 * time.millisecond)
    s3.play()
    time.sleep(200 * time.millisecond)
    s3.seek(20)
    s2.play()

    // Fade out s1
    mut vol := 1.0
    for ee := s1.length(); ee > 0; ee = ee - 16.377 {
        vol = vol - 0.016
        s1.volume(vol)
        time.sleep(16 * time.millisecond)
    }
    mut longest := int(math.max(s1.length(), s2.length()))
    longest = int(math.max(longest, s3.length()))
    time.sleep(longest * time.millisecond)
    d.free()
}

