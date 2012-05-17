function [rtwRoot] = LocInternalMathWorksDevelopment(h, rtwroot, rtwVerbose)
% LOCINTERNALMATHWORKSDEVELOPMENT:
%	See if BuildTTLCDir was specified, if so update rtw root.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/06/20 08:08:51 $

BuildTTLCDir = [];
if ~isempty(BuildTTLCDir)
    savedir = pwd;
    ttlc = fullfile(matlabroot,'rtw','ttlc','scripts');
    if exist(ttlc,'dir')
      if rtwVerbose
        feval(h.DispHook{:},['make_rtw.m: BuildTTLCDir global variable defined, invoking ',...
                            'conversion script']);
      end
      chdir(ttlc);
      [s,r]=dos('run');
      if rtwVerbose
        if ~strcmp(r,'gmake: Nothing to be done for `once''.')
          feval(h.DispHook{:},r);
        end
      end
      chdir(savedir);
    end
end


% Use development sandbox, if TMW_V5_SANDBOX environmental variable is set,
% and the directories rtw, simulink/include and extern/include in the sandbox
% exist. Otherwise use matlabroot.
tmwV5Sandbox = getenv('TMW_V5_SANDBOX');
if (~isempty(tmwV5Sandbox) && ...
    (exist(fullfile(tmwV5Sandbox,'rtw'),'dir')==7) && ...
    (exist(fullfile(tmwV5Sandbox,'simulink', 'include'),'dir')==7) && ...
    (exist(fullfile(tmwV5Sandbox,'extern', 'include'),'dir')==7)) 
        rtwRoot = fullfile(tmwV5Sandbox,'rtw');
  if rtwVerbose
    feval(h.DispHook{:},['### Using rtwroot = ',rtwRoot]);
  end
else
    rtwRoot = rtwroot; % did this to quiet "unassigned output" warning by matlab
end

%endfunction LocInternalMathWorksDevelopment
