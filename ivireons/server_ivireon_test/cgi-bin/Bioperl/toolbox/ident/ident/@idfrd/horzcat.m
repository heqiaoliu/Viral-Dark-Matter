function sys1 = horzcat(varargin)
%HORZCAT  Horizontal concatenation of IDFRD models.
%
%   M = HORZCAT(M1,M2,...) performs the concatenation
%   operation
%         M = [M1 , M2 , ...]
%
%   This operation amounts to appending the inputs and
%   adding the outputs of the IDFRD models M1, M2,...
%   These models must then have the same number of outputs,
%   and be defined for the same frequencies.
%
%   SpectrumData will be ignored and M will contain no
%   SpectrumData.
%
%   See also IDFRD/VERTCAT.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $ $Date: 2008/10/02 18:47:20 $

%ni = nargin;
nl = length(varargin);
sys1 = varargin{1};
if nl == 1
    return
end
sys1.SpectrumData = [];
sys1.NoiseCovariance = [];

sys2 = varargin{2};
inpn = pvget(sys1,'InputName');
inpn2 = pvget(sys2,'InputName');
oldflag = 0;
if isempty(inpn) && isempty(inpn2)
    oldflag = 1;
end
for k = 1:length(inpn2)
    ls = strcmp(inpn,inpn2{k});
    if any(ls),
        oldflag = 1;
    end
end
if oldflag
    ctrlMsgUtils.warning('Ident:dataprocess:idfrdHorzcatCheck1')
    sys1 = varargin;
    return
end
Freqs = sys1.Frequency;
Unit = sys1.Units;
[Ny,Nu,Nf] = size(sys1.ResponseData);
for kj = 2:length(varargin)

    sysj = idfrd(varargin{kj});
    [ny,nu,nf] = size(sysj.ResponseData);
    if ny~=Ny && nu>0
        ctrlMsgUtils.error('Ident:dataprocess:idfrdHorzcatCheck2')
    end
    try
        [freq,units] = freqcheck(Freqs,Unit,sysj.Frequency,sysj.Units);
    catch E
        throw(E)
    end

    sys1.InputName = [sys1.InputName;sysj.InputName];
    sys1.InputUnit= [sys1.InputUnit;sysj.InputUnit];

    if ~all(strcmp(sys1.OutputName,sysj.OutputName)) ||...
            ~all(strcmp(sys1.OutputUnit,sysj.OutputUnit))
        ctrlMsgUtils.warning('Ident:dataprocess:idfrdHorzcatCheck3')
    end
    if sys1.Ts~=sysj.Ts
        ctrlMsgUtils.warning('Ident:dataprocess:idfrdConcatTs')
    end

    resp = sysj.ResponseData;
    cov = sysj.CovarianceData;
    Resp = sys1.ResponseData;
    Cov = sys1.CovarianceData;
    for ky = 1:Ny
        for ku = Nu+1:Nu+nu
            Resp(ky,ku,:) = resp(ky,ku-Nu,:);
            try
                Cov(ky,ku,:,:,:) = cov(ky,ku-Nu,:,:,:);
            end
        end
    end
    sys1.ResponseData = Resp;
    sys1.CovarianceData = Cov;
    sys1.InputDelay = [sys1.InputDelay;sysj.InputDelay];
end
