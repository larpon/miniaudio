// Copyright(C) 2019-2021 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package
// miniaudio (https://github.com/dr-soft/miniaudio) by David Reid (dr-soft)
// is licensed under the unlicense and, are thus, in the publiic domain.
module x

import c

pub const used_import = c.used_import + 1

// type Result = int //C.ma_result

/*
pub enum Status {
	success = C.MA_SUCCESS
	// General errors
	error =	C.MA_ERROR // A generic error
	invalid_args = C.MA_INVALID_ARGS
	/*
		C.MA_INVALID_OPERATION {
			return 'MA_INVALID_OPERATION'
		}
		C.MA_OUT_OF_MEMORY {
			return 'MA_OUT_OF_MEMORY'
		}
		C.MA_OUT_OF_RANGE {
			return 'MA_OUT_OF_RANGE'
		}
		C.MA_ACCESS_DENIED {
			return 'MA_ACCESS_DENIED'
		}
		C.MA_DOES_NOT_EXIST {
			return 'MA_DOES_NOT_EXIST'
		}
		C.MA_ALREADY_EXISTS {
			return 'MA_ALREADY_EXISTS'
		}
		C.MA_TOO_MANY_OPEN_FILES {
			return 'MA_TOO_MANY_OPEN_FILES'
		}
		C.MA_INVALID_FILE {
			return 'MA_INVALID_FILE'
		}
		C.MA_TOO_BIG {
			return 'MA_TOO_BIG'
		}
		C.MA_PATH_TOO_LONG {
			return 'MA_PATH_TOO_LONG'
		}
		C.MA_NAME_TOO_LONG {
			return 'MA_NAME_TOO_LONG'
		}
		C.MA_NOT_DIRECTORY {
			return 'MA_NOT_DIRECTORY'
		}
		C.MA_IS_DIRECTORY {
			return 'MA_IS_DIRECTORY'
		}
		C.MA_DIRECTORY_NOT_EMPTY {
			return 'MA_DIRECTORY_NOT_EMPTY'
		}
		C.MA_AT_END {
			return 'MA_AT_END'
		}
		C.MA_NO_SPACE {
			return 'MA_NO_SPACE'
		}
		C.MA_BUSY {
			return 'MA_BUSY'
		}
		C.MA_IO_ERROR {
			return 'MA_IO_ERROR'
		}
		C.MA_INTERRUPT {
			return 'MA_INTERRUPT'
		}
		C.MA_UNAVAILABLE {
			return 'MA_UNAVAILABLE'
		}
		C.MA_ALREADY_IN_USE {
			return 'MA_ALREADY_IN_USE'
		}
		C.MA_BAD_ADDRESS {
			return 'MA_BAD_ADDRESS'
		}
		C.MA_BAD_SEEK {
			return 'MA_BAD_SEEK'
		}
		C.MA_BAD_PIPE {
			return 'MA_BAD_PIPE'
		}
		C.MA_DEADLOCK {
			return 'MA_DEADLOCK'
		}
		C.MA_TOO_MANY_LINKS {
			return 'MA_TOO_MANY_LINKS'
		}
		C.MA_NOT_IMPLEMENTED {
			return 'MA_NOT_IMPLEMENTED'
		}
		C.MA_NO_MESSAGE {
			return 'MA_NO_MESSAGE'
		}
		C.MA_BAD_MESSAGE {
			return 'MA_BAD_MESSAGE'
		}
		C.MA_NO_DATA_AVAILABLE {
			return 'MA_NO_DATA_AVAILABLE'
		}
		C.MA_INVALID_DATA {
			return 'MA_INVALID_DATA'
		}
		C.MA_TIMEOUT {
			return 'MA_TIMEOUT'
		}
		C.MA_NO_NETWORK {
			return 'MA_NO_NETWORK'
		}
		C.MA_NOT_UNIQUE {
			return 'MA_NOT_UNIQUE'
		}
		C.MA_NOT_SOCKET {
			return 'MA_NOT_SOCKET'
		}
		C.MA_NO_ADDRESS {
			return 'MA_NO_ADDRESS'
		}
		C.MA_BAD_PROTOCOL {
			return 'MA_BAD_PROTOCOL'
		}
		C.MA_PROTOCOL_UNAVAILABLE {
			return 'MA_PROTOCOL_UNAVAILABLE'
		}
		C.MA_PROTOCOL_NOT_SUPPORTED {
			return 'MA_PROTOCOL_NOT_SUPPORTED'
		}
		C.MA_PROTOCOL_FAMILY_NOT_SUPPORTED {
			return 'MA_PROTOCOL_FAMILY_NOT_SUPPORTED'
		}
		C.MA_ADDRESS_FAMILY_NOT_SUPPORTED {
			return 'MA_ADDRESS_FAMILY_NOT_SUPPORTED'
		}
		C.MA_SOCKET_NOT_SUPPORTED {
			return 'MA_SOCKET_NOT_SUPPORTED'
		}
		C.MA_CONNECTION_RESET {
			return 'MA_CONNECTION_RESET'
		}
		C.MA_ALREADY_CONNECTED {
			return 'MA_ALREADY_CONNECTED'
		}
		C.MA_NOT_CONNECTED {
			return 'MA_NOT_CONNECTED'
		}
		C.MA_CONNECTION_REFUSED {
			return 'MA_CONNECTION_REFUSED'
		}
		C.MA_NO_HOST {
			return 'MA_NO_HOST'
		}
		C.MA_IN_PROGRESS {
			return 'MA_IN_PROGRESS'
		}
		C.MA_CANCELLED {
			return 'MA_CANCELLED'
		}
		C.MA_MEMORY_ALREADY_MAPPED {
			return 'MA_MEMORY_ALREADY_MAPPED'
		}
		// General miniaudio-specific errors.
		C.MA_FORMAT_NOT_SUPPORTED {
			return 'MA_FORMAT_NOT_SUPPORTED'
		}
		C.MA_DEVICE_TYPE_NOT_SUPPORTED {
			return 'MA_DEVICE_TYPE_NOT_SUPPORTED'
		}
		C.MA_SHARE_MODE_NOT_SUPPORTED {
			return 'MA_SHARE_MODE_NOT_SUPPORTED'
		}
		C.MA_NO_BACKEND {
			return 'MA_NO_BACKEND'
		}
		C.MA_NO_DEVICE {
			return 'MA_NO_DEVICE'
		}
		C.MA_API_NOT_FOUND {
			return 'MA_API_NOT_FOUND'
		}
		C.MA_INVALID_DEVICE_CONFIG {
			return 'MA_INVALID_DEVICE_CONFIG'
		}
		C.MA_LOOP {
			return 'MA_LOOP'
		}
		// State errors.
		C.MA_DEVICE_NOT_INITIALIZED {
			return 'MA_DEVICE_NOT_INITIALIZED'
		}
		C.MA_DEVICE_ALREADY_INITIALIZED {
			return 'MA_DEVICE_ALREADY_INITIALIZED'
		}
		C.MA_DEVICE_NOT_STARTED {
			return 'MA_DEVICE_NOT_STARTED'
		}
		C.MA_DEVICE_NOT_STOPPED {
			return 'MA_DEVICE_NOT_STOPPED'
		}
		// Operation errors.
		C.MA_FAILED_TO_INIT_BACKEND {
			return 'MA_FAILED_TO_INIT_BACKEND '
		}
		C.MA_FAILED_TO_OPEN_BACKEND_DEVICE {
			return 'MA_FAILED_TO_OPEN_BACKEND_DEVICE'
		}
		C.MA_FAILED_TO_START_BACKEND_DEVICE {
			return 'MA_FAILED_TO_START_BACKEND_DEVICE'
		}
		C.MA_FAILED_TO_STOP_BACKEND_DEVICE*/
}
*/

