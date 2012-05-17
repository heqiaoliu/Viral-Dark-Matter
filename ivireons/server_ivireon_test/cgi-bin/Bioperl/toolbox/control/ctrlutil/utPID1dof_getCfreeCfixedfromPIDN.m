function [Cfree,Cfixed,C] = utPID1dof_getCfreeCfixedfromPIDN(P,I,D,N,Ts,ctrlstruct)
% UTPID1DOF_GETCFREECFIXEDFROMPIDF  is for internal use only.
% This utility function returns Cfree and Cfixed given P,I,D,N values and
% structure that describes the realization of the controller. If a
% particular coefficient is irrelevant, then use []. For example, for a PI
% controller, D = [], N= []. Another example would be a PID case where D =
% 0, in this case N = [] is allowed. In continuous-time, Ts = [] is valid.

% Author(s): Murad Abu-Khalaf  1-June-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2010/03/08 21:28:16 $

% Note that C = Cfree * Cfixed

% Do not allow any non finite value for N in the Mask. A non finite value
% for N may however arise when using the Automated Tuning utility in the
% SISO Tool. See g322687.

% Two rules are observed here:
% 1- Handle structural Zero/Pole cancellation in C(s) when P,I, or D is 0.
% Note that there could be Zero/Pole cancellations for nonzero values of
% PIDF, these are allowed.
% 2- Remove Zeros/Poles of C(s) that go to infinity for finite values of P,
% I, D, or N.

% Check the validity of the parameters P, I, D, N.
try
    localparamcheck('P',P,ctrlstruct.Controller);
    localparamcheck('I',I,ctrlstruct.Controller);
    localparamcheck('D',D,ctrlstruct.Controller);
    localparamcheckN(N,ctrlstruct.Controller);
    % No checking is being done for Ts
catch ME
    throw(ME);
end


% Reroute for the appropriate Eval subfunction
switch upper(ctrlstruct.Controller)
    case {'PID','PIDF'}
        if strcmpi(ctrlstruct.Form,'Parallel')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [Cfree,Cfixed] = PID_CT_Parallel_EvalFcn(P,I,D,N);
            else
                [Cfree,Cfixed] = PID_DT_Parallel_EvalFcn(P,I,D,N,Ts,ctrlstruct);
            end
        elseif strcmpi(ctrlstruct.Form,'Ideal')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [Cfree,Cfixed] = PID_CT_Ideal_EvalFcn(P,I,D,N);
            else
                [Cfree,Cfixed] = PID_DT_Ideal_EvalFcn(P,I,D,N,Ts,ctrlstruct);
            end
        end
    case 'PI'
        if strcmpi(ctrlstruct.Form,'Parallel')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [Cfree,Cfixed] = PI_CT_Parallel_EvalFcn(P,I);
            else
                [Cfree,Cfixed] = PI_DT_Parallel_EvalFcn(P,I,Ts,ctrlstruct);
            end
        elseif strcmpi(ctrlstruct.Form,'Ideal')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [Cfree,Cfixed] = PI_CT_Ideal_EvalFcn(P,I);
            else
                [Cfree,Cfixed] = PI_DT_Ideal_EvalFcn(P,I,Ts,ctrlstruct);
            end
        end
    case {'PD','PDF'}
        if strcmpi(ctrlstruct.Form,'Parallel')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [Cfree,Cfixed] = PD_CT_Parallel_EvalFcn(P,D,N);
            else
                [Cfree,Cfixed] = PD_DT_Parallel_EvalFcn(P,D,N,Ts,ctrlstruct);
            end
        elseif strcmpi(ctrlstruct.Form,'Ideal')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [Cfree,Cfixed] = PD_CT_Ideal_EvalFcn(P,D,N);
            else
                [Cfree,Cfixed] = PD_DT_Ideal_EvalFcn(P,D,N,Ts,ctrlstruct);
            end
        end
    case 'I'
        % Check input sizes
        if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
            [Cfree,Cfixed] = I_CT_EvalFcn(I);
        else
            [Cfree,Cfixed] = I_DT_EvalFcn(I,Ts,ctrlstruct);
        end
    case 'P'
        if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
            [Cfree,Cfixed] = P_CT_EvalFcn(P);
        else
            [Cfree,Cfixed] = P_DT_EvalFcn(P,Ts);
        end
end
C = Cfree * Cfixed;


%---------------- Continuous-time PIDF to ZPK -----------------------------
function [Cfree,Cfixed] = PID_CT_Parallel_EvalFcn(P,I,D,N)
%% PIDF to ZPK

% Generally with finite N,
%                                    (P+D*N) s^2 + (P*N+I) s + I*N
% C(s) = P + I/s + Ds/(s/N+1) -->    -------------------------------
%                                              s (s+N)
% and with N=inf,
%                                         D s^2 + P s + I
% C(s) = P + I/s + Ds/(s/N+1) -->    -------------------------------
%                                                 s

