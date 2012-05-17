function varargout = datadlg(varargin)
%DATADLG  Creates and manages the data dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.46.4.11 $  $Date: 2008/12/01 08:05:29 $

    objectId = varargin{2};
    dynamic_dialog_l(objectId);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dynamic_dialog_l(dataId)

  h = idToHandle(sfroot, dataId);
  
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Data', 'DLG_STANDALONE');
      sf('SetDynamicDialog',dataId, d);
  end	 
