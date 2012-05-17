function [validvalue, errmsg, errid, validfield] = optimoptioncheckfield(field,value)
%OPTIMOPTIONCHECKFIELD Check validity of structure field contents.
%
% This is a helper function for OPTIMSET and OPTIMGET.

%   [VALIDVALUE, ERRMSG, ERRID, VALIDFIELD] = OPTIMOPTIONCHECKFIELD('field',V)
%   checks the contents of the specified value V to be valid for the field 'field'.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $  $Date: 2009/10/24 19:17:46 $

% empty matrix is always valid
if isempty(value)
    validvalue = true;
    errmsg = '';
    errid = '';
    validfield = true;
    return
end

% Some fields are checked in optimset/checkfield: Display, MaxFunEvals, MaxIter,
% OutputFcn, TolFun, TolX. Some are checked in both (e.g., MaxFunEvals).
validfield = true;
switch field
    case {'TolCon','TolPCG','ActiveConstrTol',...
            'DiffMaxChange','DiffMinChange','TolXInteger','MaxTime', ...
            'NodeDisplayInterval','RelLineSrchBnd','TolProjCGAbs', ...
            'TolProjCG','TolGradCon','TolConSQP'}
        % non-negative real scalar
        [validvalue, errmsg, errid] = nonNegReal(field,value);
    case {'TolRLPFun'}
        % real scalar in the range [1.0e-9, 1.0e-5]
        [validvalue, errmsg, errid] = boundedReal(field,value,[1e-9, 1e-5]);
    case {'ObjectiveLimit'}
        [validvalue, errmsg, errid] = realLessThanPlusInf(field,value);
    case {'MaxFunEvals'}
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'100*numberofvariables'}); % fmincon
    case {'MaxIter'}
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'100000*numberofvariables'}); % bintprog
    case {'LargeScale','DerivativeCheck','Diagnostics','GradConstr','GradObj',...
            'Jacobian','LevenbergMarquardt', 'Simplex', ...
            'NoStopIfFlatInfeas','PhaseOneTotalScaling'}
        % off, on
        [validvalue, errmsg, errid] = stringsType(field,value,{'on';'off'});
    case {'PrecondBandWidth','MinAbsMax','GoalsExactAchieve','RelLineSrchBndDuration'}
        % integer including inf
        [validvalue, errmsg, errid] = nonNegInteger(field,value);
    case {'MaxPCGIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,{'max(1,floor(numberofvariables/2))','numberofvariables'});
    case {'MaxProjCGIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'2*(numberofvariables-numberofequalities)');        
    case {'MaxSQPIter'}
        % integer including inf or default
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'10*max(numberofvariables,numberofinequalities+numberofbounds)');
    case {'JacobPattern'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'sparse(ones(jrows,jcols))');
    case {'HessPattern'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'sparse(ones(numberofvariables))');
    case {'TypicalX'}
        % matrix or default string
        [validvalue, errmsg, errid] = matrixType(field,value,'ones(numberofvariables,1)');
    case {'HessMult','JacobMult','Preconditioner','HessFcn'}
        % function
        [validvalue, errmsg, errid] = functionType(field,value);
    case {'HessUpdate'}
        % dfp, bfgs, steepdesc
        [validvalue, errmsg, errid] = stringsType(field,value,{'dfp' ; 'steepdesc';'bfgs'});
    case {'NonlEqnAlgorithm'}
        % dogleg, lm, gn
        [validvalue, errmsg, errid] = stringsType(field,value,{'dogleg' ; 'lm'; 'gn'});
    case {'LineSearchType'}
        % cubicpoly, quadcubic
        [validvalue, errmsg, errid] = stringsType(field,value,{'cubicpoly' ; 'quadcubic' });
    case {'MeritFunction'}
        % singleobj, multiobj
        [validvalue, errmsg, errid] = stringsType(field,value,{'singleobj'; 'multiobj' });
    case {'InitialHessType'}
        % identity, scaled-identity, user-supplied
        [validvalue, errmsg, errid] = stringsType(field,value,{'identity' ; 'scaled-identity'; 'user-supplied'});
    case {'UseParallel'}
        % 'always' or 'never'
        [validvalue, errmsg, errid] = stringsType(field,value,{'always' ; 'never'});
    case {'Algorithm'}
        % active-set, trust-region-reflective, interior-point,
        % levenberg-marquardt, trust-region-dogleg, lm-line-search(undocumented)
        if ~iscell(value)
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'active-set' ; 'trust-region-reflective'; 'interior-point'; ...
                'levenberg-marquardt'; 'trust-region-dogleg'; 'lm-line-search'; 'sqp'});
        else
            % Must be {'levenberg-marquardt',positive integer}
            [validvalue, errmsg, errid] = stringPosRealCellType(field,value,{'levenberg-marquardt'});
        end
    case {'AlwaysHonorConstraints'}
        % none, bounds
        [validvalue, errmsg, errid] = ...
            stringsType(field,value,{'none' ; 'bounds'});
    case {'ScaleProblem'}
        % none, obj-and-constr, jacobian
        [validvalue, errmsg, errid] = ...
            stringsType(field,value,{'none' ; 'obj-and-constr' ; 'jacobian'});
    case {'FinDiffType'}
        % forward, central
        [validvalue, errmsg, errid] = stringsType(field,value,{'forward' ; 'central'});
    case {'Hessian'}
        if ~iscell(value)
            % If character string, has to be user-supplied, bfgs, lbfgs,
            % fin-diff-grads, on, off
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'user-supplied' ; 'bfgs'; 'lbfgs'; 'fin-diff-grads'; ...
                'on' ; 'off'});
        else
            % If cell-array, has to be {'lbfgs',positive integer}
            [validvalue, errmsg, errid] = stringPosIntegerCellType(field,value,'lbfgs');
        end
    case {'SubproblemAlgorithm'}
        if ~iscell(value)
            % If character string, has to be 'ldl-factorization', 'cg',
            % 'lu-eig-factorization' or 'cg-lu'
            [validvalue, errmsg, errid] = ...
                stringsType(field,value,{'ldl-factorization' ; 'cg' ; 'lu-eig-factorization' ; 'cg-lu'});
        else
                % Either {'ldl-factorization',positive integer} or {'cg',positive integer}
                [validvalue, errmsg, errid] = stringPosRealCellType(field,value,{'ldl-factorization' ; 'cg'});
        end
    case {'InitialHessMatrix'}
        % strictly positive matrix
        [validvalue, errmsg, errid] = posMatrixType(field,value);
    case {'MaxRLPIter'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'100*numberofvariables');
    case {'MaxNodes'}
        % integer including inf or default string
        [validvalue, errmsg, errid] = nonNegInteger(field,value,'1000*numberofvariables');
    case {'BranchStrategy'}
        % mininfeas, maxinfeas
        [validvalue, errmsg, errid] = stringsType(field,value,{'mininfeas' ; 'maxinfeas'});
    case  {'NodeSearchStrategy'}
        % df, bn
        [validvalue, errmsg, errid] = stringsType(field,value,{'df' ; 'bn'});
    case {'InitTrustRegionRadius'}
        % sqrt(numberOfVariables), positive real
        [validvalue, errmsg, errid] = posReal(field,value,'sqrt(numberofvariables)');
    case {'InitBarrierParam'}
        % positive real
        [validvalue, errmsg, errid] = posReal(field,value);
    otherwise
        validfield = false;
        validvalue = false;
        % No need to set an error. If the field isn't valid for MATLAB or Optim,
        % will have already errored in optimset. If field is valid for MATLAB,
        % then the error will be an invalid value for MATLAB.
        errid = '';
        errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegReal(field,value,string)
