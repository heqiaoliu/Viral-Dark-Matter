function [e, x0] = pe(varargin)
%PE  Computes the prediction errors of an IDNLGREY model.
%
%        E  = PE(NLSYS, DATA);
%   [E, X0] = PE(NLSYS, DATA);
%   [E, X0] = PE(NLSYS, DATA, X0INIT);
%
%   The input-output arguments are as follows.
%
%   NLSYS holds the IDNLGREY model whose output is to be simulated.
%
%   DATA is the output-input data = [Y U]. Here U is the input data that
%   can be given either as an IDDATA object or as a matrix  U = [U1 U2 ...
%   Um], where the k:th column vector is input Uk.  Similarly, Y is either
%   an IDDATA object or a matrix of outputs (with as many columns as there
%   are outputs). For time-continuous IDNLGREY objects, DATA passed as a
%   matrix will lead to that the data sample interval, Ts, is set to one.
%
%   X0INIT specifies the initial state strategy to use:
%      'zero'       : use a zero initial state x(0) and keep all states
%                     fixed (nlsys.InitialStates.Fixed is thus ignored).
%      'fixed'      : nlsys.InitialStates determines the values of the
%                     initial states, but all states are kept fixed
%                     ((nlsys.InitialStates.Fixed is thus ignored).
%      'estimate'   : nlsys.InitialStates determines the values of the
%                     initial states, but all initial states are estimated
%                    (nlsys.InitialStates.Fixed is thus ignored).
%      'model'      : nlsys.InitialStates determines the values of the
%                     initial states, which initial states to estimate, as
%                     well as their maximum and minimum values. Default.
%      vector/matrix: a column vector of appropriate length is used as
%                     initial state. For multiple experiment DATA, x(0) may
%                     be a matrix whose columns give different initial
%                     states for each experiment. With this option, all
%                     initial states are kept fixed
%                     (nlsys.InitialStates.Fixed is thus ignored).
%      struct array : an Nx-by-1 structure array with fields:
%                     Name   : name of the state (a string).
%                     Unit   : unit of the state (a string).
%                     Value  : value of the states (a finite real 1-by-Ne
%                              vector, where Ne is the number of
%                              experiments.)
%                     Minimum: minimum values of the states (a real 1-by-Ne
%                              vector or a real scalar, in which case all
%                              initial states have the same minimum value).
%                     Maximum: maximum values of the states (a real 1-by-Ne
%                              vector or a real scalar, in which case all
%                              initial states have the same maximum value).
%                     Fixed  : a boolean 1-by-Ne vector, or a scalar
%                              boolean (applicable for all states)
%                              specifying whether the initial state is
%                              fixed or not.
%
%   E holds the prediction errors. If DATA is an IDDATA object, then E will
%   also be an IDDATA object, with E.OutputData containig the prediction
%   errors. Otherwise, E will be a matrix where the k:th output is found in
%   the k:th column of E. If DATA is a multiple experiment IDDATA object,
%   so will E be.
%
%   X0 contains the initial states used. In the single experiment case it
%   is a column vector of length Nx. For multi-experiment data, X0 is an
%   Nx-by-Ne matrix with the i:th column specifying the initial state of
%   experiment i.
%
%   If pe is called without an output argument, then the prediction
%   error(s) will be shown in a plot window.
%
%   See also IDNLGREY/IDNLGREY, IDNLGREY/PREDICT, IDNLGREY/SIM,
%   IDNLGREY/PEM, IDNLGREY/FINDSTATES, IDMODEL/PE.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $ $Date: 2008/10/02 18:53:55 $
%   Written by Peter Lindskog.

% Check that the function was called with at least two or three arguments.
nin = nargin;
error(nargchk(2, 3, nin, 'struct'));

% Retrieve the number of outputs.
no = nargout;
 
% First test consistency of the model
nlsys = [];
kd = 2;
for k = 1:2
    if isa(varargin{k}, 'idnlgrey')
        nlsys = varargin{k};
        if (k == 2)
            data = varargin{1};
            kd = 1;
        else
            data = varargin{2};
            kd = 2;
        end
    end
end
if isempty(nlsys)
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','pe','IDNLGREY')
end
[errmsg, data] = checkgetiddata(data, nlsys, 'pe');
error(errmsg)

varargin{kd} = data;

% Call utpe.
if (no == 0)
    utpe(varargin{:});
elseif (no == 1)
    e = utpe(varargin{:});
elseif (no == 2)
    [e, x0] = utpe(varargin{:});
end
