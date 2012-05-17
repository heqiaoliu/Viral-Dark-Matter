function compileForCoverage(modelH)

modelName = get_param(modelH, 'name');
cmdCompile = sprintf('%s([],[],[],''compileForCoverage'')', modelName); %#ok<NASGU>
cmdTerm = sprintf('%s([],[],[],''term'')', modelName); %#ok<NASGU>
try
    evalc('evalin(''base'',cmdCompile)');
catch Mex
    evalc('evalin(''base'',term)');
    rethrow Mex
end    
evalc('evalin(''base'',cmdTerm)');
