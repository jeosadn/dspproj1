addpath('functions');
pkg load communications

%PARSING Parameters
metadata_filename = read_parameters('parameters.txt','metadata_filename');
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
audio_output_filename = read_parameters('parameters.txt','audio_output_filename');
header_char = read_parameters('parameters.txt','header_char');
header_len = str2num(read_parameters('parameters.txt','header_len'));
header_times = str2num(read_parameters('parameters.txt','header_times'));
footer_char = read_parameters('parameters.txt','footer_char');

segmentSize = str2num(read_parameters('parameters.txt','segmentSize'));
Channel = str2num(read_parameters('parameters.txt','Channel'));
a0 = str2num(read_parameters('parameters.txt','a0'));
t0 = str2num(read_parameters('parameters.txt','t0'));
a1 = str2num(read_parameters('parameters.txt','a1'));
t1 = str2num(read_parameters('parameters.txt','t1'));
decoder_delay_tolerance = str2num(read_parameters('parameters.txt','decoder_delay_tolerance'));
fprintf('Encoder parsed parameters\n');

%PARSING Metadata
metadata_string = read_metadata(metadata_filename);
fprintf('Encoder parsed metadata\n');

binary_stream = str_to_bin(metadata_string, header_char, header_len, header_times, footer_char);

%CODER
fprintf('Starting encode. This takes about 8 minutes, less than 30 seconds in Matlab\n');
tic;
coder(char(audio_input_filename), char(audio_output_filename), binary_stream, a0, t0, a1, t1, segmentSize, Channel);
fprintf('Coding time:\n');
toc;
