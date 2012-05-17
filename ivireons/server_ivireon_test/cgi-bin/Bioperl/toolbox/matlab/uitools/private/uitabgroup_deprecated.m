function h = uitabgroup_deprecated(varargin)
% This function is undocumented and will change in a future release

%   Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/12/14 14:57:02 $

%   Release: R14SP2. This feature will not work in MATLAB R13 and before.

% Warn that this old code path is no longer supported.
warn = warning('query', 'MATLAB:uitabgroup:DeprecatedFunction');
if isequal(warn.state, 'on')
    warning('MATLAB:uitabgroup:DeprecatedFunction', ...
    'This implementation of uitabgroup has been deprecated and is no longer supported.');
end

error(javachk('awt'));

h = uitools.uitabgroup(varargin{:});
h = double(h);
