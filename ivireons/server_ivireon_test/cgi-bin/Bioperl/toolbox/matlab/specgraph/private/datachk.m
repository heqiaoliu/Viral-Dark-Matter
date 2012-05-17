function y = datachk(x)
%DATACHK Convert input to full, double data for plotting
%  Y=DATACHK(X) creates a full, double array from X and returns it in Y.
%  If X is a cell array each element is converted elementwise.

%   Copyright 1984-2005 The MathWorks, Inc. 

if iscell(x)
    y = cellfun(@datachk,x,'UniformOutput',false);
else
    y = full(double(x));
end
