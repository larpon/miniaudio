// Copyright(C) 2022 Lars Pontoppidan. All rights reserved.
// Use of this source code is governed by an MIT license file distributed with this software package
// miniaudio https://github.com/dr-soft/miniaudio
// is licensed under the unlicense and, are thus, in the public domain.
//
// This example is a V version of https://miniaud.io/docs/examples/engine_effects.html
module main

import os
import time
import miniaudio as ma

const (
	delay_sec = f32(0.2)
	decay     = f32(0.25)
)

fn main() {
	basedir := os.real_path(os.join_path(os.dir(@FILE), '..', '..', '..'))
	wav_file := os.join_path(basedir, 'assets', 'audio.wav')

	engine := &ma.Engine{}

	if ma.engine_init(ma.null, engine) != .success {
		panic('Failed to initialize audio engine')
	}

	sound := &ma.Sound{}

	if ma.sound_init_from_file(engine, wav_file.str, 0, ma.null, ma.null, sound) != .success {
		panic('Failed to initialize sound "${wav_file}"')
	}

	// We'll build our graph starting from the end so initialize the delay node now. The output of
	// this node will be connected straight to the output. You could also attach it to a sound group
	// or any other node that accepts an input.
	//
	// Creating a node requires a pointer to the node graph that owns it. The engine itself is a node
	// graph. In the code below we can get a pointer to the node graph with ma.engine_get_node_graph()
	// or we could simple cast the engine to a ma_node_graph* like so:
	//
	// ma.node_graph(voidptr(engine))
	//
	// The endpoint of the graph can be retrieved with ma.engine_get_endpoint().

	channels := ma.engine_get_channels(engine)
	sample_rate := ma.engine_get_sample_rate(engine)

	delay_node_config := ma.delay_node_config_init(channels, sample_rate, u32(sample_rate * delay_sec),
		decay)

	delay_node := &ma.DelayNode{}
	if ma.delay_node_init(ma.engine_get_node_graph(engine), &delay_node_config, ma.null,
		delay_node) != .success {
		panic('Failed to initialize delay node')
	}

	ma.node_attach_output_bus(delay_node, 0, ma.engine_get_endpoint(engine), 0)

	// Connect the output of the sound to the input of the effect.
	ma.node_attach_output_bus(sound, 0, delay_node, 0)

	// Start the sound after it's applied to the sound. Otherwise there could be a scenario where
	// the very first part of it is read before the attachment to the effect is made.
	ma.sound_start(sound)

	time.sleep(1800 * time.millisecond)

	ma.sound_uninit(sound)
	ma.delay_node_uninit(delay_node, ma.null)
	ma.engine_uninit(engine)
}
