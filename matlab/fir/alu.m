% Parameters
num_loops = 64;
sum = 0;
fx_sum = 0;

% Initialize results array
result = 0;
bin_out = fopen('alu_output.txt', 'w');
data_in = fopen('alu_input.txt', 'w');
coeff_in = fopen('alu_coef.txt', 'w');
% Perform MAC operation in a loop
for i = 1:(num_loops)
     % MAC operation: Multiply input_data and coefficients, then accumulate
    % generate random decimals from -2 to 2
    coef_data = 4 * rand() - 2;
    coef_data = coef_data * 2^12;
    coef_data = round(coef_data);
    input_data = 4 * rand() - 2;
    input_data = input_data * 2^12;
    input_data = round(input_data);
    sum = sum + input_data * coef_data;
    bin_data = dec2bin(input_data, 16);
    bin_coef = dec2bin(coef_data, 16);
    fp_sum = fx2fp(dec2bin(sum, 32));
    % Save result to the results array
    fprintf(data_in, '%s\n', bin_data);
    fprintf(coeff_in, '%s\n', bin_coef);
    fprintf(bin_out, '%s\n', fp_sum);
end

% Save results to a file

fclose(bin_out);
fclose(data_in);
fclose(coeff_in);
