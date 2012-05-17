function fnames = fieldnames(sys)
% FIELDNAMES  Returns the field names of IDMODEL model.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/04/28 03:19:26 $


% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Return field names.
fnames = pnames(sys);
