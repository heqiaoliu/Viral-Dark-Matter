function [e, x0] = pe(varargin)
%IDMODEL/PE  Computes the prediction errors of an IDMODEL.
%
%        E  = PE(MOD, DATA);
%   [E, X0] = PE(MOD, DATA);
%   [E, X0] = PE(MOD, DATA, INIT);
%
%   The input-output arguments are as follows.
%   E : The prediction errors. An IDDATA object, with E.OutputData
%       containing the errors.
%   DATA : The output-input data as an IDDATA object. (See help IDDATA)
%   MOD: The model as any IDMODEL object, IDPOLY, IDSS, IDARX, IDGREY
%          or IDPROC.
%   INIT: The initialization strategy: one of
% 	    'e': Estimate initial state so that the norm of E is minimized
%	         This state is returned as X0. For multiexperiment data, X0 is
%            a matrix, where column k correspond to experiment k.
%       'd': Same as 'e', but if Model.InputDelay is non-zero, these delays
%            are first converted to explicit model delays, and the extra initial
%            states are also estimated and used for the calculation of E.
%            (To have these returned in X0, first apply inpd2nk to (discrete
%            time version of) the model.)
%	    'z': Take the initial state as zero.
%	    'm': Use the model's internal initial state.
%       X0: a column vector of appropriate length to be used as
%           initial value. For multiexperiment DATA X0 may be a matrix
%           with columns giving the initial states for each experiment.
%   If INIT is not specified, MOD.InitialState is used, so that
%      'Estimate', 'Backcast' and 'Auto' gives an estimated initial state,
%      while 'Zero' gives 'z' and 'Fixed' gives 'm'.
%
%   If pe is called without an output argument, then the prediction
%   error(s) will be shown in a plot window.
%
%   There are slight variations in values of INIT for different model
%   types. See INLARX/PE, IDNLGREY/PE and IDNLHW/PE.
%
%   See also PREDICT, COMPARE, RESID, FINDSTATES.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:19:45 $
%   Written by Lennart Ljung.

no = nargout;
error(nargchk(2, 4, nargin, 'struct'));

% Call utpe.
try
    if (no == 0)
        utpe(varargin{:});
    elseif (no == 1)
        e = utpe(varargin{:});
    elseif (no == 2)
        [e, x0] = utpe(varargin{:});
    end
catch E
    throw(E)
end