function cm_format = getCompuMethodFormat(fracSlope,fixExp,bias,numBits,cmUnits)
%GETCOMPUMETHODFORMAT outputs the string Format for the COMPU_METHOD for
% integers and fixed point numbers.
% [length].[layout] is the required format. Length indicates the overall
% length. Layout indicates the number of decimal places.

%   Copyright 2009 The MathWorks, Inc.

%set the maximum number of digits that can be in the decimal place
limit_digits_in_decimal_places = 16;
%calculate number of digits based on the number of bits
numBitslength = length(num2str(2^numBits));

if (fracSlope == 1) && (bias == 0)
    if fixExp >= 0
        layout = 0;
    elseif fixExp <= -(limit_digits_in_decimal_places)
        %setting a limit to the number of digits in the decimal place
        layout = limit_digits_in_decimal_places;
    else
        %different calculation for numBitslength is required for this case
        %example:
        numBitslength = length(num2str(2^(numBits+fixExp)));
        %e.g. 2^-4 require 4 decimal places
        layout = abs(fixExp);
    end
    
    total_length = numBitslength + layout;
    cm_format = ['%' num2str(total_length) '.' num2str(layout)];
else
    %default layout when a bias is provided and fracSlope not equal to 1
    cm_format = 'customformat';
    %the string 'customformat' is replaced by the default format specified
    %in asap2setup.tlc. If a different cm_format string is returned then
    %that cm_format will be used for the respective Compu Method
end

% Example of using the Units to decide the COMPU METHOD format
if strcmp(cmUnits,'rpm')
%     cm_format='%4.0';
% elseif strcmp(cmUnits,'m/(s^2)')
%     cm_format='%6.2';
end

end
