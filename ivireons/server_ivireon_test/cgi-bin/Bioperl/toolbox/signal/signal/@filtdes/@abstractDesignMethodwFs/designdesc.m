function str = designdesc(d)
%DESIGNDESC Returns the comment that precedes the design call.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2008/05/31 23:26:42 $

str = sprintf('%% Calculate the coefficients using the %s function.', ...
    upper(designfunction(d)));

% [EOF]
