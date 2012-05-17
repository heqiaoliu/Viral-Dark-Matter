function f = ifft2(x,varargin)
%Embedded MATLAB Library Function

%   Limitations:
%     The 'symmetric' option is not supported.

%   Copyright 1984-2008 The MathWorks, Inc.
%#eml

eml_assert(nargin > 0, 'Not enough input arguments.');
eml_assert(nargin < 5, 'Too many input arguments.');
eml_prefer_const(varargin);
if nargin > 1 && ischar(varargin{end})
    eml_assert(strcmp(varargin{end},'nonsymmetric'), ...
        'Only the ''nonsymmetric'' option is supported in Embedded MATLAB.');
    f = ifft2(x,varargin{1:end-1});
    return
end
if nargin == 1
    mrows = [];
    ncols = [];
elseif nargin == 2
    eml_assert(false, ...
        'If you specify MROWS, you also have to specify NCOLS.');
else
    mrows = varargin{1};
    ncols = varargin{2};
end
f = ifft(ifft(x,ncols,2),mrows,1);
