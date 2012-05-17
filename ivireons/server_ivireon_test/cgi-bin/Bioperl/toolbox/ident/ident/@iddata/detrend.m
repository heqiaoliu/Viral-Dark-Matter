function [zd, Tr] = detrend(z,Type,brp)
%DETREND Removes trends from data sets.
%
%   Removing Input/Output Signal Means and Linear Trends:
%       ZD = DETREND(Z)
%       ZD = DETREND(Z,Type,BREAKPOINTS)
%
%   Z is the data set to be detrended, organized with the data records as
%   column vectors. ZD is returned as the detrended data.
%
%   If Type = 0 (the default case) the sample means are removed from each of
%   the columns.
%
%   If Type = 1, linear trends are removed. A continuous, piecewise linear
%   trend is adjusted to each of the data records, and then removed. The
%   interior breakpoints for the linear trend segments are contained in
%   the row vector BREAKPOINTS. BREAKPOINTS are time sample numbers. The
%   default value is that there are no interior breakpoints, so that one
%   single straight line is removed from each of the data records. Note
%   that when break points are specified, Type must be 1. Same BREAKPOINTS
%   are used for all input and output signals. For multi-experiment data,
%   you may specify separate breakpoints for each experiment by using a
%   cell array of row vectors.
%
%   Fetching Information on Removed Trends:
%   [Zd, Tr] = DETREND(Z,...)
%   returns the removed trend as a TrendInfo object Tr. Tr stores the
%   removed means (when Type=0), in properties InputOffset and
%   OutputOffset. If linear trend is removed (Type=1), Tr contains the
%   constants defining the line in properties InputOffset, InputSlope,
%   OutputOffset and OutputSlope, such that the equations of the removed
%   lines, as a function of time are:
%   uLine = InputSlope*(time-t0) + InputOffset   %input data trend
%   yLine = OutputSlope*(time-t0) + OutputOffset %output data trend
%
%   where t0 is the start time.
%
%   Trend information cannot be returned if break points are specified.
%   Therefore, if DETREND is called with 3 input arguments, the number of
%   output arguments must be 1.
%
%   Removing Pre-specified Offsets:
%   Zd = DETREND(Z, Tr)
%   removes the signal offsets or linear trends as specified in the
%   TrendInfo object Tr. This allows removal of constants (offsets) and
%   lines that are not automatically derived from the data Z. This is
%   useful for removing offsets corresponding to physical equilibrium from
%   transient data (such as a step response, where offset is not signal
%   mean). Use the "getTrend" function to create the TrendInfo object and
%   specify the signal to be removed using its properties.
%
%   Example:
%   Suppose Dat is an IDDATA object containing I/O signals (2 input, 1
%   output) with following offsets:
%       Inputs: 12.5 Volts and 500 deg K respectively.
%       Output: 600 m/s.
%   Use the TrendInfo object to store these offset levels and also remove
%   them from data:
%       Tr = getTrend(Dat);
%       Tr.InputOffset  = [12.5 500];
%       Tr.OutputOffset = 600;
%       newDat = detrend(Dat, Tr);
%
%   Detrending Frequency Domain Data:
%   The only detrending option for frequency domain data is removal of data
%   mean (Type=0):
%   Zd = DETREND(Z,0); %remove zero frequency which represents data mean
%   A TrendInfo object cannot be provided as an input argument. Also, linear
%   trends cannot be removed.
%
%   See also idutils.TrendInfo, GETTREND, RETREND, IDFILT.

%   L. Ljung 7-8-87
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.4.4.7 $  $Date: 2008/12/04 22:33:43 $

ni = nargin;
no = nargout;
if ni < 2, Type = 0; end % Default is mean removal, unlike DETREND for double data.

% data must not contain missing samples
if isnan(z)
    ctrlMsgUtils.error('Ident:utility:missingData','detrend')
end

% Trend info cannot be returned if break points are specified
if ni>2 && no>1
    ctrlMsgUtils.error('Ident:dataprocess:noTrendInfoForBreakPts')
end

customT = false; %TrendInfo object specified
% If a TrendInfo object is specified as input, nargin must be 2.
if isa(Type,'idutils.TrendInfo')
    customT = true;
    if ni>2
        ctrlMsgUtils.error('Ident:dataprocess:detrendTrendInfoInput')
    end
    Tr = Type;
elseif ~isa(Type,'double') || ~any(Type==[0 1])
    ctrlMsgUtils.error('Ident:dataprocess:detrendcheck3');
end

[Nall,ny,nu,nexp] = size(z);
if ni<3
    brp = repmat({0},1,nexp);
elseif ni>2 && ~iscell(brp)
    brp = repmat({brp},1,nexp);
end
    
dataname = inputname(1);
if no>1 && ~customT
    Tr = idutils.TrendInfo(nu,ny,nexp);
end
Tr.DataName = dataname;

y = z.OutputData;
u = z.InputData;
zd = z;

if ~customT
    umean = cell(1,nexp); ymean = cell(1,nexp);
    if Type>0
        uslope = repmat({zeros(1,nu)},1,nexp);
        yslope = repmat({zeros(1,ny)},1,nexp);
    end
end

