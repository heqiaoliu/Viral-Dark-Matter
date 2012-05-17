function g = etfe(data,M,N,T)
%ETFE   Computes the Empirical Transfer Function Estimate and Periodogram.
%   G = ETFE(DATA)   or   G = ETFE(DATA,M)
%
%   DATA is an IDDATA object and contains the input-output data or a time series.
%   See HELP IDDATA. If an input is present G is returned as the ETFE
%   (the ratio of the output Fourier transfor to the input Fourier transform)
%   for the data. For a time series  G is returned as the periodogram
%   (the normed absolute square of the Fourier transform) of the data.
%   G is returned as an IDFRD object. See HELP IDFRD.
%
%   With M specified, a smoothing operation is performed on the raw spectral
%   estimates using a Hamming Window, giving a frequency resolution of
%   about pi/M. Default, M = [], gives no smoothing.
%
%   For non-periodic data, the transfer function is estimated at 128 equally
%   spaced frequencies between 0 (excluded) and pi. This number can be changed
%   to N  by   G = ETFE(DATA,M,N).
%
%   PERIODIC DATA: If the (input) data is marked as periodic (DATA.Period = integer)
%   and contains an integer number of periods, the frequency response is computed
%   at the frequencies k*2*pi/period for k=0 up to the Nyquist frequency.
%   To compute the spectrum of a periodic signal S, it must be an input signal:
%   DATA = iddata([],S,'Ts',Ts,'Period',per). For periodic data, the arguments N and
%   M are ignored.
%
%   FREQUENCY DOMAIN DATA: If the data set is defined in the frequency domain, G is
%   returned as an IDFRD object, defined from the ratio of output to input at
%   all frequencies, where the input is non-zero. If M is defined, the corresponding
%   smoothing is applied.

%   See also IDFRD, BODE, NYQUIST, FFPLOT and SPA.

%   L. Ljung 7-7-87
%   Revised 3-8-89, 4-20-91
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.25.4.12 $ $Date: 2008/12/29 02:07:20 $

error(nargchk(1,4,nargin,'struct'))

%   The frequency function can be plotted by BODE, FFPLOT and NYQUIST.
%       Some initial checks on the arguments

if nargin<4,
    T=[];
end,
if nargin<3
    N = [];
end
if nargin<2,
    M=[];
end
if isa(data,'frd'), data = idfrd(data);end
if isa(data,'idfrd')
    data = iddata(data);
end
flipyu = 0;
if ~isa(data,'iddata')
    if isa(data,'double')
        [Ncap,nz] = size(data);
        if nz>2,
            ctrlMsgUtils.error('Ident:estimation:etfeNonSISO')
        end
        if isempty(T),T=1;end
        if nz==2
            data = iddata(data(:,1),data(:,2),T);
        else
            data = iddata(data,[],T);
        end
    else
        ctrlMsgUtils.error('Ident:estimation:etfeDataRequired')
    end
end

dom = pvget(data,'Domain');
if strcmp(dom,'Frequency')
    % First we concantenate multiexperiment data
    [dum,ny,nu,nexp] = size(data);
    if nexp>1
        dat = getexp(data,1);
        for kexp = 2:nexp
            dat = [dat;getexp(data,kexp)];
        end
    else
        dat = data;
    end
    
    if isempty(N)
        N=pvget(dat,'Radfreqs'); %%LL to be discussed
        N = N{1};
    end
    nam = pvget(data,'Name');
    if isempty(nam)
        nam = inputname(1);
        dat = pvset(dat,'Name',nam);
    end
    if isempty(M)
        res = 0;
    else
        fre = pvget(dat,'Radfreqs');
        mx = max(fre{1});
        res = pi*mx/M;
    end
    g = spafdr(dat,res,N);
    es = pvget(g,'EstimationInfo');
    es.Method = 'ETFE';
    g = pvset(g,'EstimationInfo',es);
    return
end
[ze,Ne,ny,nu,T,Name,Ncaps,errflag] = idprep(data,0,inputname(1));
if ~isempty(errflag.message), error(errflag), end
if ~isempty(Name), data.Name = Name; end

per = pvget(data,'Period');
empI = cellfun('isempty',per);
if any(empI)
    per{empI} = inf(max(nu,ny),1);
end

per = [per{:}];

%{
for kexp = 1:Ne
    if isempty(per{kexp})
        per{kexp} = inf(max(nu,ny),1);
    end
    pertest(:,kexp) = per{kexp};
end
%}

if length(unique(per(:)))~=1
    ctrlMsgUtils.warning('Ident:estimation:etfeNonUniquePeriods')
    Period = false;
else
    Period = ~isinf(per(1));
    if Period && fix(Ncaps(1)/per(1))~=(Ncaps(1)/per(1))
        ctrlMsgUtils.warning('Ident:estimation:etfePartialPeriods')
        Period = false;
    end
end

per = per(1);
if Period
    resp = [];
    spe = [];
end

if isempty(N)
    if ~Period
        N = 128;
    else
        N =  per;
    end
end

if ny==0 || nu==0
    Yd = zeros(N,max(ny,nu));
    resp = [];
else
    
    Yd = zeros(N,ny,nu);
    Ud = zeros(N,nu);
end

