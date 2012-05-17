function [c, q, errorID, errorMSG] = utIMC_1DFDiscrete(Zero,Pole,Gain,Ts,Alpha)
% IMC Tuning Subroutines (Discrete).

%--------------------------------------------------------------------------
% Discrete Time System: a plant belongs to one of the following four
% categories:
%   (1) marginally stable and MP        
%       ideal order(c) is order(P)
%       maximum order(c) is order(P) + max(Number of zeros of P,1)
%   (2) marginally stable and NMP       
%       ideal order(c) is order(P)
%       maximum order(c) is order(P) + max(Number of zeros of P,1)
%   (3) unstable and MP                 
%       ideal order(c) is order(P)
%       maximum order(c) is order(P)
%   (4) unstable and NMP
%       maximum order(c) is
%       #zero(P)*2+#negzero(P)*2+#RHPpole(P)*2+#RHPzero(P)+relOrder(P)+1

%   Author(s): R. Chen
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2008/09/15 20:36:24 $

%--------------------------------------------------------------------------
%% initialize outputs
c = []; q = []; errorID = ''; errorMSG = '';
%--------------------------------------------------------------------------
%% Plant Information
%--------------------------------------------------------------------------
% obtain plant pole zero information
indRHPzero = (abs(Zero)>1);                         % indices of open RHP zeros
indRHPpole = (abs(Pole)>1);                         % indices of open RHP poles
indIntegrator = (real(Pole)==1)&(imag(Pole)==0);    % indices of integrators
indImagPole = (abs(Pole)==1)&(~indIntegrator);      % indices of poles on imag axis other than origin
NumRHPzeros = sum(indRHPzero);                      % number of open RHP zeros 
NumRHPpoles = sum(indRHPpole);                      % number of open RHP poles 
NumIntegrator = sum(indIntegrator);                 % number of integrators
NumImagPoles = sum(indImagPole);                    % number of poles on imag axis other than origin
NumRHPpolesInVM = NumRHPpoles+NumIntegrator+1; 
% exit if open RHP poles are not distinctive (repeated integrators are OK)
if NumRHPpoles>1 && any(mpoles(Pole(indRHPpole))~=1) || ...
   NumImagPoles>1 && any(mpoles(Pole(indImagpole))~=1)
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
% 2. Factorize P as P = PM * PA where PA is z^-N times the all-pass portion
% PA's numerator consists of all open RHP zeros of P and N is selected to
% make Z^N*P bi-proper  
% Note: (1) PA is 1/z^N when plant is MP. (2) PM's zeros contain PA's poles
N = length(Pole)-length(Zero);
if IsPlantMP
    Zero_PA = [];
    Pole_PA = zeros(N,1);
    Gain_PA = 1;
    Zero_PM = [Zero;Pole_PA];
    Pole_PM = Pole;
    Gain_PM = Gain;
else
    Zero_PA = Zero(indRHPzero);
    Pole_PA = 1./conj(Zero_PA);
    Gain_PA = real(prod(1-Pole_PA))/real(prod(1-Zero_PA));
    Pole_PA = [Pole_PA;zeros(N,1)];
    Zero_PM = [Zero(~indRHPzero);Pole_PA];
    Pole_PM = Pole;
    Gain_PM = Gain/Gain_PA;
