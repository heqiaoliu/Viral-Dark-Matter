function [errmsg, PValue] = checkgetAlgorithmProperty(PName, PValue, ny)
%CHECKGETALGORITHMPROPERTY  Checks that the specified algorithm property
%   information is valid. PRIVATE FUNCTION.
%
%   [ERRMSG, PVALUE] = CHECKGETALGORITHMPROPERTY(PNAME, PVALUE, NY);
%
%   PNAME is a string specifying the algorithm property to be checked and
%   returned.
%   NY is number of model outputs (required for checking Weighting)
%
%   PVALUE holds the property value to be checked.
%
%   ERRMSG is a struct specifying the first error encountered during
%   property value checking (empty if no errors found).

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.12 $ $Date: 2009/12/07 20:42:41 $
%   Written by Peter Lindskog.

% Check that the function is called with two arguments.
error(nargchk(2, 3, nargin, 'struct'));

% Perform the specified property checking.
switch(PName)
    case 'SimulationOptions'
        % A.1. Check that SimulationOptions is a structure.
        if ~isstruct(PValue)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp1'; 
            msg = ctrlMsgUtils.message(ID,'SimulationOptions');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % A.2. Check that PValue contains the correct SimulationOptions fields.
        Names1 = fieldnames(PValue);
        Names2 = fieldnames(idnlgreydef('SimulationOptions'));
        if (length(Names1) ~= length(Names2)) || ~all(ismember(Names1, Names2))
            ID = 'Ident:idnlmodel:idnlgreyAlgProp2'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % A.3. Check the contents of SimulationsOptions.
        % 1. Solver should be 'auto', 'ode113', 'ode15s', 'ode23',
        %    'ode23s', 'ode23t', 'ode23tb', 'ode45', 'ode5', 'ode4',
        %    'ode3', 'ode2', 'ode1', or 'fixedstepdiscrete'.
        solver = PValue.Solver;
        if ~ischar(solver) || (ndims(solver) ~= 2) || isempty(solver) || (size(solver, 1) ~= 1)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp3'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        else
            choices = {'auto' 'ode113' 'ode15s' 'ode23' 'ode23s' 'ode23t' 'ode23tb' 'ode45' ...
                'ode5' 'ode4' 'ode3' 'ode2' 'ode1' 'fixedstepdiscrete'};
            if strcmpi(solver, choices{4})
                choice = 4;
            elseif strcmpi(solver, choices{6})
                choice = 6;
            elseif strcmpi(solver, choices{10})
                choice = 10;
            elseif strcmpi(solver, choices{12})
                choice = 12;
            elseif strcmpi(solver, choices{13})
                choice = 13;
            else
                choice = strmatch(lower(solver), choices);
            end
            if isempty(choice)
                ID = 'Ident:idnlmodel:idnlgreyAlgProp2';
                msg = ctrlMsgUtils.message(ID,solver);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (length(choice) > 1)
                choices = {choices{choice}};
                choice = '';
                for j = 1:length(choices)
                    choice = [choice(:)' '''' choices{j} ''', '];
                end
                ID = 'Ident:general:ambiguousAlgOptVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.Solver',choice(1:end-2));
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (choice < 2)
                PValue.Solver = 'Auto';
            elseif (choice < 3)
                PValue.Solver = 'ode113';
            elseif (choice < 4)
                PValue.Solver = 'ode15s';
            elseif (choice < 5)
                PValue.Solver = 'ode23';
            elseif (choice < 6)
                PValue.Solver = 'ode23s';
            elseif (choice < 7)
                PValue.Solver = 'ode23t';
            elseif (choice < 8)
                PValue.Solver = 'ode23tb';
            elseif (choice < 9)
                PValue.Solver = 'ode45';
            elseif (choice < 10)
                PValue.Solver = 'ode5';
            elseif (choice < 11)
                PValue.Solver = 'ode4';
            elseif (choice < 12)
                PValue.Solver = 'ode3';
            elseif (choice < 13)
                PValue.Solver = 'ode2';
            elseif (choice < 14)
                PValue.Solver = 'ode1';
            else
                PValue.Solver = 'FixedStepDiscrete';
            end
        end
        
        % 2. SimulationOptions.RelTol should be a scalar positive real.
        if ~isRealScalar(PValue.RelTol, 0, Inf, false)
            ID = 'Ident:general:positiveScalarAlgOptVal'; 
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.RelTol');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 3. SimulationOptions.AbsTol should be a scalar positive real.
        if ~isRealScalar(PValue.AbsTol, 0, Inf, false)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.AbsTol');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 4. SimulationOptions.MinStep should be 'Auto' or a finite
        %    scalar strictly positive real.
        MinStep = PValue.MinStep;
        if (ndims(MinStep) ~= 2)
            ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.MinStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif ischar(MinStep)
            if isempty(MinStep) || ~strncmpi(MinStep,'auto',length(MinStep))
                ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.MinStep');
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                PValue.MinStep = 'Auto';
            end
            MinStep = 0;
        elseif isnumeric(MinStep)
            if ~isRealScalar(MinStep, eps(0), Inf, true)
                ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.MinStep');
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
        else
            ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.MinStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 5. SimulationOptions.MaxStep should be 'Auto' or a finite scalar
        %    positive real.
        MaxStep = PValue.MaxStep;
        if (ndims(MaxStep) ~= 2)
            ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.MaxStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif ischar(MaxStep)
            if isempty(MaxStep) || ~strncmpi(MaxStep,'auto',length(MaxStep))
                ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.MaxStep');
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                PValue.MaxStep = 'Auto';
            end
            MaxStep = Inf;
        elseif isnumeric(MaxStep)
            if ~isRealScalar(MaxStep, eps(0), Inf, true)
                ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.MaxStep');
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
        else
            ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.MaxStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 6. SimulationOptions.InitialStep should be 'Auto' or a finite scalar
        %    positive real.
        InitialStep = PValue.InitialStep;
        if (ndims(InitialStep) ~= 2)
            ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.InitialStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif ischar(InitialStep)
            if isempty(InitialStep) || ~strncmpi(InitialStep,'auto',length(InitialStep))
                ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.InitialStep');
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                PValue.InitialStep = 'Auto';
            end
            InitialStep = MinStep;
        elseif isnumeric(InitialStep)
            if ~isRealScalar(InitialStep, eps(0), Inf, true)
                ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
                msg = ctrlMsgUtils.message(ID,'SimulationOptions.InitialStep');
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
        else
            ID = 'Ident:general:posScalarOrAutoAlgoPropVal';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions.InitialStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % Check that SimulationOptions.MinStep < SimulationOptions.MaxStep.
        if (MinStep >= MaxStep)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp6a';
            msg = ctrlMsgUtils.message(ID,...
                'SimulationOptions.MinStep',sprintf('%g',MinStep),...
                'SimulationOptions.MaxStep',sprintf('%g',MaxStep));
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % Check that SimulationOptions.MinStep <= SimulationOptions.InitialStep <= SimulationOptions.MaxStep.
        if (InitialStep < MinStep)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp6b';
            msg = ctrlMsgUtils.message(ID,...
                'SimulationOptions.MinStep',sprintf('%g',MinStep),...
                'SimulationOptions.InitialStep',sprintf('%g',InitialStep));
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif (InitialStep > MaxStep)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp6b';
            msg = ctrlMsgUtils.message(ID,...
                'SimulationOptions.InitialStep',sprintf('%g',InitialStep),...
                'SimulationOptions.MaxStep',sprintf('%g',MaxStep));
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 7. Check that SimulationOptions.MaxOrder is 1, 2, 3, 4, or 5.
        if ~isIntScalar(PValue.MaxOrder, 1, 5, false)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp7'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 8. SimulationOptions.FixedStep should be 'Auto' or a scalar real such that 0 < FixedStep <= 1.
        FixedStep = PValue.FixedStep;
        if (ndims(FixedStep) ~= 2)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp8'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        elseif ischar(FixedStep)
            if (isempty(FixedStep) || isempty(strmatch(lower(FixedStep), 'auto')))
                ID = 'Ident:idnlmodel:idnlgreyAlgProp8'; msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                PValue.FixedStep = 'Auto';
            end
        elseif isnumeric(FixedStep)
            if ~isRealScalar(FixedStep, eps(0), 1, true)
                ID = 'Ident:idnlmodel:idnlgreyAlgProp8'; msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            end
        else
            ID = 'Ident:idnlmodel:idnlgreyAlgProp8'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    case 'GradientOptions'
        % B.1. Check that GradientOptions is a structure.
        if ~isstruct(PValue)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp1';
            msg = ctrlMsgUtils.message(ID,'SimulationOptions');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % B.2. Check that GradientOptions contains the correct fields.
        Names1 = fieldnames(PValue);
        Names2 = fieldnames(idnlgreydef('GradientOptions'));
        if (length(Names1) ~= length(Names2)) || ~all(ismember(Names1, Names2))
            ID = 'Ident:idnlmodel:idnlgreyAlgProp9'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % B.3. Check the contents of GradientOptions.
        % 1. GradientOptions.DiffScheme should be 'Auto', 'Central
        %    approximation', 'Forward approximation', or 'Backward
        %    approximation'.
        [errmsg, value] = isValidStr(PValue.DiffScheme, {'Auto'                        ...
            'Central approximation' 'Forward approximation' 'Backward approximation'}, ...
            'GradientOptions.DiffScheme');
        if ~isempty(errmsg)
            return;
        end
        PValue.DiffScheme = value;
        
        % 2. GradientOptions.DiffMinChange should be a finite scalar strictly positive real.
        if ~isRealScalar(PValue.DiffMinChange, eps(0), Inf, true)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'GradientOptions.DiffMinChange');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 3. GradientOptions.DiffMaxChange should be a scalar strictly
        %    positive real.
        if ~isRealScalar(PValue.DiffMaxChange, eps(0), Inf, false)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'GradientOptions.DiffMaxChange');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % Check that GradientOptions.DiffMinChange < GradientOptions.DiffMaxChange.
        if (PValue.DiffMinChange >= PValue.DiffMaxChange)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp6a';
            msg = ctrlMsgUtils.message(ID,...
                'GradientOptions.DiffMinChange',sprintf('%g',PValue.DiffMinChange),...
                'GradientOptions.DiffMaxChange',sprintf('%g',PValue.DiffMaxChange));
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 4. GradientOptions.GradientType should be 'Auto', 'Basic', or 'Refined'.
        [errmsg, value] = isValidStr(PValue.GradientType, ...
            {'Auto' 'Basic' 'Refined'}, 'GradientOptions.GradientType');
        if ~isempty(errmsg)
            return;
        end
        PValue.GradientType = value;
    case 'SearchMethod'
        % C. SearchMethod should be 'Auto', 'gn', 'gna' 'grad', 'lm' or
        %    'lsqnonlin'.
        if (ndims(PValue) ~= 2) || ~ischar(PValue) || isempty(PValue) ||...
                (size(PValue, 1) ~= 1)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp10'; 
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        else
            choices = {'Auto' 'gn' 'gna' 'grad' 'lm' 'lsqnonlin'};
            if strcmpi(PValue, choices{2})
                choice = 2;
            else
                choice = strmatch(lower(PValue), lower(choices));
            end
            if isempty(choice)
                ID = 'Ident:idnlmodel:idnlgreyAlgProp11';
                msg = ctrlMsgUtils.message(ID,PValue);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            elseif (length(choice) > 1)
                choices = {choices{choice}};
                choice = '';
                for j = 1:length(choices)
                    choice = [choice(:)','''' choices{j} ''', '];
                end
                ID = 'Ident:general:ambiguousAlgPropVal';
                msg = ctrlMsgUtils.message(ID,'SearchMethod',choice(1:end-2));
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                PValue = choices{choice};
                if (strcmpi(choices{choice}, 'lsqnonlin') && ~(isoptiminstalled))
                    ID = 'Ident:idnlmodel:idnlgreyAlgProp12';
                    msg = ctrlMsgUtils.message(ID);
                    errmsg = struct('identifier',ID,'message',msg);
                    return;
                end
            end
        end
    case 'Criterion'
        % D. Minimization criterion should be 'trace' or 'det'.
        if (ndims(PValue) ~= 2) || ~ischar(PValue) || isempty(PValue) ||...
                (size(PValue, 1) ~= 1)
            ID = 'Ident:general:invalidCriterion';
            msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        else
            choices = {'det','trace'};
            Ind = strncmpi(PValue,choices,length(PValue));
            if ~any(Ind)
                ID = 'Ident:general:invalidCriterion';
                msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
                return;
            else
                PValue = choices{Ind};
            end
        end
    case 'Weighting'
        % E. Weighting matrix.
        [sr, sc] = size(PValue);
        if (~isrealmat(PValue) || any(~isfinite(PValue(:))) || (sr~=ny) || ...
                (sr ~= sc) || (~isempty(PValue) && min(eig(PValue)) < 0))
            if ny==0
                ID = 'Ident:general:incorrectWeighting2'; msg = ctrlMsgUtils.message(ID);
                errmsg = struct('identifier',ID,'message',msg);
            elseif ny==1
                ID = 'Ident:general:positiveScalarAlgPropVal';
                msg = ctrlMsgUtils.message(ID,'Weighting');
                errmsg = struct('identifier',ID,'message',msg);
            else
                ID = 'Ident:general:incorrectWeighting1'; msg = ctrlMsgUtils.message(ID,ny);
                errmsg = struct('identifier',ID,'message',msg);
            end
            return;
        end
    case 'MaxIter'
        % F. MaxIter should be a scalar positive integer.
        if ~isIntScalar(PValue, 0, Inf, false)
            ID = 'Ident:general:positiveIntAlgPropVal';
            msg = ctrlMsgUtils.message(ID,'MaxIter');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    case 'Tolerance'
        % G. Tolerance should be a finite scalar positive real.
        if ~isRealScalar(PValue, 0, Inf, true)
            ID = 'Ident:general:nonnegativeNumAlgPropVal'; msg = ctrlMsgUtils.message(ID,'Tolerance');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    case 'LimitError'
        % H. LimitError should be a finite scalar positive real.
        if ~isRealScalar(PValue, 0, Inf, true)
            ID = 'Ident:general:nonnegativeNumAlgPropVal'; msg = ctrlMsgUtils.message(ID,'LimitError');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    case 'Display'
        % I. Display should be 'Off', 'On' or 'Full'.
        [errmsg, PValue] = isValidStr(PValue, {'Off' 'On' 'Full'}, 'Display');
        if ~isempty(errmsg)
            return;
        end
    case 'Advanced'
        %J.1. Check that Advanced is a structure.
        if ~isstruct(PValue)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp1'; msg = ctrlMsgUtils.message(ID,'Advanced');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % J.2. Check that Advanced contains the correct fields.
        Names1 = fieldnames(PValue);
        Names2 = fieldnames(idnlgreydef('Advanced'));
        if (length(Names1) ~= length(Names2)) ||  ~all(ismember(Names1, Names2))
            ID = 'Ident:idnlmodel:idnlgreyAlgProp13'; msg = ctrlMsgUtils.message(ID);
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % J.3. Check the contents of Advanced.
        % 1. Advanced.GnPinvConst should be a finite scalar positive real.
        if ~isRealScalar(PValue.GnPinvConst, 0, Inf, true)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'Advanced.GnPinvConst');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 2. Advanced.MinParChange should be a finite scalar strictly positive real.
        if ~isRealScalar(PValue.MinParChange, eps(0), Inf, true)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'Advanced.MinParChange');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 3. Advanced.StepReduction should be a finite scalar real larger than 1.
        if ~isRealScalar(PValue.StepReduction, 1+eps(1), Inf, true)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp14';
            msg = ctrlMsgUtils.message(ID,'Advanced.StepReduction');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 4. Advanced.MaxBisections should be a positive scalar integer.
        if ~isIntScalar(PValue.MaxBisections, 0, Inf, false)
            ID = 'Ident:general:positiveIntAlgPropVal';
            msg = ctrlMsgUtils.message(ID,'Advanced.MaxBisections');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 5. Advanced.LMStartValue should be a finite scalar strictly positive real.
        if ~isRealScalar(PValue.LMStartValue, eps(0), Inf, true)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'Advanced.LMStartValue');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 6. Advanced.LMStep should be a finite scalar real larger than 1.
        if ~isRealScalar(PValue.LMStep, 1+eps(1), Inf, true)
            ID = 'Ident:idnlmodel:idnlgreyAlgProp14';
            msg = ctrlMsgUtils.message(ID,'Advanced.LMStep');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 7. Advanced.RelImprovement should be a scalar positive integer.
        if ~isRealScalar(PValue.RelImprovement, 0, Inf, false)
            ID = 'Ident:general:nonnegativeNumAlgPropVal';
            msg = ctrlMsgUtils.message(ID,'Advanced.RelImprovement');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
        
        % 8. Advanced.MaxFunEvals should be a scalar strictly positive integer.
        if ~isIntScalar(PValue.MaxFunEvals, eps(0), Inf, false)
            ID = 'Ident:general:positiveScalarAlgOptVal';
            msg = ctrlMsgUtils.message(ID,'Advanced.MaxFunEvals');
            errmsg = struct('identifier',ID,'message',msg);
            return;
        end
    otherwise
        ID = 'Ident:general:unknownAlgoProp';
        msg = ctrlMsgUtils.message(ID,PName,'idnlgrey algorithm');
        errmsg = struct('identifier',ID,'message',msg);
        return;
