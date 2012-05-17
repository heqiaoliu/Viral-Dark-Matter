function probStruct = createProblemStruct(solverName,defaultSolver,useValues)
%CREATEPROBLEMSTRUCT Create problem structure for different solvers
%   Create problem structure for 'solverName'. If defaultSolver is [] then 'fmincon' is assumed to
%   be the default solver. The optional third argument is used to populate the problem structure
%   'probStruct' with the values from 'useValues'.
%
%   Private to OPTIMTOOL

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/11/16 22:26:11 $

% Perform a license check for optional toolbox
if ~isempty(ver('globaloptim')) && license('test','gads_toolbox')
    enableAllSolvers = true;
else
    enableAllSolvers = false;
end

gadsSolvers = {'ga','patternsearch','gamultiobj','simulannealbnd'};

% If called with one argument and the argument is a string
if nargin == 1 && nargout <= 1 && isequal(solverName,'solvers')
    probStruct = struct( ...
        'fmincon',[],'fminunc',[],'lsqnonlin',[], ...
        'lsqcurvefit',[],'linprog',[],'quadprog',[], ...
        'bintprog',[],'fgoalattain',[],'fminimax',[], ...
        'fseminf',[], 'fminsearch',[],'fzero',[], ...
        'fminbnd',[], 'fsolve',[],'lsqlin',[],'lsqnonneg',[]);

    if enableAllSolvers % Add gads solvers
        probStruct.ga = [];
        probStruct.patternsearch = [];
        probStruct.simulannealbnd = [];
        probStruct.gamultiobj = [];
    end
    return;
end

if nargin < 3
    useValues = [];
end

if nargin < 2 || isempty(defaultSolver)
    defaultSolver = 'fmincon';
end

if ~enableAllSolvers && any(strcmpi(solverName,gadsSolvers))
    warning('MATLAB:createProblemStruct:invalidSolver','%s is not available; starting OPTIMTOOL with %s solver',upper(solverName),upper(defaultSolver));
    solverName = defaultSolver;
end
% The fields in the structure are in the same order as they are passed to
% the corresponding solver. 
switch solverName
    case 'fmincon' %1
        probStruct = struct('objective',[],'x0',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[],'nonlcon',[]);
    case 'fminunc' %2
        probStruct = struct('objective',[],'x0',[]);
    case 'lsqnonlin' %3
        probStruct = struct('objective',[],'x0',[], ...
            'lb',[],'ub',[]);
    case 'lsqcurvefit' %4
        probStruct = struct('objective',[],'x0',[], ...
             'xdata',[],'ydata',[],'lb',[],'ub',[]);
    case 'linprog' %5
        probStruct = struct('f',[],'Aineq',[],'bineq',[], ...
            'Aeq',[],'beq',[],'lb',[],'ub',[],'x0',[]);
    case 'quadprog' %6
        probStruct = struct('H',[],'f',[],'Aineq',[], ...
            'bineq',[],'Aeq',[],'beq',[],'lb',[],'ub',[],'x0',[]);
    case 'bintprog' %7
        probStruct = struct('f',[],'Aineq',[], ...
            'bineq',[],'Aeq',[],'beq',[],'x0',[]);
    case 'fgoalattain' %8
        probStruct = struct('objective',[],'x0',[], ...
            'goal',[],'weight',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[],'nonlcon',[]);
    case 'fminimax' %9
        probStruct = struct('objective',[],'x0',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[],'nonlcon',[]);
    case 'fseminf' %10
        probStruct = struct('objective',[],'x0',[], ...
            'ntheta',[],'seminfcon',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[]);
    case 'fminsearch' %11
        probStruct = struct('objective',[],'x0',[]);
    case 'fzero' %12
        probStruct = struct('objective',[],'x0',[]);
    case 'fminbnd' %13
        probStruct = struct('objective',[],'x1',[],'x2',[]); 
    case 'fsolve' %14
        probStruct = struct('objective',[],'x0',[]);
    case 'lsqlin' %15
        probStruct = struct('C',[],'d',[],'Aineq',[], ...  
            'bineq',[],'Aeq',[],'beq',[],'lb',[],'ub',[],'x0',[]);
    case 'lsqnonneg' %16
        probStruct = struct('C',[],'d',[]);
    case 'ga' %17
        probStruct = struct('fitnessfcn',[],'nvars',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[],'nonlcon',[],'rngstate',[]);
    case 'patternsearch' %18
        probStruct = struct('objective',[],'x0',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[],'nonlcon',[],'rngstate',[]);
    case 'simulannealbnd' %19
        probStruct = struct('objective',[],'x0',[], ...
            'lb',[],'ub',[],'rngstate',[]);
    case 'gamultiobj' %20
        probStruct = struct('fitnessfcn',[],'nvars',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'lb',[],'ub',[],'rngstate',[]);
    case 'all'
        probStruct = struct('objective',[],'x0',[],'f',[],'H',[], ...
            'lb',[],'ub',[],'nonlcon',[], 'x1',[],'x2',[], ...
            'Aineq',[],'bineq',[],'Aeq',[],'beq',[], ...
            'xdata',[],'ydata',[],'goal',[],'weight',[], ...
            'C',[],'d',[],'ntheta',[],'seminfcon',[]);
        if enableAllSolvers
            probStruct.nvars =[];
            probStruct.fitnessfcn = [];
            probStruct.rngstate = [];
        end
        solverName = defaultSolver;
   otherwise
        error('optim:createProblemStruct:UnrecognizedSolver','Unrecognized solver name.');
end
% Add the 'solver' field in the structure.
probStruct.solver = solverName;

% Copy the values from the struct 'useValues' to 'probStruct'.
if ~isempty(useValues)
    copyfields = fieldnames(probStruct);
    Index = ismember(copyfields,fieldnames(useValues));
    for i = 1:length(Index)
        if Index(i)
            probStruct.(copyfields{i}) = useValues.(copyfields{i});
        end
    end
end
