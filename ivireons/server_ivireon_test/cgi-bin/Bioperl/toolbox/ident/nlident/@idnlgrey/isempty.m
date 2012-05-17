function value = isempty(nlsys)
%ISEMPTY  Checks whether an IDNLGREY object is empty or not. It
%   returns 1 in such a case and 0 otherwise. An empty IDNLGREY
%   object is an object where FileName is the empty string.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2008/06/13 15:23:36 $
%   Written by Peter Lindskog.

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Return value.
value = isempty(nlsys.FileName);