function h = double(this)
%DOUBLE   Cast filter to a double-precision arithmetic version.
%   See help in dfilt/double.

%   Author(s): R. Losada
%   Copyright 2003-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:33:11 $

h = feval(str2func(class(this)));

% Get coefficient names
cn = coefficientnames(h);

for n = 1:length(cn),
    set(h,cn{n},get(this,cn{n}));
end

setfdesign(h,getfdesign(this)); % Carry over fdesign obj
setfmethod(h,getfmethod(this));

% [EOF]
