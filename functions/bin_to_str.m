function str_output = bin_to_str(binary_input, header_char, header_len, footer_char)
    code_len = 12;

    decode_header(1:header_len) = header_char;
    for idx = 1:length(binary_input)
        if (length(binary_input) < idx || length(binary_input) < idx+code_len*header_len)
            fprintf('Header not found in message, assuming message starts on bit 1\n');
            idx = 1; %#ok<FXSET>
            break;
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

        string_char = cast(bi2de(binary_char), 'char');
        if (string_char == footer_char)
            break;
        end
        result = [result string_char]; %#ok<AGROW>
    end
    if idx >= length(binary_msg)-code_len-1
        fprintf('Error, no end of metadata found\n');
    end

    str_output = result;
end