end
PA = zpk(Zero_PA,Pole_PA,Gain_PA,Ts);
PMinv = zpk(Pole_PM,Zero_PM,1/Gain_PM,Ts); 
%--------------------------------------------------------------------------
%% IMC Controller Synthesis
%--------------------------------------------------------------------------
% plant is stable
if IsPlantStable
    % 1. design qH = 1/PM [Theorem 8.1-1]
    qH = PMinv;
    % 2. design q_tilde [Eqn. 8.1-7, 8.1-8, 8.1-11]
    % modify qH to deal with the poles of qH that have negative real
    % part. Because those poles lead to undesirable intersampling rippling
    % in the closed loop system, they are replaced by poles at origin. So
    % we have:   
    %       q_tilde = qH * q_ * B
    %   where q_ = z^(-M)*prod((z-k(j))/(1-k(j))) and B = 1 for step input
    % M is the number of such poles, k(j) are the values of such poles.
    indexNegativePole = (real(Zero_PM)<0);
    if any(indexNegativePole)
        Zero_Q_ = Zero_PM(indexNegativePole);
        Pole_Q_ = zeros(sum(indexNegativePole),1);
        Gain_Q_ = 1/real(prod(1-Zero_Q_));
        q_ = zpk(Zero_Q_,Pole_Q_,Gain_Q_,Ts);
        % get q_tilde
        q_tilde = qH*q_;
    else
        % get q_
        Zero_Q_ = [];
        Pole_Q_ = [];
        Gain_Q_ = 1;
        q_ = zpk(Zero_Q_,Pole_Q_,Gain_Q_,Ts);
        % get q_tilde
        q_tilde = qH;
    end
    % 3. design filter [Eqn. 8.2-1]
    % filter is (1-Alpha)z/(z-Alpha) for step input 
    f = zpk(0,Alpha,1-Alpha,Ts);
    % 4. obtain IMC controller q
    q = q_tilde*f;
    % 5. btain classical feedback controller c 
    fPA = feedback(q_*f,PA,1);    
    % with p/z cancellation at Pole_PA
    % Note, if q_ is not 1, feedback(q_*f,PA,1) does not contain a zero at
    % 0 from f
    set(fPA,'Z',[Zero_Q_;zeros(1,isempty(Pole_Q_))]);
    set(qH,'P',Zero(~indRHPzero));
    % get c
    c = qH*fPA;
% plant is unstable but MP   
elseif IsPlantMP
    % 1. design qH where bp=bv, VM = PM*z/(z-1) for step input [Theorem
    % 9.2-1] For a MP plant, q_tilde is 1/PM
    qH = PMinv;
    % 2. design q_tilde and prevent intersample rippling [Eqn. 9.2-20, 8.1-8, 9.2-22]
    % modify qH to deal with the poles of qH that have negative real
    % part. Because those poles lead to undesirable intersampling rippling
    % in the closed loop system, they are replaced by poles at origin. So
    % we have:   
    %       q_tilde = qH * q_ * B
    %   where q_ = z^(-M)*prod((z-k(j))/(1-k(j))), B = (b0+b1/z+...)
    % M is the number of such poles, k(j) are such poles.
    indexNegativePole = (real(Zero_PM)<0);    
    NumNegativePole = sum(indexNegativePole);
    if NumNegativePole>0
        % get q_
        Zero_Q_ = Zero_PM(indexNegativePole);
        Pole_Q_ = zeros(NumNegativePole,1);
        Gain_Q_ = 1/real(prod(1-Zero_Q_));
        q_ = zpk(Zero_Q_,Pole_Q_,Gain_Q_,Ts);
        % get B(z)
        B = localCalculateB(q_,Ts,Pole(indRHPpole),NumRHPpolesInVM,NumRHPpoles,NumIntegrator,NumNegativePole);
        % get q_tilde
        q_tilde = qH*q_*B;
    else
        % get q_tilde
        q_ = zpk([],[],1,Ts);
        B = zpk([],[],1,Ts);        
        q_tilde = qH;
    end
    % 3. design filter [Theorem 9.3-1]
    f = localCalculateF(Alpha,Ts,Pole(indRHPpole),NumRHPpolesInVM,NumRHPpoles,NumIntegrator);
    % 4. obtain IMC controller q
    q = q_tilde*f;
    % 5. obtain classical feedback controller c
    c = minreal(qH*feedback(q_*B*f,PA,1));