for kexp = 1:Ne
    Ncap = Ncaps(kexp);
    y = ze{kexp}(:,1:ny);
    u = ze{kexp}(:,ny+1:nu+ny);
    nfft = 2*ceil(Ncap/N)*N;
    l = nfft;
    if M<0,
        M = l;
    end
    if isempty(M),
        M = l;
    end
    M = M/2; % this is to make better agreement with SPA.
    M1 = fix(l/M);sc=l/(2*N);
    if ny==0
        ny = nu; y = u;
        u = []; nu = 0;
        flipyu = 1;
    end
    if Period
        [resp1,spe1,freqs] = etfeper(y,u,per,T);
        if isempty(resp)
            resp = resp1*Ncap;
        else
            resp = resp + resp1*Ncap;
        end
        if isempty(spe)
            spe = spe1*Ncap;
        else
            spe = spe +spe1*Ncap;
        end
    else
        freqs = (1:N)'*pi/N/T;
        if nu==0
            Y = abs(fft(y,nfft,1)).^2*T;
            if M1>1,
                ha = .54 - .46*cos(2*pi*(0:M1)'/M1);
                ha = ha/(norm(ha)^2);
                Y = [Y(l-M1+2:l,:);Y];
                Y = filter(ha,1,Y);
            end
            Yd = Yd + Y(M1+fix(M1/2)+sc:sc:M1+fix(M1/2)+l/2,:);
        else
            Y = fft(y,nfft,1);
            U = fft(u,nfft,1);
            Y = [Y(l-M1+2:l,:);Y];
            U = [U(l-M1+2:l,:);U];
            for ky = 1:ny
                for ku = 1:nu
                    Y1(:,ky,ku) = Y(:,ky).*conj(U(:,ku));
                end
            end
            Y = Y1; clear Y1; %Y.*conj(U);
            U = abs(U).^2;
            if M1>1
                ha = .54 - .46*cos(2*pi*(0:M1)'/M1);
                ha = ha/(norm(ha)^2);
                Y = filter(ha,1,Y);
                U = filter(ha,1,U);
            end
            Yd = Yd+Y(M1+fix(M1/2)+sc:sc:M1+fix(M1/2)+l/2,:,:);
            Ud = Ud+U(M1+fix(M1/2)+sc:sc:l/2+M1+fix(M1/2),:);
        end
    end % if period
end % over kexp
if Period
    resp = resp/sum(Ncaps);
    spe = spe/sum(Ncaps);
else
    if nu == 0
        resp = [];
        spe=zeros(ny,ny,N);
        for ky = 1:ny
            spe(ky,ky,:) = Yd(:,ky)/sum(Ncaps);
        end
    else
        spe =[];
        for ky=1:ny
            for ku=1:nu
                zer = find(abs(Ud(:,ku))==0);
                Ud(zer,ku) = ones(length(zer),1);
                resp(ky,ku,:) =  Yd(:,ky,ku)./Ud(:,ku);
                resp(ky,ku,zer)=inf*ones(length(zer),1);
            end
        end
    end
end
g = idfrd(resp,freqs,[],'SpectrumData',spe,'Ts',T);
est = pvget(g,'EstimationInfo');
est.Status = 'Estimated model';
est.Method='ETFE';
mm = M*2;%getting back to the original M
if mm==l
    mm=[];
end
est.WindowSize = mm;
Nam = pvget(data,'Name');
if isempty(Nam), Nam = inputname(1);end
est.DataName = Nam;
est.DataLength=sum(Ncaps);
est.DataDomain = 'Time';
est.DataInterSample = pvget(data,'InterSample');
est.DataTs = get(data,'Ts');
if Period
    est.Period = per;
end
if flipyu
    yna = pvget(data,'InputName');
    yu = pvget(data,'InputUnit');
else
    yna = pvget(data,'OutputName');
    yu = pvget(data,'OutputUnit');
end
if isa(data,'iddata');
    if strcmpi(pvget(data,'Domain'),'time')
        TimeUnit = pvget(data,'TimeUnit');
        if isempty(TimeUnit),TimeUnit = 's';end
        Units = ['rad/',TimeUnit];
    else
        Units = get(data,'unit');
    end
else
    Units = 'rad/s';
end
was = warning('off'); [lw,lwid] = lastwarn;
g = pvset(g,'EstimationInfo',est,...
    'InputName',pvget(data,'InputName'),'OutputName',yna,...
    'InputUnit',pvget(data,'InputUnit'),'OutputUnit',yu,'Units',Units);
warning(was), lastwarn(lw,lwid)

%--------------------------------------------------------------------------
function [resp,spe,freqs] = etfeper(y,u,L,T)
per = L;
%[Ncap,nz]=size(z);
Ncap = size(y,1);
ml = Ncap/per;
resp = [];
spe = [];
if fix(per/2)==per/2 % even number
    frno = 1:per/2+1;
else
    frno = 1:(per+1)/2;
end
for ky=1:size(y,2)
    if ml>1
        y1 = sum(reshape(y(:,ky),L,ml).');
    else
        y1 = y;
    end
    Y = fft(y1);
    if size(u,2)==0
        spe(ky,ky,:) = abs(Y(frno).^2*T/Ncap);
    else
        for ku=1:size(u,2)
            u1 = sum(reshape(u(:,ku),L,ml).');
            U = fft(u1);
            frno = frno(abs(U(frno))>0.00001*max(abs(U)));
            resp(ky,ku,:) = (Y(frno)./U(frno)).';
        end
    end
end
freqs = ((frno-1)*2*pi/per/T)';
