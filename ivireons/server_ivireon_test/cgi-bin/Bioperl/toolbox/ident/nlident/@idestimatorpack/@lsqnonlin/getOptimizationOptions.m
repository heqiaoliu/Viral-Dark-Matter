function option = getOptimizationOptions(this, varargin)
%GETOPTIMIZATIONOPTIONS  Interprets the optimization options which may be
%   structure differently for various models.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.14 $ $Date: 2009/04/21 03:23:00 $
%   Written by Rajiv Singh.

% Initializations.
Model = this.Model;
option = optimset('lsqnonlin');
option.PrecondBandWidth = Inf; % Force medium scale trust-region.
option.Jacobian = 'on';
option.Display = 'off';

% Get algorithm info.
if (nargin > 1)
    alg = varargin{1};
else
    alg = Model.Algorithm;
end

option.TolFun = alg.Tolerance*1e-3;  % todo: lsqnonlin defaults are usually lower.

if alg.MaxIter<0
    option.MaxIter = 0;
    option.TolFun = Inf; %to stop iterations prematurely
else
    option.MaxIter = alg.MaxIter;
end

if isa(this.Data,'iddata')
    option.DataSize = size(this.Data, 1);
elseif iscell(this.Data)
    % time domain data in raw form
    if iscell(this.Data{1}) %idnlfun case
        option.DataSize = size(this.Data{1}{1}, 1);
    else
        % deconstructed iddata (such as idpoly/pem_f)
        option.DataSize = cellfun(@(x)size(x,1),this.Data);
    end
else
    ctrlMsgUtils.error('Ident:utility:unknownData','lsqnonlin')
end

option.Criterion = alg.Criterion;
option.Weighting = alg.Weighting;

%option.CostType = 'SSE'; % Fixed cost type for lsqnonlin, where doSqrLam is false.

option.ComputeProjFlag = false; % initialization

% ask model to configure model-specific properties
option = configureOptimizationOptions(Model, alg, option, this); 

if isa(Model,'idmodel') && ~option.struc.realflag
    ctrlMsgUtils.error('Ident:estimation:LsqnonlinComplexData')
end
    
% should a data-driven minimal projection of parameter set be computed? -> No.
option.ProjectionFun = '';

% Attach output function.
option.OutputFcn = @localOutput;

% Initialize field for iteration info
option.IterInfo = struct('Iteration',0);

Display = option.Display;

% Display = 'Full' should be treated as Display = 'On' for nonlinear models.
% todo: handle "full" Display for idnlgrey?
if (isa(Model, 'idnlmodel') && strcmpi(Display, 'full'))
    Display = 'On';
end

%showpar = false;
if strcmpi(Display,'full')
    struc = struct([]); ParInd = []; names = {};
    allPar = getParameterVector(this.Model);
    %allPar0 = allPar;
    Dirn = zeros(length(allPar),1);
    Pdisp = {};
    if isa(this.Model, 'idmodel')
        struc  = option.struc;
        ParInd = setdiff(1:struc.Npar,struc.fixparind);
        names = pvget(this.Model,'PName');
            if isempty(names)
                this.Model = setpname(this.Model);
                names = pvget(this.Model,'PName');
            end
            NamLen = max(cellfun('length',names))+1; %maximum char length of a par name
        Pdisp = cell(struc.Npar,1);
        Nl = double(' ');
            names = cellfun(@(x)sprintf('%s%s',x,char(Nl*ones(1,NamLen-length(x)))),...
            names,'UniformOutput',false);
        %showpar = ~option.ComputeProjFlag;
    end
end
prevloss = [];

% Determine heading to display.
commonheader = LocalGetCommonHeader(option);

