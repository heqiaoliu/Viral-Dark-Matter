function Z = retrend(Zd,Tr)
%RETREND Add trend to data.
%   Z = RETREND(Zd, Tr) adds signal offsets or linear trends as specified
%   in the TrendInfo object Tr to the time-domain data Z. RETREND performs
%   the reverse operation of DETREND. Signals removed from data using the
%   DETREND function can be reapplied to data using RETREND.
%
%   Note that the trend removed from data (data mean or linear trend) can be
%   retrieved using the second output argument of the DETREND function.
%
%   Example:
%   Suppose Dat is an IDDATA object containing I/O signals (2 input, 1
%   output) with following offsets:
%       Inputs: 12.5 Volts and 500 deg K respectively.
%       Output: 600 m/s.
%   For linear model identification, it is advisable to remove these
%   offsets from the data. Use the TrendInfo object to store these
%   offset levels and also remove them from data:
%       T = getTrend(Dat);
%       T.InputOffset  = [12.5 500];
%       T.OutputOffset = 600;
%       newDat = detrend(Dat, T);
%
%   To simulate a model that was estimated using newDat about the
%   existing operating point, use SIM and RETREND functions:
%       input = newDat(:,[],:)     %extract the input signal
%       ylin = sim(model, input);  %simulation about zero equilibrium
%       ytotal = retrend(ylin, T); %add output trend information
%
%   RETREND is not supported for frequency domain data. Set the
%   input/output signal values at frequency = 0 to the desired signal means
%   directly. For example if u0 and y0 are input and output data mean values
%   (respectively) to be added to SISO data Z, you may do:
%       fr0 = (Zd.Frequency==0);
%       Z.InputData(fr0)  = u0;
%       Z.OutputData(fr0) = y0;
%
%   See also idutils.TrendInfo, GETTREND, DETREND, IDFILT.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2008/10/31 06:11:12 $

error(nargchk(nargin,2,2))

[N,ny,nu,nexp] = size(Zd);
dom = Zd.Domain;

% data type check
if ~isa(Tr,'idutils.TrendInfo')
    ctrlMsgUtils.error('Ident:dataprocess:retrendCheck1')
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

if strcmpi(dom,'frequency')
    ctrlMsgUtils.error('Ident:dataprocess:retrendCheck2')
end

if nu==0 && ny==0
    % quick return for empty data object
    Z = Zd;
    return;
end

time = pvget(Zd,'SamplingInstants');
t0 = cellfun(@(x)x(1),time,'UniformOutput',false);
udat = Zd.InputData;
ydat = Zd.OutputData;

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
        udat{kexp} = udat{kexp} + bsxfun(@plus,uoff{TrInd(kexp)}, bsxfun(@times,(time{kexp}-t0{kexp}),uslope{TrInd(kexp)}));
    end
    if ny>0
        ydat{kexp} = ydat{kexp} + bsxfun(@plus,yoff{TrInd(kexp)}, bsxfun(@times,(time{kexp}-t0{kexp}),yslope{TrInd(kexp)}));
    end
end

name = inputname(1);
if ~isempty(name)
    note = sprintf('Data obtained by adding trend to data ''%s''.',name);
else
    note = 'Data obtained by adding trend.';
end

Z = pvset(Zd,'OutputData',ydat,'InputData',udat,'Notes',note);
