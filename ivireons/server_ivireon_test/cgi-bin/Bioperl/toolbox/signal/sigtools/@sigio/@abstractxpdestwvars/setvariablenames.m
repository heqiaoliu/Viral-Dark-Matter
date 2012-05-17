function dummy = setvariablenames(h, P)
%SETVARIABLENAMES SetFunction for the VariableNames property.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/04/13 00:27:30 $

if isempty(P),
    dummy = [];
    return;
else
    lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
    set(lvh,'Values',P);
    
    dummy = [];
end

% [EOF]
