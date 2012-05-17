function plot(varargin)
%PLOT plots input/output nonlinearity and linear responses for
%Hammerstein-Wiener (IDNLHW) models.
%
% The plot window shows a block diagram representation of the IDNLHW
% model:
%
%       [ U_NL ] ----> [ Linear Block ] ----> [ Y_NL ]
%
%   Navigate the various plots by clicking on one of the three blocks:
%   U_NL: Input nonlinearity plots
%   Linear Block: Step, impulse, bode and pole-zero plots of linear block.
%   Y_NL: Output nonlinearity plots.
%
%   PLOT(MODEL) creates a plot window for idnlhw object MODEL.
%
%   PLOT(M1,M2,M3,..) plots the responses of multiple models M1, M2, M3..
%
%   PLOT(M1,S1, M2,S2, ...) allows specifications of linestyle as a
%   character string (S1 for model M1, S2 for model M2 etc). Example:
%   plot(model1,'b-', model2,'r*', model3,'c-.')
%
%   PLOT(M1,S1, M2,S2, M3,S3,...,PVPairs) allows specification of
%   property-value pairs to modify the plot properties.
%
%   PV Pairs supported:
%     NumberOfSamples: Number of data points used for the input regressors
%     when evaluating the nonlinearities at individual input or output
%     channels. Default: 100. This property does not affect the plots of
%     the linear block (step, bode,..).
%
%     InputRange: Range ([min, max]) of regressor values to use when
%     evaluating the nonlinearities at each input channel. 'uRange' may be
%     used as a shortcut name for this property. Default: the range of
%     regressor values used during each model's estimation.
%
%     OutputRange: Range ([min, max]) of regressor values to use when
%     evaluating the nonlinearities at each output channel. 'yRange' may be
%     used as a shortcut name for this property. Default: the range of
%     regressor values used during each model's estimation.
%
%     Time: The time samples at which the transient responses (step and
%     impulse) of the linear block of the idnlhw model must be computed.
%     This property takes the same values as a STEP plot of the model. By
%     default, each model's dynamics determine the time samples used. It
%     may be specified as:
%           A positive scalar: denotes end time for transient responses
%           of all models (e.g.: 10).
%           A [min, max] range: a vector with two entries specifies the
%           time-interval over which the transient response must be
%           computed (e.g.: [0 10]).
%           A vector of time instants: a double vector of equi-sampled
%           values denotes the time samples at which the
%           transient response must be computed (e.g.: [0:0.1:10]).
%
%     Frequency: Frequencies at which the bode response must be computed for
%     the linear block of the models. By default, the response is computed
%     at some automatically chosen frequencies inside the Nyquist frequency
%     range. This property takes the same values as the IDMODEL/BODE
%     method. It may be specified as:
%           W = {Wmin, Wmax}: frequency interval between Wmin and Wmax (in
%           units rad/(model.TimeUnit)) is covered, using logarithmically
%           placed points. With W = {Wmin,Wmax,NP}, the frequency vector
%           uses NP points.
%           W = vector of non-negative frequency values allows
%           computation of bode response at those frequencies.
%
%           Note: Frequencies above Nyquist frequency (pi/model.Ts) are
%           ignored.
%
%     Examples:
%     plot(model1,'b-', model2, 'g', 'num',50,'time',10,'urange',[-2 2]);
%     plot(mod1, mod2,'time',[1 500],'freq',{0.01,10,100},'yrange',[0 1000]);
%
%   The plot illustrates Mi.OutputNonlinearity and/or Mi.InputNonlinearity,
%   which is the static nonlinearity at the output and/or at the input. It
%   also shows the responses of the embedded linear block, obtained by
%   using the LinearModel property. By default, a STEP plot is shown.
%   Note that the step plot of the linear block (same as
%   step(idnlhw_model.LinearModel)) is not same as the step plot of the
%   IDNLHW model itself (same as step(idnlhw_model)). Other plot types
%   available for the linear block are: BODE, IMPULSE and POLE-ZERO MAP.
%   Click on the blocks in the diagram at the top and use the popup menus
%   to navigate the various views.
%
%   See also idnlarx/plot, idnlmodel/step, idmodel/step, idmodel/bode,
%   idmodel/pzmap, evaluate.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.8 $ $Date: 2008/10/02 18:54:18 $

v = varargin;

% number of samples
indN = find(strncmpi(v, 'n', 1));
N = 100;
if ~isempty(indN)
    if numel(indN)>1
        ctrlMsgUtils.error('Ident:general:multipleSpecForOpt','NumberOfSamples','plot')
    end
    if (nargin==indN) || ~isposintscalar(v{indN+1})
        ctrlMsgUtils.error('Ident:general:PosIntOptionValue','NumberOfSamples','plot','idnlhw/plot')
    end
    N = v{indN+1};
    
    % remove indices for PVpair from v
    v(indN:indN+1) = [];
end

