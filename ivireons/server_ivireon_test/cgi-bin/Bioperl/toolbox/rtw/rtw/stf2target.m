function [hObj, stfInfo] = stf2target(varargin)
% STF2TARGET: Read from the system target file and generate appropriate target component

% Copyright 2002-2006 The MathWorks, Inc.
% $Revision: 1.1.6.11 $
  
  hObj = [];
  
  name = varargin{1};
  if nargin > 1
      settings = varargin{2};
  else
      settings = [];
  end
  
  if isempty(name)
      DAStudio.error('RTW:utility:emptyValue','system target file');
    return;
  end

  % check that rtw is installed
  if ~(exist('rtwprivate')==2 | exist('rtwprivate')==6)
      DAStudio.error('RTW:configSet:rtwComponentUnavailable');
    return;
  end

  [fullSTFName, fid, prevfpos] = rtwprivate('getstf', [], name);
  if (fid == -1)
      DAStudio.error('RTW:utility:fileIOError',name,'find');
    return;
  end
  
  stfInfo = systlc_browse(matlabroot, fullSTFName);
  
  % get the class name for target component from stf if any
  className = rtwprivate('tfile_classname', fid);
  
  closestf(fid, prevfpos);
  
  if ~isempty(className)
    try
        hObj = eval(className);
        % Pass switchTarget settings to object so that it can
        % performance special operation if needed, e.g. ert
        % auto configuration targets.
        if ~isempty(settings) && isprop(hObj, 'TargetID')
            set(hObj, 'TargetID', settings);
        end
    end
    
    % a target object must be of Simulink.TargetCC
    if ~isa(hObj, 'Simulink.TargetCC')
      hObj = [];
    end
    
    return;
  end
  
  % we cannot get a class name from stf; then generate a generic target object
  % and fill it with rtwoptions in stf
  hObj = Simulink.STFCustomTargetCC(name);
  
