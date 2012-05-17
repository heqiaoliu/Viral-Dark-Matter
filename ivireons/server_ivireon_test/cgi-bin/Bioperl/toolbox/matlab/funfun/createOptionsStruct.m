function [optionsStruct,optionsFcn]  = createOptionsStruct(solverName,useValues)
%CREATEOPTIONSSTRUCT Create options structure for different solvers
%   Create options structure for 'solverName'. If defaultSolver is [] then
%   'fmincon' is assumed to be the default solver. The optional third
%   argument is used to populate the options structure 'optionsStruct' with
%   the values from 'useValues'.
%
%   Private to OPTIMTOOL

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5.4.1 $  $Date: 2010/06/14 14:27:39 $

if nargin < 2
    useValues = [];
end
% Perform a license check for optional solvers
if ~isempty(ver('globaloptim')) && license('test','gads_toolbox')
    enableAllSolvers = true;
else
    enableAllSolvers = false;
end

% Call appropriate options setting function for each solver
switch solverName
    case {'fmincon','fminunc','lsqnonlin','lsqcurvefit','linprog', ...
            'quadprog','bintprog','fgoalattain','fminimax','fseminf', ...
            'fminsearch','fzero','fminbnd','fsolve','lsqlin','lsqnonneg'}
        optionsStruct = optimset(useValues);
        optionsFcn = 'optimset';
    case {'ga','gamultiobj'}
        optionsStruct = gaoptimset(useValues);
        optionsFcn = 'gaoptimset';
    case 'patternsearch'
        optionsStruct = psoptimset(useValues);
        optionsFcn = 'psoptimset';
    case 'simulannealbnd'
        optionsStruct = saoptimset(useValues);
        optionsFcn = 'saoptimset';
    case 'all'
        allfields = fieldnames(optimset);
        if enableAllSolvers
            data = load('OPTIMTOOL_OPTIONSFIELDS.mat','globaloptimOptions');
            allfields = [allfields; data.globaloptimOptions];
        end
        optionsStruct = createEmptyStruct(allfields);
        optionsFcn = '';
    otherwise
        error('optim:createOptionsStruct:UnrecognizedSolver','Unrecognized solver name.');
end

% Copy the values from the struct 'useValues' to 'optionsStruct'.
if ~isempty(useValues)
    copyfields = fieldnames(optionsStruct);
    Index = ismember(copyfields,fieldnames(useValues));
    for i = 1:length(Index)
        if Index(i)
            optionsStruct.(copyfields{i}) = useValues.(copyfields{i});
        end
    end
end

%-----------------------------------------------------
function optionsStruct = createEmptyStruct(allfields)

optionsStruct = struct();
for i = 1:length(allfields)
    if ~isfield(allfields{i},optionsStruct)
        optionsStruct.(allfields{i}) = [];
    end
end
