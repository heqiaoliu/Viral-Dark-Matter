function theList = catList(hMessageLog)
%catList Return sorted list of all unique message category strings.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2006/10/18 03:22:51 $

% Get all Category strings
theList = iterator.visitImmediateChildren( ...
    cacheMergedLog(hMessageLog), ...
    @(hItem)hItem.Category );

% Unique-ify
theList = sort(unique(theList));

% [EOF]
