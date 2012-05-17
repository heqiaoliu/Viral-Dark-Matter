function bfitcheckshownormresiduals(checkon,datahandle)
% BFITCHECKSHOWNORMRESIDUALS Show norm of residuals as text on figure.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.14.4.6 $  $Date: 2009/01/29 17:16:26 $

residinfo = getappdata(double(datahandle),'Basic_Fit_Resid_Info');
axesH = get(datahandle,'parent'); % need this in case subplots in figure
figH = get(axesH,'parent');
residfigure = bfitfindresidfigure(figH,residinfo.figuretag);

fitsshowing = find(getappdata(double(datahandle),'Basic_Fit_Showing'));

residnrmTxtH = getappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle');

if checkon
    residnrmTxtH = bfitcreatenormresidtxt(residinfo.axes,residfigure,datahandle,fitsshowing);
    if ~isempty(residnrmTxtH)
        appdata.type = 'residnrmtxt';
        appdata.index = [];
        setappdata(residnrmTxtH,'bfit',appdata);
        setappdata(residnrmTxtH, 'Basic_Fit_Copy_Flag', 1);
    end
else % delete
    if ~isempty(residinfo.axes) % The axes could have been deleted already
        delete(residnrmTxtH)
    end
    residnrmTxtH = [];
end
setappdata(double(datahandle),'Basic_Fit_ResidTxt_Handle', residnrmTxtH); % norm of residuals txt

guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
guistate.showresid = checkon;
setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);

