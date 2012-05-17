function datf = ifft(dat)
%IDDATA/IFFT Compute IFFT of frequency domain IDDATA signals.
%
%   DATI = IFFT(DAT) converts the frequency domain IDDATA signal to the
%   time domain data using IFFT and sorting the data with respect to
%   frequencies. 
%
%   The frequency domain data should be defined for equally spaced
%   frequency points, stretching from frequency 0 to the Nyquist frequency: 
%       DAT.Frequency = [0:df:F], where df = 2*pi/(N*DAT.Ts) and F =
%       pi/DAT.Ts if N is odd and F = pi/DAT.Ts * (1- 1/N) if N is even
%       (N = number of frequencies). 
%
%   For complex data, the frequency vector must be symmetric about the
%   origin. 
%   
%   Converting continuous-time data:
%   If DAT.Ts is zero, the Nyquist frequency is assumed to be equal to the
%   largest frequency value in the data (Nf = max(DAT.Frequency)). If
%   Nyquist frequency is greater than this value, extend the I/O signals in
%   DAT manually to Nyquist frequency by zero-padding:
%       ynew = [DAT.y; zeros(N,ny)];
%       unew = [DAT.u; zeros(N,nu)];
%       freq = linspace(0,Nf,size(DAT,1)+N)
%       DAT = set(DAT, 'input', unew, 'output', ynew, 'frequency', freq);
%       (N is number of frequency samples required to extend the values to
%       Nyquist frequency Nf.) 
%
%   See also FFT.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.10.4.7 $ $Date: 2009/04/21 03:22:10 $

if strcmpi(dat.Domain,'time')
    ctrlMsgUtils.error('Ident:dataprocess:ifftDataDomain')
end

if isempty(dat)
    datf = dat;
    datf.Domain = 'Time';
    return
end

dat = chgunits(dat,'rad/s');
datf = dat;
y = dat.OutputData;
u = dat.InputData;
fre = dat.SamplingInstants;
ts = dat.Ts;
erid = 'Ident:dataprocess:ifftFreqVector';
ermsg = ctrlMsgUtils.message(erid);

Ne = length(y);
Y = cell(1,Ne);
U = cell(1,Ne);
for kexp = 1:Ne
    N = size(y{kexp},1);
    if N>1
        fre1 = fre{kexp};
        Ts = ts{kexp};
        if Ts>0
            Nf = pi/Ts;
        else
            Nf = max(fre1);
            ts{kexp} = pi/Nf;
        end
        
        %TEST if IFFT can be applied: first and last frequency, and equal step
        
        df = diff(fre1);
        ddf = diff(df);
        fnr = max(abs(fre1));
        % 1. Equal frequency sampling:
        if max(abs(ddf))/fnr>0.0001
            error(erid,ermsg);
        end
        N = length(fre1);
        % 2. frequency zero must be included:
        n0 = find(abs(fre1)<df(1)/1000);
        if isempty(n0)
            error(erid,ermsg)
        end
        
        % Any negative frequencies must be matched by the same positive
        % ones
        kt = find(fre1<0);
        if ~isempty(kt)
            compl = 1;
            if norm( fre1( n0+(kt(end):-1:kt(1)) ) + fre1(kt) )> fnr/10000
                error(erid,ersmg)
            end
        else
            compl = 0;
        end
        % compute the length of the original sequence
        if compl
            No = N;
        else
            if (abs(fre1(end)-Nf)<0.0001*fnr)
                No = 2*N-2;
            elseif  (abs(fre1(end)-Nf*(1-1/(2*N-1)))<0.0001*fnr)
                No = 2*N-1;
            else
                error(erid,ermsg)
            end
        end
        if ~compl %Real time domain data
            if  fix(No/2)==No/2
                Y{kexp} = real(ifft([y{kexp};conj(y{kexp}(end-1:-1:2,:))],[],1));
                U{kexp} = real(ifft([u{kexp};conj(u{kexp}(end-1:-1:2,:))],[],1));
            else
                Y{kexp} = real(ifft([y{kexp};conj(y{kexp}(end:-1:2,:))],[],1));
                U{kexp} = real(ifft([u{kexp};conj(u{kexp}(end:-1:2,:))],[],1));
            end
        else
            Y{kexp} = ifft([y{kexp}(n0:end,:);y{kexp}(1:n0-1,:)],[],1);
            U{kexp} = ifft([u{kexp}(n0:end,:);u{kexp}(1:n0-1,:)],[],1);
            if realdata(dat)
                Y{kexp} = real(Y{kexp});
                U{kexp} = real(U{kexp});
            end
        end
        datf.SamplingInstants{kexp} = [];
        datf.Tstart{kexp} = [];
        sqN = sqrt(size(Y{kexp},1));
        Y{kexp} = sqN*Y{kexp};
        U{kexp} = sqN*U{kexp};
    else % N=1
        Y{kexp} = y{kexp};
        U{kexp} = u{kexp};
        datf.Tstart{kexp} = [];
    end
end
datf.InputData = U;
datf.OutputData = Y;
datf.Ts = ts;
datf.Domain = 'Time';

% reset name, notes, userdata
datf.Name = ''; 
datf.Notes = {};
datf.UserData = [];

% set time mark
datf = timemark(datf,'c');
