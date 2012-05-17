function varargout = simCompare(simout,sys,in,varargin)
% SIMCOMPARE compares the simulation results SIMOUT against the linear
% simulation of SYS with the input signal IN.
%
%   frest.simCompare(simout,sys,in) compares the simulation results simout
%   against the linear simulation results of simulating sys with input
%   signal in. The linear simulation results will be offset by the initial
%   output value(s) in the simout data.
%
%   frest.simCompare(simout,sys,in,x0) compares the simulation results simout
%   against the linear simulation results of simulating sys with input
%   signal in and initial state x0. As initial state is provided, the
%   linear simulation result will not be offset by the initial output
%   value(s) in the simout data.
%   
%   [y,t] = frest.simCompare(simout,sys,in) returns the linear simulation
%   output, y, of the system sys against the input signal in and the time
%   vector t. No plot is drawn on the screen.  The matrix y has length(t)
%   rows and as many columns as outputs in sys.  For state-space models, 
%      [y,t,x] = frest.simCompare(simout,sys,in,x0) 
%   also returns the state trajectory x, a matrix with length(t) rows and
%   as many columns as states, using the initial condition x0.
%
%   See also frestimate, frest.simView

%  Author(s): Erman Korkut 23-Mar-2009
%  Revised:
%  Copyright 2003-2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2009/12/05 02:33:30 $

% Error checking
% Check number of input & output arguments
error(nargchk(3,4,nargin));
no = nargout;
error(nargoutchk(0,3,no));
% Simout should be a cell array of Simulink.Timeseries objects.
if ~iscell(simout)
    ctrlMsgUtils.error('Slcontrol:frest:SimCompareSimoutNotCellArrayOfSimulinkTs') 
end
type = cellfun(@class,simout,'UniformOutput',false);
if ~all(strcmp('Simulink.Timeseries',type(:)))
    ctrlMsgUtils.error('Slcontrol:frest:SimCompareSimoutNotCellArrayOfSimulinkTs') 
end
% In should be one of the offered types or a MATLAB timeseries
if ~(isa(in,'timeseries') || isa(in,'frest.Sinestream') ||...
        isa(in,'frest.Chirp') || isa(in,'frest.Random'))
    ctrlMsgUtils.error('Slcontrol:frest:SimCompareInvalidInput')     
end

% sys should be a single model if outputs are requested.
syssize = size(sys);
nsys =  prod(syssize(3:end));
gridsize = syssize(1:2);
if (no > 0) && (nsys > 1)
    ctrlMsgUtils.error('Slcontrol:frest:SimCompareRequiresSingleModelWithOutputArgs')
end

% Parse input arguments
x0 = [];
% Initial condition
if nargin > 3 && isa(sys,'ss')
    % Check that each system in the array has the same number of states
    if numel(unique(order(sys))) > 1
        ctrlMsgUtils.error('Slcontrol:frest:SimCompareOrderMismatchInLTIArray')
    end
    x0 = varargin{1};
end
src = frestviews.SimcompareSource;
flatoutput = frest.frestutils.flattenSimulationOutput(simout,LocalFindNumSamples(in));
src.Output = flatoutput;
src.Input = in;

% Check that there are as many samples in the output as in the input
if isa(in,'timeseries')
    insig = in;
    numsamps = in.Length;
else
    insig = generateTimeseries(in);
    numsamps = insig.Length;
end

% If output arguments is specified, return before plotting
if no > 0
    [linear_y, linear_s] = LocalRunLinearSimulation(sys,src,in,insig,numsamps,x0);
    varargout{1} = linear_y;
    if no > 1 
            varargout{2} = insig.Time(:);
        if no > 2
            if isa(sys,'ss')
                varargout{3} = linear_s;
            else
                varargout{3} = [];                
            end
        end
    end      
    return;
end

for ct = 1:numel(src.Output)
    if numsamps ~= numel(src.Output{ct}.Time)
        ctrlMsgUtils.error('Slcontrol:frest:SimCompareInputOutputSizeMismatch'); 
    end
