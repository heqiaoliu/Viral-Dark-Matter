function x=pre_inputs(fcns,x)
%PREPROCESSINPUTS Preprocess inputs.
%
%  PREPROCESSINPUTS(fcns,x)

% Copyright 2007-2010 The MathWorks, Inc.

for i=1:fcns.numInputs
  x(i,:) = nnproc.forward(fcns.inputs(i).process,x(i,:));
end
