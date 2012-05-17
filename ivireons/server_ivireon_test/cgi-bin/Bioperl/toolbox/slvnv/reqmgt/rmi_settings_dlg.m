function varargout = rmi_settings_dlg(varargin)    %#ok<STOUT>
% UI for controlling RMI settings

%  Copyright 1984-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2009/04/21 04:56:23 $
    persistent rmisettingdlg;
    if ~isempty(rmisettingdlg)
        try
           rmisettingdlg.show();
           return;
        catch Mex %#ok<NASGU>
        end
    end
    dlgSrc = ReqMgr.ReqmgtSettings;
    rmisettingdlg = DAStudio.Dialog(dlgSrc);

