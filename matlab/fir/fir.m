% Design 64-tap 16-bit FIR filter
% fir function takes:
%  b: filter coefficients
%  x: input signal
%  z: filter state
% and returns:
%  y: output signal
%  z: updated filter state

function [y,z] = fir(b,x,z)
    y = zeros(size(x));
    for n=1:length(x)
        z = [x(n); z(1:end-1)];  % shift input into filter state
        % print z
        y(n) = b * z; % compute output
    end
end

