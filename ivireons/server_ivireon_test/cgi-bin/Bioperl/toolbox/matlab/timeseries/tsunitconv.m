function convFactor = tsunitconv(outunits,inunits)
%TSUNITCONV Utility function used to convert time units
%
%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/08/23 19:05:59 $

convFactor = 1; % Return 1 if error or unknown units
try %#ok<TRYNC>
    if strcmp(outunits,inunits)
        return;
    end

    % Factors are based on {'weeks', 'days', 'hours', 'minutes', 'seconds',
    % 'milliseconds', 'microseconds', 'nanoseconds'}
    availableUnits = {'weeks', 'days', 'hours', 'minutes', 'seconds',...
      'milliseconds', 'microseconds', 'nanoseconds'};
    factors = [604800 86400 3600 60 1 1e-3 1e-6 1e-9];  
    indIn = find(strcmp(inunits,availableUnits));
    if isempty(indIn)
        return
    end
    factIn = factors(indIn);
    indOut = find(strcmp(outunits,availableUnits));
    if isempty(indOut)
        return
    end
    factOut = factors(indOut);
    convFactor = factIn/factOut;
end