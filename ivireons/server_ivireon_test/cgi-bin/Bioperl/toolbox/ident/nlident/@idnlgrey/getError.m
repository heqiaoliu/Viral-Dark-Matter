function [e, y, err] = getError(nlsys, data, x0, par)
%GETERROR  Returns the residuals between the experimental and the predicted
%   data. Low-level IDNLGREY method.
%
%   [E, ERR] = GETERROR(NLSYS, DATA, X0, PAR);
%   [E, Y, ERR] = GETERROR(NLSYS, DATA, X0, PAR);
%
%   Inputs:
%      NLSYS: IDNLGREY object to be simulated.
%      DATA : IDDATA object.
%      X0   : initial state matrix (Nx-by-Ne).
%      PAR  : parameter value cell array.
%
%   Outputs:
%      E  : prediction error result; a cell array with Ne elements. Each
%           cell contains a double matrix of size n(k)-by-ny, which is the
%           difference between the measured output(s) and the predicted
%           output(s) of the model.
%      Y  : simulation result; a cell array with Ne elements. Each cell
%           contains a double matrix of size n(k)-by-ny, which is the
%           result of simulation using the k'th experiment of the data
%           DATA.
%      ERR: flag indicating whether simulation was successful (false) or
%           not (true); boolean array of length Ne.
%
%   If getError is called with two output arguments, then only E and ERR
%   are returned.
%
%   See also IDNLGREY/PE.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.1 $ $Date: 2006/11/17 13:37:18 $

% Get number of experiments of data.
ne = size(data, 'ne');

% If necessary, get InitialStates values from NLSYS.
nin = nargin;
nout = nargout;
if ((nin < 3) || isempty(x0))
    X = nlsys.InitialStates;
    x0 = cat(1, X.Value);
end
if ((ne > 1) && (size(x0, 2) == 1))
    x0 = repmat(x0, 1, ne);
end

% If necessary, get Parameters values from NLSYS.
if ((nin < 4) || isempty(par))
    P = nlsys.Parameters;
    par = {P.Value};
end

% Perform simulation.
[y, err] = getSimResult(nlsys, data, x0, par);
ymeas = pvget(data, 'OutputData');

% Return a cell array of error vectors, one for each data experiment.
% Each cell element is a n(k)-by-ny matrix.
e = cell(1, ne);
for k = 1:ne
    e{k} = ymeas{k}-y{k};
end

% If the number of outputs are 2, then return E and ERR only.
if (nout == 2)
    y = err;
end

% Note: shape of e must be preserved because data for different output
% channels might be needed separately, such as when calculating LimitError,
% calling this function from, PE etc. In case of Jacobian, the data for all
% outputs, for one experiment and one parameter, is folded into a tall
% vector.