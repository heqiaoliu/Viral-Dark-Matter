function [r1C, alphaC, SignAtPI, ssR1Func, AuxFunc] = utPIDGetR1Discrete(Model,Type,TAU,PlotNeeded)
% Singular frequency based P/PI/PID Tuning sub-routine (Discrete).
%
% This function finds local minimums and maximums of r1(z) curve. 
%
% Input arguments
%   Model:      plant model
%   Type:       'p', 'pi', 'pid'
%   TAU:        derivative filter time constant used in PIDF
%
% Output arguments
%   r1C:        critical r1 values
%   alphaC:     critical frequencies
%   SignAtPI:   the sign of r1(PI) 
%   ssR1Func:   r1(z) in ss format
%   AuxFunc:    auxiliary function to be used by other routines
%
% Note: 
%   1. Model should not contain any differentiator
%   2. 0 is always a critical frequency (because of no differentiator in model) 
%   3. alphaC are sorted. 

%   Author(s): Rong Chen
%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2008/12/04 22:21:11 $

% ------------------------------------------------------------------------
%% initialize output
sw = warning('off'); [lw,lwid] = lastwarn; %#ok<*WNOFF>
alphaC = [];
% get sampling time
Ts = abs(getTs(Model));
% get inverse of plant in state space
invModel = ss(inv(Model));
% set PI constant
valuePI = 3.1415926359;

% ------------------------------------------------------------------------
%% R1Func in state space format
z = dss(eye(2),[0;-1],[1 0],0,[0 1;0 0],Ts);    
switch lower(Type)
    case 'p'
        % ssR1Func for c0 comes from c0 + real(1/G(z)) = 0
        ssR1Func = -(invModel+invModel')/2;
        AuxFunc = [];
    case 'pi'
        % ssR1Func for c1 comes from c1*imag(z) + imag((z-1)/G(z)) = 0
        ssR1Func = -(z*invModel+invModel')/(z+1);
        AuxFunc = (z-1)*invModel;
    case 'pid'    
        if TAU==0
            % ssR1Func for r1 comes from -r1*imag(z) + imag((z-1)/G(z)) = 0
            ssR1Func = (z*invModel+invModel')/(z+1);
            AuxFunc = (z-1)*invModel;
        else
            % ssR1Func for r1 comes from -r1*imag(z) + imag((z-z0)*(z-1)/G(z)/z) = 0
            z0 = (2*TAU-Ts)/(2*TAU+Ts);
            %z0 = TAU/(TAU+Ts);
            ssR1Func = ((z-z0)*invModel-(z0*z-1)*invModel')/(z+1);
            AuxFunc = (z-z0)*(z-1)*invModel/z;
        end
end

% ------------------------------------------------------------------------
%% Compute critical frequencies alphaC
if strcmpi(Type,'p')
    % get zeros of Imag{1/G(z)}
    Z = zero(invModel-invModel');
    % obtain critical frequencies as z on unit circle (Schur stability)
    if ~isempty(Z)
        % get raw critical alpha which may involve non-extrema to be removed
        Angles = abs(angle(Z((abs(abs(Z)-1)<1e-4))));
        Angles(Angles>valuePI) = valuePI;
        alphaC = unique(Angles);
    end
else
    % Compute d(r1(z))/dz
    if isempty(get(ssR1Func,'E'))
        [A B C D] = ssdata(ssR1Func); %#ok<NASGU>
        NX = size(A,1);
        dR1Func = ss([A eye(NX);zeros(NX) A],[zeros(NX,1);B],[C zeros(1,NX)],0,Ts);        
    else
        [A B C D E] = dssdata(ssR1Func); 
        NX = size(A,1);
        dR1Func = dss([A E;zeros(NX) A],[zeros(NX,1);B],[C zeros(1,NX)],0,blkdiag(E,E),Ts);
    end
    % get zeros of d(r1)/dz
    Z = zero(dR1Func);    
    % Obtain critical alpha between 0 and pi from Z
    if ~isempty(Z)
        % get raw critical alpha which may involve non-extrema
        Angles = abs(angle(Z((abs(abs(Z)-1)<1e-4))));
        Angles(Angles>valuePI) = valuePI;
        alphaC = unique(Angles);
        % refine critical alpha
        alphaC = utPIDRefineAlphaC(alphaC,ssR1Func);
    end
end
% if alphaC is not empty, alpha = 0 is already added and just sort it
if isempty(alphaC)
    alphaC = 0;
    r1C = real(freqresp(ssR1Func,exp(0*1i)));
else
    r1C = squeeze(real(freqresp(ssR1Func,exp(alphaC*1i))));
end

%% plot r1(alpha) curve and display local minimums and maximums
if PlotNeeded
    plotR1(r1C,alphaC,ssR1Func,valuePI);    
end
% ------------------------------------------------------------------------
%% determine sign at alpha=pi
% the sign of r1 at alpha = pi
if alphaC(end)==valuePI
    SignAtPI = 0;
else
    SignAtPI = sign(real(freqresp(ssR1Func,exp(((alphaC(end)+valuePI)/2*1i))))-...
        real(freqresp(ssR1Func,exp((alphaC(end)*1i)))));
end

%% reset warning
warning(sw); lastwarn(lw,lwid);


%% ----------------------------------------------------------------
function plotR1(r1C,alphaC,ssR1Func,valuePI)
figure;hold on;
alpha = 0:1e-2:valuePI;
r1 = squeeze(real(freqresp(ssR1Func,exp(alpha*1i))));
plot(alpha,r1);
xlabel('alpha');
ylabel('r1');
plot(alphaC,r1C,'*');

