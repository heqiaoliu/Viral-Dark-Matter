function [ny, nu] = size(nlobj, nr)
%SIZE  Input-output size of nonlinearity estimators.
%
%   [Ny, Nu] = SIZE(NL)
%
%   NL: an nonlinearity estimator object or an array of such objects.
%   Ny: the number of output channels, that is the number of nonlinearity
%      estimator objects contained in NL.
%   Nu: the number of inputs.
%
%   Nu is an 1-by-Ny vector, containing the number of inputs for the Ny
%   output channels.
%
%   If any nonlinearity estimator object contained in NL has undertermined
%   number of inputs, the corresponding value in Nu is NaN.
%
%   To access only one of the size use Ny = size(nlsys, 1), Nu =
%   size(nlsys, 2), or Ny = size(nlsys, 'Ny'), Nu = size(nlsys, 'Nu'), etc.
%
%   N = SIZE(NL) returns the 1-by-(Ny+1) vector [Ny Nu].
%
%   When SIZE(NL) is called with no output argument, the information is
%   displayed in the MATLAB command window.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:39 $

% Author(s): Qinghua Zhang

% Check that the function is called with 1 or 2 input arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Check that the function is called with 0, 1 or 2 output arguments.
nout = nargout;
error(nargoutchk(0, 2, nout, 'struct'));

if ((nin == 2) && (nout == 2))
    ctrlMsgUtils.error('Ident:utility:sizeWithMultiOutputs')
end

if (nin < 2)
    nr = [];
end

if ~isempty(nr)
    errflag = 1;
    if ischar(nr)
        nr = strmatch(lower(nr), {'ny', 'nu'});
        if (length(nr) == 1)
            errflag = 0;
        end
    elseif isreal(nr)
        if ((nr == 1) || (nr == 2))
            errflag = 0;
        end
    end
    if errflag
        ctrlMsgUtils.error('Ident:idnlfun:sizeCheck1')
    end
else
    nr = 0;
end


ny = numel(nlobj);
%nu = [];
if ny==1
    nu = regdimension(nlobj);
else
    nu = zeros(1,ny);
    idnlfunVecFlag = isa(nlobj,'idnlfunVector');
    for ky=1:numel(nlobj)
        if idnlfunVecFlag
            nu(ky) = regdimension(nlobj.ObjVector{ky});
        else
            nu(ky) = regdimension(nlobj(ky));
        end
    end
end
nu(nu<0) = NaN;

if (nout<=1) && (nr==2)
    ny = nu;
elseif (nout==1) && (nr==0)
    ny = [ny, nu];
end

if nout==0 && nr==0
    if ny==1
        fprintf([upper(class(nlobj)), ' object with 1 output and %d input(s).\n'], nu);
    else
        dispstr = sprintf([upper(class(nlobj)), ' object with %d outputs and ['], ny);
        dispstr = [dispstr, sprintf('%d ', nu)];
        dispstr = sprintf([dispstr(1:end-1), '] input(s).']);
        disp(dispstr)
    end
    clear ny nu
end

% FILE END