end

% Assign variable name to system if it does not have a name
if isempty(sys.Name)
    inname = inputname(2);
    if ~isempty(inname)
        sys.Name = inname;
    else
        sys.Name = 'untitled';        
    end
end

% Create plot in the current axis
p = frestviews.SimcomparePlot(gca,sys,gridsize);

% Create the response that will show the nonlinear results
p.addresponse;
% Set data source and function
p.Responses(end).DataSrc = src;
p.Responses(end).DataFcn = {'getTimeData' src ...
    [1 numsamps] p.Responses(end) gridsize};
p.Responses(end).Name = ctrlMsgUtils.message('Slcontrol:frest:ResponseName',...
    frest.frestutils.getInputTypeString(src.Input));
% Add DC characteristic
p.Responses(end).addchar('InitialOutput','resppack.TimeInitialValueData', 'resppack.TimeFinalValueView');
% Set characteristics DataFcn
c = p.Responses(end).Characteristics;
c.DataFcn = {'getInitialOutput' c.Data c gridsize src.Output};

% Run linear simulations and add their responses
for ct=1:nsys
    thisSys = sys(:,:,ct);
    if ~isempty(thisSys) % skip empty systems
        src = frestviews.SimcompareSource;
        src.Input = in;
        src.Output = flatoutput;
        % Run linear simulation
        [linear_y, ~] = LocalRunLinearSimulation(thisSys,src,in,insig,numsamps,x0);
        src.LinearOutput = linear_y;
        % Add response for linear simulation
        p.addresponse;
        p.Responses(end).DataSrc = src;
        p.Responses(end).DataFcn = {'getLinearTimeData' src ...
            [1 numsamps] p.Responses(end) gridsize};
        % Add system name (and index if LTI array)
        if length(syssize)<3
            astr = '';
        elseif all(syssize(4:end)==1)
            astr = sprintf('(:,:,%d)',ct);
        else
            asize = syssize(3:end);
            aindex = cell(1,length(asize));
            [aindex{:}] = ind2sub(asize,ct);
            astr = sprintf(',%d',aindex{:});
            astr = sprintf('(:,:%s)',astr);
        end
        systemstr = sprintf('%s%s',thisSys.Name,astr);
        p.Responses(end).Name = ctrlMsgUtils.message('Slcontrol:frest:LinearResponseName',...
            systemstr,frest.frestutils.getInputTypeString(src.Input));        
    end
end

% Delete datatips when the axis is clicked
set(allaxes(p),'ButtonDownFcn',{@frest.frestutils.clearDataTips})

% Make the axes labels and title to be international friendly
p.AxesGrid.Title = ctrlMsgUtils.message('Controllib:plots:strTimeResponse');
p.AxesGrid.XLabel = ctrlMsgUtils.message('Controllib:plots:strTime');
p.AxesGrid.YLabel = ctrlMsgUtils.message('Controllib:plots:strAmplitude');

% Draw now
if strcmp(p.AxesGrid.NextPlot, 'replace')
    p.Visible = 'on';  % new plot created with Visible='off'
else
    draw(p)  % hold mode
end


% Set the hoverfig as the WindowButtonMotionFcn
fig = ancestor(p.AxesGrid.Parent,'figure');
if isempty(get(fig,'WindowButtonMotionFcn'))
    set(fig,'WindowButtonMotionFcn',@(x,y) hoverfig(fig));
end

% Right-click menus
% Use standart step plot menu
ltiplotmenu(p, 'step');
% Remove the items that do not apply
items = p.AxesGrid.UIContextMenu.Children;
set(items(strcmp('characteristics',get(items,'Tag'))),'Visible','off');


