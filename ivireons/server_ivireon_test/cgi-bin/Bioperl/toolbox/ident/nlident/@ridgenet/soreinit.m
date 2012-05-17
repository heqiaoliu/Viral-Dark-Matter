function nlobj = soreinit(nlobj, mag)
%SOREINIT single object nonlinearity estimator random reinitialization for RIDGENET
%
%  nlobj = soreinit(nlobj, mag)
%
%  This is method overloads idnlfun/soreinit.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:55:23 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soreinit')
end

th = sogetParameterVector(nlobj);
th = th .* (1+randn(size(th))*mag);
nlobj = sosetParameterVector(nlobj, th);

% Set weights to zero
nlobj.Parameters.LinearCoef = 0*nlobj.Parameters.LinearCoef;
nlobj.Parameters.OutputCoef = 0*nlobj.Parameters.OutputCoef;
nlobj.Parameters.OutputOffset = 0*nlobj.Parameters.OutputOffset;

% FILE END