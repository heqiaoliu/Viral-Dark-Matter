function b = blanks(n)
%BLANKS String of blanks.
%   BLANKS(n) is a string of n blanks.
%   Use with DISP, e.g.  DISP(['xxx' BLANKS(20) 'yyy']).
%   DISP(BLANKS(n)') moves the cursor down n lines.
%
%   See also CLC, HOME, FORMAT.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.10.4.1 $  $Date: 2009/04/21 03:26:40 $

space = ' ';
b = space(ones(1,n));