% Any nonnegative real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) ;
if nargin > 2
    valid = valid || isequal(value,string);
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:NonNegReal:negativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:NonNegReal:negativeNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative scalar.',field);
    end
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = nonNegInteger(field,value,strings)
% Any nonnegative real integer scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value >= 0) && value == floor(value) ;
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative integer (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real non-negative integer.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = matrixType(field,value,strings)
% Any matrix
valid =  isa(value,'double');
if nargin > 2
    valid = valid || any(strcmp(value,strings));
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:notANonNegInteger';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a matrix (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:posMatrixType:notAPosMatrix';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a matrix.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = posMatrixType(field,value)
% Any positive scalar or all positive vector
valid =  isa(value,'double') && all(value > 0) && isvector(value);
if ~valid
    errid = 'optimlib:optimoptioncheckfield:posMatrixType:notAPosMatrix';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: \n must be a positive scalar or a vector with positive entries.',field);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = functionType(field,value)
% Any function handle or string (we do not test if the string is a function name)
valid =  ischar(value) || isa(value, 'function_handle');
if ~valid
    errid = 'optimlib:optimoptioncheckfield:functionType:notAFunction';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a function handle.',field);
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringsType(field,value,strings)
% One of the strings in cell array strings
valid =  ischar(value) && any(strcmp(value,strings));

if ~valid
    % Format strings for error message
    allstrings = formatCellArrayOfStrings(strings);

    errid = 'optimlib:optimoptioncheckfield:stringsType:notAStringsType';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s:\n must be %s.',field, allstrings);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = boundedReal(field,value,bounds)
% Scalar in the bounds
valid =  isa(value,'double') && isscalar(value) && ...
    (value >= bounds(1)) && (value <= bounds(2));
if ~valid
    errid = 'optimlib:optimoptioncheckfield:boundedReal:notAboundedReal';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: \n must be a scalar in the range [%6.3g, %6.3g].', ...
        field, bounds(1), bounds(2));
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringPosIntegerCellType(field,value,strings)
% A cell array that is either {strings,positive integer} or {strings}
valid = numel(value) == 1 && strcmp(value{1},'lbfgs') || numel(value) == 2 && ...
    strcmp(value{1},'lbfgs') && isreal(value{2}) && isscalar(value{2}) && value{2} > 0 && value{2} == floor(value{2});

