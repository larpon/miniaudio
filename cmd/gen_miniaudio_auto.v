// Copyright(C) 2021 Lars Pontoppidan. All rights reserved.
module main

import os

const (
	lib_name      = 'miniaudio'
	c2v_types_map = {
		'char':                   'byte'
		'signed char':            'byte'
		'unsigned char':          'byte'
		//
		'short':                  'i16'
		'short int':              'i16'
		'signed short':           'i16'
		'signed short int':       'i16'
		//
		'unsigned short':         'u16'
		'unsigned short int':     'u16'
		// i16
		'int':                    'int'
		'signed':                 'int'
		'signed int':             'int'
		'unsigned':               'u32'
		'unsigned int':           'u32'
		'long':                   'int'
		'long int':               'int'
		'signed long':            'int'
		'signed long int':        'int'
		//
		'unsigned long':          'u32'
		'unsigned long int':      'u32'
		//
		'long long':              'i64'
		'long long int':          'i64'
		'signed long long':       'i64'
		'signed long long int':   'i64'
		//
		'unsigned long long':     'u64'
		'unsigned long long int': 'u64'
		//
		'float':                  'f32'
		'double':                 'f64'
		'long double':            'f64'
	}
	c2v_alias_enums = {
		'ma_format':      'Format'
		'ma_result':      'Result'
		'ma_device_type': 'DeviceType'
		'playback':       'Playback'
	}
	c2v_alias_typedefs = {
		'ma_semaphore':      'Semaphore'
		'ma_event':          'Event'
		'ma_pcm_converter':  'PCMConverter'
		'ma_decoder':        'Decoder'
		'ma_device':         'Device'
		'ma_context':        'Context'
		'ma_context_config': 'ContextConfig'
		'ma_mutex':          'Mutex'
		'ma_decoder_config': 'DecoderConfig'
		'ma_device_config':  'DeviceConfig'
	}
	keywords = {
		'type': 'typ'
		'lock': 'locking'
	}
	skip_typedefs = [
		'ma_decoder',
		'ma_result',
		'playback',
		'ma_device',
		'ma_context',
		'ma_context_config',
		'ma_mutex',
		'ma_decoder_config',
		'ma_device_config',
	]
	skip_keywords = ['',
	/*'DWORD','WORD','ma_I','wasapi',
		'ma_pa_','__coreaudio',
		'drwav_','drmp3_','drflac_',
		'stbvorbis','AudioClient','__alsa',
		'ma_jack', 'ma_sio','AAudio', '__uwp','backends[','stbvorbis_'*/]
)

