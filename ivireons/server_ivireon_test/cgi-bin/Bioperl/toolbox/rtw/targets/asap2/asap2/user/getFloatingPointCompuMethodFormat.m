function cm_format = getFloatingPointCompuMethodFormat(dataType,cmUnits)
%GETFLOATINGPOINTCOMPUMETHODFORMAT outputs the string Format for the
% COMPU_METHOD for floating point numbers. 
% [length].[layout] is the required format. Length indicates the overall
% length. Layout indicates the number of decimal places.

%   Copyright 2009 The MathWorks, Inc.

if strcmp(dataType, 'SINGLE')
    cm_format = '%8.6';
elseif strcmp(dataType, 'DOUBLE')
    cm_format = '%15.10';
end

% Example of using the Units to decide the COMPU METHOD format 
if strcmp(cmUnits,'rpm')
%     cm_format='%4.0';
% elseif strcmp(cmUnits,'m/(s^2)')
%     cm_format='%6.2';
end

end

