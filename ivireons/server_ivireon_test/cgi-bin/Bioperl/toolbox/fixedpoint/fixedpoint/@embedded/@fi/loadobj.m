function y = loadobj(x)
% LOADOBJ Load filter for fi objects when the "DataType" is "Double"

%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/10/10 02:21:11 $

if isstruct(x) 
    % Code to convert struct x to a fi-double: y
    % Create an embedded.fi and set its properties from structure x
    y = embedded.fi;
    cellXVals = struct2cell(x);
    cellXFields = fieldnames(x);
    for i = 1:length(cellXFields)
        y.(cellXFields{i}) = cellXVals{i};
    end
else
    y = x;
end