function varargout = eventdlg(varargin)
%EVENTDLG  Creates and manages the event dialog box

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.23.2.10 $  $Date: 2008/12/01 08:05:47 $

    objectId = varargin{2};
    dynamic_dialog_l(objectId);

function dynamic_dialog_l(eventId)
    
  h = idToHandle(sfroot, eventId);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Event', 'DLG_STANDALONE');
      sf('SetDynamicDialog',eventId, d);
  end




