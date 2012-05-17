function bfitdatastatcleanup(fighandle)
% BFITDATASTATCLEANUP clean up anything needed for the Data Statistics GUI.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.8.4.4 $  $Date: 2009/01/29 17:16:33 $

if ishghandle(fighandle) % if figure still open or in the process of being deleted
    if ~isempty(bfitFindProp(fighandle,'Data_Stats_GUI_Object'))
        set(handle(fighandle), 'Data_Stats_GUI_Object',[]);
    end
    if ~isempty(bfitFindProp(fighandle,'Basic_Fit_GUI_Object'))
        bfitguiobj = get(handle(fighandle), 'Basic_Fit_GUI_Object');
    else
        bfitguiobj = [];
    end
    if isempty(bfitguiobj) % both gui's gone, reset double buffer state
        doublebufferstate = getappdata(fighandle,'bfit_doublebuffer');
        if ~isempty(doublebufferstate)
            set(fighandle,'doublebuffer', doublebufferstate);
            rmappdata(fighandle,'bfit_doublebuffer'); % remove it so we set doublebuffer on if reopen gui
        end
    end
end
% reset normalized?