// ma_uint32 read_and_mix_pcm_frames_f32(ma_decoder* pDecoder, float* pOutputF32, ma_uint32 frameCount)
// fn C.read_and_mix_pcm_frames_f32(pDecoder &C.ma_decoder, pOutputF32 voidptr, frameCount u32) u32
// #define macros
// fn C.ma_countof(x voidptr) int
// fn C.ma_countof(obj []f32) int

pub enum DeviceType {
	playback = C.ma_device_type_playback
	capture  = C.ma_device_type_capture
	duplex   = 3 // C.ma_device_type_playback | C.ma_device_type_capture, /* 3 */
	loopback = C.ma_device_type_loopback
}

pub enum Format {
	unknown = C.ma_format_unknown
	u8      = C.ma_format_u8
	s16     = C.ma_format_s16
	s24     = C.ma_format_s24
	s32     = C.ma_format_s32
	f32     = C.ma_format_f32
	count   = C.ma_format_count
}

struct C.ma_pcm_converter {}

type PCMConverter = C.ma_pcm_converter

[heap]
struct C.ma_decoder {
	outputFormat     int // Format //C.ma_format
	outputChannels   u32 // C.ma_uint32
	outputSampleRate u32 // C.ma_uint32
}

type Decoder = C.ma_decoder

struct C.playback {
mut:
	format   int // Format //int //C.ma_format
	channels u32 // C.ma_uint32
	// channelMap [32 /*C.MA_MAX_CHANNELS*/ ]ma_channel
}

type Playback = C.playback

[typedef]
struct C.ma_device {
mut:
	pUserData voidptr
	playback  C.playback
}

type Device = C.ma_device

[typedef]
struct C.ma_context {
	// logCallback voidptr // C.ma_log_proc
}

type Context = C.ma_context

[typedef]
struct C.ma_context_config {
	// mut:
	// logCallback voidptr // C.ma_log_proc
}

type ContextConfig = C.ma_context_config

[typedef]
struct C.ma_mutex {}

type Mutex = C.ma_mutex

