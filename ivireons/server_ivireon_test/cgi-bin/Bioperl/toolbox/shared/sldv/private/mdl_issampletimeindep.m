function sampTimeInd = mdl_issampletimeindep(modelH)

%   Copyright 2008-2009 The MathWorks, Inc.

    solverType = get_param(modelH, 'SolverType');    
    sampTimeInd = false;
    if strcmp(solverType, 'Fixed-step')
        sampTimeInd = strcmp(get_param(modelH,'SampleTimeConstraint'),...
                             'STIndependent');
    end      
end