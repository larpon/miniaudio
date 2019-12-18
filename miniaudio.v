// Copyright(C) 2019 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

// miniaudio (https://github.com/dr-soft/miniaudio)
// is licensed under the unlicense and, are thus, in the publiic domain.

module miniaudio

enum DeviceType
{
    playback = 1, // ma_device_type_playback
    capture  = 2, // ma_device_type_capture
    duplex   = 3, // ma_device_type_playback | ma_device_type_capture, /* 3 */
    loopback = 4 // ma_device_type_loopback
}

/*
pub fn play(filename string) {
    mut ma := from(filename)
    ma.play()
}

pub fn length(filename string) f64 {
    ma := from(filename)
    return ma.length()
}

pub struct Device {
    mut:
        device          &C.ma_device
        decoder         &C.ma_decoder
}
*/

pub struct MiniAudio {
    mut:
        device_config   C.ma_device_config
        device          &C.ma_device
        decoder         &C.ma_decoder

        error           string
        initialized     bool
}


fn data_callback(p_device &C.ma_device, p_output voidptr, p_input voidptr, frame_count u32) {

    p_decoder := p_device.pUserData
    if p_decoder == C.NULL {
        return
    }

    frames_read := C.ma_decoder_read_pcm_frames(p_decoder, p_output, frame_count)

    //println('Decoding '+frames_read.str()+'/'+frame_count.str())

    //(void)pInput;
}

pub fn from(filename string) MiniAudio {

    mut ma := MiniAudio {
        device: 0
        decoder: 0

        error:''
        initialized: false
    }

    decoder := &C.ma_decoder{}
    mut result := int(C.ma_decoder_init_file(filename.str, C.NULL, decoder))

    if result != C.MA_SUCCESS {
        ma.error = 'miniaudio'+@FN+': failed to init decoder from "$filename" (ma_decoder_init_file ${translate_error_code(result)} )'
        return ma
    }
    ma.decoder = decoder

    mut device_config := C.ma_device_config_init(DeviceType.playback)

    device_config.playback.format   = ma.decoder.outputFormat
    device_config.playback.channels = ma.decoder.outputChannels
    device_config.sampleRate        = ma.decoder.outputSampleRate
    device_config.dataCallback      = data_callback
    device_config.pUserData         = ma.decoder

    ma.device_config = device_config

    device := &C.ma_device{}
    result = int( C.ma_device_init(C.NULL, &ma.device_config, device) )

    if result != C.MA_SUCCESS {
        ma.error = 'miniaudio'+@FN+': failed to initialize device (ma_device_init ${translate_error_code(result)})'
        C.ma_decoder_uninit( ma.decoder )
        return ma
    }
    ma.device = device

    //println(ma.device)
    //println(ma.decoder)

    ma.initialized = true

    return ma
}


pub fn (ma mut MiniAudio) play() {

    if !ma.initialized { return }

    if ma.is_playing() {
        ma.stop()
    }

    println('Seeking frame 0')
    ma.seek_frame(0)

    ma.start()
}

pub fn (ma mut MiniAudio) stop() {

    if !ma.initialized { return }

    mut result := C.MA_SUCCESS

    if ma.is_playing() {
        println('Stopping device')
        result = int(C.ma_device_stop(ma.device))
        if result != C.MA_SUCCESS {
            ma.error = 'miniaudio'+@FN+': failed to stop device (ma_device_stop ${translate_error_code(result)})'
            ma.free()
            return
        }
        println('Device stopped')
    } else {
        println('Device not started')
    }
}

pub fn (ma mut MiniAudio) start() {

    if !ma.initialized { return }

    if !ma.is_playing() {

        println('Starting device')
        result := int( C.ma_device_start( ma.device ) )

        if result != C.MA_SUCCESS {
            ma.error = 'miniaudio'+@FN+': failed to start device playback (ma_device_start ${translate_error_code(result)})'
            ma.free()
        }
        println('Started device')
    } else {
        println('Device already started')
    }
}

pub fn (ma MiniAudio) is_playing() bool {

    if !ma.initialized { return false }

    if C.ma_device_is_started( ma.device ) {
        return true
    }

    return false
}

pub fn (ma mut MiniAudio) seek(ms f64) {

    if !ma.initialized { return }

    if ms < 0 || ms > ma.length() { return }

    println('Seek to millisecond '+ms.str())

    ma.seek_frame( u64( (ms / f64(1000)) * f64(ma.sample_rate()) ) )

}

pub fn (ma mut MiniAudio) seek_frame(pcm_frame u64) {

    if !ma.initialized { return }

    if pcm_frame < 0 || pcm_frame > ma.pcm_frames() { return }

    println('Seek PCM frame '+pcm_frame.str())

    result := int( C.ma_decoder_seek_to_pcm_frame(ma.decoder, pcm_frame) )
    if result != C.MA_SUCCESS {
        ma.error = 'miniaudio'+@FN+': failed to seek device to PCM frame $pcm_frame (ma_decoder_seek_to_pcm_frame ${translate_error_code(result)})'
        ma.free()
    }

}


pub fn (ma MiniAudio) length() f64 {

    if !ma.initialized { return f64(0) }

    pcm_frames := f64(ma.pcm_frames())
    sample_rate := f64(ma.sample_rate())

    //println(pcm_frames)
    //println(sample_rate)

    return (pcm_frames / sample_rate) * f64(1000)
}

/*
pub fn (ma MiniAudio) pos() f64 {
    C.ma_decoder_read_pcm_frames
}*/

pub fn (ma MiniAudio) sample_rate() u32 {

    if !ma.initialized { return u32(0) }

    return u32(ma.decoder.outputSampleRate)
}

pub fn (ma MiniAudio) pcm_frames() u64 {

    if !ma.initialized { return u64(0) }

    return u64(C.ma_decoder_get_length_in_pcm_frames(ma.decoder))
}

pub fn (ma mut MiniAudio) free() {
    ma.initialized = false

    C.ma_device_uninit(ma.device)
    C.ma_decoder_uninit(ma.decoder)

    ma.device = 0
    ma.decoder = 0
    println('Device free')
}
