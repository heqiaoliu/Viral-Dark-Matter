function matlabVersion = check_matlab_version
%CHECK_MATLAB_VERSION This M-function is called when initializing Stateflow.
%                     It checks that the Stateflow image is running with a
%                     valid matlab version.

%   Copyright 1995-2008 The MathWorks, Inc.
%   $Revision: 1.18.2.4 $  $Date: 2009/07/29 03:18:34 $


remain=['.',version];
matlabVersion = [];
for  i =1:3
    [token1,remain]=strtok(remain(2:end),'.');
    matlabVersion= [matlabVersion,token1];
end

matlabVersion =  eval(matlabVersion);


