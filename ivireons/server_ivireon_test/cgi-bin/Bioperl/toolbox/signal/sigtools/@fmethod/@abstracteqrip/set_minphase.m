function minphase = set_minphase(this, minphase)
%SET_MINPHASE   PreSet function for the 'minphase' property.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2005/06/30 17:37:18 $

if isfdtbxinstalled
    if isminorderodd(this),
        error(generatemsgid('invalidSpecification'), ...
            'Equiripple cannot design minimum-phase odd order filters.');
    end
    set(this, 'privMinPhase', minphase);
else
    error(generatemsgid('invalidSpecification'), ...
        'The ''MinPhase'' property is only settable when the Filter Design Toolbox is installed.');
end

% [EOF]
