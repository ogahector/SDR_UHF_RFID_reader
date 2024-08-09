function bitstream = string_to_bitstream(input_string)
    % Function to convert a string to a bitstream (binary representation)
    
    % Ensure input is a character array
    if ~ischar(input_string)
        error('Input must be a character array.');
    end
    
    % Initialize an empty array to store the bitstream
    bitstream = [];
    
    % Loop through each character in the input string
    for i = 1:length(input_string)
        % Get the ASCII value of the character
        ascii_value = uint8(input_string(i));
        
        % Convert the ASCII value to a binary string (8 bits)
        binary_string = dec2bin(ascii_value, 8);
        
        % Convert the binary string to a numeric array of 0s and 1s
        binary_array = binary_string - '0';
        
        % Append the binary array to the bitstream
        bitstream = [bitstream binary_array];
    end
end