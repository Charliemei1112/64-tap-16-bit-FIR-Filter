% Design 64-tap 16-bit FIR filter
% fx_32: 32-bit fixed-point 2's binary number, 8-bit integer and 24-bit fraction
% fx_16: 16-bit floating-point binary IEEE754

function fp_16 = fx2fp(fx_32)
    % Convert 32-bit fixed-point to 16-bit floating-point
    % initiate fp_16
    fp_16 = zeros(1, 16);
    % 1. find the sign bit
    sign = fx_32(1);
    % 2. if sign is 1, we need to change 0-bit to 1-bit and 1-bit to 0-bit, and add 1
    if (sign == '1')
        fx_32 = strrep(fx_32, '0', 'x');
        fx_32 = strrep(fx_32, '1', '0');
        fx_32 = strrep(fx_32, 'x', '1');
        fx_32 = dec2bin(bin2dec(fx_32) + 1, 32);
    end
    % 3. find the MSB 1-bit
    msb = find(fx_32 == '1', 1);
    if (msb < 22)
        % assign mantissa to be msb+1 to mas+10
        mantissa = fx_32(msb+1:msb+10);
        % assign exponent to be 23 - msb
        exponent = 23 - msb;
    else
        % assign mantissa to be 23 to 32
        mantissa = fx_32(23:32);
        % assign exponent to be 0
        exponent = 0;
    end
    % 4. assign the sign bit to fp_16
    fp_16(1) = sign;
    % 5. assign the exponent to fp_16
    fp_16(2:6) = dec2bin(exponent, 5);
    % 6. assign the mantissa to fp_16
    fp_16(7:16) = mantissa;
    % print sign, mantissa, exponent
    % fprintf('sign: %s\n', sign);
    % fprintf('exponent: %d\n', exponent);
    % fprintf('mantissa: %s\n', mantissa);
end

