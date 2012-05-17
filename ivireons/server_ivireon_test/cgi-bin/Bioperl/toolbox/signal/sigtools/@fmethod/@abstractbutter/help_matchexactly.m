function help_matchexactly(this)
%HELP_MATCHEXACTLY   Display help for MatchExactly.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:42:01 $

disp(sprintf('%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''MatchExactly'', MATCH) designs a Butterworth filter', ...
    '    and matches the frequency and magnitude specification for the band', ...
    '    MATCH exactly.  The other band will exceed the specification.  MATCH', ...
    '    can be ''stopband'' or ''passband'' and is ''stopband'' by default.'));
disp(' ');

% [EOF]