if D == 0                 % C(s) = P + I/s
    if I == 0             % C(s) = P
        Cfree = zpk([],[],P);                    % Inverted by Case 7
        Cfixed = zpk([],[],1);
    elseif P == 0         % C(s) = I/s
        Cfree = zpk([],[],I);                    % Inverted by Case 6
        Cfixed = zpk([],0,1);
    else                  % C(s) = P + I/s
        Cfree = zpk(-I/P,[],P);                  % Inverted by Case 4
        Cfixed = zpk([],0,1);
    end
elseif I == 0             % C(s) = P + Ds/(s/N+1)
    if isinf(N)       % C(s) = P + Ds
        Cfree = zpk(-P/D,[],D);                  % Inverted by Case 5
    else % C(s) = P + Ds/(s/N+1)
        % zpk(tf([P+D*N P*N], [1 N]))
        if abs(P+D*N)<=sqrt(eps)*(abs(P)+abs(D*N))   % Check if P+D*N == 0
            Cfree = zpk([],-N,P*N);              % Inverted by Case 6.1
        else
            Cfree = zpk(-P*N/(P+D*N),-N,P+D*N);  % Inverted by Case 3
        end
    end
    Cfixed = zpk([],[],1);
else                      % C(s) = P + I/s + Ds/(s/N+1)
    if isinf(N)
        Cfree = zpk(tf([D P I],1)); % C(s) = P + I/s + Ds with D~=0, % Inverted by Case 2
    else  % C(s) = P + I/s + Ds/(s/N+1)
        % zpk(tf([P+D*N P*N+I I*N], [1 N]))
        if abs(P+D*N)<=sqrt(eps)*(abs(P)+abs(D*N))   % Check if P+D*N == 0
            if abs(P*N+I)<=sqrt(eps)*(abs(P*N)+abs(I)) % Check if PN+I == 0
                Cfree = zpk([],-N,I*N);          % Inverted by Case 5.1
            else
                Cfree = zpk(-I*N/(P*N+I),-N,P*N+I); % Inverted by Case 2.1
            end
        else
            Cfree = zpk(tf([P+D*N P*N+I I*N], [1 N])); % Inverted by Case 1
        end
    end
    Cfixed = zpk([],0,1);
end
function [Cfree,Cfixed] = PID_CT_Ideal_EvalFcn(P,I,D,N)
%% PIDF to ZPK

% Generally with finite N,
%                                          (1+D*N) s^2 + (I+N) s + I*N
% C(s) = P (1 + I/s + Ds/(s/N+1) ) --> P  -------------------------------
%                                                    s (s+N)
% and with N=inf,
%                                                D s^2 + s + I
% C(s) = P (1 + I/s + Ds/(s/N+1) ) --> P  -------------------------------
%                                                       s

if D == 0                 % C(s) = P (1 + I/s)
    if I == 0             % C(s) = P
        Cfree = zpk([],[],P);                        % Inverted by Case 6
        Cfixed = zpk([],[],1);
    else                  % C(s) = P (1 + I/s)
        Cfree = zpk(-I,[],P);                        % Inverted by Case 4
        Cfixed = zpk([],0,1);
    end
elseif I == 0             % C(s) = P (1 + Ds/(s/N+1))
    if isinf(N)       % C(s) = P (1 + Ds)
        Cfree = zpk(-1/D,[],P*D);                    % Inverted by Case 5
    else % C(s) = P (1 + Ds/(s/N+1))
        % zpk(tf(P*[1+D*N N], [1 N]))
        if abs(1+D*N)<=sqrt(eps)*(1+abs(D*N))   % Check if 1+D*N == 0
            Cfree = zpk([],-N,P*N);                  % Inverted by Case 5.2
        else
            Cfree = zpk(-N/(1+D*N),-N,P*(1+D*N));    % Inverted by Case 3
        end
    end
    Cfixed = zpk([],[],1);
else                      % C(s) = P (1 + I/s + Ds/(s/N+1))
    if isinf(N)       % C(s) = P (1 + I/s + Ds)
        Cfree = zpk(tf([D 1 I],1));                  % Inverted by Case 2
        Cfree.k = P * Cfree.k;  % Reason to do this is to handle P=0 because
        % zpk(0*tf(den,num)) = []/[]/0 <--> z/p/k
    else  % C(s) = P (1 + I/s + Ds/(s/N+1))
        % zpk(tf(P*[1+D*N N+I I*N], [1 N]))
        if abs(1+D*N)<=sqrt(eps)*(1+abs(D*N))   % Check if 1+D*N == 0
            if abs(N+I)<=sqrt(eps)*(abs(N)+abs(I)) % Check if N+I == 0
                Cfree = zpk([],-N,P*I*N);            % Inverted by Case 5.1
            else
                Cfree = zpk(-I*N/(I+N),-N,P*(N+I));  % Inverted by Case 2.1
            end
        else
            Cfree = zpk(tf([1+D*N I+N I*N], [1 N])); % Inverted by Case 1
            Cfree.k = P * Cfree.k;
        end
    end
    Cfixed = zpk([],0,1);
