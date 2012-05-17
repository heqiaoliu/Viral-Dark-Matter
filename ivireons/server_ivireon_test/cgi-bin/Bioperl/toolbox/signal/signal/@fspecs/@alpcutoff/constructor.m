function constructor(h,N,Wc)
%CONSTRUCTOR   

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:11:27 $

if nargin > 1,
    h.FilterOrder = N;
end

if nargin > 2,
    h.Wcutoff = Wc;
end

% [EOF]