% plant is unstable and NMP   
else
    % 1. design qH 
    % assume a step disturbance is added at the plant input.  Then we have
    % VM = PM*z/(z-1) for step input [Theorem 9.2-1] 
    % a generic solution for qH is: qH = z/PM/VM * {VM/z/PA}*
    % compute VM/z/PA = PM/PA/(z-1)
    zInvPAinvVm = zpk([Zero_PM;Pole_PA],[Pole_PM;Zero_PA;1],Gain_PM/Gain_PA,Ts);
    % compute {zInvPAinvVm}* 
    [Num, Den] = tfdata(zInvPAinvVm,'v');
    % get partial fraction of zInvPAinvVm
    [sysR,sysP] = utIMC_PartialFraction(Num,Den,[Pole_PM;Zero_PA;1],1e-3);
    if any(isnan(sysR))
        errorID = 'control:autotuning:unstable';
        errorMSG = 'This tuning method failed to produce a stable feedback loop. Please adjust tuning settings or try another tuning method.';
        return
    end
    % retain strictly proper terms except for those corresponding to the
    % zeros of PA
    indSys = ~ismember(sysP,Zero_PA);
    sysR = sysR(indSys); sysP = sysP(indSys);    
    % we also throw away the biproper and improper terms in PFE
    [NumSys,DenSys] = residue(sysR,sysP,0);
    % form {zInvPAinvVm}* 
    [Zero_zInvPAinvVmStar, Pole_zInvPAinvVmStar, Gain_zInvPAinvVmStar] = ...
        zpkdata(tf(real(NumSys),DenSys,Ts),'v');
    % There are cancellations at poles of PM and 1 between zeros of
    % zVMinv = (z-1)/PM and poles of zInvPAinvVmStar
    zVMinvPAinvVmStar = zpk(Zero_zInvPAinvVmStar,Zero_PM,Gain_zInvPAinvVmStar/Gain_PM,Ts);
    % calculate qH = z/PM/VM * {VM/z/PA}*
    qH = PMinv*zVMinvPAinvVmStar;
    % 2. design q_tilde and prevent intersample rippling [Eqn. 9.2-20, 8.1-8, 9.2-22]
    % modify qH to deal with the poles of qH that have negative real
    % part. Because those poles lead to undesirable intersampling rippling
    % in the closed loop system, they are replaced by poles at origin. So
    % we have:   
    %       q_tilde = qH * q_ * B
    %   where q_ = z^(-M)*prod((z-k(j))/(1-k(j))), B = (b0+b1/z+...)
    % M is the number of such poles, k(j) are such poles.
    [ZeroQH PoleQH] = zpkdata(qH,'v');
    indexNegativePole = (real(PoleQH)<0);
    NumNegativePole = sum(indexNegativePole);
    if NumNegativePole>0
        % get q_
        Zero_Q_ = PoleQH(indexNegativePole);
        Pole_Q_ = zeros(NumNegativePole,1);
        Gain_Q_ = 1/real(prod(1-Zero_Q_));
        q_ = zpk(Zero_Q_,Pole_Q_,Gain_Q_,Ts);
        % get B(z)
        B = localCalculateB(q_,Ts,Pole(indRHPpole),NumRHPpolesInVM,NumRHPpoles,NumIntegrator,NumNegativePole);
        % get q_tilde
        q_tilde = qH*q_*B;
    else
        % get q_tilde
        q_ = zpk([],[],1,Ts);
        B = zpk([],[],1,Ts);        
        q_tilde = qH;
    end
    % 3. design filter [Theorem 9.3-1]
    f = localCalculateF(Alpha,Ts,Pole(indRHPpole),NumRHPpolesInVM,NumRHPpoles,NumIntegrator);
    % 4. obtain IMC controller q
    q = q_tilde*f;
    % 5. obtain classical feedback controller c
    c = minreal(qH*feedback(q_*B*f,PA,1));