end
function [Cfree,Cfixed] = PI_CT_Parallel_EvalFcn(P,I)
%% PI to ZPK

if I == 0             % C(s) = P
    Cfree = zpk([],[],P);                    % Inverted by Case 7
    Cfixed = zpk([],[],1);
elseif P == 0         % C(s) = I/s
    Cfree = zpk([],[],I);                    % Inverted by Case 6
    Cfixed = zpk([],0,1);
else                  % C(s) = P + I/s
    Cfree = zpk(-I/P,[],P);                  % Inverted by Case 4
    Cfixed = zpk([],0,1);
end
function [Cfree,Cfixed] = PI_CT_Ideal_EvalFcn(P,I)
%% PI to ZPK

if I == 0             % C(s) = P
    Cfree = zpk([],[],P);                        % Inverted by Case 6
    Cfixed = zpk([],[],1);
else                  % C(s) = P (1 + I/s)
    Cfree = zpk(-I,[],P);                        % Inverted by Case 4
    Cfixed = zpk([],0,1);
end
function [Cfree,Cfixed] = PD_CT_Parallel_EvalFcn(P,D,N)
%% PDF to ZPK

if D == 0                 % C(s) = P
    Cfree = zpk([],[],P);                       % Inverted by Case 7
    Cfixed = zpk([],[],1);
else                      % C(s) = P + Ds/(s/N+1)
    if isinf(N)       % C(s) = P + Ds
        Cfree = zpk(-P/D,[],D);                  % Inverted by Case 5
    else % C(s) = P + Ds/(s/N+1)
        % zpk(tf([P+D*N P*N], [1 N]))
        if abs(P+D*N)<=sqrt(eps)*(abs(P)+abs(D*N))   % Check if P+D*N == 0
            Cfree = zpk([],-N,P*N);              % Inverted by Case 6.1
        else
            Cfree = zpk(-P*N/(P+D*N),-N,P+D*N);  % Inverted by Case 3
        end
    end
    Cfixed = zpk([],[],1);
end
function [Cfree,Cfixed] = PD_CT_Ideal_EvalFcn(P,D,N)
%% PDF to ZPK

if D == 0                 % C(s) = P
    Cfree = zpk([],[],P);                        % Inverted by Case 6
    Cfixed = zpk([],[],1);
else                      % C(s) = P (1 + Ds/(s/N+1))
    if isinf(N)       % C(s) = P (1 + Ds)
        Cfree = zpk(-1/D,[],P*D);                    % Inverted by Case 5
    else % C(s) = P (1 + Ds/(s/N+1))
        % zpk(tf(P*[1+D*N N], [1 N]))
        if abs(1+D*N)<=sqrt(eps)*(1+abs(D*N))   % Check if 1+D*N == 0
            Cfree = zpk([],-N,P*N);                  % Inverted by Case 5.2
        else
            Cfree = zpk(-N/(1+D*N),-N,P*(1+D*N));    % Inverted by Case 3
        end
    end
    Cfixed = zpk([],[],1);
end
function [Cfree,Cfixed] = I_CT_EvalFcn(I)
%% I to ZPK

% C(s) = I/s
Cfree = zpk([],[],I);
Cfixed = zpk([],0,1);
function [Cfree,Cfixed] = P_CT_EvalFcn(P)
%% P to ZPK

% C(s) = P
Cfree = zpk([],[],P);
Cfixed = zpk([],[],1);


%---------------- Discrete time PIDF to ZPK -------------------------------
function [Cfree,Cfixed] = PID_DT_Parallel_EvalFcn(P,I,D,N,Ts,ctrlstruct)
%% PIDF to ZPK

% General approach is
%
%   C(s) = P + I/s + Ds/(s/N+1) -->
%
%
%             n1*z + m1                    N
%   P + I r1 -----------  +  D  -----------------------------
%                z - 1                          n2*z + m2
%                                1  +   N   r2 ------------
%                                                  z - 1
%
%             n1*z + m1                    N (z - 1)
%   P + I r1 -----------  +  D  -----------------------------
%               z - 1             z - 1  +   N r2 (n2*z + m2)
%
%
%
%             n1*z + m1         D*N                  (z - 1)
%   P + I r1 -----------   + --------   *  -----------------------------
%                z - 1        1+N*r2*n2              1 - N*r2*m2
%                                           z -    --------------
%                                                    1 + N*r2*n2
%
%
%          n1*z + m1            z - 1
%   P + a -----------  +  b * --------------
%             z - 1             z - c
%
%
%
%   (P+a*n1+b)*z^2 + (-P*(1+c)-n1*a*c+m1*a-2*b)*z + (P*c-a*m1*c+b)
%   --------------------------------------------------------------
%                 (z - 1)  (z - c)
%
% Note that for n2=1, |c|< 1 for N>0!
%

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);
[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);