fn main() {
	cur_dir := os.dir(@FILE)
	miniaudio_base := os.real_path(os.join_path(cur_dir, '..', 'c', 'miniaudio'))
	// miniaudio_includes := os.join_path(miniaudio_base)
	mut c_headers := [os.join_path(miniaudio_base, 'miniaudio.h')]
	// c_headers.sort()

	mut miniaudio_c_v := '// Copyright(C) 2021 Lars Pontoppidan. All rights reserved.
// NOTE this file is auto-generated by cmd/${os.file_name(@FILE)}
module miniaudio

import ${lib_name}.c

pub const used_import = c.used_import


// C.ma_result
pub enum Result {
	success = 0
	error // TODO add all
}

// C.ma_device_type
pub enum DeviceType {
	playback = C.ma_device_type_playback
	capture = C.ma_device_type_capture
	duplex = 3 //C.ma_device_type_playback | C.ma_device_type_capture, /* 3 */
	loopback = C.ma_device_type_loopback
}

// C.ma_format
pub enum Format {
	unknown = C.ma_format_unknown
	u8 = C.ma_format_u8
	s16 = C.ma_format_s16
	s24 = C.ma_format_s24
	s32 = C.ma_format_s32
	f32 = C.ma_format_f32
	count = C.ma_format_count
}

struct C.ma_pcm_converter {}
type PCMConverter = C.ma_pcm_converter

[heap]
struct C.ma_decoder {
pub mut:
	outputFormat     Format // C.ma_format
	outputChannels   u32 // C.ma_uint32
	outputSampleRate u32 // C.ma_uint32
}
pub type Decoder = C.ma_decoder

struct C.playback {
pub mut:
	format   Format //C.ma_format
	channels u32 // C.ma_uint32
	// channelMap [32 /*C.MA_MAX_CHANNELS*/ ]ma_channel
}
pub type Playback = C.playback

[typedef]
struct C.ma_device {
pub mut:
	pUserData voidptr
	playback  Playback
}
pub type Device = C.ma_device

[typedef]
struct C.ma_context {
	logCallback voidptr // C.ma_log_proc
}
pub type Context = C.ma_context

[typedef]
struct C.ma_context_config {
mut:
	logCallback voidptr // C.ma_log_proc
}
pub type ContextConfig = C.ma_context_config

[typedef]
struct C.ma_mutex {}
pub type Mutex = C.ma_mutex

[typedef]
struct C.ma_decoder_config {
	outputFormat     Format //C.ma_format
	outputChannels   u32 // C.ma_uint32
	outputSampleRate u32 // C.ma_uint32
}
pub type DecoderConfig = C.ma_decoder_config

[typedef]
struct C.ma_device_config {
mut:
	deviceType               DeviceType
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
	playback                 Playback
}
pub type DeviceConfig = C.ma_device_config

[typedef]
struct C.ma_event {}
pub type Event = C.ma_event
'
	for c_header in c_headers {
		miniaudio_c_v += gen_v_code(c_header)
	}

	miniaudio_c_v = miniaudio_c_v.replace('C.float', 'f32')
	miniaudio_c_v = miniaudio_c_v.replace('C.void*', 'voidptr')
	miniaudio_c_v = miniaudio_c_v.replace('C.size_t', 'usize')
	miniaudio_c_v = miniaudio_c_v.replace('C.int', 'int')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_uint64', 'u64')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_int32', 'int')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_uint32', 'u32')
	miniaudio_c_v = miniaudio_c_v.replace('C.unsigned', 'u32')
	miniaudio_c_v = miniaudio_c_v.replace('&C.void', 'voidptr')
	miniaudio_c_v = miniaudio_c_v.replace('void C.void', '')
	miniaudio_c_v = miniaudio_c_v.replace('(void)', '()')
	miniaudio_c_v = miniaudio_c_v.replace('&C.const void', 'voidptr')
	miniaudio_c_v = miniaudio_c_v.replace('&C.const char', '&char')
	miniaudio_c_v = miniaudio_c_v.replace('lock C.', '// lock C.')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_bool32', 'bool')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_bool8', 'bool')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_format', 'Format')
	miniaudio_c_v = miniaudio_c_v.replace('Format_', 'C.ma_format_')
	miniaudio_c_v = miniaudio_c_v.replace('C.ma_device_type', 'DeviceType')
	miniaudio_c_v = miniaudio_c_v.replace('DeviceType_', 'C.ma_device_type_')

	os.write_file(os.real_path(os.join_path(cur_dir, '..', '${lib_name}.auto.c.v')), miniaudio_c_v) or {
		panic(err)
	}
}

fn eat_lines_until(from int, lines []string, marked fn (line string) bool) []string {
	mut gulp := []string{}
	for i := from; i < lines.len; i++ {
		line := lines[i]
		gulp << line
		if marked(line) {
			return gulp
		}
	}
	return gulp
}

fn gen_v_code(path string) string {
	filename := os.file_name(path)

	mut c := '//
// $filename
//

'
	// eprintln('Reading "$path"')
	code := os.read_file(path) or { panic(err) }

	// eprintln('Reading "$code"')

	mut v_types := []string{} // TODO

	lines := code.split('\n')
	mut skip := 0
	for i, line in lines {
		if line == '#endif  /* miniaudio_h */' {
			break
		}

		if skip > 0 {
			skip--
			continue
		}

		if line.contains('#if defined(MA_EXPERIMENTAL__DATA_LOOPING_AND_CHAINING)') {
			lns := eat_lines_until(i, lines, fn (l string) bool {
				return l.starts_with('#endif')
			})
			skip = lns.len - 1
			continue
		}

		if line.starts_with('typedef struct') {
			if line.contains(';') {
				tds, vtyps := typedef_struct([line])
				if tds != '' {
					v_types << vtyps
					c += tds + '\n\n'
				}
				continue
			}
			typedefa := eat_lines_until(i, lines, fn (l string) bool {
				return l.starts_with('}') && l.contains(';')
			})
			skip = typedefa.len - 1
			tds, vtyps := typedef_struct(typedefa)
			if tds != '' {
				v_types << vtyps
				c += tds + '\n\n'
			}
		}
		if line.starts_with('MA_API') {
			api_export := eat_lines_until(i, lines, fn (l string) bool {
				return l.contains(';')
			})

			for ae_line in api_export {
				if ae_line.contains_any_substr(skip_keywords) {
					// println('skipping: $ae_line')
					continue
				}
			}

			skip = api_export.len - 1

			if !api_export[0].contains(';') {
				continue
			}

			if api_export[0].contains('...') {
				c += '// Skipped:\n/*\n${api_export.join(' ')}\n*/\n\n'
				continue
			}

			c += export_api(api_export) + '\n\n'
		}
	}
	return c + '\n'
}

