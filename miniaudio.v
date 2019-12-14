// Copyright(C) 2019 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

// miniaudio (https://github.com/dr-soft/miniaudio)
// is licensed under the unlicense and, are thus, in the publiic domain.

module miniaudio

#flag -I ./miniaudio/c
#flag -I ./miniaudio/c/miniaudio

#flag linux -lpthread -lm -ldl

#flag -D DR_WAV_IMPLEMENTATION
#include "extras/dr_wav.h" /* Enables WAV decoding. */

#flag -D DR_MP3_IMPLEMENTATION
#include "extras/dr_mp3.h" /* Enables MP3 decoding. */

#flag -D DR_FLAC_IMPLEMENTATION
#include "extras/dr_flac.h" /* Enables FLAC decoding. */

#flag -D MINIAUDIO_IMPLEMENTATION

#include "miniaudio.h"
#include "miniaudio_wrap.h"

enum ma_device_type
{
    ma_device_type_playback = 1,
    ma_device_type_capture  = 2,
    ma_device_type_duplex   = 3, //ma_device_type_playback | ma_device_type_capture, /* 3 */
    ma_device_type_loopback = 4
}

struct C.ma_decoder
{
    outputFormat C.ma_format
    outputChannels C.ma_uint32
    outputSampleRate C.ma_uint32
}

struct C.playback {
    mut:
        format  C.ma_format
        channels C.ma_uint32
        channelMap [32 /*C.MA_MAX_CHANNELS*/]ma_channel
}

[typedef] struct C.ma_device {}
[typedef] struct C.ma_context {}
[typedef] struct C.ma_decoder_config {}
[typedef] struct C.ma_device_config {
    mut:
    deviceType                C.ma_device_type
    sampleRate                C.ma_uint32
    bufferSizeInFrames        C.ma_uint32
    bufferSizeInMilliseconds  C.ma_uint32
    periods                   C.ma_uint32
    performanceProfile        C.ma_performance_profile
    noPreZeroedOutputBuffer   C.ma_bool32
    noClip                    C.ma_bool32
    dataCallback              voidptr //C.ma_device_callback_proc
    stopCallback              C.ma_stop_proc
    pUserData                 voidptr

    playback    C.playback
}

// ma_result ma_decoder_uninit(ma_decoder* pDecoder);
fn C.ma_decoder_uninit(decoder &C.ma_decoder) C.ma_result

// ma_result ma_decoder_init_file(const char* pFilePath, const ma_decoder_config* pConfig, ma_decoder* pDecoder);
fn C.ma_decoder_init_file( filepath charptr, decoder_config &C.ma_decoder_config, decoder &C.ma_decoder) C.ma_result

// ma_device_config ma_device_config_init(ma_device_type deviceType);
fn C.ma_device_config_init( device_type ma_device_type) C.ma_device_config

// ma_result ma_device_init(ma_context* pContext, const ma_device_config* pConfig, ma_device* pDevice);
fn C.ma_device_init(context &C.ma_context, config &C.ma_device_config, device &C.ma_device) C.ma_result

// ma_result ma_device_start(ma_device* pDevice);
fn C.ma_device_start(device &C.ma_device) C.ma_result

// void ma_device_uninit(ma_device* pDevice)
fn C.ma_device_uninit(device &C.ma_device)


pub struct MiniAudio {
    mut:
        device_config   C.ma_device_config
        device          &C.ma_device
        decoder         &C.ma_decoder

        error           string
        ready           bool
}


pub fn new_as(filename string) MiniAudio {
    dbgn := 'miniaudio.new_as'

    mut ma := MiniAudio{
        device: 0
        decoder: 0

        error:''
    }

    /*
    ma.device_config = &C.ma_device_config
    */
    //ma.device = &C.ma_device
    //ma.decoder = &C.ma_decoder

    decoder := C.ma_decoder{}
    mut result := int(C.ma_decoder_init_file(filename.str, C.NULL, &decoder))

    if result != C.MA_SUCCESS {
        ma.error = '$dbgn: (ma_decoder_init_file) $result failed to open $filename'
        return ma
    }
    ma.decoder = &decoder

    mut device_config := C.ma_device_config_init(ma_device_type.ma_device_type_playback)

    device_config.playback.format   = ma.decoder.outputFormat
    device_config.playback.channels = ma.decoder.outputChannels
    device_config.sampleRate        = ma.decoder.outputSampleRate
    device_config.dataCallback      = C.data_callback
    device_config.pUserData         = ma.decoder

    ma.device_config = device_config

    device := C.ma_device{}
    result = int( C.ma_device_init(C.NULL, &ma.device_config, &device) )

    if result != C.MA_SUCCESS {
        ma.error = '$dbgn: (ma_device_init) $result failed to initialize device'
        C.ma_decoder_uninit( ma.decoder )
        return ma
    }
    ma.device = &device

    println('new()')
    println(ma.device)
    println(ma.decoder)

    return ma
}

pub fn (ma mut MiniAudio) play() {
    dbgn := 'miniaudio.play'

    println('play()')
    println(ma.device)
    println(ma.decoder)

    result := int( C.ma_device_start(ma.device) )

    if result != C.MA_SUCCESS {
        ma.error = '$dbgn: (ma_device_start) $result failed to start device playback'
        C.ma_device_uninit(ma.device)
        C.ma_decoder_uninit(ma.decoder)
    }

}

pub fn (ma mut MiniAudio) end() {
    C.ma_device_uninit(ma.device)
    C.ma_decoder_uninit(ma.decoder)

    ma.device = 0
    ma.decoder = 0
}


/*
pub fn play_once(filename string) MiniAudio {

    dbgn := 'miniaudio.play_once'

    mut ma := MiniAudio{
        device: &C.ma_device
        decoder: &C.ma_decoder

        error:''
    }

    mut result := int(C.ma_decoder_init_file(filename.str, C.NULL, &ma.decoder))

    if result != C.MA_SUCCESS {
        ma.error = '$dbgn: (ma_decoder_init_file) $result failed to open $filename'
        return ma
    }

    mut device_config := C.ma_device_config_init(ma_device_type.ma_device_type_playback)

    device_config.playback.format   = ma.decoder.outputFormat
    device_config.playback.channels = ma.decoder.outputChannels
    device_config.sampleRate        = ma.decoder.outputSampleRate
    device_config.dataCallback      = C.data_callback
    device_config.pUserData         = &ma.decoder

    ma.device_config = device_config

    result = int( C.ma_device_init(C.NULL, &ma.device_config, &ma.device) )

    if result != C.MA_SUCCESS {
        ma.error = '$dbgn: (ma_device_init) $result failed to initialize device'
        C.ma_decoder_uninit( &ma.decoder )
        return ma
    }

    println('new()')
    println(&ma.device)
    println(&ma.decoder)

    ma.ready = true

    if !ma.ready {
        ma.error = '$dbgn: backend not ready'
    }

    println('play()')
    println(&ma.device)
    println(&ma.decoder)

    result = int( C.ma_device_start(&ma.device) )

    if result != C.MA_SUCCESS {
        ma.error = '$dbgn: (ma_device_start) $result failed to start device playback'
        C.ma_device_uninit(&ma.device)
        C.ma_decoder_uninit(&ma.decoder)
    }

    return ma

}*/
