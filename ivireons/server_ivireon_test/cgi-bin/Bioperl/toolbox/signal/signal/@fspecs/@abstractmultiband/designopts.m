function s = designopts(this, dmethod)
%DESIGNOPTS   Display the design options.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/30 17:35:12 $

hmethod = feval(getdesignobj(this, dmethod));

s = designopts(hmethod, this.NBands);

% [EOF]