% input range
indU = find(strncmpi(v, 'ur', 2) | strncmpi(v, 'in', 2));
uRange = [];
if ~isempty(indU)
    if numel(indU)>1
        ctrlMsgUtils.error('Ident:general:multipleSpecForOpt','InputRange','plot')
    end
    
    if (nargin==indU)
        ctrlMsgUtils.error('Ident:plots:minMaxPropVal','InputRange','plot')
    else
        uRange = v{indU+1};
        if ~isrealrowvec(uRange) || any(~isfinite(uRange))  || (numel(uRange)~=2) || (uRange(1)>=uRange(2))
            ctrlMsgUtils.error('Ident:plots:minMaxPropVal','InputRange','plot')
        end
    end
    
    % remove indices for PVpair from v
    v(indU:indU+1) = [];
end

% output range
indY = find(strncmpi(v, 'yr', 2) | strncmpi(v, 'ou', 2));
yRange = [];
if ~isempty(indY)
    if numel(indY)>1
        ctrlMsgUtils.error('Ident:general:multipleSpecForOpt','OutputRange','plot')
    end
    if (nargin==indY)
        ctrlMsgUtils.error('Ident:plots:minMaxPropVal','OutputRange','plot')
    else
        yRange = v{indY+1};
        if ~isrealrowvec(yRange) || any(~isfinite(yRange)) || (numel(yRange)~=2) || (yRange(1)>=yRange(2))
            ctrlMsgUtils.error('Ident:plots:minMaxPropVal','OutputRange','plot')
        end
    end
    
    % remove indices for PVpair from v
    v(indY:indY+1) = [];
end

% Time
indT = find(strncmpi(v, 't', 1));
T = [];
if ~isempty(indT)
    if numel(indT)>1
        ctrlMsgUtils.error('Ident:general:multipleSpecForOpt','Time','plot')
    end
    if (nargin==indT)
        ctrlMsgUtils.error('Ident:plots:timeValFormat')
    else
        T = v{indT+1};
        if ~all(isfinite(T)) || ~(isposrealscalar(T) || (isrealrowvec(T) && all(diff(T)>0)))
            ctrlMsgUtils.error('Ident:plots:timeValFormat')
        elseif numel(T)>1
            Tsdemand = T(2)-T(1);
            if ~all(abs(diff(T)-Tsdemand)<Tsdemand/1000)
                ctrlMsgUtils.error('Ident:plots:invalidTimeSampling')
            end
        end
    end
    
    % remove indices for PVpair from v
    v(indT:indT+1) = [];
end


% Frequency
indF = find(strncmpi(v, 'f', 1));
W = [];
if ~isempty(indF)
    if numel(indF)>1
        ctrlMsgUtils.error('Ident:general:multipleSpecForOpt','Frequency','plot')
    end
    if (nargin==indF)
        ctrlMsgUtils.error('Ident:plots:freqValFormat')
    else
        W = v{indF+1};
        if iscell(W)
            try
                Wm = cell2mat(W);
                if numel(Wm)<2 || numel(Wm)>3 || ~all(isfinite(Wm)) || ~isrealvec(Wm) || Wm(1)>=Wm(2) || any(Wm<0)
                    ctrlMsgUtils.error('Ident:plots:freqValFormat')
                elseif numel(Wm)==3 && (~isposrealscalar(Wm(3)))
                    ctrlMsgUtils.error('Ident:plots:freqCellFormat')
                end
            catch
                ctrlMsgUtils.error('Ident:plots:freqValFormat')
            end
        elseif ~isfloat(W) || ~all(isfinite(W)) || ~isrealvec(W) || any(W<0) || any(diff(W)<0)
            ctrlMsgUtils.error('Ident:plots:invalidFreqVec')
        end
    end
    
    % remove indices for PVpair from v
    v(indF:indF+1) = [];
end

% Models
ind = 0;
dataobj = handle([]);
for k = 1:length(v)
    if isa(v{k},'idnlhw')
        ind = ind+1;
        LS = {};
        m = v{k};
        
        if ~isestimated(m)
            wname = inputname(k);
            if isempty(wname)
                wname = ['no. ',int2str(k)];
            else
                wname = ['''',wname,''''];
            end
            ctrlMsgUtils.warning('Ident:utility:nonEstimatedModel2',wname,'plot')
            continue;
        end
        
        if ~isempty(get(m,'Name'))
            modelname = get(m,'Name');
        else
            modelname = inputname(k);
        end
        if isempty(modelname)
            modelname = ['untitled',int2str(ind)];
        end
        % check linestyle string
        if k<length(v) && ischar(v{k+1})
            LS = v(k+1); %cell
        end
        
        dataobj(ind) = plotpack.nlhwdata(m,modelname);
        dataobj(ind).StyleArg = LS;
    end
end

if isempty(dataobj)
    ctrlMsgUtils.error('Ident:plots:noValidModels','IDNLHW')
end

plotobj = plotpack.idnlhwplot(dataobj,N);
plotobj.Range.Input = uRange;
plotobj.Range.Output = yRange;
plotobj.Time = T;
plotobj.Frequency = W;

% set initial plot
plotobj.showPlot;

set(plotobj.Figure,'vis','on','ResizeFcn',@(es,ed)plotobj.executeResizeFcn,...
    'HandleVisibility','callback');
set(plotobj.Figure,'userdata',plotobj);
