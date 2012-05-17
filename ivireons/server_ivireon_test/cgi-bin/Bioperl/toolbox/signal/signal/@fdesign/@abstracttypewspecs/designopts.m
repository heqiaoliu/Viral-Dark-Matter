function s = designopts(this, designmethod)
%DESIGNOPTS   Return information about the design options.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:11:07 $

error(nargchk(2,2,nargin,'struct'));
s = designopts(this.CurrentSpecs, lower(designmethod));

% [EOF]
