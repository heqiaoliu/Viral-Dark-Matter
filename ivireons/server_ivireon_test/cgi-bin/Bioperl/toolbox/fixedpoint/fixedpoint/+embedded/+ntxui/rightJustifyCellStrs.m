function y = rightJustifyCellStrs(x)
% Combine all strings in cell-vector x into a single, carriage-return
% delimited string that contains right-justified strings from x.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:20:36 $

% Return length of longest string
% Useful right-justified formatting
N = numel(x);
xlen = cellfun(@numel,x);
Nmax = max(xlen);
cr = sprintf('\n');
y = blanks(N*(Nmax+1)); % N strings, each with max str length and CR
j=1;
for i=1:N
    ni = xlen(i);
    offset = Nmax-ni;
    y(j+offset:j+offset+ni-1) = x{i};
    j=j+Nmax+1;
    if i<N
        y(j-1) = cr;
    end
end