a = I*r1;
b = D*N/(1+N*r2*n2);
c = (1-N*r2*m2)/(1+N*r2*n2);

if D == 0                 % C(z) = P + I * r1*(n1*z+m1)/(z-1)
    if I == 0             % C(z) = P
        Cfree = zpk([],[],P,Ts);                   % Inverted by Case 7
        Cfixed = zpk([],[],1,Ts);
    elseif P == 0         % C(z) = I * r1*(n1*z+m1)/(z-1)
        if n1==0
            Cfree = zpk([],[],I*r1,Ts);% Inverted by Case 6
        else
            Cfree = zpk(-m1,[],I*r1,Ts);          % Inverted by Case 4
        end
        Cfixed = zpk([],1,1,Ts);
    else                  % C(z) = P + I * r1*(n1*z+m1)/(z-1)
        if abs(P+I*r1*n1)<=sqrt(eps)*(abs(P)+abs(I*r1*n1))   % Check for P+I*r1*n1 == 0
            Cfree = zpk([],[],-(P-I*r1*m1),Ts);      % Inverted by Case 6
            % Note that when n1 =0, P =0, and the P=0 branch is executed
            % before this one
        else
            Cfree = zpk((P-I*r1*m1)/(P+I*r1*n1),[],P+I*r1*n1,Ts);    % Inverted by Case 4
        end
        Cfixed = zpk([],1,1,Ts);
    end
elseif I == 0             % C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
    if isinf(N)       % C(z) = P + D/r2*(z-1)/(n2*z+m2)
        if n2==0
            Cfree = zpk((D-P*r2)/D,[],D/r2,Ts);  % D~=0              % Inverted by Case 5
            Cfixed = zpk([],[],1,Ts);
        else
            p = -m2;
            if abs(P+D/r2)<=sqrt(eps)*(abs(P)+abs(D/r2))
                z = [];
                k = P*m2-D/r2;        % Inverted by Case 6.1
            else
                k = P+D/r2;
                z = (D/r2-P*m2)/(P+D/r2);    % Inverted by Case 3
            end
            Cfree = zpk(z,[],k,Ts);
            Cfixed = zpk([],p,1,Ts);
        end
    else                  % C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
        % b1 =  P*(1+N*r2*n2)+D*N  /  1 + N*r2*n2 = P+b
        % b0 =-(P*(1-N*r2*m2)+D*N) /  1 + N*r2*n2 = -(P*c+b)
        % a1 =  1;
        % a0 =  -(1 - N*r2*m2)      /  1 + N*r2*n2
        % zpk(tf([b1 b0], [a1 a0]))
        if abs(P*(1+N*r2*n2)+D*N)<=sqrt(eps)*(abs(P)*(1+N*r2*n2)+abs(D*N))   % Check if b1 == 0
            Cfree = zpk([],c,-(P*c+b),Ts);    % Inverted by Case 6.1
        else
            Cfree = zpk((P*c+b)/(P+b),c,(P+b),Ts);                % Inverted by Case 3
        end
        Cfixed = zpk([],[],1,Ts);
    end
