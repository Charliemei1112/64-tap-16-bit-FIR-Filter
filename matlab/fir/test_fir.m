% Parameters
coef_num_loops = 64;
fir_num_loops = 16384;
sum = 0;

% Initialize results array
result = 0;
bin_out = fopen('output.txt', 'w');
bin_fp_out = fopen('fp_output.txt', 'w');
data_in = fopen('fir_input.txt', 'w');
coeff_in = fopen('coef.txt', 'w');

% filter coefficients 1*64
b = zeros(1, coef_num_loops);
% input data 1*512
x = zeros(1, fir_num_loops);
% filter state 1*64
z = zeros(coef_num_loops, 1);

for i = 1:(coef_num_loops)
    % MAC operation: Multiply input_data and coefficients, then accumulate
    % generate random decimals from -2 to 2
    coef_data = 2 * rand() - 1;
    coef_data = coef_data * 2^12;
    coef_data = round(coef_data);
    b(i) = coef_data;
    bin_coef = dec2bin(coef_data, 16);
    % write coef_data to file
    fprintf(coeff_in, '%s\n', bin_coef);
end

for i = 1:(fir_num_loops)
    % MAC operation: Multiply input_data and coefficients, then accumulate
    % generate random decimals from -2 to 2
    input_data = 2 * rand() - 1;
    input_data = input_data * 2^12;
    input_data = round(input_data);
    x(i) = input_data;
    bin_input = dec2bin(input_data, 16);
    % write input_data to file
    fprintf(data_in, '%s\n', bin_input);
end

[y,z] = fir(b,x,z);    

for (i = 1:fir_num_loops)
    % write output_data to file
    % fprintf('y[%d] = %d\n', i, y(i));
    bin_output = dec2bin(y(i),32);
    bin_fp_output = fx2fp(bin_output);
    fprintf(bin_out, '%s\n', bin_output);
    fprintf(bin_fp_out, '%s\n', bin_fp_output);
end

% Save results to a file

fclose(bin_out);
fclose(data_in);
fclose(coeff_in);
fclose(bin_fp_out);
