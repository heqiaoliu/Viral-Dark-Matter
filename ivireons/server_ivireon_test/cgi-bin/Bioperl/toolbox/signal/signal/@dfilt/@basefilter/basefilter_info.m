function [p, v] = basefilter_info(this)
%BASEFILTER_THISINFO   Get the information for this filter.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.3 $  $Date: 2008/10/02 19:04:42 $

% Get the stability
if isstable(this)
    stablestr = 'Yes';
else
    stablestr = 'No';
end

islinphaseflag = islinphase(this);
if islinphaseflag,
    linphase = 'Yes'; 
    if isfir(this) && isreal(this),
        t = firtype(this);
        if iscell(t),
            t = [t{:}];
        end
        linphase = [linphase, ' (Type ',int2str(t), ')'];
    end
else
    linphase = 'No';
end

[coeffp, coeffv] = coefficient_info(this);

p = {'Filter Structure', coeffp{:}, 'Stable', 'Linear Phase'};
v = {get(this, 'FilterStructure'), coeffv{:}, stablestr, linphase};

% [EOF]