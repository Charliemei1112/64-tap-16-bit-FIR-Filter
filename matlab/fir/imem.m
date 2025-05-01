% Parameters
num_loops = 64;

% Initialize results array
result = 0;
data_in = fopen('imem_input.txt', 'w');
% Perform MAC operation in a loop
for i = 1:(num_loops)
    % MAC operation: Multiply input_data and coefficients, then accumulate

    input_data = randi([-16384, 16383]);
    bin_data = dec2bin(input_data, 16);

    % Save result to the results array
    fprintf(data_in, '%s\n', bin_data);
end

% Save results to a file

% Close files
fclose(data_in);
