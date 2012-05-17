function str = validvaluestring(hPrm)
%VALIDVALUESTRING Returns the valid value in string form

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:38:32 $

vValues = hPrm.ValidValues;

if isa(vValues, 'function_handle'),
    
    % Display the function handle as it would appear by itself
    str = ['@' func2str(vValues)];
elseif iscell(vValues),

    % Loop over the valid values and wrap them in single quotes
    str = '';
    for i = 1:length(vValues),
        str = [str '''' vValues{i} ''' '];
    end
else
    
    % Display the range
    str = [num2str(vValues(1)) ' to ' num2str(vValues(end))];
    
    % If there are 3 elements, the middle must be the step
    if length(vValues) == 3,
        str = [str ' in steps of ' num2str(vValues(2))];
    end
end

% [EOF]
