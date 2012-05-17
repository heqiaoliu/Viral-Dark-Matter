function P = setvariablelabels(h, P)
%SETVARIABLELABELS SetFunction for the VariableLabels property.

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/10/18 21:10:48 $

if ~isempty(P),
    lvh = getcomponent(h, '-class', 'siggui.labelsandvalues');
    
    for n = 1:length(P),
        newP{n} = [xlate(P{n}),':'];
    end
    set(lvh,'Labels',newP);
end

% [EOF]
