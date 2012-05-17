function bfitcheckplotresiduals(checkon,datahandle,plottype,subploton,showresidon)
% BFITCHECKPLOTRESIDUALS plots residuals.
%     BFITCHECKPLOTRESIDUALS(CHECKON,DATAHANDLE,PLOTTTYPE,SUBPLOTON,SHOWRESIDON)
%     plots residuals if CHECKON for data DATAHANDLE using plot 
%     type PLOTTYPE on a subplot if SUBPLOTON, otherwise on a 
%     separate figure. The norm of norm of the residuals is 
%     also shown as text on the plot if SHOWRESIDON.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.15.4.7 $  $Date: 2009/01/29 17:16:23 $

axesH = get(datahandle,'parent'); % need this in case subplots in figure
figH = get(axesH,'parent');
fitsshowing = find(getappdata(double(datahandle),'Basic_Fit_Showing'));
infarray = repmat(inf,1,12);

bfitlistenoff(figH)

residinfo = getappdata(double(datahandle),'Basic_Fit_Resid_Info');
oldResidfigure = bfitfindresidfigure(figH, residinfo.figuretag);
if ~isempty(oldResidfigure) && ~isequal(figH,oldResidfigure) && ishghandle(oldResidfigure)
    bfitlistenoff(oldResidfigure)
end

newResidfigure = oldResidfigure;
if checkon
    [residinfo, residhandles] = bfitplotresids(figH,axesH,datahandle,fitsshowing,subploton,plottype);
    newResidfigure = bfitfindresidfigure(figH, residinfo.figuretag);
 else
    % remove axes
    if ishghandle(residinfo.axes)
        delete(residinfo.axes) % this should delete the txt and all resid plots....
        if figH == oldResidfigure %resids in subplot
            axesHposition = getappdata(double(datahandle),'Basic_Fit_Fits_Axes_Position');
            set(axesH,'position',axesHposition);
        end
    end
    residinfo.axes = []; 
    residhandles = infarray;
end

setappdata(double(datahandle),'Basic_Fit_Resid_Info',residinfo); 
setappdata(double(datahandle),'Basic_Fit_Resid_Handles', residhandles); % array of handles of residual plots

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
guistate.plotresids = checkon;
guistate.plottype = plottype;
guistate.subplot = ~subploton;
setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

if showresidon
    bfitcheckshownormresiduals(checkon,datahandle)
    residtxtH = getappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle'); % norm of residuals txt
else
    residtxtH = [];
end

% update appdata (whether on/off)

setappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle', residtxtH); % norm of residuals txt

bfitlistenon(figH)

if ~isequal(figH,newResidfigure)
    bfitlistenon(newResidfigure)
end
