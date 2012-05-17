function help_matchexactly(this)
%HELP_MATCHEXACTLY   

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:37:08 $

disp(sprintf('%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''MatchExactly'', MATCH) designs an Elliptic filter', ...
    '    and matches the frequency and magnitude specification for the band', ...
    '    MATCH exactly.  The other band will exceed the specification.  MATCH', ...
    '    can be ''stopband'', ''passband'' or ''both'', and is ''both'' by default.'));
disp(' ');

% [EOF]
