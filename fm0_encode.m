function fm0_encoded = fm0_encode(bitstream)
    % Function to encode a bitstream into FM0 encoding

    % Ensure bitstream is a row vector
    if iscolumn(bitstream)
        bitstream = bitstream';
    end
    
    % Initialize encoded stream
    fm0_encoded = [];
    
    % Initial state (assume starting with a low signal)
    previous_level = 0;

    for i = 1:length(bitstream)
        bit = bitstream(i);
        
        if bit == 1 || bit == '1'
            % For bit '1', toggle the signal at the start
            current_level = ~previous_level;
            fm0_encoded = [fm0_encoded current_level ~current_level];
        else
            % For bit '0', no toggle at the start
            current_level = previous_level;
            fm0_encoded = [fm0_encoded current_level ~current_level];
        end
        
        % Update the previous level to the current level
        previous_level = current_level;
    end

    % append DUMMY 1
    current_level = ~previous_level;
    fm0_encoded = [fm0_encoded current_level ~current_level];
end