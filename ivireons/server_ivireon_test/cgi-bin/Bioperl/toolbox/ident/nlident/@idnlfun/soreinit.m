function nlobj = soreinit(nlobj, mag)
%SOREINIT single object nonlinearity estimator random reinitialization
%
%  nlobj = soreinit(nlobj, mag)
%
%  This is the generic method which is overloaded by some subclasses of
%  idnlfun.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:41 $

% Author(s): Qinghua Zhang

if numel(nlobj)>1
    ctrlMsgUtils.error('Ident:idnlfun:scalarNLRequired','soreinit')
end

th = sogetParameterVector(nlobj);
th = th .* (1+randn(size(th))*mag);
nlobj = sosetParameterVector(nlobj, th);

% FILE END