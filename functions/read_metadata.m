function str_result = read_metadata(metadata_filename)
    metadata_string = '';
    metadata_file = fopen(metadata_filename, 'r');
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

    str_result = metadata_string;
end
