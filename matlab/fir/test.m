% This is the test script for the FIR filter

% open input.txt file
input_file = fopen('input.txt', 'w');
% open output.txt file
output_file = fopen('output.txt', 'w');
% open coef.txt file
coef_file = fopen('coef.txt', 'w');
% open 

nx = 512;
t = linspace(0,2*pi,nx)';

% generate sinusoid input signal
x = sin(2*pi*0.1*t) + sin(2*pi*0.2*t) + sin(2*pi*0.5*t);

% write input to input.txt
fprintf(input_file, '%d\n', x);

% plot input signal
% figure(1);
% plot(x);
% title('Input Signal');
% xlabel('Time');
% ylabel('Amplitude');

% Generate low-pass filter coefficients
% random integer from 0 to 10
b = fir1(63, 0.5);
fprintf(coef_file, '%d\n', b);


% Initilize filter state with first 64 samples of input signal
z = zeros(64,1);

% Apply filter to input signal
[y,z] = fir(b,x,z);

% write y to output.txt
fprintf(output_file, '%d\n', y);

% plot output signal
% figure(2);
% plot(y);
% title('Output Signal');
% xlabel('Time');
% ylabel('Amplitude');

% close files
fclose(input_file);
fclose(output_file);

exit;
