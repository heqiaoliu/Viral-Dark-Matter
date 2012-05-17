function Ts = getTs(this)
% GETTS Returns the sampling time of the state identified by THIS.
%
% TS is a double scalar (cell array of scalars if THIS is an object array).
% It is set to zero for continuous states.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2006/09/30 00:25:22 $

n = numel(this);

if n == 1
  Ts = [];
else
  Ts = cell(n,1);
  Ts(:) = {[]};
end

warning('modelpack:AbstractMethod', ...
        'Method needs to be implemented by subclasses.');
