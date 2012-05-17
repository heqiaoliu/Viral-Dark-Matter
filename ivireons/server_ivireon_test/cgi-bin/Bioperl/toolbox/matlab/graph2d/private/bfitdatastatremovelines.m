function [xstatsH, ystatsH] = bfitdatastatremovelines(figHandle, currdata)
% BFITDATASTATREMOVELINES remove data stat lines for the current data.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2009/01/29 17:16:34 $

xstatsH = [];
ystatsH = [];

% for data now showing, remove plots and update appdata
xstatsshow = getappdata(double(currdata),'Data_Stats_X_Showing');

% xstatsshow empty means the datastat GUI was never used on this data
if ~isempty(xstatsshow)

    bfitlistenoff(figHandle)

    ystatsshow = getappdata(double(currdata),'Data_Stats_Y_Showing');
    xstatsH = getappdata(double(currdata),'Data_Stats_X_Handles');
    ystatsH = getappdata(double(currdata),'Data_Stats_Y_Handles');
    
    % Delete plots, update handles to Inf
    % Don't update "Showing" appdata since that tells us what to replot if needed
    %  (i.e. what checkboxes were checked)
    for i = find(xstatsshow)
        if ishghandle(xstatsH(i))
            delete(xstatsH(i));
        end
        xstatsH(i) = Inf;
    end
    for i = find(ystatsshow)
        if ishghandle(ystatsH(i))
            delete(ystatsH(i));
        end
        ystatsH(i) = Inf;
    end
    
    bfitlistenon(figHandle)
end


