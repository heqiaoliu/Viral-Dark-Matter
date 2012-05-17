function [xcolname, ycolname] = bfitdatastatsgetcolnames(dataHandle)
%BFITDATASTATSGETCOLNAMES gets columns labels to use in the Data Statistics GUI

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/07/12 18:09:36 $

dh = handle(dataHandle);
if isa(dh, 'graph2d.lineseries')
    xcolname = get(dh, 'XDataSource');
    if isempty(xcolname)
        xcolname = 'X';
    end
    ycolname = get(dh, 'YDataSource');
    if isempty(ycolname)
        ycolname = 'Y';
    end
else
    xcolname = 'X';
    ycolname = 'Y';
end