if strcmpi(z.Domain,'frequency')
    if customT
        % custom offset removal is no possible from frequency domain data
        ctrlMsgUtils.error('Ident:dataprocess:trendRemovalFreqData2')
    end
    
    if Type>0
        % linear trend cannot be removed from frequency domain data
        ctrlMsgUtils.error('Ident:dataprocess:trendRemovalFreqData1')
    end
    
    fr = z.SamplingInstants;
    for kexp = 1:nexp
        fr0 = find(fr{kexp}==0);
        if isempty(fr0)
            ctrlMsgUtils.warning('Ident:dataprocess:detrendcheck1')
        elseif numel(fr0)>1
            ctrlMsgUtils.error('Ident:dataprocess:detrendcheck2');
        end
        umean{kexp} = u{kexp}(fr0,:);
        ymean{kexp} = y{kexp}(fr0,:);
        y{kexp}(fr0,:) = zeros(1,ny);
        u{kexp}(fr0,:) = zeros(1,nu);
    end
    zd.InputData = u;
    zd.OutputData = y;
    
    if no>1
        if isempty(fr0)
            ctrlMsgUtils.error('Ident:dataprocess:detrendNoZeroFreqTrend');
        end
        Tr.InputOffset = umean;
        Tr.OutputOffset = ymean;
    end
    
    return
end

t = pvget(z,'SamplingInstants');
Ts = pvget(z,'Ts');

if ~customT
    yd = cell(size(y));
    ud = cell(size(u));
    for kexp = 1:length(y)
        z1 = [y{kexp} u{kexp}];
        bp = brp{kexp};
        N = Nall(kexp);
        if ~isempty(Ts{kexp}) || Type==0
            if nargin < 3
                z1d = detrend(z1,Type);
            else
                z1d = detrend(z1,Type,bp);
            end
            
            if no>1
                % store trend info
                umean{kexp} = z1(1,ny+1:end)-z1d(1,ny+1:end);
                ymean{kexp} = z1(1,1:ny)-z1d(1,1:ny);
                if Type>0 && N>1
                    dT = Ts{kexp};
                    uslope{kexp} = (z1(2,ny+1:end)-z1d(2,ny+1:end)-umean{kexp})/dT;
                    yslope{kexp} = (z1(2,1:ny)-z1d(2,1:ny)-ymean{kexp})/dT;
                end
            end
        else
            % non-uniformly sampled data with Type=1
            tim = t{kexp}-t{kexp}(1); %so that time starts at zero
            allbp = unique([0;bp(:);N-1]);
            lb = length(allbp)-1;
            R = [zeros(N,lb),ones(N,1)];
            
            for k = 1:lb
                if k==1
                    offset = 0;
                else
                    offset = tim(allbp(k));
                end
                R(allbp(k)+1:end,k) = tim(allbp(k)+1:end)-offset;
            end
            
            LinInfo = R\z1;
            z1d = z1-R*LinInfo;
            
            if no>1 %never true for the case where breakpoints are specified
                uslope{kexp} = LinInfo(1,ny+1:end);
                yslope{kexp} = LinInfo(1,1:ny);
                umean{kexp} = LinInfo(2,ny+1:end);
                ymean{kexp} = LinInfo(2,1:ny);
            end
            
        end
        
        yd{kexp} = z1d(:,1:ny);
        ud{kexp} = z1d(:,ny+1:end);
    end
    
    zd = pvset(z,'OutputData',yd,'InputData',ud);
    
    if no>1
        Tr.InputOffset = umean;
        Tr.OutputOffset = ymean;
        if Type>0
            Tr.InputSlope = uslope;
            Tr.OutputSlope = yslope;
        end
    end
else
    % Remove custom offsets and lines
    
    if nu==0 && ny==0
        % quick return for empty data object
        zd = z;
        return;
    end
    
    % dimensions check
    nexpt = 1;
    uoff = Tr.InputOffset;
    yoff = Tr.OutputOffset;
    if iscell(uoff)
        nexpt = numel(uoff);
        nut = numel(uoff{1});
    else
        nut = numel(uoff);
    end
    
    if nexpt>1
        nyt = numel(yoff{1});
    else
        nyt = numel(yoff);
    end
    
    if nu~=nut && nu~=0
        ctrlMsgUtils.error('Ident:dataprocess:trendCheck1y')
    end
    
    if ny~=nyt && ny~=0
        ctrlMsgUtils.error('Ident:dataprocess:trendCheck1y')
    end
    
    if nexp~=nexpt && nexpt~=1
        ctrlMsgUtils.error('Ident:dataprocess:trendCheck2')
    end
    
    
    t0 = cellfun(@(x)x(1),t,'UniformOutput',false);
    uslope = Tr.InputSlope;
    yslope = Tr.OutputSlope;
    TrInd = 1:nexpt;
    if nexpt==1
        if nexp>1
            %allow scalar expansion
            TrInd = ones(1,nexp);
        end
        uoff = {uoff}; yoff = {yoff}; uslope = {uslope}; yslope = {yslope};
    end
    
    for kexp = 1:nexp
        if nu>0
            u{kexp} = u{kexp} - bsxfun(@plus,uoff{TrInd(kexp)}, bsxfun(@times,(t{kexp}-t0{kexp}),uslope{TrInd(kexp)}));
        end
        
        if ny>0
            y{kexp} = y{kexp} - bsxfun(@plus,yoff{TrInd(kexp)}, bsxfun(@times,(t{kexp}-t0{kexp}),yslope{TrInd(kexp)}));
        end
    end
    zd = pvset(z,'OutputData',y,'InputData',u);
end
