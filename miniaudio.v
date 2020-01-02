// Copyright(C) 2019 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package

// miniaudio (https://github.com/dr-soft/miniaudio) by David Reid (dr-soft)
// is licensed under the unlicense and, are thus, in the publiic domain.

module miniaudio

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

struct AudioBuffer {
    mut:
        dsp                         C.ma_pcm_converter // PCM data converter

        volume                      f64 // Audio buffer volume
        pitch                       f64 // Audio buffer pitch

        playing                     bool
        paused                      bool

        looping                     bool
        loops                       int

        is_stream                   bool
        is_static                   bool

        is_sub_buffer_processed     [2]bool

        frame_cursor_pos            u64 // Frame cursor position
        buffer_size_in_frames       u64 // Total buffer size in frames
        total_frames_processed      u64 // Total frames processed in this buffer (required for play timming)

        buffer                      byteptr // Data buffer, on music stream keeps filling
}

pub struct MiniAudio {
    mut:
        context                 &C.ma_context
        context_config          C.ma_context_config

        device                  &C.ma_device
        device_config           C.ma_device_config

        decoder                 &C.ma_decoder

        mutex                   &C.ma_mutex

        initialized             bool

        buffers                 []AudioBuffer
}

fn log_callback( p_context &C.ma_context, p_device &C.ma_device, logLevel u32, message charptr ) {
    println('miniaudio ERROR '+tos3(message))
    exit(1)
}

fn data_callback(p_device &C.ma_device, p_output voidptr, p_input voidptr, frame_count u32) {

    // Heavily inspired, if not outright copied from raylib: https://github.com/raysan5/raylib/blob/c20ccfe274f94d29dcf1a1f84048a57d56dedce6/src/raudio.c#L275
    ma := &MiniAudio(p_device.pUserData)
    if ma == C.NULL { return }

    if !ma.initialized { return }

    p_decoder := ma.decoder
    if p_decoder == C.NULL { return }

    // Mixing is basically just an accumulation, we need to initialize the output buffer to 0
    C.memset(p_output, 0, frame_count*p_device.playback.channels*C.ma_get_bytes_per_sample(p_device.playback.format))

    C.ma_mutex_lock(ma.mutex)

    /*frames_read :=*/ C.ma_decoder_read_pcm_frames(p_decoder, p_output, frame_count)

    /*
        for (AudioBuffer *audioBuffer = firstAudioBuffer; audioBuffer != NULL; audioBuffer = audioBuffer->next)
        {
            // Ignore stopped or paused sounds
            if (!audioBuffer->playing || audioBuffer->paused) continue;

            ma_uint32 framesRead = 0;

            while (1)
            {
                if (framesRead > frameCount)
                {
                    TraceLog(LOG_DEBUG, "Mixed too many frames from audio buffer");
                    break;
                }

                if (framesRead == frameCount) break;

                // Just read as much data as we can from the stream
                ma_uint32 framesToRead = (frameCount - framesRead);

                while (framesToRead > 0)
                {
                    float tempBuffer[1024]; // 512 frames for stereo

                    ma_uint32 framesToReadRightNow = framesToRead;
                    if (framesToReadRightNow > sizeof(tempBuffer)/sizeof(tempBuffer[0])/DEVICE_CHANNELS)
                    {
                        framesToReadRightNow = sizeof(tempBuffer)/sizeof(tempBuffer[0])/DEVICE_CHANNELS;
                    }

                    ma_uint32 framesJustRead = (ma_uint32)ma_pcm_converter_read(&audioBuffer->dsp, tempBuffer, framesToReadRightNow);
                    if (framesJustRead > 0)
                    {
                        float *framesOut = (float *)pFramesOut + (framesRead*device.playback.channels);
                        float *framesIn  = tempBuffer;

                        MixAudioFrames(framesOut, framesIn, framesJustRead, audioBuffer->volume);

                        framesToRead -= framesJustRead;
                        framesRead += framesJustRead;
                    }

                    // If we weren't able to read all the frames we requested, break
                    if (framesJustRead < framesToReadRightNow)
                    {
                        if (!audioBuffer->looping)
                        {
                            StopAudioBuffer(audioBuffer);
                            break;
                        }
                        else
                        {
                            // Should never get here, but just for safety,
                            // move the cursor position back to the start and continue the loop
                            audioBuffer->frameCursorPos = 0;
                            continue;
                        }
                    }
                }

                // If for some reason we weren't able to read every frame we'll need to break from the loop
                // Not doing this could theoretically put us into an infinite loop
                if (framesToRead > 0) break;
            }
        }
    */

    //println('Decoding '+frames_read.str()+'/'+frame_count.str())

    C.ma_mutex_unlock(ma.mutex)

}

pub fn from(filename string) MiniAudio {

    mut ma := &MiniAudio {
        context: 0
        mutex: 0
        device: 0
        decoder: 0

        initialized: false
    }

    ma.init_context()

    ma.init_mutex()

    ma.init_decoder_from_file(filename)

    ma.device_config = C.ma_device_config_init(DeviceType.playback)

    ma.device_config.playback.format   = ma.decoder.outputFormat
    ma.device_config.playback.channels = ma.decoder.outputChannels
    ma.device_config.sampleRate        = ma.decoder.outputSampleRate
    ma.device_config.dataCallback      = data_callback
    ma.device_config.pUserData         = ma

    ma.init_device()

    $if debug { println('miniaudio::from using '+ptr_str(ma.device_config.pUserData)) }

    ma.initialized = true

    return ma
}

