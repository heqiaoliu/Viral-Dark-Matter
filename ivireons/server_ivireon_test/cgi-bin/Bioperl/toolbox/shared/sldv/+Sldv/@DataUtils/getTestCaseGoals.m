function [goals, depth] = getTestCaseGoals(sldvData, idx)    
    simData = Sldv.DataUtils.getSimData(sldvData,idx);
    nGoals =  length(simData.objectives);    
    goals = [];
    depth = [];

    if (nGoals > 0)
        goalId = simData.objectives(1).objectiveIdx;
        goals = sldvData.Objectives(goalId);
        depth = simData.objectives(1).atStep;
        if (nGoals > 1)
            for i=2:nGoals
                goalId = simData.objectives(i).objectiveIdx;
                goals(end+1) = sldvData.Objectives(goalId);
                depth(end+1) = [ simData.objectives(i).atStep ]; 
            end
        end
    end
end