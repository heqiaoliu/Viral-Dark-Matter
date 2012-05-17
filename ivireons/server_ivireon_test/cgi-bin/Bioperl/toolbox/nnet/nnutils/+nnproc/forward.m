function x = forward(pfcns,x)
%PROCESSFORWARD Applies processing functions and settings to a matrix.
%
% Syntax
%   
%   y = nnproc.forward(processFcns,processSettings,x)
%
% Description
%
%   PROCESSFORWARD(processFcns,processSettings,x) takes:
%     processFcns - row cell array of N processing function names
%     processSettings - row cell array of N associated configurations
%     x - cell array of matrices to be processed
%   and returns the processed matrix (or matrices) m2.

% Copyright 2007-2010 The MathWorks, Inc.

pfcns = nnproc.active_fcns(pfcns);
[rows,cols] = size(x);
functionOrder = 1:length(pfcns);
for i=1:rows
  for j=1:cols
    xij = x{i,j};
    for k = functionOrder
      xij = pfcns(k).apply(xij,pfcns(k).settings);
    end
    x{i,j} = xij;
  end
end

