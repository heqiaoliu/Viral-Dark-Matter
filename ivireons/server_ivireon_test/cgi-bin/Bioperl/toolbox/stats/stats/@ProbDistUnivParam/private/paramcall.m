function y=paramcall(fun,x,par)
%PARAMCALL Helper to call a function with parameters from a vector.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:40 $

% For 1- or 2-parameter calls, do this as efficiently as possible
if isscalar(par)
    y = fun(x,par);
elseif numel(par)==2
    y = fun(x,par(1),par(2));
else
    pc = num2cell(par);
    y = fun(x,pc{:});
end