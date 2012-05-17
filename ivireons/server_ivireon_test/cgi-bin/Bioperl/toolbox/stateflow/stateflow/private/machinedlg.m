function varargout = machinedlg(varargin)
%EVENTDLG  Creates and manages the machine dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.18.2.10 $  $Date: 2008/12/01 08:06:40 $


    objectId = varargin{2};
    dynamic_dialog_l(objectId);


function dynamic_dialog_l(machineid)
  
  h = idToHandle(sfroot, machineid);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Machine', 'DLG_STANDALONE');
      sf('SetDynamicDialog',machineid, d);
  end

