function c = getcharacter(h, indx)
%GETCHARACTER Returns the character to use for a given index

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/05/31 23:28:01 $

cb = get(h, 'ConstrainedBands');

if any(indx == cb)

    % Get the IRType and based on that determine the list of all valid
    % units and get the current units
    Type = get(h, 'IRType');
    I = find(strcmp(get(h, Type), set(h, Type)));
    
    if I == 1
        % This means we selected dB
        c = 'A';
    elseif I == 2
        
        % This means we selected Linear or squared
        if strncmpi(Type, 'IIR', 3)
            c = 'E';
        elseif strncmpi(Type, 'FIR', 3)
            c = 'D';
        end
    end
else
    c = 'W';
end

% [EOF]
