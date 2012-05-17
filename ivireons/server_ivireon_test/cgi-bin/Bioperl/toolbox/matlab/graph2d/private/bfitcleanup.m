function bfitcleanup(fighandle, numberpanes)
% BFITCLEANUP clean up anything needed for the Basic Fitting GUI.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.10.4.3 $  $Date: 2009/01/29 17:16:30 $

% Now that Basic Fitting invokes the callback for this function 
% asynchronously, it is possible for this function to be called after a 
% Basic Fitting figure has been deleted. Check for Basic_Fit_Current_Data 
% appdata to make sure we are cleaning up a Basic Fitting figure.
if ishghandle(fighandle) && isappdata(fighandle, 'Basic_Fit_Current_Data')
    datahandle = getappdata(fighandle,'Basic_Fit_Current_Data');
    if ~isempty(datahandle)
        guistate = getappdata(double(datahandle),'Basic_Fit_Gui_State');
        guistate.panes = numberpanes;
        setappdata(double(datahandle),'Basic_Fit_Gui_State', guistate);
    end
    set(handle(fighandle), 'Basic_Fit_GUI_Object', []);
	if ~isempty(bfitFindProp(fighandle,'Data_Stats_GUI_Object'))
		bfitguiobj = get(handle(fighandle), 'Data_Stats_GUI_Object');
	else
		bfitguiobj = [];
	end
    if isempty(bfitguiobj) % both gui's gone, reset double buffer state
        set(fighandle,'doublebuffer',getappdata(fighandle,'bfit_doublebuffer'));    
        rmappdata(fighandle,'bfit_doublebuffer'); % remove it so we set doublebuffer on if reopen gui
    end
% reset normalized?
end

