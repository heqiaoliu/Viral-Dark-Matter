function selectionString = var2string(selectedData)

% Create an array of strings based on the selectedData array.

%   Copyright 2007-2008 The MathWorks, Inc.

selectionString = '';
% Use a tab separated list to ensure paste-ability to Variable Editor
if ~isempty(selectedData)
    selectionString = sprintf('%f\t',selectedData(1,:));
    selectionString = selectionString(1:end-1);
    for k=2:size(selectedData,1)
        rowStr = sprintf('%f\t',selectedData(k,:));
        selectionString = sprintf('%s\n%s',selectionString,rowStr(1:end-1));
    end
end