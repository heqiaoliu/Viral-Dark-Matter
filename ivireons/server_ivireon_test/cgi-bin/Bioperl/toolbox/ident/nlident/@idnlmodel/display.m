function display(nlsys)
%DISPLAY  Display for IDNLMODEL objects.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2008/06/13 15:24:28 $

% Author(s): Qinghua Zhang

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Display IDNLMODEL information on the screen.
disp('IDNLMODEL object.');

% FILE END