function flag = fifeature(featureStr,varargin)
% FIFEATURE Undocumented internal TMW command for feature diagnostics

%   Copyright 2007 The MathWorks, Inc.
    
error(nargchk(1,2,nargin));
findpackage('embedded');

if nargin == 1
    flag = feature(featureStr);
    return;
else % nargin == 2
    val = varargin{1};
    flag = feature(featureStr,val);
end
