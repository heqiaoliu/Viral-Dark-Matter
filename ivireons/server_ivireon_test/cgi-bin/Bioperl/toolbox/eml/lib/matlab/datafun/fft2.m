function f = fft2(x,mrows,ncols)
%Embedded MATLAB Library Function

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
if nargin == 1
    mrows = [];
    ncols = [];
elseif nargin == 2
    eml_assert(false, ...
        'If you specify MROWS, you also have to specify NCOLS.');
end
eml_prefer_const(mrows,ncols);
f = fft(fft(x,ncols,2),mrows,1);
