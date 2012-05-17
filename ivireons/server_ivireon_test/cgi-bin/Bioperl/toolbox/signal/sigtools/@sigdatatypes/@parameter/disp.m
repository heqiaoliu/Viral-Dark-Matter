function disp(hPrm)
%DISP Display the parameter object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:38:26 $

if length(hPrm) == 1,

    % If there is only one parameter object, display it's details
    disp(['Name        : ', hPrm.Name]);
    disp(['Tag         : ', hPrm.Tag]);
    disp(['ValidValues : ' validvaluestring(hPrm)]);
    
    disp(' ');
    
    value = hPrm.Value;
    if ischar(hPrm.Value)
        disp(sprintf('Value       : %s', value));
    else
        disp(['Value       : ' num2str(value)]);
    end
else
    
    % If there are more than 1 parameter object just display the type and size
    [r c] = size(hPrm);
    disp([class(hPrm) ': ' num2str(r) '-by-' num2str(c)]);
end

disp(' ');

% [EOF]
