function slprofile_unhilite_system(varargin)
%SLPROFILE_UNHILITE_SYSTEM Unhilite all blocks in a system
%   SLPROFILE_UNHILITE_SYSTEM('path/block') will unhilite all
%   blocks in the model.  It will unhilite all blocks, even 
%   if the block given in the argument is not hilited.  
%   It will not unhilite any blocks that are in windows that
%   are not open though. 

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.4.2.5 $  $Date: 2008/02/20 01:30:37 $
  
  
  %-------------%
  % Check usage %
  %-------------%
  if nargin == 1 && ischar(varargin{1})
    sysStr     = varargin{1};
  else
    DAStudio.error('Simulink:tools:slprof_unhilite_usage');
  end

  %----------------------------------------%
  % Locate block owner (if not model only) %
  %----------------------------------------%

  slashes = findstr('/',sysStr);
  
  % Doubled slashes indicate slashes in the block name. These are
  % not path separators and we must remove them.

  slashesLen = length(slashes);
  rmSlashes  = [];
  
  i = 1;
  while i < slashesLen
    if slashes(i) == slashes(i+1) - 1
      rmSlashes(end+1:end+2) = [i,i+1];
      i = i + 2;
    else
      i = i + 1;
    end
  end

  slashes(rmSlashes) = [];

  if ~isempty(slashes)
    model     = sysStr(1:slashes(1)-1);
  else
    model     = sysStr;
  end
  
  %-------------------------%
  % show the located system %
  %-------------------------%  
  if ~bdIsLoaded(model)
    load_system(model);
  end

  %--------------------------------%
  % Unhilite the specified block   %
  %--------------------------------%

  objs  = find_system(model, 'LookUnderMasks','all','FollowLinks','on',...
                      'FindAll', 'on','HiliteAncestors','default');
  for i=1:length(objs)
    if strcmp(get_param(get_param(objs(i),'Parent'),'Open'),'on')
      hilite_system(objs(i), 'none');
    end
  end    
