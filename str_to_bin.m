function bin_output = str_to_bin(metadata_string, header_char, header_len, header_times, footer_char)
    code_len = 12;
    encode_header(1:header_len*header_times) = header_char;
    encode_footer(1:2) = footer_char;
    msg_string = [encode_header metadata_string encode_footer];
    binary_output = [];
    for idx = 1:length(msg_string)
        binary_char = de2bi(double(msg_string(idx)), 8);

        code_word = [];
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

        binary_output = [binary_output code_word]; %#ok<AGROW>
    end

    bin_output = binary_output;
end