else                      % C(z) = P + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
    if isinf(N)   % C(z) = P + I * r1*(n1*z+m1)/(z-1) + D/r2*(z-1)/(n2*z+m2)
        b2 = P*n2+I*r1*n1*n2+D/r2;
        b1 = P*(m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2;
        b0 = -P*m2+I*r1*m1*m2+D/r2;
        a1 = n2;
        a0 = m2;
        % zpk(tf([b2 b1 b0], [a1 a0]))
        if abs(b2)<=sqrt(eps)*(abs(P*n2)+abs(I*r1*n1*n2)+abs(D/r2))   % Check if b2==0
            if abs(b1)<=sqrt(eps)*(abs(P*(m2-n2))+abs(I*r1*(n1*m2+m1*n2))+abs(2*D/r2)) % Check if b1==0
                % Note that this implies that D=0, b1 = P+I*r1*n1=0, and
                % that b0 = -P+I*r1*m1. This repeats a similar case
                % in the main IF statement covering D==0. (Inverted by Case 6)
                Cfree = zpk([],[],b0,Ts);            % Inverted by Case 5.1
                Cfixed = zpk([],[1 -a0],1,Ts);
            else
                % Note that this implies that D=0, b1 = P+I*r1*n1, and
                % that -b0 = P-I*r1*m1. This repeats a similar case
                % in the main IF statement covering D==0. (Inverted by Case 6)
                Cfree = zpk(-b0/b1,[],b1,Ts);         % Inverted by Case 2.1
                Cfixed = zpk([],[1 -a0],1,Ts);
            end
        else
            if a1==0
                Cfree = zpk(tf([b2 b1 b0],1,Ts));         % Inverted by Case 2
                Cfixed = zpk([],1,1,Ts);
            else
                Cfree = zpk(tf([b2 b1 b0],1,Ts));    % Inverted by Case 1
                Cfixed = zpk([],[1 -a0],1,Ts);
            end
        end
    else  % C(z) = P + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
        b2 = P+a*n1+b;
        b1 = -P*(1+c)-n1*a*c+m1*a-2*b;
        b0 = P*c-a*m1*c+b;
        % zpk(tf([b2 b1 b0], [1 -c]))
        if abs(b2)<=sqrt(eps)*(abs(P)+abs(a*n1)+abs(b))   % Check if b2==0
            if abs(b1)<=sqrt(eps)*(abs(P)+abs(P*c)+abs(n1*a*c)+abs(m1*a)+abs(2*b)) % Check if b1==0
                Cfree = zpk([],c,b0,Ts);                  % Inverted by Case 5.1
                Cfixed = zpk([],1,1,Ts);
            else
                Cfree = zpk(-b0/b1,c,b1,Ts);              % Inverted by Case 2.1
                Cfixed = zpk([],1,1,Ts);
            end
        else
            Cfree = zpk(tf([b2 b1 b0],[1 -c],Ts));        % Inverted by Case 1
            Cfixed = zpk([],1,1,Ts);
        end
    end
end
function [Cfree,Cfixed] = PID_DT_Ideal_EvalFcn(P,I,D,N,Ts,ctrlstruct)
%% PIDF to ZPK

% General approach is
%
%   C(s) = P (1 + I/s + Ds/(s/N+1) ) -->
%
%
%                 n1*z + m1                    N
%   P ( 1  + I r1 -----------  +  D  -----------------------------    )
%                    z - 1                          n2*z + m2
%                                   1  +   N   r2 ------------
%                                                      z - 1
%
%                 n1*z + m1                    N (z - 1)
%   P ( 1 + I r1 -----------  +  D  -----------------------------     )
%                    z - 1             z - 1  +   N r2 (n2*z + m2)
%
%
%
%                n1*z + m1         D*N                 (z - 1)
%   P ( 1 + I r1 -----------   + -------- *  ------------------------ )
%                   z - 1        1+N*r2*n2              1 - N*r2*m2
%                                             z -    --------------
%                                                       1 + N*r2*n2
%
%
%               n1*z + m1            z - 1
%   P ( 1 + a -----------  +  b * --------------  )
%                  z - 1             z - c
%
%
%
%        (1+a*n1+b)*z^2 + (-(1+c)-n1*a*c+m1*a-2*b)*z + (c-a*m1*c+b)
%   P ( ------------------------------------------------------------ )
%                          (z - 1)  (z - c)
%
%   Note that for n2=1, |c|< 1 for N>0!
%
%

%   When N is infinity, the following equations apply:
%
%
%                n1*z + m1                    (z - 1)
%   P ( 1 + I r1 -----------   + D/r2 *   ------------------ )
%                   z - 1                     n2*z + m2
%
%
%           b2*z^2 + b1*z + b0
%   P ( ------------------------- )
%          (z - 1)  (n2*z + m2)
%
%
%  b2 = n2+I*r1*n1*n2+D/r2;
%  b1 = (m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2;
%  b0 = -m2+I*r1*m1*m2+D/r2;
%
%
[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);
[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);
a = I*r1;
b = D*N/(1+N*r2*n2);
c = (1-N*r2*m2)/(1+N*r2*n2);

if D == 0                 % C(z) = P ( 1 + I * r1*(n1*z+m1)/(z-1) )
    if I == 0             % C(z) = P
        Cfree = zpk([],[],P,Ts);              % Inverted by Case 7
        Cfixed = zpk([],[],1,Ts);
    else
        % C(z) = P (1 + I * r1*(n1*z+m1)/(z-1) )
        if abs(1+I*r1*n1)<=sqrt(eps)*(1+abs(I*r1*n1))   % Check for 1+I*r1*n1 == 0
            Cfree = zpk([],[],-P*(1-I*r1*m1),Ts);    % Inverted by Case 6
        else
            Cfree = zpk((1-I*r1*m1)/(1+I*r1*n1),[],P*(1+I*r1*n1),Ts);    % Inverted by Case 4
        end
        Cfixed = zpk([],1,1,Ts);
    end
elseif I == 0             % C(z) = P ( 1 + D*N/( 1+N*r2*(n2*z+m2)/(z-1)) )
    if isinf(N)       % C(z) = P ( 1 + D/r2*(z-1)/(n2*z+m2) )
        if n2==0
            Cfree = zpk((D-r2)/D,[],P*D/r2,Ts);     % Inverted by Case 5
            Cfixed = zpk([],[],1,Ts);
        else
            p = -m2;
            if abs(n2+D/r2)<=sqrt(eps)*(n2+abs(D/r2))
                z = [];
                k = -P*(D/r2-m2);         % Inverted by Case 6.1
            else
                k = P*(n2+D/r2);
                z = (D/r2-m2)/(n2+D/r2);  % Inverted by Case 3
            end
            Cfree = zpk(z,[],k,Ts);
            Cfixed = zpk([],p,1,Ts);
        end
    else                  % C(z) = P ( 1 + D*N/( 1+N*r2*(n2*z+m2)/(z-1) ))
        % b1 =   (1+N*r2*n2)+D*N  /  1 + N*r2*n2 = (1+b)
        % b2 = -((1-N*r2*m2)+D*N) /  1 + N*r2*n2 = -(c+b)
        % a1 =  1;
        % a2 =  -(1 - N*r2*m2)      /  1 + N*r2*n2
        % zpk(tf(P*[b1 b2], [a1 a2]))
        if abs((1+N*r2*n2)+D*N)<=sqrt(eps)*((1+N*r2*n2)+abs(D*N))   % Check if b1 == 0
            Cfree = zpk([],c,-P*(c+b),Ts);    % Inverted by Case 6.1
        else
            Cfree = zpk((c+b)/(1+b),c,P*(1+b),Ts);           % Inverted by Case 3
        end
        Cfixed = zpk([],[],1,Ts);
    end
else                      % C(z) = P*( 1 + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) ) )
    if isinf(N)   % C(z) = P*(1 + I * r1*(n1*z+m1)/(z-1) + D/r2*(z-1)/(n2*z+m2))
        b2 = n2+I*r1*n1*n2+D/r2;
        b1 = (m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2;
        b0 = -m2+I*r1*m1*m2+D/r2;
        a1 = n2;
        a0 = m2;
        % zpk(tf(P*[b2 b1 b0], [a1 a0]))
        if abs(b2)<=sqrt(eps)*(n2+abs(I*r1*n1*n2)+abs(D/r2))   % Check if b2==0
            if abs(b1)<=sqrt(eps)*(abs((m2-n2))+abs(I*r1*(n1*m2+m1*n2))+abs(2*D/r2)) % Check if b1==0
                % Note that this implies that D=0, b1 = m2+I*r1*n1*m2=0, and
                % that b0 = -m2+I*r1*m1. This repeats a similar case
                % in the main IF statement covering D==0.(Inverted by Case 6)
                Cfree = zpk([],[],P*b0,Ts);        % Inverted by Case 5.1
                Cfixed = zpk([],[1 -a0],1,Ts);
            else
                % Note that this implies that D=0, b1 = m2+I*r1*n1*m2=0, and
                % that b0 = -m2+I*r1*m1. This repeats a similar case
                % in the main IF statement covering D==0.(Inverted by Case 4)
                Cfree = zpk(-b0/b1,[],P*b1,Ts);    % Inverted by Case 2.1
                Cfixed = zpk([],[1 -a0],1,Ts);
            end
        else
            if a1==0
                Cfree = zpk(tf([b2 b1 b0],a0,Ts));     % Inverted by Case 2
                Cfree.k = P * Cfree.k; % Reason for doing this is to handle P = 0 because % zpk(0*tf(den,num)) =[]/[]/0 <--> zpk
                Cfixed = zpk([],1,1,Ts);
            else
                Cfree = zpk(tf([b2 b1 b0],1,Ts));      % Inverted by Case 1
                Cfree.k = P * Cfree.k;
                Cfixed = zpk([],[1 -a0],1,Ts);
            end
        end
    else  % C(z) = P *( 1 + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
        b2 = 1+a*n1+b;
        b1 = -(1+c)-n1*a*c+m1*a-2*b;
        b0 = c-a*m1*c+b;
        % zpk(tf(P*[b2 b1 b0], [1 -c]))
        if abs(b2)<=sqrt(eps)*(1+abs(a*n1)+abs(b))   % Check if b2==0
            if abs(b1)<=sqrt(eps)*(1+abs(c)+abs(n1*a*c)+abs(m1*a)+abs(2*b)) % Check if b1==0
                Cfree = zpk([],c,P*b0,Ts);            % Inverted by Case 5.1
            else
                Cfree = zpk(-b0/b1,c,P*b1,Ts);        % Inverted by Case 2.1
            end
            Cfixed = zpk([],1,1,Ts);
        else
            Cfree = zpk(tf([b2 b1 b0],[1 -c],Ts));    % Inverted by Case 1
            Cfree.k = P * Cfree.k;
            Cfixed = zpk([],1,1,Ts);
        end
    end
    
end
function [Cfree,Cfixed] = PI_DT_Parallel_EvalFcn(P,I,Ts,ctrlstruct)
%% PI to ZPK

% General approach is
%                  (P+r1*n1*I)*z - (P-m1*r1*I)
% P + I s^-1 -->  ------------------------
%                            z - 1

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);

if I == 0             % C(z) = P
    Cfree = zpk([],[],P,Ts);                   % Inverted by Case 7
    Cfixed = zpk([],[],1,Ts);
elseif P == 0         % C(z) = I * r1*(n1*z+m1)/(z-1)
    if n1==0
        Cfree = zpk([],[],I*r1,Ts);           % Inverted by Case 6
    else
        Cfree = zpk(-m1,[],I*r1,Ts);           % Inverted by Case 4
        % The zeros here should not be fixed to allow going back to PI from
        % I
    end
    Cfixed = zpk([],1,1,Ts);
else                  % C(z) = P + I * r1*(n1*z+m1)/(z-1)
    if abs(P+I*r1*n1)<=sqrt(eps)*(abs(P)+abs(I*r1*n1))   % Check for P+I*r1*n1 == 0
        Cfree = zpk([],[],-(P-I*r1*m1),Ts);      % Inverted by Case 6
    else
        Cfree = zpk((P-I*r1*m1)/(P+I*r1*n1),[],P+I*r1*n1,Ts);    % Inverted by Case 4
    end
    Cfixed = zpk([],1,1,Ts);
end
function [Cfree,Cfixed] = PI_DT_Ideal_EvalFcn(P,I,Ts,ctrlstruct)
%% PI to ZPK

% General approach is
%                         (1+r1*n1*I)*z - (1-m1*r1*I)
% P (1 + I s^-1) --> P * -------------------------
%                                 z - 1

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);

