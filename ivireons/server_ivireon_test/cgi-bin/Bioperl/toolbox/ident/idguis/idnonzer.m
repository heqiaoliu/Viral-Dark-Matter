function zerst = idnonzer(inp)
%IDNONZER Returns subset of input vector that are valid handles.
%   INP:   A vector of candidate handles
%   ZERST: Vector of valid handles

%   L. Ljung 4-4-94
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/07/03 20:43:09 $

zerst = [];
try
    inp = inp(:);
    inp = inp(inp>0);
    zerst = inp(ishandle(inp));
end