if ~valid  
    errid = 'optimlib:optimoptioncheckfield:notAStringPosIntegerCellType';
    errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a cell-array of the form {''%s'', positive integer}.',field, strings);
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = stringPosRealCellType(field,value,strings)
% A cell array that is either {strings,positive real} or {strings}
valid = (numel(value) >= 1) && any(strcmpi(value{1},strings));
if (numel(value) == 2) 
   valid = valid && isreal(value{2}) && (value{2} >= 0);
end

if ~valid  
    % Format strings for error message
    allstrings = formatCellArrayOfStrings(strings);

    errid = 'optimlib:optimoptioncheckfield:notAStringPosRealCellType';
    errmsg = ...
       sprintf(['Invalid value for OPTIONS parameter %s: must be a cell-array of the form {string, positive real},\n', ... 
                'where string is %s.'],field,allstrings);
else
    errid = '';
    errmsg = '';
end
%-----------------------------------------------------------------------------------------
function [valid, errmsg, errid] = posReal(field,value,string)
% Any positive real scalar or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value > 0) ;
if nargin > 2
   valid = valid || strcmpi(value,string);
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:nonPositiveNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive scalar (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:nonPositiveNum';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real positive scalar.',field);
    end
else
    errid = '';
    errmsg = '';
end

%-----------------------------------------------------------------------------------------

function [valid, errmsg, errid] = realLessThanPlusInf(field,value,string)
% Any real scalar that is less than +Inf, or sometimes a special string
valid =  isreal(value) && isscalar(value) && (value < +Inf);
if nargin > 2
    valid = valid || strcmpi(value,string);
end
if ~valid
    if ischar(value)
        errid = 'optimlib:optimoptioncheckfield:PlusInfReal';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real scalar less than +Inf (not a string).',field);
    else
        errid = 'optimlib:optimoptioncheckfield:PlusInfReal';
        errmsg = sprintf('Invalid value for OPTIONS parameter %s: must be a real scalar less than +Inf.',field);
    end
else
    errid = '';
    errmsg = '';
end

%---------------------------------------------------------------------------------
function    allstrings = formatCellArrayOfStrings(strings)
%formatCellArrayOfStrings converts cell array of strings "strings" into an 
% array of strings "allstrings", with correct punctuation and "or" depending
% on how many strings there are, in order to create readable error message.

% To print out the error message beautifully, need to get the commas and "or"s
% in all the correct places while building up the string of possible string values.
    allstrings = ['''',strings{1},''''];
    for index = 2:(length(strings)-1)
        % add comma and a space after all but the last string
        allstrings = [allstrings, ', ''', strings{index},''''];
    end
    if length(strings) > 2
        allstrings = [allstrings,', or ''',strings{end},''''];
    elseif length(strings) == 2
        allstrings = [allstrings,' or ''',strings{end},''''];
    end