if I == 0             % C(z) = P
    Cfree = zpk([],[],P,Ts);              % Inverted by Case 7
    Cfixed = zpk([],[],1,Ts);
else
    % C(z) = P (1 + I * r1*(n1*z+m1)/(z-1) )
    if abs(1+I*r1*n1)<=sqrt(eps)*(1+abs(I*r1*n1))   % Check for 1+I*r1*n1 == 0
        Cfree = zpk([],[],-P*(1-I*r1*m1),Ts);    % Inverted by Case 6
    else
        Cfree = zpk((1-I*r1*m1)/(1+I*r1*n1),[],P*(1+I*r1*n1),Ts);    % Inverted by Case 4
    end
    Cfixed = zpk([],1,1,Ts);
end
function [Cfree,Cfixed] = PD_DT_Parallel_EvalFcn(P,D,N,Ts,ctrlstruct)
%% PDF to ZPK

% General approach is:
%                                       N
% P + D*N/(1+N*s^-1) --> P + D  -------------------------------
%                                                  (n2*z + m2)
%                                 1   +  N * r2 *  -----------
%                                                    z - 1
%
%
%                           P*(1+N*r2*n2)+D*N          P*(1-N*r2*m2)+D*N
%                          ----------------- z    -   -------------------
%                              1 + N*r2*n2               1 + N*r2*n2
% P + D*N/(1+N*s^-1) -->  -----------------------------------------------
%                                                        1 - N*r2*m2
%                                            z    -     -------------
%                                                        1 + N*r2*n2
%

