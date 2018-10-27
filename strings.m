clear;
clc;
%COMPAT
%pkg load communications; %Octave version (Leave commented for matlab)
%ENDCOMPAT

%Parameters
filename = 'metadata.txt';
code_len = 12; %can be 8 (no checking), 9 (parity checking) or 12 (ECC up to 1 bit)
header_char = '#';
header_len = 4;
header_times = 3;
footer_char = '@';

%Encoding
metadata_string = '';
metadata_file = fopen(filename, 'r');
line = fgetl(metadata_file);
[item, ~] = strtok(line, '|');

while ischar(item)
    metadata_string = strcat(metadata_string, '|', item);
    line = fgetl(metadata_file);
    if line == -1
        break;
    end
    [item, ~] = strtok(line, '|');
end
fclose(metadata_file);

encode_header(1:header_len*header_times) = header_char;
encode_footer(1:2) = footer_char;
msg_string = [encode_header metadata_string encode_footer];
binary_output = [];
for idx = 1:length(msg_string)
    binary_char = de2bi(double(msg_string(idx)), 8);

    code_word = [];
    if code_len == 8
        code_word = binary_char;
    elseif code_len == 9
        parity_bit = mod(sum(binary_char), 2);
        code_word = [binary_char parity_bit];
    elseif code_len == 12
        code_word(03) = binary_char(01);
        code_word(05) = binary_char(02);
        code_word(06) = binary_char(03);
        code_word(07) = binary_char(04);
        code_word(09) = binary_char(05);
        code_word(10) = binary_char(06);
        code_word(11) = binary_char(07);
        code_word(12) = binary_char(08);
        code_word(01) = mod(code_word(03) + code_word(05) + code_word(07) + code_word(09) + code_word(11), 2);
        code_word(02) = mod(code_word(03) + code_word(06) + code_word(07) + code_word(10) + code_word(11), 2);
        code_word(04) = mod(code_word(05) + code_word(06) + code_word(07) + code_word(12), 2);
        code_word(08) = mod(code_word(09) + code_word(10) + code_word(11) + code_word(12), 2);
    else
        fprintf('Illegal code_len encode\n');
    end

    binary_output = [binary_output code_word]; %#ok<AGROW>
end

%Error inyection
binary_output = [1 0 1 0 1 binary_output]; %Alignment error
inyect_err = [1 15 43 201 503 805]; %Bit transmission error
for idx = inyect_err
    binary_output(idx) = ~binary_output(idx);
end

%Bridge from ENCODE to DECODE
binary_input = binary_output;

%DECODE
%Message header identification
decode_header(1:header_len) = header_char;
for idx = 1:length(binary_input)
    if (length(binary_input) < idx || length(binary_input) < idx+code_len*header_len)
        fprintf('Header not found in message, aborting binary decode\n');
        return;
    end

    header = '';
    for pos = 1:code_len:code_len*header_len
        code_word = binary_input(pos-1+idx:pos-1+idx+code_len-1);
        binary_char = [];
        if code_len == 8
            binary_char = code_word(1:8);
        elseif code_len == 9
            binary_char = code_word(1:8);
        elseif code_len == 12
            check1 = mod(code_word(01) + code_word(03) + code_word(05) + code_word(07) + code_word(09) + code_word(11), 2);
            check2 = mod(code_word(02) + code_word(03) + code_word(06) + code_word(07) + code_word(10) + code_word(11), 2);
            check4 = mod(code_word(04) + code_word(05) + code_word(06) + code_word(07) + code_word(12), 2);
            check8 = mod(code_word(08) + code_word(09) + code_word(10) + code_word(11) + code_word(12), 2);
            err_bit_pos = check1*1 + check2*2 + check4*4 + check8*8;
            if (err_bit_pos > 12)
            elseif (err_bit_pos ~= 0)
                code_word(err_bit_pos) = ~code_word(err_bit_pos);
            end
            binary_char(01) = code_word(03);
            binary_char(02) = code_word(05);
            binary_char(03) = code_word(06);
            binary_char(04) = code_word(07);
            binary_char(05) = code_word(09);
            binary_char(06) = code_word(10);
            binary_char(07) = code_word(11);
            binary_char(08) = code_word(12);
        else
            fprintf('Illegal code_len decode\n');
        end
        string_char = cast(bi2de(binary_char), 'char');
        header = [header string_char]; %#ok<AGROW>
    end
    if strcmp(header, decode_header)
        break;
    end