end   
%--------------------------------------------------------------------------
%% Subroutines
%--------------------------------------------------------------------------
function B = localCalculateB(q_,Ts,openRHPpoles,NumRHPpolesInVM,NumRHPpoles,NumIntegrator,NumNegativePole)
% follows [Eqn. 9.2-22 and 9.2-24] and assume no repeated open RHP Den in plant
[Num_q_ Den_q_] = tfdata(q_,'v');
ZeroOrderPoles = [1;openRHPpoles];
A = zeros(NumRHPpolesInVM,NumRHPpolesInVM);
b = zeros(NumRHPpolesInVM,1);
for ctRHPpole = 1:NumRHPpoles+1
    A(ctRHPpole,:) = ZeroOrderPoles(ctRHPpole).^(0:-1:-(NumRHPpolesInVM-1));
end
b(1:length(ZeroOrderPoles)) = polyval(Den_q_,ZeroOrderPoles)./polyval(Num_q_,ZeroOrderPoles);
% deal with integrators
if NumIntegrator>0
    % convert into lamda (z=1/lamda)
    qColumn = (fliplr(Num_q_))'; 
    % create PQ matrix
    PQ = zeros(NumIntegrator+1,NumNegativePole+1);
    for ct = 1:NumIntegrator+1
        if ct==1
            PQ(ct,:) = ones(1,NumNegativePole+1);
        else
            PQ(ct,1:NumNegativePole+2-ct) = polyder(PQ(ct-1,1:NumNegativePole+3-ct));
        end
    end
    % create PB matrix
    PB = zeros(NumIntegrator+1,NumRHPpolesInVM);
    for ct = 1:NumIntegrator+1
        if ct==1
            PB(ct,:) = ones(1,NumRHPpolesInVM);
        else
            PB(ct,1:NumRHPpolesInVM+1-ct) = polyder(PB(ct-1,1:NumRHPpolesInVM+2-ct));
        end
    end
    % obtain coefficients
    for ct = 1:NumIntegrator
        Coeff = poly(repmat(-1,ct,1));
        Sum = zeros(1,NumRHPpolesInVM);
        for j=1:ct+1
            Sum = Sum + Coeff(j)*PQ(ct-j+2,:)*qColumn*PB(j,:);
        end
        % convert back from lamda (z=1/lamda)            
        A(NumRHPpoles+1+ct,:) = fliplr(Sum);
        b(NumRHPpoles+1+ct) = 0;
    end
end
coefficients = real(A\b);
B = zpk(tf(coefficients',[1 repmat(0,1,NumRHPpolesInVM-1)],Ts));

function f = localCalculateF(Alpha,Ts,openRHPpoles,NumRHPpolesInVM,NumRHPpoles,NumIntegrator)
% follows [Theorem 9.3-1] which assumes no repeated open RHP poles in plant
% define w 
w = NumRHPpolesInVM;
% get PHI
PHI = zeros(NumRHPpoles,w);
for ct = 1:NumRHPpoles
    PHI(ct,:) = openRHPpoles(NumRHPpoles-ct+1).^(-1:-1:-w)-1;
end
% get NW
NW = zeros(NumIntegrator,w);
for i = 1:NumIntegrator
    for j = 1:w
        if i<=j
            NW(i,j) = prod(j:-1:j-i+1);
        end
    end
end
% get Chi
Chi1 = zeros(NumRHPpoles,1);
for ct = 1:NumRHPpoles
    Chi1(ct) = (openRHPpoles(NumRHPpoles-ct+1)-Alpha)/(1-Alpha)/openRHPpoles(NumRHPpoles-ct+1)-1;
end
Chi2 = zeros(NumIntegrator,1);
if ~isempty(Chi2)
    Chi2(1) = -Alpha/(1-Alpha);
end
Chi = [Chi1;Chi2];
% get coefficients for B
B1W = real([PHI;NW]\Chi);
B0 = 1-sum(B1W);
coefficients = [B0;B1W];
% build filter
f = zpk(0,Alpha,1-Alpha,Ts)*tf(coefficients',[1 repmat(0,1,w)],Ts);        

