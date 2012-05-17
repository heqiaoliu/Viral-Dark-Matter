% Function: cleanRestore =====================================================
% Abstract:
%   Restore the changes we made by cleanChange.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/12/01 07:26:09 $

function cleanRestore(h, mode, varargin)

  for i = length(h.ChangeRec) : -1 :1    
    switch h.ChangeRec(i).Mode
     case 'parameter'
      paramName = h.ChangeRec(i).Key;
      dirtyBef = rtwprivate('dirty_restore',h.ModelHandle);
      oldVal   = h.ChangeRec(i).Setting;
      set_param(h.ModelHandle, paramName, oldVal);
      rtwprivate('dirty_restore',h.ModelHandle,dirtyBef);
     
     case 'configset'      
      dirtyBef = rtwprivate('dirty_restore',h.ModelHandle);
      newSet = h.ChangeRec(i).Key;
      oldSet = h.ChangeRec(i).Setting;
      setActiveConfigSet(h.ModelHandle, oldSet);
      detachConfigSet(h.ModelHandle, newSet);
      rtwprivate('dirty_restore',h.ModelHandle,dirtyBef);
      
      otherwise
        assertMsg = 'Internal error: unhandled clean restore in Real-Time Workshop build process';
        assert(false,assertMsg);
     end
  end
  
%endfunction cleanRestore
