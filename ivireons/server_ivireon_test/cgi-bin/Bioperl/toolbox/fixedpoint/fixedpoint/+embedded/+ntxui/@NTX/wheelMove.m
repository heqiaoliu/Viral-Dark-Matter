function wheelMove(ntx,ev)
% Mouse scroll wheel modified/moved

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:22:23 $

% Allow DialogPanel to handle wheel events in its area
handled = mouseScrollWheel(ntx.dp,ev);
if handled
    return % EARLY EXIT
end

% There are currently no other wheel event actions defined in NTX
