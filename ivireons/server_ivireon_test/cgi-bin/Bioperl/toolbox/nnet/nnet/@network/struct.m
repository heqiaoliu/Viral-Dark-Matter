function s = struct(net)
%STRUCT Convert a neural network object to a structure.
%
%  <a href="matlab:doc struct">struct</a>(NET) take a network and returns its object information
%  as a structure.

% Copyright 2009-2010 The MathWorks, Inc.

s = nnconvert.obj2struct(net);
