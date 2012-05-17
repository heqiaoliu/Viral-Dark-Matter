function matlabVersion = check_matlab_version
%CHECK_MATLAB_VERSION This M-function is called when initializing Stateflow.
%                     It checks that the Stateflow image is running with a
%                     valid MATLAB version.

%   Copyright 1995-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/09/09 21:44:26 $

remain=['.',version];
matlabVersion = [];
for  i =1:3
    [token1,remain]=strtok(remain(2:end),'.');
    matlabVersion= [matlabVersion,token1];
end


matlabVersion =  eval(matlabVersion);
isOk = (matlabVersion>=530);
if ~isOk
  more('off');
  fileName = mfilename;
  [i,j,k]=regexp(fileName,['\',filesep,'(\w+)\',filesep,'private\',filesep,'.*$'], 'once');
  if (~isempty(i) && ~isempty(k))
      %extract the (\w+) component name match
      componentName = fileName(k{1}(1):k{1}(2));
      componentVersion = evalc(['type(''',componentName,'/Contents.m'')']);
      [s,e] = regexp(componentVersion,'Version[^\n]*', 'once');
      if (~isempty(s))
          componentVersion = componentVersion(s:e);
      else
          componentVersion = 'unknown (there is no version number in its Contents.m)';
      end
  else
      componentName = '<unknown component>';
      componentVersion = 'unknown';
  end

  componentName(1) = upper(componentName(1));
  error('slvnv:simcoverage:MatlabVersionCheck',...
    ['\nCan not initialize %s due to incompatible versions of %s and MATLAB images!\n'...
    ,'   %s image is %s\n'...
    ,'   MATLAB image is Version %s\n'...
    ,'Please check your installation of MATLAB, SIMULINK, and %s.']...
    ,componentName, componentName, componentName, componentVersion, version, componentName);


end