end

%Truncate starting irrelevant bits
binary_msg_temp = binary_input(idx:length(binary_input));

%Truncate ending irrelevant bits
end_pos = length(binary_msg_temp) - mod(length(binary_msg_temp), code_len);
binary_msg = binary_msg_temp(1:end_pos);

fprintf('Message header detected in binary stream at bit %d, resizing from %d:%d to %d:%d\n', idx, 1, length(binary_input), idx, end_pos);

%Message decoding
result = '';
for idx = 1:code_len:length(binary_msg)
    code_word = binary_msg(idx:idx+code_len-1);

    binary_char = [];
    if code_len == 8
        binary_char = code_word(1:8);
    elseif code_len == 9
        if mod(sum(code_word), 2) ~= 0
            fprintf('Parity error on char %.0f\n', idx/code_len+1);
        end
        binary_char = code_word(1:8);
    elseif code_len == 12
        check1 = mod(code_word(01) + code_word(03) + code_word(05) + code_word(07) + code_word(09) + code_word(11), 2);
        check2 = mod(code_word(02) + code_word(03) + code_word(06) + code_word(07) + code_word(10) + code_word(11), 2);
        check4 = mod(code_word(04) + code_word(05) + code_word(06) + code_word(07) + code_word(12), 2);
        check8 = mod(code_word(08) + code_word(09) + code_word(10) + code_word(11) + code_word(12), 2);
        err_bit_pos = check1*1 + check2*2 + check4*4 + check8*8;
        if (err_bit_pos > 12)
            fprintf('Hamming code error on char %.0f, cannot recover\n', idx/code_len+1);
        elseif (err_bit_pos ~= 0)
           fprintf('Hamming code error on char %.0f, bit %d corrected\n', idx/code_len+1, err_bit_pos);
           code_word(err_bit_pos) = ~code_word(err_bit_pos);
        end
        binary_char(01) = code_word(03);
        binary_char(02) = code_word(05);
        binary_char(03) = code_word(06);
        binary_char(04) = code_word(07);
        binary_char(05) = code_word(09);
        binary_char(06) = code_word(10);
        binary_char(07) = code_word(11);
        binary_char(08) = code_word(12);
    else
        fprintf('Illegal code_len decode\n');
    end

    string_char = cast(bi2de(binary_char), 'char');
    if (string_char == footer_char)
        break;
    end
    result = [result string_char]; %#ok<AGROW>
end
if idx >= length(binary_msg)-code_len-1
    fprintf('Error, no end of metadata found\n');
end

%Message Parsing
remain = result;
[Header, remain] = strtok(remain, '|');

if strcmp(remain, metadata_string)
    fprintf('Test pass\n');
else
    fprintf('Test fail\n');
    fprintf('%s\n', metadata_string);
end
fprintf('%s\n', remain);

[Title, remain] = strtok(remain, '|');
[Artist, remain] = strtok(remain, '|');
[Author, remain] = strtok(remain, '|');
[Album, remain] = strtok(remain, '|');
[Date, remain] = strtok(remain, '|');
[Invited, remain] = strtok(remain, '|');
[Producer, remain] = strtok(remain, '|');

fprintf('Los metadatos empotrados en el audio son los siguientes:\nTitulo: %s\nArtista: %s\nAutor: %s\nAlbum: %s\nFecha de publicacion: %s\nArtista invitado: %s\nProductor: %s\n', Title, Artist, Author, Album, Date, Invited, Producer);
