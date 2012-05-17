function nlobj = soreinit(nlobj, mag)
%SOREINIT single object nonlinearity estimator random reinitialization for PWLINEAR
%
%  nlobj = soreinit(nlobj, mag)
%
%  This is method overloads idnlfun/soreinit.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:55:16 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soreinit')
end

th = sogetParameterVector(nlobj);
th = th .* (1+randn(size(th))*mag);
nlobj = sosetParameterVector(nlobj, th);

% Set weights to zero
nlobj.internalParameter.LinearCoef = 0*nlobj.internalParameter.LinearCoef;
nlobj.internalParameter.OutputCoef = 0*nlobj.internalParameter.OutputCoef;
nlobj.internalParameter.OutputOffset = 0*nlobj.internalParameter.OutputOffset;

nlobj.assignedBreakPoints = [];

% FILE END