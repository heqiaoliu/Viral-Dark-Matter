function str = designdesc(d)
%DESIGNDESC   Returns the design comment.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2009/12/28 04:35:40 $

str = sprintf('%% Construct an FDESIGN object and call its %s method.', ...
    upper(designfunction(d)));

% [EOF]
