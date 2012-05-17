function varargout = autoscale(this,x)
%AUTOSCALE   

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:09:23 $

error(nargchk(2,2,nargin,'struct'));

% Verify that the structure support autoscale
verifyautoscalability(this);

if nargout>0,
    that = copy(this);
else
    that = this;
end

for k=1:length(that.Stage),
    that.Stage(k) = autoscale(that.Stage(k),x);
end

if nargout>0,
    varargout{1} = that;
end

% [EOF]
