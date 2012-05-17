function nntbfound = isnntbinstalled
%ISNNTBINSTALLED  Check if Neural Network Toolbox is installed.

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2008/04/28 03:21:57 $

%persistent isNNTBInstalledFlag;
%mlock;

%if isempty(isNNTBInstalledFlag)
nntbfound = license('test', 'neural_network_toolbox') && ~isempty(ver('nnet'));
%end

%nntbfound = isNNTBInstalledFlag;
