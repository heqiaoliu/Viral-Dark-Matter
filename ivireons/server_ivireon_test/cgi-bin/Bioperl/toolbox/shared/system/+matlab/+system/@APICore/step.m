%step   Process inputs using the object algorithm
% 
%   Y = step(H,x) processes the input data, x, to produce the output, Y,
%   for System object, H.
% 
%   [Y1,...,YN] = step(H,x) produces N outputs.
% 
%   Every System object has a step method. The step method processes the
%   input data according to the object algorithm. The number of input and
%   output arguments depends on the algorithm, and may depend also on one
%   or more property settings. The step method for some objects accepts
%   fixed-point (fi) inputs.
% 
%   Calling step on an object puts that object into a locked state. When
%   locked, you cannot change non-tunable properties or any input
%   characteristics (size, data type and complexity) without reinitializing
%   (unlocking and relocking) the object.
% 
%   See the object class help for information specific to the step method
%   for that System object.

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:08:31 $

% [EOF]