fn (ma mut MiniAudio) init_context() {
    // Init audio context
    context := &C.ma_context{
        logCallback: 0
    }

    ma.context_config = C.ma_context_config_init()
    ma.context_config.logCallback = log_callback

    result := int( C.ma_context_init(C.NULL, 0, &ma.context_config, context) )
    if result != C.MA_SUCCESS {
        println('miniaudio::'+@FN+' ERROR: Failed to initialize audio context.  (ma_context_init ${translate_error_code(result)} ')
        exit(1)
    }
    ma.context = context

    $if debug { println('miniaudio::'+@FN+' INFO: Initialized context '+ptr_str(ma.context)) }
}

fn (ma mut MiniAudio) init_mutex() {

    // We need a valid context
    if ma.context == 0 { return }

    // Init audio mutex
    mutex := &C.ma_mutex{}
    result := int( C.ma_mutex_init(ma.context, mutex) )
    if result != C.MA_SUCCESS {
        println('miniaudio::'+@FN+' ERROR: Failed to initialize audio mutex.  (ma_mutex_init ${translate_error_code(result)} ')
        exit(1)
    }
    ma.mutex = mutex

    $if debug { println('miniaudio::'+@FN+' INFO: Initialized mutex '+ptr_str(ma.mutex)) }
}

fn (ma mut MiniAudio) init_decoder_from_file(filename string) {

    // Init decoder
    decoder := &C.ma_decoder{}
    result := int(C.ma_decoder_init_file(filename.str, C.NULL, decoder))

    if result != C.MA_SUCCESS {
        println('miniaudio::'+@FN+' ERROR: Failed to init decoder from "$filename" (ma_decoder_init_file ${translate_error_code(result)} )')
        exit(1)
    }
    ma.decoder = decoder

    $if debug { println('miniaudio::'+@FN+' INFO: Initialized decoder '+ptr_str(ma.decoder)) }
}

fn (ma mut MiniAudio) init_device() {
    // Init audio device from device_config

    device := &C.ma_device{ pUserData: 0 }
    result := int( C.ma_device_init(ma.context, &ma.device_config, device) )

    if result != C.MA_SUCCESS {
        println('miniaudio::'+@FN+': failed to initialize device (ma_device_init ${translate_error_code(result)})')
        C.ma_decoder_uninit( ma.decoder )
        exit(1)
    }
    ma.device = device

    $if debug { println('miniaudio::'+@FN+' INFO: Initialized device '+ptr_str(ma.device)) }

    //println(ma.device)
    //println(ma.decoder)
}

pub fn (ma mut MiniAudio) start() {

    if !ma.initialized { return }

    if !ma.is_playing() {

        $if debug { println('Starting device '+ptr_str(ma.device)) }
        result := int( C.ma_device_start( ma.device ) )

        if result != C.MA_SUCCESS {
            println('miniaudio::'+@FN+': failed to start device playback (ma_device_start ${translate_error_code(result)})')
            ma.free()
            exit(1)
        }
        $if debug { println('Started device') }
    } else {
        $if debug { println('Device already started') }
    }
}


pub fn (ma MiniAudio) is_playing() bool {

    if !ma.initialized { return false }

    if C.ma_device_is_started( ma.device ) {
        return true
    }

    return false
}



/*
pub fn (ma MiniAudio) pos() f64 {
    C.ma_decoder_read_pcm_frames
}*/

pub fn (ma MiniAudio) sample_rate() u32 {

    if !ma.initialized { return u32(0) }

    return ma.decoder.outputSampleRate
}


pub fn (ma mut MiniAudio) play() {

    if !ma.initialized { return }

    if ma.is_playing() {
        ma.stop()
    }

    ma.seek_frame(0)

    ma.start()
}

pub fn (ma mut MiniAudio) stop() {

    if !ma.initialized { return }

    mut result := C.MA_SUCCESS

    if ma.is_playing() {
        $if debug { println('Stopping device') }
        result = int(C.ma_device_stop(ma.device))
        if result != C.MA_SUCCESS {
            println('miniaudio::'+@FN+': failed to stop device (ma_device_stop ${translate_error_code(result)})')
            ma.free()
            exit(1)
        }
        $if debug { println('Device stopped') }
    } else {
        $if debug { println('Device not started') }
    }
}



pub fn (ma mut MiniAudio) seek(ms f64) {

    if !ma.initialized { return }

    if ms < 0 || ms > ma.length() { return }

    $if debug { println('Seek to millisecond '+ms.str()) }

    ma.seek_frame( u64( (ms / f64(1000)) * f64(ma.sample_rate()) ) )

}

pub fn (ma mut MiniAudio) seek_frame(pcm_frame u64) {

    if !ma.initialized { return }

    if pcm_frame < 0 || pcm_frame > ma.pcm_frames() { return }

    $if debug { println('Seek PCM frame '+pcm_frame.str() + '/' + ma.pcm_frames().str()) }

    result := int( C.ma_decoder_seek_to_pcm_frame(ma.decoder, pcm_frame) )

    if result != C.MA_SUCCESS {
        println('miniaudio::'+@FN+': failed to seek device to PCM frame $pcm_frame (ma_decoder_seek_to_pcm_frame ${translate_error_code(result)})')
        ma.free()
        exit(1)
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

pub fn (ma MiniAudio) pcm_frames() u64 {

    if !ma.initialized { return u64(0) }

    return u64(C.ma_decoder_get_length_in_pcm_frames(ma.decoder))
}

pub fn (ma mut MiniAudio) free() {

    ma.initialized = false

    C.ma_device_uninit(ma.device)
    C.ma_decoder_uninit(ma.decoder)
    C.ma_context_uninit(ma.context)
    C.ma_mutex_uninit(ma.mutex)

    ma.context = 0
    ma.mutex = 0
    ma.device = 0
    ma.decoder = 0

}
