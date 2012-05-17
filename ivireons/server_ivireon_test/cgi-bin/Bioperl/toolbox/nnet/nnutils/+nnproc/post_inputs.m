function x=post_inputs(fcns,x)
%POSTPROCESSINPUTS Preprocess inputs.
%
%  POSTPROCESSINPUTS(fcns,x)

% Copyright 2007-2010 The MathWorks, Inc.

for i=1:fcns.numInputs
  x(i,:) = nnproc.reverse(fcns.inputs(i).process,x(i,:));
end
