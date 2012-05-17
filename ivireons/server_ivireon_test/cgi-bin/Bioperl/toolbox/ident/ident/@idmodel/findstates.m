function x0 = findstates(model, data, init)
%FINDSTATES Estimate initial states of the model for a given data set.
%
% If MODEL is not in state-space form, the states should be interpreted
% as those corresponding to IDSS(MODEL).
%
% Calling Syntax:
%   X0 = FINDSTATES(MODEL, DATA) estimates the states of MODEL that provide
%   the best (least-squares) fit to output signal in DATA. X0 is the value
%   of states at time DATA.TStart.
%   Inputs:
%       MODEL: an IDMODEL object, such as IDPOLY or IDSS.
%       DATA:  an IDDATA object with matching input/output dimensions. For
%       multi-experiment data, X0 is a matrix, where column k corresponds
%       to experiment k of DATA.
%   Output:
%       X0: estimated initial state vector.
%
%   X0 = FINDSTATES(MODEL, DATA, INIT) allows specification of how the
%   initial states should be estimated using an INIT flag. Allowable values
%   of INIT are:
%       'e': Estimate initial state so that the norm of prediction error is
%            minimized. This is the default.
%       'd': Same as 'e', but if MODEL.InputDelay is non-zero, these delays
%            are first converted to explicit model delays, and the extra
%            initial states (those corresponding to the delays) are also
%            estimated and returned.This option is not available for
%            continuous-time models. 
%
% See also PE, COMPARE, IDMODEL/SIM, IDNLARX/FINDSTATES, IDNLHW/FINDSTATES.

% Copyright 2007-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/04/21 03:22:22 $

if nargin<3
    init = 'e';
end

LocalValidateINIT(model,init);

if isa(data,'idfrd')
    data = iddata(data);
end

if strcmpi(init,'d')
    model = inpd2nk(model);
end

data = idutils.utValidateData(data,model,'both',true,'findstates');

try
    [err, x0] = pe(model,data,'init','e');
catch E
    throw(E)
end

%--------------------------------------------------------------------------
function LocalValidateINIT(model,init)
% validate INIT value

if ~any(strcmpi(init,{'e','d'}))
    ctrlMsgUtils.error('Ident:analysis:findstatesInvalidINIT')
end

if (model.Ts==0) && strcmpi(init,'d')
    ctrlMsgUtils.error('Ident:analysis:findstatesCTInitOption')
end


    