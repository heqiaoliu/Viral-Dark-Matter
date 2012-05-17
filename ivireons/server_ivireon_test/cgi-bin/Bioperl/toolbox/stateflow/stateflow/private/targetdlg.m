function varargout = targetdlg(varargin)
%TARGETDLG  Creates and manages the main target dialog box
%           There are two other dialog boxes associated with
%           target manager. They are defined in dlg_coder_flags.m
%           and dlg_custom_target.m functions.

%   E.Mehran Mestchian
%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.68.2.11 $  $Date: 2008/12/01 08:08:20 $
  
    objectId = varargin{2};
    deleteOnCancel = 0;
    if(nargin > 2)
        deleteOnCancel = varargin{3};
    end
    dynamic_dialog_l(objectId, deleteOnCancel);

%--------------------------------------------------------------------------
%  ddg constructor
%--------------------------------------------------------------------------
function dynamic_dialog_l(targetId, deleteOnCancel)
  h = idToHandle(sfroot, targetId);
  if ~isempty(h)
      if(deleteOnCancel)
        h.Tag = ['_DDG_INTERMEDIATE_' sf_scalar2str(targetId)];
      end
	  d = DAStudio.Dialog(h, 'Target', 'DLG_STANDALONE');
      sf('SetDynamicDialog', targetId, d);
  end	
