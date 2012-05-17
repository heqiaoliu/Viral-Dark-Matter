function msg = surfchk(varargin)
%SURFCHK Check arguments to surf/mesh routines.
%   MSG = SURFCHK(Z), or
%   MSG = SURFCHK(Z,C), or
%   MSG = SURFCHK(X,Y,Z), or
%   MSG = SURFCHK(X,Y,Z,C) performs data validation on the inputs as if 
%   calling surf or mesh. An error message structure is returned if the
%   inputs are invalid.

%   Copyright 2006 The MathWorks, Inc.

error(nargchk(0,4,nargin,'struct'));

msg.message = 0;
msg.identifier = 0;
msg = msg(zeros(0,1));

if nargin == 0
    return;
end
if nargin == 2 || nargin == 4
    zmatrix = varargin{nargin-1};
    cmatrix = varargin{nargin};
else
    zmatrix = varargin{nargin};
    cmatrix = zmatrix;
end

if nargin == 1 || nargin == 2
    [zm,zn] = size(zmatrix);
    xmatrix = 1:zn;
    ymatrix = 1:zm;
else
    xmatrix = varargin{1};
    ymatrix = varargin{2};
end

if (~isreal(zmatrix) || ~isreal(cmatrix) || ...
    ~isreal(xmatrix) || ~isreal(ymatrix))
    msg = struct('message','X, Y, Z, and C cannot be complex.',...
                 'identifier',id('ComplexData'));
end

[xm,xn] = size(xmatrix);
[ym,yn] = size(ymatrix);
[zm,zn] = size(zmatrix);

if ((xm == 1 && xn ~= zn) || ...
    (xn == 1 && xm ~= zn) || ...
    (xm ~= 1 && xn ~= 1 && (xm ~= zm || xn ~= zn)) || ...
    (ym == 1 && yn ~= zm) || ...
    (yn == 1 && ym ~= zm) || ...
    (ym ~= 1 && yn ~= 1 && (ym ~= zm || yn ~= zn)))
    msg = struct('message','Data dimensions must agree.',...
                 'identifier',id('InvalidDataDimensions'));
end
if (zm == 1 || zn == 1)
    msg = struct('message','Z must be a matrix, not a scalar or vector.',...
                 'identifier',id('NonMatrixData'));
end

function out = id(str)
    out = ['MATLAB:surfchk:' str];