function varargout = statedlg(varargin)
%EVENTDLG  Creates and manages the state dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.26.4.12 $  $Date: 2008/12/01 08:08:09 $


    objectId = varargin{2};
    dynamic_dialog_l(objectId);

function dynamic_dialog_l(stateId)
  
  h = idToHandle(sfroot, stateId);
  if ~isempty(h)
      if isa(h, 'Stateflow.SLFunction')
          open_system(h.getDialogProxy.Handle, 'Parameter');
      else
          d = DAStudio.Dialog(h, 'State', 'DLG_STANDALONE');
          sf('SetDynamicDialog',stateId, d);
      end
  end	 