[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);
b = D*N/(1+N*r2*n2);
c = (1-N*r2*m2)/(1+N*r2*n2);

if D == 0                 % C(z) = P
    Cfree = zpk([],[],P,Ts);                   % Inverted by Case 7
    Cfixed = zpk([],[],1,Ts);
else
    if isinf(N)       % C(z) = P + D*(z-1)/r2/(n2*z+m2)
        if n2==0
            Cfree = zpk((D-P*r2)/D,[],D/r2,Ts);     % Inverted by Case 5
            Cfixed = zpk([],[],1,Ts);
        else
            p = -m2;
            if abs(P+D/r2)<=sqrt(eps)*(abs(P)+abs(D/r2))
                z = [];
                k = P*m2-D/r2;        % Inverted by Case 6.1
            else
                k = P+D/r2;
                z = (D/r2-P*m2)/(P+D/r2);    % Inverted by Case 3
            end
            Cfree = zpk(z,[],k,Ts);
            Cfixed = zpk([],p,1,Ts);
        end
    else                  % C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
        % b1 =  P*(1+N*r2*n2)+D*N  /  1 + N*r2*n2 = P+b
        % b0 =-(P*(1-N*r2*m2)+D*N) /  1 + N*r2*n2 = -(P*c+b)
        % a1 =  1;
        % a0 =  -(1 - N*r2*m2)     /  1 + N*r2*n2
        % zpk(tf([b1 b0], [a1 a0]))
        if abs(P*(1+N*r2*n2)+D*N)<=sqrt(eps)*(abs(P)*(1+N*r2*n2)+abs(D*N))   % Check if b1 == 0
            Cfree = zpk([],c,-(P*c+b),Ts);    % Inverted by Case 6.1
        else
            Cfree = zpk((P*c+b)/(P+b),c,(P+b),Ts);                % Inverted by Case 3
        end
        Cfixed = zpk([],[],1,Ts);
    end
