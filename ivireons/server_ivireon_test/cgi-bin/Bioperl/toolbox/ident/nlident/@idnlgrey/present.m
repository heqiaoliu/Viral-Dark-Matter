function txt = present(nlsys)
%PRESENT  Displays detailed IDNLGREY information on the screen.
%
%   PRESENT(NLSYS) shows detailed information about the IDNLGREY object
%   NLSYS on the screen.
%
%   TXT = PRESENT(NLSYS) sends the result of present to the variable TXT,
%   i.e., not to the screen.
%    
%   See also IDNLGREY/DISPLAY.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2008/06/13 15:23:44 $
%   Written by Peter Lindskog.

% Check that the function is called with one argument.
error(nargchk(1, 1, nargin, 'struct'));

% Return the result to the screen or to a variable.
if (nargout > 0)
   txt = display(nlsys, 1);
else
   disp(display(nlsys, 1));
end