function str_result = read_parameters(parameters_filename, parameter)
    parameters_string = '';
    parameters_file = fopen(parameters_filename, 'r');
    line = fgetl(parameters_file);
    item = strsplit(line,{' ','='});
    
    str_result = '';
    parameter_name = item(1,1);
    
    while true
        if (strcmp(parameter_name,parameter))
          str_result = cell2mat(item(1,2));
          break
        else
          line = fgetl(parameters_file);
          if line == -1
            break;
          end
          item = strsplit(line,{' ','='});
          parameter_name = item(1,1);
        end
    end
    
    fclose(parameters_file);
end