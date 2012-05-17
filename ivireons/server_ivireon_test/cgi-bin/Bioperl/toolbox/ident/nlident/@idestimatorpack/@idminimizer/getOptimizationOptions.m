function option = getOptimizationOptions(this, varargin)
%GETOPTIMIZATIONOPTIONS  Interprets the optimization options which may be
%   structured differently for various models.

% todo: replace this with setOptimizationOptions, that does not return an
% output (updated "this" directly)

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision: 1.1.10.11 $ $Date: 2009/03/09 19:14:45 $

% Get model and algorithm information.
Model = this.Model;
if (nargin > 1)
    alg = varargin{1};
else
    alg = Model.Algorithm;
end

% Default assignments for all model types.
option = alg;

%todo: move this to configureOptimizationOptions?
if isa(this.Data,'iddata')
    option.DataSize = size(this.Data, 1); %number of samples
elseif iscell(this.Data)
    % time domain data in raw form
    if iscell(this.Data{1}) %idnlfun case
        option.DataSize = size(this.Data{1}{1}, 1);
    else
        % deconstructed iddata (such as idpoly/pem_f)
        option.DataSize = cellfun(@(x)size(x,1),this.Data);
    end
elseif isa(this.Data,'idfrd')
    option.DataSize = size(this.Data, 3); % num freq (%todo: what is the use?)
else
    ctrlMsgUtils.error('Ident:utility:unknownData','idminimizer')
end

% Should a data-driven minimal projection of parameter set be computed?
option.ComputeProjFlag = false; %default (overridden for ssfree)
option.ProjectionFun = '';

% ask model to configure model-specific properties
option = configureOptimizationOptions(Model, alg, option, this);

option.isLinmod = isa(Model,'idmodel');
option.isPoly = isa(Model,'idpoly');
option.isReal = ~option.isLinmod || option.struc.realflag; 

if ~isfield(option.Advanced,'InitGnaTol')
    option.Advanced.InitGnaTol = 1e-4;
end

% Attach output function.
option.OutputFcn = @localOutput;

% Initialize field for iteration info
option.IterInfo = struct('Iteration',0);

Display = option.Display;
showpar = false;
if strcmpi(Display,'full')
    struc = struct([]); ParInd = []; names = {};
    allPar = getParameterVector(this.Model);
    Dirn = zeros(length(allPar),1);
    Pdisp = {};
    if isa(this.Model, 'idmodel')
        struc  = option.struc;
        showpar = ~option.ComputeProjFlag;
        if showpar
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
        end
    end
    %prevloss = [];  
end

prevloss = [];

% Determine heading to display.
commonheader = LocalGetCommonHeader(option);

