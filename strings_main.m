clear;
clc;
delete './coded.wav';

%Parameters
metadata_filename = 'metadata.txt';
audio_input_filename = './sample2.wav';
header_char = '#';
header_len = 4;
header_times = 3;
footer_char = '@';

segmentSize = 6000;
Channel = 1;
a0 = 0.831;
t0 = 792;
a1 = 0.628;
t1 = 837;
decoder_delay_tolerance = 3;

%PARSING
metadata_string = read_metadata(metadata_filename);

binary_stream = str_to_bin(metadata_string, header_char, header_len, header_times, footer_char);

%CODER
tic;
coder(audio_input_filename, binary_stream, a0, t0, a1, t1, segmentSize, Channel);
fprintf('Coding time:\n');
toc;

%DECODER
tic;
dataDecoded = decoder(a0, t0, a1, t1, segmentSize, Channel, decoder_delay_tolerance);
fprintf('Decoding time:\n');
toc;

%POSTPARSING
result = bin_to_str(dataDecoded, header_char, header_len, footer_char);

parse_metadata(result);