end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalRunLinearSimulation
%  Run the linear simulation and store output and states
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [linear_y, linear_s] = LocalRunLinearSimulation(sys,src,in,insig,numsamps,x0)
syssize = size(sys);
gridsize = syssize(1:2);
% Convert to state-space
sys_ss = ss(sys);
% Pre allocate output and states
linear_y = zeros(numsamps,gridsize(1),gridsize(2));
linear_s = zeros(numsamps,order(sys_ss),gridsize(2));
% Determine if many linear simulations are necesssary
[isManySim,isFollow] = LocalIsManyLinearSimNecessary(in);
for ctin = 1:gridsize(2)
    if ~isManySim
        linear_t = insig.Time(:);
        linear_u = zeros(numsamps,gridsize(2));
        % Set this channel's input
        linear_u(:,ctin) = insig.Data(:);
        % Run simulation
        [linear_y(:,:,ctin),~,linear_s(:,:,ctin)] = lsim(sys_ss,linear_u,linear_t,x0);
        % Adjust the offset if no initial condition is specified
        if isempty(x0)
            for ctout = 1:gridsize(1)
                linear_y(:,ctout,ctin) = linear_y(:,ctout,ctin)+src.Output{ctout,ctin}.Data(1);
            end
        end
    else
        % Sinestream input and many simulations are necessary
        output_ind = 1;
        x_init = x0;
        for ctsim = 1:numel(in.Frequency)
            insigthisfreq = frest.frestutils.pickFrequencyFromSinestream(in,ctsim,insig);
            linear_t = insigthisfreq.time(:);
            thisfreqLen = numel(linear_t);
            linear_u = zeros(thisfreqLen,gridsize(2));
            linear_u(:,ctin) = insigthisfreq.data(:);                        
            % Run simulation
            if ~isFollow
                [linear_y(output_ind:(output_ind+thisfreqLen-1),:,ctin),~,linear_s(output_ind:(output_ind+thisfreqLen-1),:,ctin)] = ...
                    lsim(sys_ss,linear_u,linear_t,x0);
                if isempty(x0)
                    for ctout = 1:gridsize(1)
                        linear_y(output_ind:(output_ind+thisfreqLen-1),ctout,ctin) = ...
                            linear_y(output_ind:(output_ind+thisfreqLen-1),ctout,ctin) + ...
                            src.Output{ctout,ctin}.Data(1);
                    end
                end
                output_ind = output_ind+thisfreqLen;
            else
                [linear_y(output_ind:(output_ind+thisfreqLen-1),:,ctin),~,x] = lsim(sys_ss,linear_u,linear_t,x_init);
                linear_s(output_ind:(output_ind+thisfreqLen-1),:,ctin) = x;
                % Offset if initial condition was empty in the beginning
                if isempty(x0)
                    for ctout = 1:gridsize(1)
                        linear_y(output_ind:(output_ind+thisfreqLen-1),ctout,ctin) = ...
                            linear_y(output_ind:(output_ind+thisfreqLen-1),ctout,ctin)+...
                            src.Output{ctout,ctin}.Data(1);
                    end
                end
                % Write the last state as initial condition for next
                % iteration
                x_init = x(end,:);
                output_ind = output_ind+thisfreqLen;
            end
        end        
    end
end

end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalIsManyLinearSimNecessary
%  Determine a loop of linear simulations are necessary based on input
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [isManySim,isFollow] = LocalIsManyLinearSimNecessary(in)
isManySim = false;
isFollow = false;
if ~isa(in,'frest.Sinestream')
    return;
else
    % Sinestream signal
    switch in.SimulationOrder
        case 'Sequential'
            if in.FixedTs == -2
                isManySim = true;
                isFollow = true;
            end
        case 'OneAtATime'
            numFreq = numel(in.Frequency);
            if ~isequal(numFreq,1)
                isManySim = true;
            end                
    end
end
end

function numsamps = LocalFindNumSamples(in)
if isa(in,'timeseries')
    numsamps = in.Length;
else
    ts = in.generateTimeseries;
    numsamps = ts.Length;
end
end


    













