import os
import time
import miniaudio as ma

// void data_callback(ma_device* pDevice, void* pOutput, const void* pInput, ma_uint32 frameCount)

fn data_callback(p_device &ma.Device, p_output voidptr, p_input voidptr, frame_count u32) {
	p_decoder := &ma.Decoder(p_device.pUserData)
	if isnil(p_decoder) {
		return
	}
	C.ma_decoder_read_pcm_frames(p_decoder, p_output, frame_count, unsafe { nil })
}

fn test_basics() {
	$if ci ? {
		assert true
		return
	}
	basedir := os.real_path(os.join_path(os.dir(@FILE), '..'))
	wav_file := os.join_path(basedir, 'assets', 'audio.wav')
	// flac_file := os.join_path(basedir, 'assets', 'audio.flac')
	// mp3_file := os.join_path(basedir, 'assets', 'audio.mp3')

	decoder := ma.Decoder{}
	result := ma.decoder_init_file(wav_file.str, C.NULL, &decoder)
	if result != .success {
		panic('Could not load file: ${wav_file} ${int(result)}')
	}

	mut device_config := ma.device_config_init(.playback)
	device_config.playback.format = decoder.outputFormat
	device_config.playback.channels = decoder.outputChannels
	device_config.sampleRate = decoder.outputSampleRate
	device_config.dataCallback = voidptr(data_callback)
	device_config.pUserData = &decoder

	device := ma.Device{}
	if ma.device_init(ma.null, &device_config, &device) != .success {
		ma.decoder_uninit(&decoder)
		panic('Failed to open playback device.')
	}

	if ma.device_start(&device) != .success {
		ma.device_uninit(&device)
		ma.decoder_uninit(&decoder)
		panic('Failed to start playback device.')
	}

	time.sleep(1 * time.second)

	ma.device_uninit(&device)
	ma.decoder_uninit(&decoder)
}
