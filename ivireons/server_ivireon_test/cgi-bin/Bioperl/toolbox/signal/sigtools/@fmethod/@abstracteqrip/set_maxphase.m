function maxphase = set_maxphase(this, maxphase)
%SET_MAXPHASE   PreSet function for the 'maxphase' property.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:04:27 $

if isfdtbxinstalled
    if isminorderodd(this),
        error(generatemsgid('invalidSpecification'), ...
            'Equiripple cannot design maximum-phase odd order filters.');
    end
    thisset_maxphase(this, maxphase);
else
    error(generatemsgid('invalidSpecification'), ...
        'The ''MaxPhase'' property is only settable when the Filter Design Toolbox is installed.');
end

% [EOF]
