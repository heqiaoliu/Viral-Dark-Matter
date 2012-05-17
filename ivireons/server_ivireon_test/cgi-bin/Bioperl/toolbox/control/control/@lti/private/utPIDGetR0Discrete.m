function [r0C, alphaC, SignAtPI, ssR0Func, AuxFunc] = utPIDGetR0Discrete(Model,PlotNeeded)
% Singular frequency based PI Tuning sub-routine (Discrete).
%
% This function computes the critical frequencies and critical r0 values
% that correspond to local minimums or maximums in r0 curve. (PI case only) 
%
% Input arguments
%   Model:      plant model
%
% Output arguments
%   r0C:        critical r0 values
%   alphaC:     critical frequencies
%   SignAtPI:   the sign of r0(PI) 
%   ssR0Func:   r0(z) in ss format
%   AuxFunc:    auxiliary function used in the other equation
%
% Note: 
%   1. Model should not contain any differentiator
%   2. 0 is always a critical frequency (because of no differentiator in model) 
%   3. alphaC are sorted. 

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $ $Date: 2008/12/04 22:21:09 $

%% ------------------------------------------------------------------------
%   PI: (design with stability boundary locus)  
%       c0*sin(a) - imag((1-1/z)/G(z)) = 0
%       c0*cos(a) + c1 + real((1-1/z)/G(z)) = 0

%% ------------------------------------------------------------------------
%% initialize output
sw = warning('off'); [lw,lwid] = lastwarn; %#ok<*WNOFF>
alphaC = [];
% get sampling time
Ts = abs(getTs(Model));
% get inverse of plant
invModel = ss(inv(Model));
% set PI 
valuePI = 3.1415926359;

% ------------------------------------------------------------------------
%% R0Func in state space format
z = dss(eye(2),[0;-1],[1 0],0,[0 1;0 0],Ts);    
ssR0Func = (invModel+invModel'*z)/(z+1);
AuxFunc = invModel*ss(0,1,-1,1,Ts); % multiply by (1-1/z)

% ------------------------------------------------------------------------
%% Compute critical frequencies alphaC
% Compute d(r0(z))/dz and find zeros
if isempty(get(ssR0Func,'E'))
    [A B C D] = ssdata(ssR0Func); %#ok<NASGU>
    NX = size(A,1);
    dR0Func = ss([A eye(NX);zeros(NX) A],[zeros(NX,1);B],[C zeros(1,NX)],0,Ts);        
else
    [A B C D E] = dssdata(ssR0Func); 
    NX = size(A,1);
    dR0Func = dss([A E;zeros(NX) A],[zeros(NX,1);B],[C zeros(1,NX)],0,blkdiag(E,E),Ts);
end
% get zeros of d(r0)/dz which correspond to the local min/max on r2(alpha)
Z = zero(dR0Func);    
%% Obtain and refine critical alpha between 0 and pi from Z
if ~isempty(Z)
    % get raw critical alpha which may involve non-extrema to be removed
    Angles = abs(angle(Z((abs(abs(Z)-1)<1e-4))));
    Angles(Angles>valuePI) = valuePI;
    alphaC = unique(Angles);
    % refine critical alpha
    alphaC = utPIDRefineAlphaC(alphaC,ssR0Func);
end
if isempty(alphaC)
    alphaC = 0;
    r0C = squeeze(real(freqresp(ssR0Func,1)));    
else
    r0C = squeeze(real(freqresp(ssR0Func,exp(alphaC*1i))));
end

%% plot r0(alpha) curve and display local minimums and maximums
if PlotNeeded
    plotR0(r0C,alphaC,ssR0Func,valuePI);    
end
% ------------------------------------------------------------------------
%% determine sign at w=0 and w=inf
% the sign of r0 at alpha = pi
if alphaC(end)==valuePI
    SignAtPI = 0;
else
    SignAtPI = sign(real(freqresp(ssR0Func,exp(((alphaC(end)+valuePI)/2*1i))))-...
        real(freqresp(ssR0Func,exp((alphaC(end)*1i)))));
end

%% reset warning
warning(sw); lastwarn(lw,lwid);

%% ----------------------------------------------------------------
function plotR0(r0C,alphaC,ssR0Func,valuePI)
figure;hold on;
alpha = 1e-6:1e-4:(valuePI-1e-6);
r0 = squeeze(real(freqresp(ssR0Func,exp(alpha*1i))));
plot(alpha,r0);
xlabel('alpha');
ylabel('r0');
plot(alphaC,r0C,'*');

