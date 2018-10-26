clear;
clc;
%COMPAT
%pkg load communications; %Octave version (Leave commented for matlab)
%COMPAT

%Parameters
filename = 'metadata.txt';
code_len = 12;

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

msg_string = [metadata_string '@@'];
binary_array = [];
for idx = 1:length(msg_string)
    %COMPAT
    %binary_char = de2bi(toascii(msg_string(idx)), 8); %Octave version
    binary_char = de2bi(cast(msg_string(idx), 'uint8'), 8); %Matlab version
    %ENDCOMPAT

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
        disp('Illegal code_len encode');
    end

    binary_array = [binary_array code_word]; %#ok<AGROW>
end
inyect_err = [];
inyect_err = [1 200 1230 1300 1305];
for idx = inyect_err
    binary_array(idx) = ~binary_array(idx); %#ok<SAGROW>
end

%DECODE
result = '';
for idx = 1:code_len:length(binary_array)
    code_word = binary_array(idx:idx+code_len-1);

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
        if (check1 + check2 + check4 + check8 > 2)
            fprintf('Hamming error on char %.0f, cannot recover\n', idx/code_len+1);
        elseif (err_bit_pos ~= 0)
           fprintf('Hamming error on char %.0f, bit %d corrected\n', idx/code_len+1, err_bit_pos);
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
        disp('Illegal code_len decode');
    end

    string_char = cast(bi2de(binary_char), 'char');
    if (string_char == '@')
        break; %End of metadata is @@
    end
    result = [result string_char]; %#ok<AGROW>
end
if idx >= length(binary_array)-code_len-1
    disp('Error, no end of metadata found');
end

if strcmp(result, metadata_string)
    disp('Test pass');
else
    disp('Test fail');
    disp(metadata_string);
end
disp(result);

remain = result;
[Title, remain] = strtok(remain, '|');
[Artist, remain] = strtok(remain, '|');
[Author, remain] = strtok(remain, '|');
[Album, remain] = strtok(remain, '|');
[Date, remain] = strtok(remain, '|');
[Invited, remain] = strtok(remain, '|');
[Producer, remain] = strtok(remain, '|');

fprintf('Los metadatos empotrados en el audio son los siguientes:\nTitulo: %s\nArtista: %s\nAutor: %s\nAlbum: %s\nFecha de publicacion: %s\nArtista invitado: %s\nProductor: %s\n', Title, Artist, Author, Album, Date, Invited, Producer);