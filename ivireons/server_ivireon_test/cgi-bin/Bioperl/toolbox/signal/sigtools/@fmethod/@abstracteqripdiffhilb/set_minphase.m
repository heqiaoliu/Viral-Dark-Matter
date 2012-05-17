function minphase = set_minphase(this, minphase)
%SET_MINPHASE   PreSet function for the 'minphase' property.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:43:00 $

erstr =['The ''MinimumPhase'' property is not used when designing ',algoname(this),...
    '.'];
error(generatemsgid('invalidSpecification'), erstr);

% [EOF]