end

% Everything went fine. Return empty errmsg.
errmsg = struct([]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isIntScalar(value, low, high, islimited)
% Check that value is an integer in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (isfinite(value) && (rem(value, 1) ~= 0))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isRealScalar(value, low, high, islimited)
% Check that value is a real scalar in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [errmsg, outvalue] = isValidStr(invalue, choices, propinfo)
% Return outvalue as a unique match of choices.
errmsg = struct([]);
outvalue = '';
if (ndims(invalue) ~= 2) || ~ischar(invalue) || isempty(invalue) || (size(invalue, 1) ~= 1)
    ID = 'Ident:general:stringAlgOptVal';
    msg = ctrlMsgUtils.message(ID,propinfo);
    errmsg = struct('identifier',ID,'message',msg);
else
    choice = strmatch(lower(invalue), lower(choices));
    if isempty(choice)
        ID = 'Ident:general:invalidAlgoOptionVal';
        msg = ctrlMsgUtils.message(ID,propinfo,'idnlgrey algorithm');
        errmsg = struct('identifier',ID,'message',msg);
    elseif (length(choice) > 1)
        choices = {choices{choice}};
        choice = '';
        for j = 1:length(choices)
            choice = [choice(:)' '''' choices{j} ''', '];
        end
        ID = 'Ident:general:ambiguousAlgOptVal';
        msg = ctrlMsgUtils.message(ID,propinfo,choice(1:end-2));
        errmsg = struct('identifier',ID,'message',msg);
    else
        outvalue = choices{choice};
    end
end
