function help_matchexactly(this)
%HELP_MATCHEXACTLY   

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/12/04 23:24:13 $

disp(sprintf('%s\n%s\n%s\n%s', ...
    '    HD = DESIGN(..., ''MatchExactly'', MATCH) designs a Chebyshev type II', ...
    '    filter and matches the frequency and magnitude specification for the', ...
    '    band MATCH exactly.  The other band will exceed the specification.  MATCH', ...
    '    can be ''stopband'' or ''passband'' and is ''stopband'' by default.'));
disp(' ');

% [EOF]
