// Copyright(C) 2019 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

// miniaudio (https://github.com/dr-soft/miniaudio)
// is licensed under the unlicense and, are thus, in the publiic domain.

module miniaudio

#flag -I ./miniaudio/c
#flag -I ./miniaudio/c/miniaudio

//#flag linux -lpthread -lm -ldl

#flag -D DR_WAV_IMPLEMENTATION
#include "extras/dr_wav.h" /* Enables WAV decoding. */

#flag -D DR_MP3_IMPLEMENTATION
#include "extras/dr_mp3.h" /* Enables MP3 decoding. */

#flag -D DR_FLAC_IMPLEMENTATION
#include "extras/dr_flac.h" /* Enables FLAC decoding. */

#flag -D MINIAUDIO_IMPLEMENTATION

#include "miniaudio.h"
#include "miniaudio_wrap.h"

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
        // channelMap [32 /*C.MA_MAX_CHANNELS*/ ]ma_channel
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
    dataCallback              voidptr // C.ma_device_callback_proc
    stopCallback              voidptr // C.ma_stop_proc
    pUserData                 voidptr

    playback                  C.playback
}

// ma_result ma_decoder_uninit(ma_decoder* pDecoder);
fn C.ma_decoder_uninit(decoder &C.ma_decoder) C.ma_result

// ma_result ma_decoder_init_file(const char* pFilePath, const ma_decoder_config* pConfig, ma_decoder* pDecoder);
fn C.ma_decoder_init_file( filepath charptr, decoder_config &C.ma_decoder_config, decoder &C.ma_decoder) C.ma_result

// ma_device_config ma_device_config_init(ma_device_type deviceType);
fn C.ma_device_config_init( device_type DeviceType) C.ma_device_config

// ma_result ma_device_init(ma_context* pContext, const ma_device_config* pConfig, ma_device* pDevice);
fn C.ma_device_init(context &C.ma_context, config &C.ma_device_config, device &C.ma_device) C.ma_result

// ma_result ma_device_start(ma_device* pDevice);
fn C.ma_device_start(device &C.ma_device) C.ma_result
fn C.ma_device_is_started(device &C.ma_device) bool

//ma_result ma_device_stop(ma_device* pDevice);
fn C.ma_device_stop(device &C.ma_device) C.ma_result


// void ma_device_uninit(ma_device* pDevice)
fn C.ma_device_uninit(device &C.ma_device)


fn C.ma_decoder_get_length_in_pcm_frames(pDecoder &C.ma_decoder) i64

//ma_uint64 ma_decoder_read_pcm_frames(ma_decoder* pDecoder, void* pFramesOut, ma_uint64 frameCount);
fn C.ma_decoder_read_pcm_frames(pDecoder &C.ma_decoder, pFramesOut voidptr,  frameIndex u64) u64

//ma_result ma_decoder_seek_to_pcm_frame(ma_decoder* pDecoder, ma_uint64 frameIndex);
fn C.ma_decoder_seek_to_pcm_frame(pDecoder &C.ma_decoder, frameIndex u64) C.ma_result
