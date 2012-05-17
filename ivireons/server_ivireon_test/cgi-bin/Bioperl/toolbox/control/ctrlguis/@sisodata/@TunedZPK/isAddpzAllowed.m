function b = isAddpzAllowed(this,GroupType,PZType)
% Checks if adding the pole/zero violates any constraints.
%

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2007/08/20 16:25:24 $

Constraints = this.Constraints;

if isempty(Constraints)
    b = true;
else
    [z,p] = getPZ(this);
    CurrentZ = length(z);
    CurrentP = length(p);
    MaxZ = Constraints.MaxZeros;
    MaxP = Constraints.MaxPoles;

    switch GroupType
        case 'Real'
            if strcmpi(PZType, 'Zero')
                b = MaxZ > CurrentZ;
                % check for proper flag
                if b && (isfield(Constraints,'allowImproper') && ~Constraints.allowImproper)
                    b = CurrentZ < CurrentP;
                end
            else
                b = MaxP > CurrentP;
            end

        case 'Complex'
            if strcmpi(PZType, 'Zero')
                b = (MaxZ-1) > CurrentZ;
                % check for proper flag
                if b && (isfield(Constraints,'allowImproper') && ~Constraints.allowImproper)
                    b = CurrentZ+1 < (CurrentP);
                end
            else
                b = (MaxP-1) > CurrentP;
            end

        case {'LeadLag', 'Lead', 'Lag'}
            if (MaxZ > CurrentZ) && (MaxP > CurrentP)
                b = true;
            else
                b = false;
            end

        case 'Notch'
            if ((MaxZ-1) > CurrentZ) && ((MaxP-1) > CurrentP)
                b = true;
            else
                b = false;
            end

    end
end


