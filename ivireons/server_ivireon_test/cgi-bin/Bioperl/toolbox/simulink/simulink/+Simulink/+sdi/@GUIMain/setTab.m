function setTab(this, newSelectedTab)
% Possible Tab index can be 1,2 or 3

%   Copyright 2010 The MathWorks, Inc.
tabgroup = get(newSelectedTab,'Parent');
ch = get(tabgroup,'Children');
firstChild = handle([]);
secondChild = handle([]);
thirdChild = handle([]);
try
    firstChild = ch(1);
    secondChild = ch(2);
    thirdChild = ch(3);
catch ex
    if (~strcmpi(ex.identifier,'MATLAB:badsubscript'))
        rethrow(ex);
    end
end

if (isempty(newSelectedTab))
    return;
end

switch double(newSelectedTab)
    case double(firstChild)
        this.TabType = Simulink.sdi.GUITabType.InspectSignals;
    case double(secondChild)
        this.TabType = Simulink.sdi.GUITabType.CompareSignals;
    case double(thirdChild)
        this.TabType = Simulink.sdi.GUITabType.CompareRuns;
end
end