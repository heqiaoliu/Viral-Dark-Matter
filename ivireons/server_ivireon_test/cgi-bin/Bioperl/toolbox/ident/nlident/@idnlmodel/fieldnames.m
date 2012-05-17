function fnames = fieldnames(nlsys)
% FIELDNAMES  Returns the field names of IDNLMODEL model.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2008/06/13 15:24:29 $

%   Written by Peter Lindskog.

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Return field names.
fnames = pnames(nlsys);

% FILE END