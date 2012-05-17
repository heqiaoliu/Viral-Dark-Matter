function [evalresultsx,evalresultsy, coeffresidstrings] = bfitnormalizedata(checkon,datahandle)
% BFITNORMALIZEDATA normalize the data

%   Copyright 1984-2006 The MathWorks, Inc. 
%   $Revision: 1.11.4.3 $  $Date: 2006/05/27 18:07:59 $

if checkon
    xdata = get(datahandle,'xdata');
    normalized = [mean(xdata(~isnan(xdata))); std(xdata(~isnan(xdata)))];
    setappdata(double(datahandle),'Basic_Fit_Normalizers',normalized);
else
    normalized = [];
    setappdata(double(datahandle),'Basic_Fit_Normalizers',normalized);
end

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
if ~isequal(guistate.normalize,checkon)
    % reset scaling warning flag so it will occur
     setappdata(double(datahandle),'Basic_Fit_Scaling_Warn',[]);
end
guistate.normalize = checkon;
setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

axesH = get(datahandle,'parent');
figHandle = get(axesH, 'parent');
[fithandles, residhandles, residinfo] = bfitremovelines(figHandle,datahandle,0);
% Update appdata for line handles so legend can redraw
setappdata(double(datahandle), 'Basic_Fit_Handles',fithandles);
setappdata(double(datahandle), 'Basic_Fit_Resid_Handles',residhandles);
setappdata(double(datahandle), 'Basic_Fit_Resid_Info',residinfo);

% Get newdata info
[ignore,ignore,ignore,ignore,evalresultsx,evalresultsy,ignore,coeffresidstrings] = ...
    bfitselectnew(figHandle, datahandle);

