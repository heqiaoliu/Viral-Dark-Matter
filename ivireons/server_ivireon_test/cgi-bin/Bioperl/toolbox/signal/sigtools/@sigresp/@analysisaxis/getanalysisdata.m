function [xdata, ydata] = getanalysisdata(hObj)
%GETANALYSISDATA Return the analysis data

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:23 $

hline = getline(hObj);

xdata = cell(length(hline), 1);
ydata = xdata;

for indx = 1:length(hline),
    xdata{indx} = get(hline(indx), 'XData')/getengunitsfactor(get(hline(indx), 'Parent'));
    ydata{indx} = get(hline(indx), 'YData');
end

% ------------------------------------------------------------
function m = getengunitsfactor(hax)

if isappdata(hax, 'EngUnitsFactor'),
    m = getappdata(hax, 'EngUnitsFactor');
else
    m = 1;
end
