function maxphase = set_maxphase(this, maxphase)
%SET_MAXPHASE   PreSet function for the 'maxphase' property.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:30 $

erstr =['The ''MaximumPhase'' property is not used when designing ',algoname(this),...
    '.'];
error(generatemsgid('invalidSpecification'), erstr);

% [EOF]