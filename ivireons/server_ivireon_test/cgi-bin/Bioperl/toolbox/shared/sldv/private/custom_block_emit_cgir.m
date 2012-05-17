function res = custom_block_emit_cgir(blockH)

%   Copyright 2006-2008 The MathWorks, Inc.

modelH = bdroot(blockH);

res = 'off';
blockH = get_param(blockH, 'parent');
blockType = get_param(blockH, 'masktype');

% We need to go to the grandparent if we are inside
% a Verification Subsystem
if strcmp(blockType,'VerificationSubsystem')
    blockH = get_param(blockH, 'parent');
    blockType = get_param(blockH, 'masktype');
end


if get_param(modelH, 'RTWExternMdlXlate') == 1
    
    cs = Sldv.Token.get.getTestComponent.activeSettings;
    customBlocks = { ...
        {'Design Verifier Test Condition', cs.TestConditions}, ...
        {'Design Verifier Assumption' , cs.ProofAssumptions}...
        {'Design Verifier Test Objective', cs.TestObjectives}...
        {'Design Verifier Proof Objective',cs.Assertions} ...
                   };
    for idx = 1:length(customBlocks)
        if isequal(blockType, customBlocks{idx}{1})
            enableOpt = customBlocks{idx}{2};
            if isequal(enableOpt, 'EnableAll') || ...
                    (isequal(get_param(blockH, 'enabled'), 'on') && ~isequal(enableOpt, 'DisableAll'))
                res = 'on';
            end
        end
    end
else
    try
        if rtwenvironmentmode(modelH) && ...
                strcmpi(get_param(modelH,'SimulationMode'), 'normal') && ...
                    strcmpi(get_param(blockH, 'enabled'), 'on')
          res = 'on';
        end
      %old mask, e.g. broken link, does not have this parameter
    catch MEx %#ok<NASGU>
    end
end
