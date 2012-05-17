function varargout = junctdlg(varargin)
%JUNCTDLG  Creates and manages the junction dialog box

%   E.Mehran Mestchian
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.16.2.10 $  $Date: 2008/12/01 08:06:35 $

  
    objectId = varargin{2};
    dynamic_dialog_l(objectId);


function dynamic_dialog_l(junctId)
  h = idToHandle(sfroot, junctId);
  if ~isempty(h)
      d = DAStudio.Dialog(h, 'Junction', 'DLG_STANDALONE');
      sf('SetDynamicDialog', junctId, d);
  end	 
  

