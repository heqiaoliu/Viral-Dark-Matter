function [ymod] = step(varargin)
%STEP  Step response of IDMODELs and direct estimation from IDDATA sets.
%
%   STEP(MOD) plots the step response of the IDMODEL model MOD (either
%   IDPOLY, IDARX, IDSS or IDGREY).
%
%   STEP(DAT) estimates and plots the step response from the data set
%   DAT given as an IDDATA object. This does not apply to time series data.
%
%   For multi-input models, independent step commands are applied to each
%   input channel.
%
%   STEP(MOD,'sd',K) also plots the confidence regions corresponding to
%   K standard deviations.
%
%   STEP(MOD,'InputLevels',[U1;U2]) (or STEP(MOD,'ULEV',[U1;U2]))
%   gives a step from level U1 to level U2. For multiinput models the
%   levels may be different for different inputs, by letting the InpuLevel
%   matrix be 2-by-nu.
%
%   The time span of the plot is determined by the argument T: STEP(MOD,T).
%   If T is a scalar, the time from -T/4 to T is covered. For a
%   step response estimated directly from data, this will also show feedback
%   effects in the data (response prior to t=0).
%   If T is a 2-vector, [T1 T2], the time span from T1 to T2 is covered.
%   For a continuous time model, T can be any vector with equidistant values:
%   T = [T1:ts:T2] thus defining the sampling interval. For discrete time models
%   only max(T) and min(T) determine the time span. The time interval is modified to
%   contain the time t=0, where the input step occurs. The initial state vector
%   is taken as zero, even when specified to something else in MOD.
%
%   STEP(MOD1,MOD2,..,DAT1,..,T) plots the step responses of multiple
%   IDMODEL models and IDDATA sets MOD1,MOD2,...,DAT1,... on a single plot.
%   The time vector T is optional.  You can also specify a color, line style,
%   and markers for each system, as in
%      STEP(MOD1,'r',MOD2,'y--',MOD3,'gx').
%
%   When responses of multiple models/data are plotted together, InputLevel
%   (if specified) should be the column vector [U1;U2] (same levels for all
%   inputs) or have as many columns as the maximum number of inputs 
%   across all models/data objects.
%
%   When invoked with left-hand arguments and a model input argument
%      [Y,T,YSD] = STEP(MOD)
%   returns the output response Y and the time vector T used for
%   simulation.  No plot is drawn on the screen.  If MOD has NY
%   outputs and NU inputs, and LT=length(T), Y is an array of size
%   [LT NY NU] where Y(:,:,j) gives the step response of the
%   j-th input channel. YSD contains the standard deviations of Y.
%
%   For a DATA input MOD = STEP(DAT),  returns the model of the
%   step response, as an IDARX object. This can of course be plotted
%   using STEP(MOD). The calculation of the step response from data is based a 'long'
%   FIR model, computed with suitably prewhitened input signals. The order
%   of the prewhitening filter (default 10) can be set to NA by the
%   property/value pair  STEP( ....,'PW',NA,... ) appearing anywhere
%   in the input argument list.
%
%   NOTE: IDMODEL/STEP and IDDATA/STEP are adjusted to the use with
%   identification tasks. If you have CONTROL SYSTEM TOOLBOX and want
%   to access the LTI/STEP, use PLOT(MOD1,....,'step').

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.10.4.8 $  $Date: 2008/10/02 18:47:04 $

if nargin<1
    disp('Usage: STEP(Data/Model)')
    disp('       [Y,T,YSD] = STEP(Model,T).')
    disp('       YMOD = STEP(Data,T).')
    return
end

NA = [];
varargin = low(varargin);
kpf = find(strncmpi(varargin,'in',2)|strncmpi(varargin,'ul',2));
if ~isempty(kpf)
    if kpf == length(varargin)
        ctrlMsgUtils.error('Ident:analysis:stepCheck1')
    end
    ulevel = varargin{kpf+1};
    if ~all(isfinite(ulevel(:)))
        ctrlMsgUtils.error('Ident:analysis:stepCheck2')
    end
    if ~isa(ulevel,'double')
        ctrlMsgUtils.error('Ident:analysis:stepCheck1')
    end
end
kpf = find(strcmp(varargin,'pw'));
if ~isempty(kpf)
    if kpf == length(varargin)
        ctrlMsgUtils.error('Ident:analysis:stepCheck3')
    end
    NA = varargin{kpf+1};
    if ~isa(NA,'double')
        ctrlMsgUtils.error('Ident:analysis:stepCheck3')
    end
end
if isempty(NA)
    NA = 10;
end
T=[];
%First find desired time span, if specified. That is a double, not
%preceded by 'pw' or 'sd':
for j = 1:length(varargin)
    if isa(varargin{j},'double')
        if j==1
            ctrlMsgUtils.error('Ident:analysis:stepCheck4')
        end
        tst = varargin{j-1};
        if ischar(tst) && length(tst)>1 && any(strcmpi(tst(1:2),{'pw','sd','ul','il'}))
        else
            T = varargin{j};
        end
    end
end


for k1 = 1:length(varargin)
    if isa(varargin{k1},'iddata');
        dat = varargin{k1};
        if size(dat,'nu')==0
            ctrlMsgUtils.error('Ident:analysis:ImpulseStepTimeSeriesData')
        end
        break
    end
end

try
    ymod1 = impulse(dat,'PW',NA,T);
catch E
    % Replace impulse with step
     error(E.identifier,strrep(E.message,'impulse','step'))
end

if nargout == 0
    step(ymod1,varargin{2:end});
else
    ymod = ymod1;
end
% elseif nargout <= 2
%     [dum,tou] = step(ymod);
% else
%     [dum,tou,ysdou] = step(ymod);
%
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arg = low(arg)
for kk=1:length(arg)
    if ischar(arg{kk})
        arg{kk}=lower(arg{kk});
    end
end