[typedef]
struct C.ma_decoder_config {
	outputFormat     int // Format //C.ma_format
	outputChannels   u32 // C.ma_uint32
	outputSampleRate u32 // C.ma_uint32
}

type DecoderConfig = C.ma_decoder_config

[typedef]
struct C.ma_device_config {
mut:
	deviceType               C.ma_device_type
	sampleRate               u32 // C.ma_uint32
	bufferSizeInFrames       u32 // C.ma_uint32
	bufferSizeInMilliseconds u32 // C.ma_uint32
	periods                  u32 // C.ma_uint32
	performanceProfile       C.ma_performance_profile
	noPreZeroedOutputBuffer  C.ma_bool32
	noClip                   C.ma_bool32
	dataCallback             voidptr // C.ma_device_callback_proc
	stopCallback             voidptr // C.ma_stop_proc
	pUserData                voidptr
	playback                 C.playback
}

type DeviceConfig = C.ma_device_config

//
// ma_context
//
fn C.ma_context_config_init() C.ma_context_config
pub fn (mut cc ContextConfig) init() ContextConfig {
	return C.ma_context_config_init()
}

// ma_result ma_context_init(const ma_backend backends[], ma_uint32 backendCount, const ma_context_config* pConfig, ma_context* pContext);
fn C.ma_context_init(backends []C.ma_backend, backendCount u32, p_config &C.ma_context_config, p_context &C.ma_context) C.ma_result

// pub fn Result

// ma_result ma_context_uninit(ma_context* pContext);
fn C.ma_context_uninit(p_context &C.ma_context) C.ma_result

// ma_decoder
// ma_result ma_decoder_uninit(ma_decoder* pDecoder);
fn C.ma_decoder_uninit(decoder &C.ma_decoder) C.ma_result

// ma_result ma_decoder_init_file(const char* pFilePath, const ma_decoder_config* pConfig, ma_decoder* pDecoder);
fn C.ma_decoder_init_file(filepath &char, decoder_config &C.ma_decoder_config, decoder &C.ma_decoder) C.ma_result

// ma_result ma_decoder_init_memory(const void* pData, size_t dataSize, const ma_decoder_config* pConfig, ma_decoder* pDecoder);
fn C.ma_decoder_init_memory(data voidptr, len u64, decoder_config &C.ma_decoder_config, decoder &C.ma_decoder) C.ma_result

fn C.ma_decoder_get_length_in_pcm_frames(pDecoder &C.ma_decoder, length &u64) C.ma_result

// ma_uint64 ma_decoder_read_pcm_frames(ma_decoder* pDecoder, void* pFramesOut, ma_uint64 frameCount);
// fn C.ma_decoder_read_pcm_frames(pDecoder &C.ma_decoder, pFramesOut voidptr, frameIndex u64) u64
fn C.ma_decoder_read_pcm_frames(pDecoder &C.ma_decoder, pFramesOut voidptr, frameCount u64, pFramesRead &u64) u64

// ma_result ma_decoder_seek_to_pcm_frame(ma_decoder* pDecoder, ma_uint64 frameIndex);
fn C.ma_decoder_seek_to_pcm_frame(pDecoder &C.ma_decoder, frameIndex u64) C.ma_result

// ma_decoder_config
// ma_decoder_config ma_decoder_config_init(ma_format outputFormat, ma_uint32 outputChannels, ma_uint32 outputSampleRate);
fn C.ma_decoder_config_init(outputFormat int, outputChannels u32, outputSampleRate u32) C.ma_decoder_config

// ma_device
// ma_device_config ma_device_config_init(ma_device_type deviceType);
fn C.ma_device_config_init(device_type DeviceType) C.ma_device_config

// ma_result ma_device_init(ma_context* pContext, const ma_device_config* pConfig, ma_device* pDevice);
fn C.ma_device_init(context &C.ma_context, config &C.ma_device_config, device &C.ma_device) C.ma_result

// ma_result ma_device_start(ma_device* pDevice);
fn C.ma_device_start(device &C.ma_device) C.ma_result

fn C.ma_device_is_started(device &C.ma_device) bool

// ma_result ma_device_stop(ma_device* pDevice);
fn C.ma_device_stop(device &C.ma_device) C.ma_result

// void ma_device_uninit(ma_device* pDevice)
fn C.ma_device_uninit(device &C.ma_device)

// ma_decoder
// ma_result ma_mutex_init(ma_mutex* pMutex);
fn C.ma_mutex_init(p_mutex &C.ma_mutex) C.ma_result

// void ma_mutex_uninit(ma_mutex* pMutex);
fn C.ma_mutex_uninit(p_mutex &C.ma_mutex)

// void ma_mutex_lock(ma_mutex* pMutex);
fn C.ma_mutex_lock(p_mutex &C.ma_mutex)

// void ma_mutex_unlock(ma_mutex* pMutex);
fn C.ma_mutex_unlock(p_mutex &C.ma_mutex)

// Misc
// ma_uint32 ma_get_bytes_per_sample(ma_format format);
fn C.ma_get_bytes_per_sample(format Format) u32
