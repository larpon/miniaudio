module main

import os
import time
import miniaudio as ma

fn main() {
	basedir := os.real_path(os.join_path(os.dir(@FILE), '..', '..', '..'))
	wav_file := os.join_path(basedir, 'assets', 'audio.wav')

	engine := &ma.Engine{}
	result := ma.engine_init(ma.null, engine)
	if result != .success {
		panic('Failed to initialize audio engine.')
	}

	if ma.engine_play_sound(engine, wav_file.str, ma.null) != .success {
		panic('Failed to load and play "$wav_file".')
	}

	time.sleep(1200 * time.millisecond)

	ma.engine_uninit(engine)
}
