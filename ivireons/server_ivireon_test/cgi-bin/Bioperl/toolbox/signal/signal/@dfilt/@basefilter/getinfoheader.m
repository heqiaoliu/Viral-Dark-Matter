function str = getinfoheader(h)
%GETINFOHEADER Return the header to the info

%   Author: J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2008/10/02 19:04:43 $

% Setup the title string
if isreal(h),
    typestr = 'real';
else
    typestr = 'complex';
end

if isfir(h),
    typestr = ['FIR Filter (', typestr,')'];
else
    typestr = ['IIR Filter (', typestr,')'];
end

str = ['Discrete-Time ',typestr];

% [EOF]
