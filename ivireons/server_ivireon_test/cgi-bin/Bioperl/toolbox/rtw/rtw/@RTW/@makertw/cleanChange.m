% Function: cleanChange =====================================================
% Abstract:
%   Allow change of model setting without dirtying the model; all clean
%   change is automatically accompanied by a clean restoration before exiting.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/12/01 07:26:08 $

function cleanChange(h, mode, varargin)
switch mode
    case 'parameter'
        paramName = varargin{1};
        paramVal  = varargin{2};
        dirtyBef = rtwprivate('dirty_restore',h.ModelHandle);
        oldVal   = get_param(h.ModelHandle, paramName);
        h.ChangeRec(end+1).Mode = mode;
        h.ChangeRec(end).Key = paramName;
        h.ChangeRec(end).Setting = oldVal;
        set_param(h.ModelHandle, paramName, paramVal);
        rtwprivate('dirty_restore',h.ModelHandle,dirtyBef);
    case 'configset'
        currentSet = getActiveConfigSet(h.ModelHandle);
        newset = varargin{1};
        dirtyBef = rtwprivate('dirty_restore',h.ModelHandle);
        h.ChangeRec(end+1).Mode = mode;
        h.ChangeRec(end).Key = newset.Name;
        h.ChangeRec(end).Setting = currentSet.Name;
        attachConfigSet(h.ModelHandle, newset);
        setActiveConfigSet(h.ModelHandle, newset.Name);
        rtwprivate('dirty_restore',h.ModelHandle,dirtyBef);
  otherwise
        assertMsg = 'Internal error: unhandled clean change in Real-Time Workshop build process';
        assert(false,assertMsg);
end

%endfunction cleanChange
