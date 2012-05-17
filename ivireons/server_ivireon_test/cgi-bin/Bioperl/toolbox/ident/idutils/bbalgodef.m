function [algo, msg] = bbalgodef(algo)
%BBALGODEF black box model Algorithm definition and property check
%
% algo = bbalgodef: create the default Algorithm structure.
%
% [algo, msg] = bbalgodef(algo): check the fiedls of algo.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/06/13 15:22:06 $

% Author(s): Qinghua Zhang

if nargin==0
    algo = AlgoDef;
    msg = [];
else
    [algo, msg] = bbalgocheck(algo);
end

%==========================================================================
function Algorithm = AlgoDef
% create the default Algorithm structure

adv = struct('GnPinvConst', 1e4, ...
    'MinParChange', 1e-16, ...
    'StepReduction', 2, ...
    'MaxBisections', 10, ...
    'LMStartValue', 0.001, ...
    'LMStep', 10, ...
    'RelImprovement', 0, ...
    'MaxFunEvals', Inf);

Algorithm = struct('SearchMethod', 'Auto', ...
    'Criterion', 'det',...
    'Weighting', [],...
    'MaxIter', 20, ...
    'Tolerance', 1e-5, ...
    'LimitError', 0, ...
    'Display', 'Off', ...
    'MaxSize', idmsize, ...
    'IterWavenet', 'Auto', ...
    'Advanced', adv);

%--------------------------------------------------------------------------
function [algo, msg] = bbalgocheck(algo)
%black box Algorithm fields check

if ~(isstruct(algo) && isscalar(algo))
    msg = struct('identifier', 'Ident:general:structPropVal','message',...
        sprintf('The value of the "%s" property must be a scalar structure.','Algorithm'));
    return
end

dfalgofields = {   'SearchMethod', ...
    'Criterion',...
    'Weighting',...
    'MaxIter', ...
    'Tolerance', ...
    'LimitError', ...
    'Display', ...
    'MaxSize', ...
    'IterWavenet', ...
    'Advanced'};

algofields = fieldnames(algo);

ndefflds = length(dfalgofields);
for kf = 1:ndefflds
    if ~any(strcmp(dfalgofields{kf}, algofields))
        msg = sprintf('Algorithm must contain the field ''%s''.', dfalgofields{kf});
        msg = struct('identifier','Ident:general:missingAlgoField','message',msg);
        return
    end
end

if length(algofields)>ndefflds
    for kf = 1:length(algofields)
        if ~any(strcmp(algofields{kf}, dfalgofields))
            msg = sprintf('''%s'' is not a valid algorithm property.', algofields{kf});
            msg = struct('identifier','Ident:general:incorrectAlgoField','message',msg);
            return
        end
    end
end

dfadvfields = {'GnPinvConst',  ...
    'MinParChange',  ...
    'StepReduction', ...
    'MaxBisections', ...
    'LMStartValue',  ...
    'LMStep',  ...
    'RelImprovement', ...
    'MaxFunEvals'};

advfields = fieldnames(algo.Advanced);

for kf=1:length(dfadvfields)
    if ~any(strcmp(dfadvfields{kf}, advfields))
        msg = sprintf('The algorithm property "Advanced" must contain the field ''%s''.', dfalgofields{kf});
        msg = struct('identifier','Ident:general:missingAdvancedAlgoField','message',msg);
        return
    end
end

if ischar(algo.SearchMethod) && strcmpi(algo.SearchMethod, 'gn')
    algo.SearchMethod = 'gn';
else
    [value, msg] = strchoice({'Auto', 'gn', 'gna', 'grad', 'lm', 'lsqnonlin'}, algo.SearchMethod, 'SearchMethod');
    if ~isempty(msg)
        return
    end
    algo.SearchMethod = value;
end

% Criterion
if ~any(strncmpi(algo.Criterion,{'det','trace'},length(algo.Criterion)))
    msg = 'The value of the algorithm property "Criterion" must be ''det'' or ''trace''.';
    msg = struct('identifier','Ident:general:invalidCriterion','message',msg);
    return
elseif strncmpi(algo.Criterion,'d',1)
    algo.Criterion = 'det';
else
    algo.Criterion = 'trace';
end

% Weighting
val = algo.Weighting;
[sr,sc] = size(val);
if ndims(val)>2 || ~isrealmat(val) || any(~isfinite(val(:))) || (sr~=sc) || min(eig(val))<0
    msg = 'The value of the algorithm property "Weighting" must be a positive semi-definite square matrix of size equal to the number of outputs.';
    msg = struct('identifier','Ident:general:incorrectWeighting2','message',msg);
    return
end

% MaxIter
if ~isnonnegintscalar(algo.MaxIter)
    msg = sprintf('The value of the algorithm property "%s" must be a positive integer.','MaxIter');
    msg = struct('identifier','Ident:general:positiveIntAlgPropVal','message',msg);
    return
end

% Tolerance
if ~isnonnegrealscalar(algo.Tolerance)
    msg = sprintf('The value of the algorithm property "%s" must be 0 or a positive real number.','Tolerance');
    msg = struct('identifier','Ident:general:nonnegativeNumAlgPropVal','message',msg);
    return
end

% LimitError
if ~isnonnegrealscalar(algo.LimitError)
    msg = sprintf('The value of the algorithm property "%s" must be 0 or a positive real number.','LimitError');
    msg = struct('identifier','Ident:general:nonnegativeNumAlgPropVal','message',msg);
    return
end

% Display
[value, msg] = strchoice({'off' 'on' 'full'}, algo.Display, 'Display');
if ~isempty(msg)
    return
end
algo.Display = value;

% MaxSize
if ~isposintscalar(algo.MaxSize)
    msg = sprintf('The value of the algorithm property "%s" must be a positive integer.','MaxSize');
    msg = struct('identifier','Ident:general:positiveIntAlgPropVal','message',msg);
    return
end

[value, msg] = strchoice({'auto', 'on', 'off'}, algo.IterWavenet, 'IterWavenet');
if ~isempty(msg)
    return
end
algo.IterWavenet = value;

for kf = 1:length(dfadvfields)
    value = algo.Advanced.(dfadvfields{kf});
    if ~(isscalar(value) && value>=0)
        msg = sprintf('The value of the algorithm option "%s" must be a positive scalar.',...
            ['Advanced.',dfadvfields{kf}]);
        msg = struct('identifier','Ident:general:positiveScalarAlgOptVal','message',msg);
        return
    end
end

% FILE END