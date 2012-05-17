function str = createDimensionDisplayString(objects, classdesc)
; %#ok Undocumented
%createDimensionString - format an array dimension in a specific way
%
% createDimensionString(OBJECTS, CLASSDESC) creates a String of the
% format: CLASSDESC: 3-by-2-by-1

% Copyright 2010 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2010/03/01 05:20:28 $

dimObj = size(objects);

% Generates the array dimension with the correct distcomp object name
% Add different endings for 2, 3 and 4D
switch length(dimObj)
    case {2 3 4}
        % Use vectorised sprintf and strip the last 4 chars ('-by-')
        dimStr = sprintf('%d-by-%d-by-', dimObj);
        dimStr = dimStr(1:end-4);
    otherwise
        dimStr =[num2str(length(dimObj)) '-D'];
end

str = sprintf('%s: %s', classdesc, dimStr);
end
