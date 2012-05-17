function tOut = eml_get_out_numerictype_for_round(tIn, num_bit_grow)
%EML_GET_OUT_NUMERICTYPE_FOR_ROUND Internal use only function

%   TOUT = EML_GET_OUT_NUMERICTYPE(TIN, NUM_BIT_GROW) generates the appropriate
%   numerictype for the output of MATLAB style rounding on a fi object 
%   with numerictype TIN. TIN is expected to have DataType 'Fixed' or 
%   'ScaledDouble'. 
%   This function is used by Embedded Matlab.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2007/11/17 21:48:32 $

if ~isscaledtype(tIn)
    
    error('eml:fi:unexpectedinputtoround', ...
     'The input numerictype is expected to have DataType ''Fixed'' or ''ScaledDouble''.');
end

tOut = tIn;

if tIn.fractionlength > 0

    tOut.wordlength = max((tIn.wordlength - tIn.fractionlength + num_bit_grow), ...
                        (1 + double(tIn.signed)));

    tOut.fractionlength = 0;

end
