function selections = getallselections(hSct)
%GETALLSELECTIONS Returns all available selections

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:25:18 $

% This can be a private method

identifiers = get(hSct, 'Identifiers');
selections  = {};

% Loop over the identifiers and get only the first element
for i = 1:length(identifiers),
    if iscell(identifiers{i}),
        selections{i} = identifiers{i}{1};
    else
        selections{i} = identifiers{i};
    end
end

% [EOF]
