function OK = pIsAcceptableQdelError(pbs, out) %#ok<INUSL>
; %#ok Undocumented

% Check whether a given error message from qdel simply indicates that the
% job isn't there.

% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2007/11/09 19:50:59 $

OK = false;

% Job unknown (probably already finished)
OK = OK || ~isempty( regexp( out, 'qdel: Unknown Job Id', 'once' ) );

% Job already finishing
OK = OK || ~isempty( regexp( out, 'qdel: Request invalid for state of job', 'once' ) );
