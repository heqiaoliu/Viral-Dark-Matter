function clearDatatipSerialization(hThis)
% Removes serialized datatip information

%   Copyright 2007 The MathWorks, Inc.

hFig = hThis.Figure;
if isappdata(hFig,'DatatipInformation')
    rmappdata(hFig,'DatatipInformation');
end
if isappdata(hFig,'DatatipUpdateFcn');
    rmappdata(hFig,'DatatipUpdateFcn');
end