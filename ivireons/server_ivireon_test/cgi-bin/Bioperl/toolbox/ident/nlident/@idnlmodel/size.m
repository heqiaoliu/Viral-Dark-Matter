function [ny, nu] = size(nlsys, nr)
%SIZE  Input-output size of an IDNLMODEL object.
%
%   [Ny, Nu] = SIZE(NLSYS);
%
%   Ny is the number of output channels.
%   Nu is the number of input channels.
%
%   To access only one of the size use Ny = size(nlsys, 1), Nu =
%   size(nlsys, 2), or Ny = size(nlsys, 'Ny'), Nu = size(nlsys, 'Nu'), etc.
%
%   N = SIZE(nlsys) returns N = [Ny Nu].
%
%   When called with no output argument, the information is displayed
%   in the MATLAB command window.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.5 $ $Date: 2008/10/02 18:54:36 $

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
        ctrlMsgUtils.error('Ident:idnlmodel:sizeCheckInput')
    end
else
    nr = 0;
end

ny = length(nlsys.OutputName);
nu = length(nlsys.InputName);

if nout==0 && nr==0
    fprintf([upper(class(nlsys)), ' object with %d output(s) and %d input(s).\n'], ny, nu);
    clear ny nu
elseif (nout < 2)
    if (nr == 0)
        ny = [ny nu];
    elseif (nr == 2)
        ny = nu;
    end
end

% FILE END
