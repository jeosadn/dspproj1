addpath("functions");

clear;
clc;

%PARSING Parameters
metadata_filename = read_parameters('parameters.txt','metadata_filename');
audio_input_filename = read_parameters('parameters.txt','audio_input_filename');
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

%DECODER
tic;
dataDecoded = decoder(a0, t0, a1, t1, segmentSize, Channel, decoder_delay_tolerance);
fprintf('Decoding time:\n');
toc;

%POSTPARSING
result = bin_to_str(dataDecoded, header_char, header_len, footer_char);

parse_metadata(result);