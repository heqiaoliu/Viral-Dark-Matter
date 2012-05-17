function optimfound = isoptiminstalled
%ISOPTIMINSTALLED  Check if Optimization Toolbox is installed.

% Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/04/28 03:21:58 $

%persistent isOptimInstalledFlag;

%if isempty(isOptimInstalledFlag)
optimfound = license('test', 'optimization_toolbox') && ~isempty(ver('optim'));
%end

%optimfound = isOptimInstalledFlag;