end
function [Cfree,Cfixed] = PD_DT_Ideal_EvalFcn(P,D,N,Ts,ctrlstruct)
%% PDF to ZPK

% General approach is:
%                              (                    N                    )
% P (1 + D*N/(1+N*s^-1)) --> P ( 1 + D  -------------------------------  )
%                              (                           (n2*z + m2)   )
%                              (          1   +  N * r2*  -----------    )
%                              (                               z - 1     )
%
%
%                            (1+N*r2*n2)+D*N             (1-N*r2*m2)+D*N
%                          ----------------- z     -    -----------------
%                              1 + N*r2*n2                1 + N*r2*n2
%                       P -----------------------------------------------
%                                                         1 - N*r2*m2
%                                            z     -     ------------
%                                                         1 + N*r2*n2
%

[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);
b = D*N/(1+N*r2*n2);
c = (1-N*r2*m2)/(1+N*r2*n2);

if D == 0   % C(z) = P
    Cfree = zpk([],[],P,Ts);              % Inverted by Case 7
    Cfixed = zpk([],[],1,Ts);
else                      % C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
    if isinf(N)       % C(z) = P ( 1 + D/r2*(z-1)/(n2*z+m2) )
        if n2==0
            Cfree = zpk((D-r2)/D,[],P*D/r2,Ts);     % Inverted by Case 5
            Cfixed = zpk([],[],1,Ts);
        else
            p = -m2;
            if abs(1+D/r2)<=sqrt(eps)*(1+abs(D/r2))
                z = [];
                k = -P*(D/r2-m2);         % Inverted by Case 6.1
            else
                k = P*(1+D/r2);
                z = (D/r2-m2)/(1+D/r2);  % Inverted by Case 3
            end
            Cfree = zpk(z,[],k,Ts);
            Cfixed = zpk([],p,1,Ts);
        end
    else                  % C(z) = P ( 1 + D*N/( 1+N*r2*(n2*z+m2)/(z-1) ))
        % b1 =   (1+N*r2*n2)+D*N  /  1 + N*r2*n2 = (1+b)
        % b2 = -((1-N*r2*m2)+D*N) /  1 + N*r2*n2 = -(c+b)
        % a1 =  1;
        % a2 =  -(1 - N*r2*m2)      /  1 + N*r2*n2
        % zpk(tf(P*[b1 b2], [a1 a2]))
        if abs((1+N*r2*n2)+D*N)<=sqrt(eps)*((1+N*r2*n2)+abs(D*N))   % Check if b1 == 0
            Cfree = zpk([],c,-P*(c+b),Ts);    % Inverted by Case 6.1
        else
            Cfree = zpk((c+b)/(1+b),c,P*(1+b),Ts);           % Inverted by Case 3
        end
        Cfixed = zpk([],[],1,Ts);
    end
end
function [Cfree,Cfixed] = I_DT_EvalFcn(I,Ts,ctrlstruct)
%% I to ZPK

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);

% C(z) = I * r1*(n1*z+m1)/(z-1)
Cfree = zpk([],[],I,Ts);
if n1==0
    Cfixed = zpk([],1,r1,Ts);
else
    Cfixed = zpk(-m1,1,r1,Ts);
end
function [Cfree,Cfixed] = P_DT_EvalFcn(P,Ts)
%% P to ZPK

% C(s) = P
Cfree = zpk([],[],P,Ts);
Cfixed = zpk([],[],1,Ts);



% local functions
function localparamcheck(paramName,param,Controller)
if ~isempty(regexpi(Controller,paramName,'once'))
    if isnumeric(param) && isscalar(param) && isfinite(param) && isreal(param)
        % do nothing
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPID')
    end
end

% local functions
function localparamcheckN(param,Controller)
if ~isempty(regexpi(Controller,'D','once'))
    if isnumeric(param) && isscalar(param) && ~isnan(param) && isreal(param)
        if param <= 0
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
        end
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPID')
    end
end

function [r,n,m] = getDTMethodCoeff(Method,Ts)
% Integration methods:
%
%   1            n*z + m
%   -  --> r *  ----------
%   s              z - 1
%
% Forward Euler : r = Ts  ; n = 0; m = 1;
% Backward Euler: r = Ts  ; n = 1; m = 0;
% Trapezoidal   : r = Ts/2; n = 1; m = 1;

if strcmpi(Method,'Forward Euler')
    r = Ts;   n = 0; m = 1;
elseif strcmpi(Method,'Backward Euler')
    r = Ts;   n = 1; m = 0;
elseif strcmpi(Method,'Trapezoidal')
    r = Ts/2; n = 1; m = 1;
end