linestr = repmat('-', 1, 90);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Nested functions.                                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function stop = localOutput(newInfo, type)
        % Used to store progress information and stop optimization
        drawnow; % Force processing of any stop event.
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
        stop = LocalSendEvent(Model,newInfo,prevloss,type,alg);

        prevloss = newInfo.CurrentCost;
        
        %------------------------------------------------------------------
        function showInitialInfo
            header = sprintf('\n%s\n%s\n%s\n%s\n%s', commonheader, ...
                linestr, ...
                '                            Norm of      First-order      Improvement (%)', ...
                ' Iteration       Cost       step         optimality     Expected   Achieved    Bisections', ...
                linestr);
            disp(header);

            formatstr = ' %5.0f  %13.6g %10.3s  %13.3g  %10.3g  %10.3s       %3s';

            currOutput = sprintf(formatstr, newInfo.Iteration, ...
                newInfo.CurrentCost, '-', newInfo.FirstOrd, ...
                newInfo.ExpectedImprovement, '-', '-');
            disp(currOutput);
        end

        %------------------------------------------------------------------
        function showDisplay
            if (newInfo.Iteration > 0)
                formatstr = ' %5.0f  %13.6g %10.3g  %13.3g  %10.3g  %10.3g       %3d';
                currOutput = sprintf(formatstr, newInfo.Iteration, ...
                    newInfo.CurrentCost, newInfo.StepSize, newInfo.FirstOrd, ...
                    newInfo.ExpectedImprovement, newInfo.ActualImprovement, ...
                    newInfo.NumBisections);
                disp(currOutput);
            end
        end

        %------------------------------------------------------------------
        function showEndInfo
            disp(linestr);
        end

        %------------------------------------------------------------------
        function showFullInitialInfo
            disp(linestr(1:80))
            disp(commonheader)
            disp(linestr(1:80))
            disp('Initial Estimate:');
            disp(sprintf('   Current cost: %5.6g',newInfo.CurrentCost))
            
            if showpar
                disp('   Parameters:')
                LocalSetParameterString(0);
                disp(char(Pdisp))
            end

            disp(' ')
            %prevloss = newInfo.CurrentCost;
        end

        %------------------------------------------------------------------
        function showFullDisplay
            
            disp(sprintf('Iteration %d:',newInfo.Iteration))
            disp(sprintf('   Current cost: %5.6g   Previous cost: %5.6g',...
                newInfo.CurrentCost,prevloss));
            %prevloss = newInfo.CurrentCost;
            
            if showpar
                fprintf('   Param         %s       Prev. value    Direction \n',[char(Nl*ones(1,NamLen-8)),'New value'])
                LocalSetParameterString(1);
                disp(char(Pdisp))
            end

            disp(sprintf('   Step-size: %5.6g',newInfo.StepSize));
            disp(sprintf('   First-order optimality: %5.6g',newInfo.FirstOrd));
            disp(sprintf('   Expected improvement: %5.6g%%',...
                newInfo.ExpectedImprovement));
            disp(sprintf('   Achieved improvement: %5.6g%%\n',...
                newInfo.ActualImprovement));
        end

        %------------------------------------------------------------------
        function showFullEndInfo
            disp('Estimation complete.')
            disp(sprintf('Last improvement: %5.6g',newInfo.ActualImprovement))
            disp(sprintf('First-order optimality (largest slope): %5.6g',...
                newInfo.FirstOrd));
            disp(sprintf('Final cost: %5.6g',newInfo.CurrentCost))
            disp(' ');
        end

        %------------------------------------------------------------------
        function LocalSetParameterString(Ind)
            % return a nice display of parameter names and current values
            
            if Ind==0
                allPar(ParInd) = newInfo.CurrentValues(1:length(ParInd));
                for k_ = 1:struc.Npar
                    Pdisp{k_,:} = sprintf('   %s: %13.4g',names{k_},allPar(k_));
                end
            else
                oldPar = allPar;
                allPar(ParInd) = newInfo.CurrentValues(1:length(ParInd)); %do not re-init
                Dirn = zeros(length(allPar),1); %reinitialization is necessary ("ssfree")
                Dirn(ParInd) = newInfo.Direction(1:length(ParInd));
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
function stop = LocalSendEvent(Model,newInfo,oldcost,type,alg)
% event types: 'optimStartInfo','optimIterInfo','optimEndInfo'

stop = false;
messenger = idestimatorpack.getOptimMessenger(Model);
if isempty(messenger) || ~isa(messenger,'nlutilspack.optimmessenger')
    return;
end

stop = messenger.Stop;
%sprintf('%s:%d',type, newInfo.Iteration)
info = struct('Iteration',newInfo.Iteration,...
    'Cost',newInfo.CurrentCost,... %numel(newInfo.CurrentValues)
    'OldCost',oldcost,...
    'StepSize',newInfo.StepSize,...
    'Optimality',newInfo.FirstOrd,...
    'Bisections',newInfo.NumBisections,...
    'Name',alg.SearchMethod,...
    'ModelType',class(Model));
switch type
    case 'init'
        ed = nlutilspack.idguievent(messenger,'optimStartInfo');
    case 'iter'
        ed = nlutilspack.idguievent(messenger,'optimIterInfo');
    case 'done'
        ed = nlutilspack.idguievent(messenger,'optimEndInfo');
end
ed.Info = info;
messenger.send('optiminfo',ed);
end

%--------------------------------------------------------------------------
function str = LocalGetCommonHeader(option)
% Determine heading to display.

switch lower(option.SearchMethod)
    case 'gn'
        str = 'Gauss-Netwon line search';
    case 'gna'
        str = 'Adaptive Gauss-Netwon line search (Wills-Ninness)';
    case 'lm'
        str = 'Levenberg-Marquardt line search';
    case 'grad'
        str = 'Gradient-descent line search';
    case 'auto'
        str = 'Nonlinear least squares with automatically chosen line search method';
    otherwise
        str = 'Nonlinear least squares (line search)';
end
str = ['   Scheme: ',str];

if strcmpi(option.Criterion,'det')
    str = sprintf('Criterion: Determinant minimization\n%s',str);
else
    str = sprintf('Criterion: Trace minimization\n%s',str);
end

end