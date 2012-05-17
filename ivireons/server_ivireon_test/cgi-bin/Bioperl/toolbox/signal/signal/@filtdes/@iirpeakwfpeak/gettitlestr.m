function str = gettitlestr(d)
%GETTITLESTR Returns the title for GENMCODE

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:09:32 $

% This should be private

str = sprintf('%% IIR Peaking filter designed using the %s function.', ...
    upper(designfunction(d)));
    
% [EOF]