linestr = repmat('-', 1, 62);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested functions.                                                              %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-------------------------------------------------------------
    function stop = localOutput(values, state, type, varargin)
        % Used to store progress information and stop optimization
        drawnow; % Force processing of any stop event

        newInfo = this.getIterInfo(values, state, type);
        %TrueNobs = max(1, sum(option.DataSize)-length(values)/NY);
        if strcmpi(Display, 'on')
            switch type
                case 'init'
                    showInitialInfo;
                case 'iter'
                    showDisplay;
                case 'done'
                    showEndInfo;
                otherwise
                    % Do nothing!
            end
        elseif strcmpi(Display, 'full')
            switch type
                case 'init'
                    showFullInitialInfo;
                case 'iter'
                    showFullDisplay;
                case 'done'
                    showFullEndInfo;
                otherwise
                    % Do nothing!
            end
        end
        
        % Update current iteration information in options
        this.Options.IterInfo = newInfo;
        
        % 1. send an event to inform the GUI object.
        % 2. find out if optimization should stop
        stop = LocalSendEvent(Model,newInfo,prevloss,type);
        prevloss = newInfo.Cost;
        %------------------------------------------------------------------
        function showInitialInfo
            % Determine heading to display.
            header = sprintf('\n%s\n%s\n%s\n%s\n%s', commonheader, ...
                linestr, ...
                '                                 Norm of      First-order', ...
                ' Iteration      Cost             step         optimality  ', ...
                linestr);
            disp(header);

            formatstr = ' %5.0f    %13.6g    %10.3s    %13.3s ';
            %newInfo = this.getIterInfo(values, state, type);
            currOutput = sprintf(formatstr, newInfo.Iteration, newInfo.Cost, '-', '-');
            disp(currOutput);
        end

        %------------------------------------------------------------------
        function showDisplay
            if (state.iteration > 0) && (state.iteration <= option.MaxIter)
                formatstr = ' %5.0f    %13.6g    %10.3g    %13.3g';
                %newInfo = this.getIterInfo(values, state, type);
                currOutput = sprintf(formatstr, newInfo.Iteration, ...
                    newInfo.Cost, newInfo.StepSize, newInfo.FirstOrd);
                disp(currOutput);
            end
        end

        %------------------------------------------------------------------
        function showEndInfo
            disp(linestr);
        end
        
        %------------------------------------------------------------------
        function showFullInitialInfo
            % Determine heading to display.
            
            disp(linestr)
            disp(commonheader)
            disp(linestr)
            
            disp('Initial Estimate:');
            fprintf('   Current cost: %5.6g',newInfo.Cost)
            disp('   Parameters:')
            LocalSetParameterString(0);
            disp(char(Pdisp))
            disp(' ')
            %prevloss = newInfo.Cost;
        end

        %------------------------------------------------------------------
        function showFullDisplay
            
            fprintf('Iteration %d:',newInfo.Iteration)
            fprintf('   Current cost: %5.6g   Previous cost: %5.6g',...
                newInfo.Cost,prevloss);
            %prevloss = newInfo.Cost;
            disp('   Param          New value     Prev. value     Gradient ')
            LocalSetParameterString(1);
            disp(char(Pdisp))

            fprintf('   Step-size: %5.6g',newInfo.StepSize);
            fprintf('   First-order optimality: %5.6g',newInfo.FirstOrd);
            
        end

        %------------------------------------------------------------------
        function showFullEndInfo
            disp('Estimation complete.')
            fprintf('First-order optimality (largest slope): %5.6g',...
                newInfo.FirstOrd);
            fprintf('Final cost: %5.6g',newInfo.Cost)
            disp(' ');
        end

        %------------------------------------------------------------------
        function LocalSetParameterString(Ind)
            % return a nice display of parameter names and current values
            
            if Ind==0
                allPar(ParInd) = newInfo.Values(1:length(ParInd));
                for k_ = 1:struc.Npar
                    Pdisp{k_,:} = sprintf('   %s: %13.4g',names{k_},allPar(k_));
                end
            else
                oldPar = allPar;
                allPar(ParInd) = newInfo.Values(1:length(ParInd)); %do not re-init
                Dirn = zeros(length(allPar),1); %reinitialization is necessary ("ssfree")
                Dirn(ParInd) = newInfo.Gradient(1:length(ParInd));
                for k_ = 1:struc.Npar
                    Pdisp{k_,:} = sprintf('   %s: %13.4g  %13.4g  %13.4g',...
                        names{k_},allPar(k_),oldPar(k_),Dirn(k_));
                end
            end
            
        end
        
    end
end
%--------------------------------------------------------------------------
%- LOCAL FUNCTION (not nested)---------------------------------------------
%--------------------------------------------------------------------------
function stop = LocalSendEvent(Model,newInfo,oldcost,type)
% event types: 'optimStartInfo','optimIterInfo','optimEndInfo'

stop = false;
messenger = idestimatorpack.getOptimMessenger(Model);
if isempty(messenger) || ~isa(messenger,'nlutilspack.optimmessenger')
    return;
end

stop = messenger.Stop;

info = struct('Iteration',newInfo.Iteration,...
    'Cost',newInfo.Cost,...
    'OldCost',oldcost,...
    'StepSize',newInfo.StepSize,...
    'Optimality',newInfo.FirstOrd,...
    'Bisections',[],...
    'Name','lsqnonlin',...
    'ModelType',class(Model));

%sprintf('%s:%d',type, newInfo.Iteration)
switch type
    case 'init'
        ed = nlutilspack.idguievent(messenger,'optimStartInfo');
    case 'iter'
        ed = nlutilspack.idguievent(messenger,'optimIterInfo');
    case 'done'
        ed = nlutilspack.idguievent(messenger,'optimEndInfo');
    otherwise
        return;
end
ed.Info = info;
messenger.send('optiminfo',ed);
end

%--------------------------------------------------------------------------
function str = LocalGetCommonHeader(option)
% Determine heading to display.

%option = this.Options;
if strcmpi(option.LargeScale, 'off') % never true currently (awaiting lsqnonlin revision)
    if strcmpi(option.LevenbergMarquardt, 'off')
        str = 'Gauss-Newton line search (LSQNONLIN, LargeScale = ''Off'')';
    else
        str = 'Levenburg-Marquardt line search (LSQNONLIN, LargeScale = ''Off'')';
    end
else
    str = 'Trust-Region Reflective Newton (LSQNONLIN, LargeScale = ''On'')';
end

str = ['   Scheme: ',str];

if strcmpi(option.Criterion,'det')
    str = sprintf('Criterion: Determinant minimization\n%s',str);
else
    str = sprintf('Criterion: Trace minimization\n%s',str);
end

end