fn ma_name2v(ma string) string {
	if !ma.starts_with('ma_') {
		panic('"$ma" is not a miniaudio id')
	}
	mas := ma.split('_')
	mut ids := mas[1..]
	for mut id in ids {
		id = id.title()
	}
	return ids.join('')
}

fn us_name2v(us_str string) string {
	if us_str.contains('_') {
		mut ids := us_str.split('_')
		// mut ids := uss //[1..]
		for mut id in ids {
			id = id.title()
		}
		return ids.join('')
	}
	return us_str.title()
}

fn typedef_struct(lines []string) (string, []string) {
	// println(lines)

	mut v_types := []string{}

	for line in lines {
		if line.contains_any_substr(skip_keywords) || line.contains_any_substr(skip_typedefs) {
			return '', v_types //'/* SKIPPED ${lines.join(" ")} */'
		}
	}

	mut v_code := '' //'/*\nC signature\n${lines.join("\n")}\n*/\n'

	mut line := ''
	if lines.len == 1 {
		line = lines[0]
		tokens := line.split(' ')

		mut id := '/*TODO*/'
		if tokens.len > 2 {
			id = tokens[2].trim('{') // cpArray etc.
		}
		v_type := ma_name2v(id)
		v_types << v_type
		v_code = '[${tokens[0]}]
${tokens[1]} C.$id {}
pub type $v_type = C.$id'
		return v_code, v_types
	}

	flat := lines.join(' ').replace('\n', '')
	tokens := flat.split(' ')
	raw_members := flat.all_after('{').all_before_last('}').trim(' ').replace(' *', '* ').replace('[] ',
		' []') //.replace('const ','')
	raw_struct_ids := flat.all_after_last('}').trim(' ').all_before_last(';').replace(' ',
		'').split(',')
	mut members := raw_members.split(';')
	members = members.map(it.trim(' '))
	members = members.filter(it != '')

	// println(members)
	for struct_id in raw_struct_ids {
		v_code += '[${tokens[0]}]
${tokens[1]} C.$struct_id {\n'
		for member in members {
			msplit := member.split(' ')
			mut ptr := ''
			if msplit.len == 2 {
				mut name := msplit[1]
				if name in keywords.keys() {
					name = keywords[name]
				}

				mut kind := msplit[0]
				if kind.contains('*') {
					for _ in 0 .. kind.count('*') {
						ptr += '&'
					}
					kind = kind.replace('*', '')
				}
				if kind in c2v_types_map.keys() {
					kind = c2v_types_map[kind]
				} else if kind in c2v_alias_typedefs.keys() {
					kind = c2v_alias_typedefs[kind]
				} else {
					kind = ptr + 'C.' + kind
				}
				if name.contains('[') {
					v_code += '\t// TODO $name $kind\n'
				} else {
					v_code += '\t$name $kind\n'
				}
			}
		}
		v_code += '}\n'
		v_type := us_name2v(struct_id.all_after('ma_'))
		v_types << v_type
		v_code += 'pub type $v_type = C.$struct_id'
	}

	return v_code, v_types
}

fn export_api(lines []string) string {
	mut lns := lines.clone()

	mut sig := lns.last()
	lns.delete_last() // Only comments left, if any

	mut code := ''

	clean_sig := sig.all_after('MA_API ')
	rws := signature(clean_sig)

	code += '// $sig\n'
	code += gen_v_c_sig(rws) + '\n' // fn C. ...

	wrapper_code, fn_name := gen_v_wrap_sig(rws)

	// TODO Shutup
	if fn_name == '' || wrapper_code == '' {
		_ := ''
	}
	/*
	for i, line in lns {
		mut comment := line.all_after('///')

		if i == 0 {
			mut csp := comment.trim(' ').split(' ')
			csp[0] = ' $fn_name ' + csp[0].to_lower() + 's'
			code += '//' + csp.join(' ') + '\n'
		} else {
			code += '//' + comment + '\n'
		}
	}*/

	code += wrapper_code

	if clean_sig.contains('backends[') {
		code = '/* TODO $code */'
	}

	return '$code'
}

struct RawCArg {
	full string
	kind string
	name string
}

struct RawCSig {
	rt   string
	name string
	args []RawCArg
}

fn signature(sig string) RawCSig {
	// println(sig)

	return_type_and_fn_name := sig.all_before('(')
	rtafn_sp := return_type_and_fn_name.split(' ')

	return_type := rtafn_sp[..rtafn_sp.len - 1].join(' ').trim(' ')
	fn_name := rtafn_sp.last().trim(' ')

	mut raw_args := sig.all_after('(')
	raw_args = raw_args.all_before(')')

	raws := raw_args.split(',')

	mut args := []RawCArg{}
	for raw_arg in raws {
		args << process_c_args(raw_arg)
	}

	return RawCSig{return_type, fn_name, args}
}

fn process_c_args(arg string) RawCArg {
	mut a := arg.trim(' ')
	// println(arg)
	if a == 'void' {
		return RawCArg{a, 'void', 'void'}
	}
	if a == '...' {
		return RawCArg{a, '...', '...'}
	}

	a = a.replace(' *', '* ')
	a = a.replace('[] ', ' []')
	a = a.replace('volatile', '')
	// println(a)

	mut parts := a.split(' ')

	mut c_type := parts[..parts.len - 1].join(' ').trim(' ')
	// println('C type: $c_type')

	if c_type == '' {
		pts := parts[..parts.len - 1]
		c_type = pts[parts.len - 1].trim(' ')
	}

	kind := c_type
	name := parts[parts.len - 1..][0].trim(' ')

	// println('"$a" -> kind: `$c_type` name: `$name`')

	return RawCArg{a, kind, name}
}

fn gen_v_c_sig(sig RawCSig) string {
	mut v_c_sig := 'fn C.${sig.name}('

	mut args := ''
	for pair in sig.args {
		n, k := gen_v_c_arg_pair(pair)
		args += n + ' ' + k + ', '
	}
	args = args.trim_right(', ')

	r := v_c_sig + args + ') ' + c_to_v_c_type(sig.rt)
	return r.trim(' ')
}

fn gen_v_c_call_sig(sig RawCSig) string {
	mut v_c_sig := 'C.${sig.name}('

	mut args := ''
	for pair in sig.args {
		n, _ := gen_v_c_arg_pair(pair)
		args += n.replace('[]', '') + ', '
	}
	args = args.trim_right(', ')

	r := v_c_sig + args + ')'
	return r.trim(' ')
}

fn gen_v_c_arg_pair(pair RawCArg) (string, string) {
	mut out := ''
	mut kind := pair.kind.replace('const', '').trim(' ')
	mut name := c_to_v_var_name(pair.name)

	if name == 'type' {
		name = 'typ'
	}

	if kind == 'char*' {
		return name, 'charptr'
	}
	if kind == 'void*' {
		return name, 'voidptr'
	}
	if kind in c2v_types_map.keys() {
		return name, c2v_types_map[kind]
	}

	mut ptr := ''
	if kind.contains('*') {
		ptr = '&'
		if kind.count('*') > 1 {
			ptr = '&&'
		}
		kind = kind.replace('*', '')
	}

	if name.contains('*') {
		ptr += '&'
		name = name.replace('*', '')
	}

	out = name + ' ${ptr}C.' + kind
	if out.contains('...') {
		return name, '/*TODO*/'
	}

	return name, '${ptr}C.' + kind
}

fn gen_v_arg_pair(pair RawCArg) (string, string) {
	mut out := ''
	mut kind := pair.kind.replace('const', '').trim(' ')
	mut name := c_to_v_var_name(pair.name)

	if name == 'type' {
		name = 'typ'
	}

	mut ptr := ''
	if kind.contains('*') {
		ptr = '&'
		if kind.count('*') > 1 {
			ptr = '&&'
		}
		kind = kind.replace('*', '')
	}

	if name.contains('*') {
		ptr += '&'
		name = name.replace('*', '')
	}

	if kind == 'char*' {
		return name, 'charptr'
	}
	if kind == 'void*' {
		return name, 'voidptr'
	}
	if kind in c2v_types_map.keys() {
		return name, ptr + c2v_types_map[kind]
	}
	if kind in c2v_alias_typedefs.keys() {
		return name, ptr + c2v_alias_typedefs[kind]
	}

	out = name + ' ${ptr}C.' + kind

	if out.contains('...') {
		return name, '/*TODO*/'
	}

	return name, '${ptr}C.' + kind
}

fn gen_v_wrap_sig(sig RawCSig) (string, string) {
	mut v_type := ''
	mut c_type := ''
	mut ptr := false
	for recognized in c2v_alias_typedefs.keys() {
		// sname := sig.name
		// reg := sig.name.starts_with(recognized)
		// println('Recog! $sname in $reg ?')
		if sig.name.starts_with(recognized) {
			ptr = sig.args[0].kind.contains('*')
			mut st_kind := sig.args[0].kind.replace('*', '').replace('const', '').trim(' ')
			is_equal := recognized == st_kind
			// println('Recog! $sig.name -> "$st_kind" == "$recognized" ($is_equal) -> $v_type (pointer? $ptr)')
			if is_equal && ptr {
				c_type = recognized
				v_type = c2v_alias_typedefs[recognized]
				// println('Recog! $sig.name -> $st_kind -> $v_type (pointer? $ptr)')
			}
			// println('Recog! $sig.name -> $v_type')

			break
		}
	}

	mut v_wrap_sig := '[inline]\npub fn '

	mut fn_name := ''
	mut first := ''
	if v_type != '' {
		first = c_to_v_var_name(sig.args[0].name)
		fn_name = v_fn_name(sig.name.all_after(c_type))
		if fn_name in keywords.keys() {
			fn_name = keywords[fn_name]
		}
		v_wrap_sig += '(mut $first $v_type) ' + fn_name + '('
	} else {
		fn_name = v_fn_name(sig.name).all_after('ma_')
		v_wrap_sig += fn_name + '('
	}

	mut args := ''
	for i, pair in sig.args {
		if v_type != '' && i == 0 {
			continue
		}

		var_name, kind := gen_v_arg_pair(pair)

		args += var_name + ' ' + kind + ', '
	}
	args = args.trim_right(', ')

	v_wrap_sig += args + ') ' + c_to_v_type(sig.rt)

	mut fn_body := v_wrap_sig.trim(' ')
	// Gen function body
	fn_body += '{\n'
	fn_body += '\t'
	if sig.rt != 'void' {
		fn_body += 'return'
	}
	call_sig := gen_v_c_call_sig(sig) + '\n'
	fn_body += ' ' + call_sig
	fn_body += '}'

	return fn_body.trim(' '), fn_name
}

fn c_to_v_c_type(c_type string) string {
	mut vc_type := ''
	if c_type in c2v_alias_enums.keys() {
		return c2v_alias_enums[c_type]
	}
	if c_type in c2v_types_map.keys() {
		return c2v_types_map[c_type]
	}
	if c_type.contains('*') {
		vc_type = '&'
		if c_type.count('*') > 1 {
			vc_type = '&&'
		}
	}
	if c_type == 'void' {
		if vc_type == '&' {
			return 'voidptr'
		}
		return ''
	}
	var_name := c_type.all_before_last('*')
	return vc_type + 'C.' + var_name
}

fn c_to_v_type(kind string) string {
	if kind == 'char*' {
		return 'charptr'
	}
	if kind == 'void*' {
		return 'voidptr'
	}

	mut ptr := ''
	mut knd := kind
	if knd.contains('*') {
		ptr = '&'
		knd = knd.replace('*', '')
	}
	// mut v_type := ''
	if knd in c2v_alias_enums.keys() {
		return ptr + c2v_alias_enums[knd]
	}
	if knd in c2v_alias_typedefs.keys() {
		return ptr + c2v_alias_typedefs[knd]
	}

	if knd == 'void' {
		return ''
	}

	return ptr + 'C.' + knd
}

fn v_fn_name(c_fn_name string) string {
	mut si := 0
	mut parts := []string{}
	for i, ch in c_fn_name {
		if ch.is_capital() {
			parts << c_fn_name[si..i]
			si = i
		}

		if i == c_fn_name.len - 1 {
			parts << c_fn_name[si..]
		}
	}
	// println('$c_fn_name : $parts')
	mut v_fn_name := ''
	for str in parts {
		v_fn_name += str.to_lower() + '_'
	}
	v_fn_name = v_fn_name.trim_right('_')
	v_fn_name = v_fn_name.replace('ma_', '')
	// println('$c_fn_name -> $v_fn_name')
	return v_fn_name.trim_left('_')
}

fn c_to_v_var_name(c_var_name string) string {
	mut si := 0
	mut parts := []string{}
	for i, ch in c_var_name {
		if ch.is_capital() {
			parts << c_var_name[si..i]
			si = i
		}

		if i == c_var_name.len - 1 {
			parts << c_var_name[si..]
		}
	}
	// println('$c_fn_name : $parts')
	mut v_var_name := ''
	for str in parts {
		v_var_name += str.to_lower() + '_'
	}
	v_var_name = v_var_name.trim_right('_')
	v_var_name = v_var_name.replace('ma_', '')
	// println('$c_fn_name -> $v_var_name')
	return v_var_name.trim_left('_')
}
