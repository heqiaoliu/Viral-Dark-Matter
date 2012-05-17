function matchexactly = set_matchexactly(this, matchexactly)
%SET_MATCHEXACTLY   PreSet function for the 'matchexactly' property.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:42:36 $

error(generatemsgid('invalidSpecification'), ...
    'The MatchExactly property is only used for minimum-order designs.');

set(this, 'privMatchExactly', matchexactly);

% [EOF]
