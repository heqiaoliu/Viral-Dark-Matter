function b = initializeCompTarget(this)
% Used to determine if gain is tunable for the TunedZPK

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 17:39:46 $

b = false;
if this.isTunable
    if ~isfield(this.Constraints,'isStaticGainTunable') || ...
            this.Constraints.isStaticGainTunable
        b = true;
    end
end




    
