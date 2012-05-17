function [ny, nu, nx, np, npo, npf, ne, errmsg] = size(nlsys, no)
%SIZE  Size function for IDNLGREY objects.
%
%   N = SIZE(NLSYS);
%   N = SIZE(NLSYS, NO);
%   [NY, NU, NX, NP] = SIZE(NLSYS);
%   [NY, NU, NX, NP, NPO] = SIZE(NLSYS);
%   [NY, NU, NX, NP, NPO, NPF] = SIZE(NLSYS);
%   [NY, NU, NX, NP, NPO, NPF, NE] = SIZE(NLSYS);
%   [NY, NU, NX, NP, NPO, NPF, NE, ERRMSG] = SIZE(NLSYS);
%
%   NY is the number of outputs of NLSYS.
%   NU is the number of inputs of NLSYS.
%   NX is the number of states of NLSYS.
%   NP is the number of parameters of NLSYS.
%   NPO is the number of parameter variables of NLSYS.
%   NPF is the number of fixed parameters of NLSYS.
%   NE is the number of experiments associated with the states of NLSYS.
%
%   NY, NU, NX, NP, NPO, NPF and NE are set to NaN if nlsys is
%   inconsistent. More information about the inconsistency is then
%   delivered in ERRMSG. The function only throws an error if it is called
%   with incorrect input-output arguments.
%
%   To access only one of the size outputs, use NY = SIZE(NLSYS, 1),
%   NU = SIZE(NLSYS, 2), NX = SIZE(NLSYS, 3), NP = SIZE(NLSYS, 4),
%   NPO = size(NLSYS, 5), NPF = (NLSYS, 6), NE = (NLSYS, 7) or
%   NY = SIZE(NLSYS, 'Ny'), NU = SIZE(NLSYS, 'Nu'), etc.
%
%   When called with only one output argument, N = SIZE(NLSYS) returns
%   the vector N = [NY NU NP NX NPO NPF NE].
%
%   When called with no output argument, the information is displayed
%   in the MATLAB command window.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.8 $ $Date: 2009/03/09 19:14:56 $
%   Written by Peter Lindskog.

% Check that the function is called with one or two input arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));
nout = nargout;

% Initialize txtflag.
txtflag = false;
if ((nout == 0) && (nin == 1))
    txtflag = true;
elseif (nin == 2)
    if (ndims(no) ~= 2)
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySize1')
    elseif isnumeric(no)
        if all(size(no) == [1 1])
            if (no == 0)
                txtflag = true;
            end
        else
            ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySize1')
        end
    elseif ~ischar(no)
        ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySize1')
    end
end

% Get the data.
errmsg = '';
if isempty(nlsys)
    if txtflag
        txt = 'Empty nonlinear state space model.';
        if (nout == 0)
            disp(txt);
        else
            ny = txt;
        end
    elseif ((nout == 1) && (nin < 2))
        ny = zeros(1, 7);
    else
        ny = 0;
        nu = 0;
        nx = 0;
        np = 0;
        npo = 0;
        npf = 0;
        ne = 0;
    end
    return;
end

% Deliver the desired output.
if ((nin == 1) || (txtflag))
    if ((nout == 1) && ~(txtflag))
        ny = [nlsys.Order.ny nlsys.Order.nu nlsys.Order.nx           ...
            getnp({nlsys.Parameters.Value}) length(nlsys.Parameters) ...
            getnpf({nlsys.Parameters.Fixed})                         ...
            getne({nlsys.InitialStates.Value})];
    elseif ((nout > 1) && ~(txtflag))
        ny = nlsys.Order.ny;
        nu = nlsys.Order.nu;
        nx = nlsys.Order.nx;
        np = getnp({nlsys.Parameters.Value});
        npo = length(nlsys.Parameters);
        npf = getnpf({nlsys.Parameters.Fixed});
        ne = getne({nlsys.InitialStates.Value});
    elseif txtflag
        np = getnp({nlsys.Parameters.Value});
        npf = getnpf({nlsys.Parameters.Fixed});
        if (nlsys.Order.ny > 1)
            yess = 's';
        else
            yess = [];
        end
        if (nlsys.Order.nu > 1)
            uess = 's';
        else
            uess = [];
        end
        if (nlsys.Order.nx > 1)
            xess = 's';
        else
            xess = [];
        end
        if (np > 1)
            pess = 's';
        else
            pess = [];
        end
        txt = sprintf(['Nonlinear state space model with %d output'    ...
            yess ', %d input' uess ', ', '%d state' xess    ...
            ', and %d parameter' pess ' (%d free).'],       ...
            nlsys.Order.ny, nlsys.Order.nu, nlsys.Order.nx, ...
            np, np-npf);
        if (nout == 0)
            clear ny;
            disp(txt);
        else
            ny = txt;
        end
    end
elseif (nin == 2)
    if (nout > 1)
        ctrlMsgUtils.error('Ident:utility:sizeWithMultiOutputs2')
    end
    switch lower(no)
        case {1, 'ny'}
            ny = nlsys.Order.ny;
        case {2, 'nu'}
            ny = nlsys.Order.nu;
        case {3, 'nx'}
            ny = nlsys.Order.nx;
        case {4, 'np'}
            ny = getnp({nlsys.Parameters.Value});
        case {5, 'npo'}
            ny = length(nlsys.Parameters);
        case {6, 'npf'}
            ny = getnpf({nlsys.Parameters.Fixed});
        case {7, 'ne'}
            ny = getne({nlsys.InitialStates.Value});
        otherwise
            ctrlMsgUtils.error('Ident:idnlmodel:idnlgreySize1')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function np = getnp(value)
% Get the total number of parameters of the model.
np = 0;
for i = 1:length(value)
    np = np + length(value{i}(:));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function npf = getnpf(value)
% Get the total number of fixed parameters of the model.
npf = 0;
for i = 1:length(value)
    npf = npf + length(find(value{i}(:) == true));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ne = getne(value)
% Get the total number of fixed parameters of the model.
ne = 0;
if ~isempty(value)
    ne = length(value{1});
end
