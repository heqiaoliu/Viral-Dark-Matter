function [KpC, wC, SignAtInf, zpkR1Func] = utPIDGetR1Continuous(Model,Type,PlotNeeded)
% Singular frequency based P/PI/PID Tuning sub-routine (Continuous).
%
% This function finds local minimums and maximums of r1(w)=-real{1/Model(jw)}.
% The corresponding frequencies are wC and KpC = r1(wC) defines Kp segments
% in which the number of unstable poles remain constant. 
%
% Input arguments
%   Model:      plant model
%   Type:       'p', 'pi', 'pid'
%
% Output arguments
%   KpC:        critical Kp values as r1(wC)
%   wC:         critical frequencies (where extremes of r1(w) occur)
%   SignAtInf:  sign of r1(w) at w=inf
%   zpkR1Func:  use real(freqresp(zpkR1Func,w)) or real(evalfr(zpkR1Func,j*w)) to obtain r1(w) 
%
% Note:
%   1. Model should not contain any differentiator
%   2. 0 is always a critical frequency (because of no differentiator in model) 
%   3. wC are sorted. 

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:10 $

% ------------------------------------------------------------------------
%% initialize output
sw = warning('off'); [lw,lwid] = lastwarn; %#ok<WNOFF>
KpC = []; wC = [];

% ------------------------------------------------------------------------
%% obtain r1(jw)=-real{1/G(jw)}
% if G is (bi)proper, r1 = -0.5/f where f = 1/(1/G + 1/G')
% if G is improper, r1 = -0.5f where f = 1/G + 1/G'
[f A B C D E IsModelProper] = utComputeRealImagInverseG(Model, 'real');
[zz,pp,kk] = zpkdata(f,'v');
if IsModelProper
    zpkR1Func = zpk(pp,zz,-0.5/kk);
else
    zpkR1Func = zpk(zz,pp,-0.5*kk);
end

% ------------------------------------------------------------------------
%% Compute critical frequencies (wC) and critical Kp values (KpC)
% treat P-only controller design separately
if strcmpi(Type,'p')
    % wC are zeros of Imag{1/G(jw)}
    % if G is (bi)proper, wC are poles of f = 1/(1/G-1/G')
    % if G is improper, wC are zeros of f = 1/G-1/G'
    g = utComputeRealImagInverseG(Model, 'imag');
    if IsModelProper
        z = pole(g);
    else
        z = zero(g);
    end
    % obtain non-zero critical frequencies as z with positive pure
    % imaginary values and wC is sorted by unique function  
    if ~isempty(z)
        wC = unique(imag(z((imag(z)>0)&(abs(real(z))<=min(1,1e-2*(1+imag(z)))))));
    end
else
    % f is descriptor system where E is full rank
    % get zeros of dExtremeFunction/ds
    NX = size(A,1);
    if IsModelProper
        z = zero(dss([A E;zeros(NX) A],[zeros(NX,1);B],[C zeros(1,NX)],0,blkdiag(E,E)));    
    else
        z = zero(ss([A eye(NX);zeros(NX) A],[zeros(NX,1);B],[C zeros(1,NX)],0));
    end
    if ~isempty(z)
        % obtain non-zero critical frequencies as z with positive pure
        % imaginary values and wC is sorted by unique function  
        wC = unique(imag(z((imag(z)>0)&(abs(real(z))<=min(1,1e-2*(1+imag(z)))))));        
        % refine critical frequencies to make sure they are local extrema
        % get boundary for wC and the corresponding KpC values
        wC = refineWC(wC,zpkR1Func);
    end
end
% get critical Kp values at critical frequencies
if ~isempty(wC)
    KpC = squeeze(real(freqresp(zpkR1Func,wC)));
end

% ------------------------------------------------------------------------
%% compute Kp(w) at w=0
KpAt0 = evalfr(zpkR1Func,0);
if isfinite(KpAt0)
    wC = [0;wC];
    KpC = [KpAt0;KpC];
end

% ------------------------------------------------------------------------
%% determine sign at w=inf and compute Kp(inf) if sign==0
% add wC=inf case
KpAtInf = evalfr(zpkR1Func,inf);
if isfinite(KpAtInf)
    % r1(inf) is finite, IRB exists
    wC = [wC;inf];
    KpC = [KpC;KpAtInf];
    SignAtInf = 0;
else
    % r1(inf) is infinite, IRB does not exist but sign of Kp(inf) is needed
    SignAtInf = sign(diff(real(freqresp(zpkR1Func,[wC(end) max(1,wC(end)*10)]))));
end

%% plot r1(w) curve and display local minimums and maximums
if PlotNeeded
    plotR1(KpC,wC,zpkR1Func,SignAtInf);    
end

%% reset warning
warning(sw); lastwarn(lw,lwid);

%% ----------------------------------------------------------------
function wC = refineWC(wC,zpkR1Func)
if ~isempty(wC)
    KpCraw = squeeze(real(freqresp(zpkR1Func,wC)));
    wBND = [0;diff([wC;wC(end)+max(1,wC(end))])/2+wC];
    KpBND = squeeze(real(freqresp(zpkR1Func,wBND)));
    options = optimset('TolX',1e-8,'Display','off');
    for ct = 1:length(wC)
        if KpBND(ct)>KpCraw(ct) && KpBND(ct+1)>KpCraw(ct)
            % local minimum
            wC(ct) = fminbnd(@(x) real(freqresp(zpkR1Func,x)),wBND(ct),wBND(ct+1),options);
        elseif KpBND(ct)<KpCraw(ct) && KpBND(ct+1)<KpCraw(ct)
            % local maximum
            wC(ct) = fminbnd(@(x) -real(freqresp(zpkR1Func,x)),wBND(ct),wBND(ct+1),options);
        else 
            % not a local extreme
            wC(ct) = NaN;
        end        
    end
    wC = wC(~isnan(wC));
end

%% ----------------------------------------------------------------
function plotR1(KpC,wC,zpkR1Func,SignAtInf)
h = figure;
hold on;
if SignAtInf==0
    KpAtInf = KpC(end);
    wC = wC(1:end-1);
    KpC = KpC(1:end-1);
end
if isempty(wC)
    w = 0.01:0.1:100;
    Kp = real(freqresp(zpkR1Func,w));
    Kp = (Kp(:))';
    plot(w,Kp);
elseif length(wC)==1
    if wC==0
        w = 0:0.1:100;
    else
        w = wC/2:wC/100:wC*2;
    end
    Kp = real(freqresp(zpkR1Func,w));
    Kp = (Kp(:))';
    plot(w,Kp);
else
    % add w->inf case
    W = unique([wC;10*wC(end)]);
    for ct = 1:length(W)-1
        w = W(ct):(W(ct+1)-W(ct))/100:W(ct+1);
        Kp = real(freqresp(zpkR1Func,w));
        Kp = (Kp(:))';
        plot(w,Kp);
    end
end
plot(wC,KpC,'o');
if SignAtInf==0
    Xlim = get(get(h,'currentAxes'),'xlim');
    plot(Xlim(2),KpAtInf,'o');
end
xlabel('w');
ylabel('Kp');

