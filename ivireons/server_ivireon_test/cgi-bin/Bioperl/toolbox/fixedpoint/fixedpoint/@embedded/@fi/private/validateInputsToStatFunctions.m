function validateInputsToStatFunctions(x,fnname)
%VALIDATE_INPUTS_TO_STAT_FUNCTIONS Internal use only: check inputs to mean, median.
%   Validate that the input is (a) not a slope-bias scaled FI, and (b) not a FI-boolean.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:07:30 $


if isslopebiasscaled(numerictype(x))

    error(['fi:' fnname ':slopeBiasNotSupported'],['Inputs to ''' fnname...
        ''' that are FI objects must have an integer power-of-two slope, and a bias of 0.']);
elseif isboolean(x)

    error(['fi:' fnname ':boolean:notallowed'],['Function ''' fnname...
        ''' is not defined for FI objects of data type ''boolean''.']);    
end  
