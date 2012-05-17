function strs = getlegendstrings(this, varargin)
%GETLEGENDSTRINGS Returns the legend strings.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:34 $
  
for k = 1:length(getline(this)),
    strs{k} = sprintf('Response %d\n',k);
end
  
% [EOF]
