function [c, q, errorID, errorMSG] = utIMC_1DFContinuous(Zero,Pole,Gain,tau)
% IMC Tuning Subroutines (Continuous).

%--------------------------------------------------------------------------
% Continuous Time System: a plant belongs to one of the following four
% categories:
%   (1) marginally stable and MP        
%       ideal order(c) is   (1) order(P) when P is strictly proper
%                           (2) order(P) + 1 when P is biproper  
%   (2) marginally stable and NMP       
%       ideal order(c) is   (1) order(P) when P is strictly proper
%                           (2) order(P) + 1 when P is biproper  
%   (3) unstable and MP                 
%       ideal order(c) is   (1) order(P) when P is strictly proper
%                           (2) order(P) + 1 when P is biproper
%       maximum order(c) is (1) order(P) + Number of unstable poles when P is strictly proper
%                           (2) order(P) + Number of unstable poles + 1 when P is biproper
%   (4) unstable and NMP
%       ideal order(c) is   (1) order(P)*2 when P is strictly proper
%                           (2) order(P)*2 + 1 when P is biproper
%       maximum order(c) is (1) order(P)*2 + Number of unstable poles + Number of unstable zeros when P is strictly proper
%                           (2) order(P)*2 + Number of unstable poles + Number of unstable zeros + 1 when P is biproper
%

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/09/15 20:36:23 $

%--------------------------------------------------------------------------
%% initialize outputs
c = []; q = []; errorID = ''; errorMSG = '';
%--------------------------------------------------------------------------
%% Plant Information
%--------------------------------------------------------------------------
% obtain plant pole zero information
indRHPzero = (real(Zero)>0);                        % indices of open RHP zeros
indRHPpole = (real(Pole)>0);                        % indices of open RHP poles
indIntegrator = (real(Pole)==0)&(imag(Pole)==0);    % indices of integrators
indImagPole = (real(Pole)==0)&(imag(Pole)>0);       % indices of poles on imag axis other than origin
NumRHPzeros = sum(indRHPzero);                      % number of open RHP zeros 
NumRHPpoles = sum(indRHPpole);                      % number of open RHP poles 
NumIntegrator = sum(indIntegrator);                 % number of integrators
NumImagPoles = sum(indImagPole);                    % number of poles on imag axis other than origin
% exit if open RHP poles or poles on imag axis are not distinctive
if NumRHPpoles>1 && any(mpoles(Pole(indRHPpole))~=1) || ...
   NumImagPoles>1 && any(mpoles(Pole(indImagPole))~=1)
   errorID = 'control:autotuning:imc_openrhppole';
   errorMSG = 'IMC tuning method does not support a plant with repeated (marginally) unstable poles.';
   return
end
% get plant category
IsPlantStable = (NumRHPpoles+NumIntegrator==0);
IsPlantMP = (NumRHPzeros==0);
%--------------------------------------------------------------------------
%% Plant Factorization: P = PM * PA
%--------------------------------------------------------------------------
% Factorize P as P = PM * PA where PA is the all-pass portion (PA's numerator
% consists of all open RHP zeros as well as the time delay) [Theorem 4.1-1] 
% Note: (1) PA is 1 when plant is MP. (2) |PA(jw)|=1 for any w. (3) PM's
% zeros contain PA's poles when plant is NMP.
if IsPlantMP
    Zero_PM = Zero;    
    Pole_PM = Pole;
    Gain_PM = Gain;
else
    Zero_PA = Zero(indRHPzero);        
    Pole_PA = conj(-Zero_PA);
    Gain_PA = (-1)^length(Zero_PA);
    PA = zpk(Zero_PA,Pole_PA,Gain_PA);
    Zero_PM = [Zero(~indRHPzero);Pole_PA];    
    Pole_PM = Pole;
    Gain_PM = Gain/Gain_PA;
end
PMinv = zpk(Pole_PM,Zero_PM,1/Gain_PM); 
%--------------------------------------------------------------------------
%% IMC Controller Synthesis
%--------------------------------------------------------------------------
% plant is stable
if IsPlantStable
    % 1. design q_tilde [Eqn. 4-1.12]: q_tilde = 1/PM
    q_tilde = PMinv;
    % 2. calculate filter as 1/(tau*s+1)^filterOrder. Set filter order such
    % that q = q_tilde*f is proper [Section 4.2.1]
    filterOrder = max(length(Pole_PM)-length(Zero_PM),1); 
    f = zpk([],repmat(-1/tau,1,filterOrder),(1/tau)^filterOrder);
    % 3. Obtain IMC controller q
    q = q_tilde*f;
    % 4. Obtain classical feedback controller c 
    if IsPlantMP
        fPA = feedback(f,1,1);
    else
        fPA = feedback(f,PA,1);
        % there are cancellations at Pole_PA between zeros of fPA and
        % poles of q_tilde
        set(fPA,'Z',[]);
        set(q_tilde,'P',Zero(~indRHPzero));
    end
    c = q_tilde*fPA;
