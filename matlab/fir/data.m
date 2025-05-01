% Parameters
num_loops = 128;

% Initialize results array
result = 0;
data_in = fopen('data_input.txt', 'w');
data_decimal_in = fopen('data_decimal_input.txt', 'w');
% Perform MAC operation in a loop
for i = 1:(num_loops)
    % MAC operation: Multiply input_data and coefficients, then accumulate
    % generate random decimals from -2 to 2
    input_data = 4 * rand() - 2;
    input_data = input_data * 2^12;
    input_data = round(input_data);
    bin_data = dec2bin(input_data, 16);
    % Save result to the results array
    fprintf(data_in, '%s\n', bin_data);
    fprintf(data_decimal_in, '%d\n', input_data);
end

% Save results to a file

fclose(data_in);
fclose(data_decimal_in);
