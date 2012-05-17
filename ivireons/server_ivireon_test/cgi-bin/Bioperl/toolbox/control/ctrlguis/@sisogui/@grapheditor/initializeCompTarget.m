function initializeCompTarget(this)
% Used to set the fields for EditedBlock and GainTargetBlock for the
% grapheditors.

% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2005/12/22 17:42:32 $

% TunedLoop for editor
L = this.LoopData.L(this.EditedLoop);

TunedFactors = L.TunedFactors;

DefaultTarget = sisodata.TunedZPK;
DefaultTarget.setZPKGain(1);

if isempty(TunedFactors)
    this.EditedBlock = DefaultTarget;
    this.GainTargetBlock = handle(zeros(0,1));
    this.GainTunable = false;
else
    % Find TunableList of Blocks
    ValidIdx = [];
    for ct = 1:length(TunedFactors)
        if TunedFactors(ct).isTunable
            if ~isfield(TunedFactors(ct).Constraints,'isStaticGainTunable') || ...
                    TunedFactors(ct).Constraints.isStaticGainTunable
                ValidIdx = [ValidIdx; ct];
            end
        end
    end
    if isempty(ValidIdx)
        % No Valid tuned factors for tunable gain
            this.EditedBlock = DefaultTarget;
            this.GainTargetBlock = handle(zeros(0,1));
            this.GainTunable = false;
    else
        % Keep current setting if valid else take first valid tunedfactor
        if isempty(this.GainTargetBlock)
            idx = [];
        else
            idx = find(this.GainTargetBlock==TunedFactors);
        end
        if isempty(idx)
            Target = TunedFactors(ValidIdx(1));
        else
            Target = TunedFactors(idx);
        end
        this.EditedBlock = Target;
        this.GainTargetBlock = Target;
        this.GainTunable = true;
    end

end





    