% plant is unstable but MP   
elseif IsPlantMP
    % 1. design q_tilde 
    % assume a step disturbance is added at the plant input.  From [Theorem
    % 5.2-1] we have a generic solution as q_tilde equals {VM/PA}* divided
    % by (PM*VM).  For a MP plant, q_tilde is 1/PM
    q_tilde = PMinv;
    % 2. design filter [Section 5.3.1]
    f = localDesignFilter(tau,q_tilde,NumRHPpoles,NumIntegrator,Pole(indRHPpole));
    % 3. Obtain IMC controller q
    q = q_tilde*f;
    % 4. Obtain classical feedback controller c = q_tilde * f/(1-f)
    % Theoretically the order of C is the order of plant (+1 if bi-proper).
    % There should be cancellation between unstable poles of f/(1-f) and
    % unstable zeros of q_tilde. minreal is used to remove them. However,
    % due to numerical error introduced in f, unstable poles in c may
    % remain.
    c = minreal(q_tilde*feedback(f,1,1));
% plant is unstable and NMP   
else    
    % 1. design q_tilde 
    % assume a step disturbance is added at the plant input.  From [Theorem
    % 5.2-1] we have a generic solution as q_tilde equals {VM/PA}* divided
    % by (PM*VM).
    PAinvVm = zpk([Zero_PM;Pole_PA],[Pole_PM;Zero_PA;0],Gain_PM/Gain_PA);
    % compute {PAinvVm}* 
    [Num, Den] = tfdata(PAinvVm,'v');
    % get partial fraction of zInvPAinvVm
    [sysR,sysP,sysK] = utIMC_PartialFraction(Num,Den,[Pole_PM;Zero_PA;0],1e-3);
    if any(isnan(sysR))
        errorID = 'control:autotuning:unstable';
        errorMSG = 'This tuning method failed to produce a stable feedback loop. Please adjust tuning settings or try another tuning method.';
        return
    end
    % all terms involving zeros of PA are omitted
    indSys = ~ismember(sysP,Zero_PA);
    sysR = sysR(indSys); sysP = sysP(indSys);    
    % we also throw away the biproper or improper terms in PFE
    [NumSys,DenSys] = residue(sysR,sysP,sysK);
    % form {zInvPAinvVm}* 
    [Zero_PAinvVmStar, Pole_PAinvVmStar, Gain_PAinvVmStar] = zpkdata(tf(real(NumSys),DenSys),'v');
    % There are cancellations at poles of PM and 0 between zeros of
    % VMinv and poles of PAinvVmStar
    VMinvPAinvVmStar = zpk(Zero_PAinvVmStar,Zero_PM,Gain_PAinvVmStar/Gain_PM);
    % calculate qH = z/PM/VM * {VM/z/PA}*
    q_tilde = PMinv*VMinvPAinvVmStar;
    % 2. design filter [Section 5.3.1]
    f = localDesignFilter(tau,q_tilde,NumRHPpoles,NumIntegrator,Pole(indRHPpole));
    % 3. obtain IMC controller q
    q = q_tilde*f;
    % 4. obtain classical feedback controller c = q_tilde * f/(1-PA*f)
    % Theoretically the order of C is the order of plant (+1 if bi-proper).
    % There should be cancellation between unstable poles of f/(1-PA*f) and
    % unstable zeros of q_tilde. minreal is used to remove them. However,
    % due to numerical error introduced in f, unstable poles in c may
    % remain.
    c = minreal(PMinv*feedback(VMinvPAinvVmStar*f,PA,1));
end   
%--------------------------------------------------------------------------
%% Subroutines
%--------------------------------------------------------------------------
function f = localDesignFilter(tau,q_tilde,NumRHPpoles,NumIntegrator,RHPpoles)
k = NumRHPpoles+NumIntegrator+1; % since Vm always contains an pole at origin for step input
m = max(length(zero(q_tilde))-length(pole(q_tilde)),1); % make sure q=q_tilde*f is proper
filterOrder = m+k-1;
% 3. calculate filter as sum(a(k)s^k)/(tau*s+1)^filterOrder
coefficients = ones(1,k);
for ct=1:NumIntegrator
    coefficients(ct+1) = prod(filterOrder-(0:(ct-1)))*tau^ct;
end
if NumRHPpoles>0
    A = zeros(NumRHPpoles,NumRHPpoles);
    for ctRHPpole = 1:length(RHPpoles)
        A(ctRHPpole,:) = RHPpoles(ctRHPpole).^(NumIntegrator+(1:NumRHPpoles));
    end
    b = (tau*RHPpoles+1).^filterOrder-coefficients(1:NumIntegrator+1)*(tau.^(0:NumIntegrator))';
    coefficients(NumIntegrator+2:end) = (real(A\b))';
end
% compute f    
coefficients = fliplr(coefficients);
f = tf(coefficients,fliplr(poly(repmat(-tau,1,filterOrder))));
