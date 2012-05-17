function y = utSimNonlin(sys, X)
%Simulate the neuralnet or customnet nonlinearity (single object)
% Used by sfunnonlin S function block

% Copyright 2007-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/10/02 18:52:11 $

if ~isa(sys,'neuralnet') && ~isa(sys,'customnet') %currently, only these two require simulation in MATLAB
    ctrlMsgUtils.error('Ident:simulink:utSimNonlin1')
end

X = X(:).';
y = soevaluate(sys,X);
