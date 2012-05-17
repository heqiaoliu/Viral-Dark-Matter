function [P, I, D, N] = utPID1dof_getPIDNfromZPK(z,p,k,Ts,ctrlstruct)
% UTPID1DOF_GETPIDNFROMZPK is for internal use only.
% This utility function returns the P,I,D,N values given the ZPK of the
% equivalent compensator and a structure that describes the realization of
% the controller. The returned values will be empty if they are not
% required by the ctrlstruct. For example, if ctrlstruct.Controller = 'PI',
% the output will include D = [] and N = [].

% Author(s): Murad Abu-Khalaf  27-May-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/03/08 21:28:17 $

% Reroute for the appropriate Inv subfunction
P = []; I = []; D = []; N = [];
switch upper(ctrlstruct.Controller)
    case {'PID','PIDF'}
        if strcmpi(ctrlstruct.Form,'Parallel')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [P, I, D, N] = PID_CT_Parallel_InvFcn(z,p,k);
            else
                [P, I, D, N] = PID_DT_Parallel_InvFcn(z,p,k,Ts,ctrlstruct);
            end
        elseif strcmpi(ctrlstruct.Form,'Ideal')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [P, I, D, N] = PID_CT_Ideal_InvFcn(z,p,k);
            else
                [P, I, D, N] = PID_DT_Ideal_InvFcn(z,p,k,Ts,ctrlstruct);
            end
        end
    case 'PI'
        if strcmpi(ctrlstruct.Form,'Parallel')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [P, I] = PI_CT_Parallel_InvFcn(z,p,k);
            else
                [P, I] = PI_DT_Parallel_InvFcn(z,p,k,Ts,ctrlstruct);
            end
        elseif strcmpi(ctrlstruct.Form,'Ideal')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [P, I] = PI_CT_Ideal_InvFcn(z,p,k);
            else
                [P, I] = PI_DT_Ideal_InvFcn(z,p,k,Ts,ctrlstruct);
            end
        end
    case {'PD','PDF'}
        if strcmpi(ctrlstruct.Form,'Parallel')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [P, D, N] = PD_CT_Parallel_InvFcn(z,p,k);
            else
                [P, D, N] = PD_DT_Parallel_InvFcn(z,p,k,Ts,ctrlstruct);
            end
        elseif strcmpi(ctrlstruct.Form,'Ideal')
            if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
                [P, D, N] = PD_CT_Ideal_InvFcn(z,p,k);
            else
                [P, D, N] = PD_DT_Ideal_InvFcn(z,p,k,Ts,ctrlstruct);
            end
        end
    case 'P'
        if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
            P = P_CT_InvFcn(z,p,k);
        else
            P = P_DT_InvFcn(z,p,k,Ts,ctrlstruct);
        end
    case 'I'
        if strcmpi(ctrlstruct.TimeDomain,'Continuous-time')
            I = I_CT_InvFcn(z,p,k);
        else
            I = I_DT_InvFcn(z,p,k,Ts,ctrlstruct);
        end
end


%---------------- Continuous-time ZPK to PIDF -----------------------------
function [P, I, D, N] = PID_CT_Parallel_InvFcn(z,p,k)
%% ZPK to PIDF

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (s-p1)(s-p2)
% Case B:   k *  ........    / s^2

%  Case A
if (length(p(p ~= 0))==2)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

%  Case B:
%  Remove free integrators added if the compensator does currently
%  have a fixed component.  If there is a fixed component then error out
%  since the derivative time constant cannot be zero.
if any(p == 0)
    if length(p(p == 0))==1
        p(p == 0) = [];
        isintegrating = true;
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    isintegrating = false;
end

% Check if non-integrating pole results in a non positive N
if numel(p)==1
    N = -p;
    if N <= 0
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    N = [];
end

% ATTENTION: When k=0, there could be a discontinuity goin from ZPK to
% Gains to ZPK again.
% if k == 0
%     P = 0; I = 0; D = 0;
%     TunableParameters(6).Value = P;
%     TunableParameters(7).Value = I;
%     TunableParameters(8).Value = D;
%     return;
% end

% Generally with finite N,
%                                    (P+D*N) s^2 + (P*N+I) s + I*N
% C(s) = P + I/s + Ds/(s/N+1) -->    -------------------------------
%                                              s (s+N)
% and with N=inf,
%                                         D s^2 + P s + I
% C(s) = P + I/s + Ds/(s/N+1) -->    -------------------------------
%                                                 s


% The following Zero/Pole configurations could be mapped back to a Parallel
% PIDF:

% Case 1:   k * (s-z1)(s-z2) / s(s-p2)
%           C(s) = P + I/s + Ds/(s/N+1)
%           PID are nonzero, N is finite (can handle P = 0)
%
% Case 2:   k * (s-z1)(s-z2) / s
%           C(s) = P + I/s + Ds
%           PID are nonzero, N is infinite (can handle P = 0)
%
% Case 2.1: k * (s-z1) / s(s-p2)
%           C(s) = P + I/s + Ds/(s/N+1)
%           PID are nonzero, N is finite, and P+DN = 0
%
% Case 3:   k * (s-z1) / (s-p1)
%           C(s) = P + Ds/(s/N+1)
%           PD are nonzero, I is zero, N is finite  (can handle P = 0)
%
% Case 4:   k * (s-z1) / s
%           C(s) = P + I/s
%           PI are nonzero, D is zero, N can be anything
%
% Case 5:   k * (s-z1)
%           C(s) = P + Ds
%           PD are nonzero, I is zero, N is infinite (can handle P = 0)
%
% Case 5.1: k / s(s-p2)
%           C(s) = P + I/s + Ds/(s/N+1)
%           PIDF are nonzero, N is finite, P+DN = 0, and PN+I = 0
%
% Case 6:   k / s
%           C(s) = I/s
%           I is nonzero, PD are zero, N can be anything
%
% Case 6.1: k / (s-p1)
%           C(s) = P + Ds/(s/N+1)
%           PD are nonzero, I is zero, N is finite, and P+DN = 0
%
% Case 7:  k
%           P is nonzero, ID are zero, N can be anything (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 2
        z1 = z(1); z2 = z(2);
        if numel(p)==1 && isintegrating     % Case 1
            I = k*real(z1*z2)/N; % I = k*z1*z2/N
            P = -(k*(real(z1+z2))+I)/N; % P = -(k*(z1+z2)+I)/N
            D = (k-P)/N;
        elseif numel(p)==0 && isintegrating % Case 2
            N = inf;
            D = k;
            I = k*real(z1*z2); % I = k*z1*z2
            P = -k*(real(z1+z2)); %  P = -k*(z1+z2)
        else  %  k*(s-z1)(s-z2)  && k*(s-z1)(s-z2)/(s-p1) are not allowed
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
    case 1
        z1=z(1);
        if numel(p) == 1 && isintegrating   % Case 2.1
            I = -k*z1/N;
            P = (k-I)/N;
            D = -P/N;
        elseif numel(p) == 1                % Case 3
            I = 0;
            P = -k*z1/N;
            D = (k-P)/N;
        elseif isintegrating                % Case 4
            D = 0;
            P = k;
            I = -k*z1;
        else                                % Case 5
            I = 0;
            N = inf;
            D = k;
            P = -k*z1;
        end
    case 0
        if numel(p) == 1 && isintegrating   % Case 5.1
            I = k/N;
            P = -I/N;
            D = -P/N;
        elseif isintegrating                % Case 6
            I = k;
            P = 0;
            D = 0;
        elseif numel(p) == 1                % case 6.1
            I = 0;
            P = k/N;
            D = -P/N;
        else                                % Case 7
            P = k;
            I = 0;
            D = 0;
        end
end
function [P, I, D, N] = PID_CT_Ideal_InvFcn(z,p,k)
%% ZPK to PIDF

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (s-p1)(s-p2)
% Case B:   k *  ........    / s^2

%  Case A:
if length(p(p ~= 0))==2
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

%  Case B:
%  Remove free integrators added if the compensator does currently
%  have a fixed component.  If there is a fixed component then error out
%  since the derivative time constant cannot be zero.
if any(p == 0)
    if length(p(p == 0))==1
        p(p == 0) = [];
        isintegrating = true;
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    isintegrating = false;
end

% Check if non-integrating pole results in a non positive N
if numel(p)==1
    N = -p;
    if N <= 0
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    N = [];
end

% Generally with finite N,
%                                          (1+D*N) s^2 + (I+N) s + I*N
% C(s) = P (1 + I/s + Ds/(s/N+1) ) --> P  -------------------------------
%                                                    s (s+N)
% and with N=inf,
%                                                D s^2 + s + I
% C(s) = P (1 + I/s + Ds/(s/N+1) ) --> P  -------------------------------
%                                                       s

% The following Zero/Pole configurations could be mapped back to an Ideal
% PIDF:

% Case 1:   k * (s-z1)(s-z2) / s(s-p2)
%           C(s) = P ( 1 + I/s + Ds/(s/N+1) )
%           PID are nonzero, N is finite
%           Ideal form cannot handle z1*z2+N*(z1+z2)==0. Note that this
%           covers expressions including the case ( z1=0 && z2=0 ).
%
% Case 2:   k * (s-z1)(s-z2) / s
%           C(s) = P ( 1 + I/s + Ds )
%           PID are nonzero, N is infinite
%           Ideal form cannot handle z1+z2==0. Note this covers
%           expressions includes the case (z1=0&&z2=0).
%
% Case 2.1: k * (s-z1) / s(s-p2)
%           C(s) = P ( 1 + I/s + Ds/(s/N+1) )
%           PID are nonzero, N is finite, and 1+DN = 0
%           Ideal form cannot handle z1=-N.
%
% Case 3:   k * (s-z1) / (s-p1)
%           C(s) = P ( 1 + Ds/(s/N+1) )
%           PD are nonzero, I is zero, N is finite
%           Ideal form cannot handle z1 = 0
%
% Case 4:   k * (s-z1) / s
%           C(s) = P (1 + I/s)
%           PI are nonzero, D is zero, N can be anything
%
% Case 5:   k * (s-z1)
%           C(s) = P (1 + Ds)
%           PD are nonzero, I is zero, N is infinite
%           Ideal form cannot handle z1 = 0
%
% Case 5.1: k / s(s-p2)
%           C(s) = P (1 + I/s + Ds/(s/N+1))
%           PIDF are nonzero, N is finite, 1+DN = 0, and N+I = 0
%
% Case 5.2: k / (s-p1)
%           C(s) = P (1 + Ds/(s/N+1))
%           PD are nonzero, I is zero, N is finite, and 1+DN = 0
%
% Case 6:   k
%           P is nonzero, ID are zero, N can be anything (can handle P = 0)

% Ideal form cannot handle
%           k / s
%           C(s) = I/s

% Compute the inverse function
switch numel(z)
    case 2
        z1=z(1);z2=z(2);
        if numel(p)==1 && isintegrating     % Case 1
            % Check if z1*z2+N*(z1+z2)==0
            if abs(z1*z2+N*(z1+z2))<=sqrt(eps)*(abs(z1*z2)+N*abs(z1)+N*abs(z2));
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                DN1 = -N^2/real(z1*z2+N*(z1+z2));  %(1+D*N)=-N^2/(z1*z2+N(z1+z2))
                D = (DN1-1)/N;
                P = k/DN1;
                I = real(z1*z2)*DN1/N;   % I = z1*z2*(1+D*N)/N
            end
        elseif numel(p)==0 && isintegrating % Case 2
            % Check if z1+z2==0
            if abs(z1+z2)<=sqrt(eps)*(abs(z1)+abs(z2));
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                N = inf;
                D = -1/real(z1+z2);   % D = -1 / (z1+z2)
                P = k/D;  % D~=0 because of the error message checking
                I = real(z1*z2)*D;    % I = z1*z2*D
            end
        else  %  k*(s-z1)(s-z2)  && k*(s-z1)(s-z2)/(s-p1) are not allowed
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
    case 1
        z1=z(1);
        if numel(p) == 1 && isintegrating   % Case 2.1
            D = -1/N;
            if z1==-N
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                I = -z1*N/(z1+N);
                P = k*(z1+N)/N^2;    % P = k/(I+N) and for all z1, I~=-N. Plot I(z1)!
            end
        elseif numel(p) == 1                % Case 3
            I = 0;
            if z1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                D = -(N+z1)/(N*z1);  %  1+D*N = N/-z1;
                P = -k*z1/N;        %  P = k/(1+D*N);
            end
        elseif isintegrating                % Case 4
            P = k;
            I = -z1;
            D = 0;
        else
            if z1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else                             % Case 5
                I = 0;
                N = inf;
                D = -1/z1;
                P = -k*z1; %P = k/D;
            end
        end
    case 0
        if numel(p) == 1 && isintegrating         % Case 5.1
            I = -N;
            D = -1/N;
            P = k/(I*N); % I~=0 because N~=0
        elseif numel(p) == 1                      % case 5.2
            D = -1/N;
            I = 0;
            P = k/N;
        elseif numel(p) == 0 && ~isintegrating    % Case 6
            P = k;
            I = 0;
            D = 0;
        else  % Covers the case C(s) = I/s
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
end
function [P, I]       = PI_CT_Parallel_InvFcn(z,p,k)
%% ZPK to PI

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (s-p1)
% Case B:   k *  (s-z1)

%  Case A:
if numel(p)==1 && p ~= 0
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
elseif numel(p)==1 && p == 0
    isintegrating = true;
else
    isintegrating = false;
end

%  Case B:
if isempty(p) && ~isempty(z)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

% The following Zero/Pole configurations could be mapped back to a Parallel
% PI:

% Case 4:   k * (s-z1) / s
%           C(s) = P + I/s
%           PI are nonzero
%
% Case 6:   k / s
%           C(s) = I/s
%           I is nonzero, P is zero
%
% Case 7:   k
%           P is nonzero, I is zero (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 1               % Case 4
        P = k;
        I = -k*z;
    case 0
        if isintegrating % Case 6
            P = 0;
            I = k;
        else             % Case 7
            P = k;
            I = 0;
        end
end
function [P, I]       = PI_CT_Ideal_InvFcn(z,p,k)
%% ZPK to PI

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (s-p1)
% Case B:   k *  (s-z1)
% Case C:   k / s

%  Case A:
if numel(p)==1 && p ~= 0
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
elseif numel(p)==1 && p == 0
    isintegrating = true;
else
    isintegrating = false;
end

%  Case B & Case C:
if isempty(p) ~= isempty(z)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end


% The following Zero/Pole configurations could be mapped back to an Ideal
% PI:

% Case 4:   k * (s-z1) / s
%           C(s) = P (1 + I/s)
%           PI are nonzero
%
% Case 6:   k
%           P is nonzero, I is zero (can handle P = 0)


% Compute the inverse function
if isintegrating       % Case 4
    P = k;
    I = -z;
else                   % Case 6
    P = k;
    I = 0;
end
function [P, D, N]    = PD_CT_Parallel_InvFcn(z,p,k)
%% ZPK to PDF

% Error out since N cannot be zero.
if any(p == 0)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
end

% The following Zero/Pole configurations could be mapped back to a Parallel
% PDF:

% Case 3:   k * (s-z1) / (s-p1)
%           C(s) = P + Ds/(s/N+1)
%           PD are nonzero, N is finite (can handle P=0)
%
% Case 5:   k * (s-z1)
%           C(s) = P + Ds
%           PD are nonzero, N is infinite (can handle P=0)
%
% Case 6.1: k / (s-p1)
%           C(s) = P + Ds/(s/N+1)
%           PD are nonzero, N is finite, and P+DN = 0
%
% Case 7:  k
%           P is nonzero, D is zero, N can be anything (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 1
        if numel(p) == 1     % Case 3
            N = -p;
            P = -z*k/N;
            D = (k-P)/N;
        else
            P = -k*z;        % Case 5
            D = k;
            N = inf;
        end
    case 0
        if numel(p) == 1     % case 6.1
            N = -p;
            P = k/N;
            D = -P/N;
        else                 % Case 7
            P = k;
            D = 0;
            N = [];
        end
end
function [P, D, N]    = PD_CT_Ideal_InvFcn(z,p,k)
%% ZPK to PDF

% Error out since N cannot be zero.
if any(p == 0)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
end

% There are nine main possible Zero/Pole configurations and 3 edge cases
% possible all are listed by the # of zeros:

% Case 3:   k * (s-z1) / (s-p1)
%           C(s) = P ( 1 + Ds/(s/N+1) )
%           PD are nonzero, N is finite
%           Ideal form cannot handle z1 = 0
%
% Case 5:   k * (s-z1)
%           C(s) = P (1 + Ds)
%           PD are nonzero, N is infinite
%           Ideal form cannot handle z1 = 0
%
% Case 5.2: k / (s-p1)
%           C(s) = P (1 + Ds/(s/N+1))
%           PD are nonzero, N is finite, and 1+DN = 0
%
% Case 6:   k
%           P is nonzero, D is zero, N can be anything (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 1
        z1=z(1);
        if numel(p) == 1                     % Case 3
            N = -p;
            if z1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                D = -(N+z1)/(N*z1);  %  1+D*N = N/-z1;
                P = -k*z1/N;        %  P = k/(1+D*N);
            end
        else
            if z1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else                             % Case 5
                N = inf;
                D = -1/z1;
                P = -k*z1; %P = k/D;
            end
        end
    case 0
        if numel(p) == 1                    % case 5.2
            N = -p;
            P = k/N;
            D = -1/N;
        else                                % Case 6
            P = k;
            D = 0;
            N = [];
        end
end
function I            = I_CT_InvFcn(~,p,k)
%% ZPK to I

% The following cases will pass the constraints requirements but should be
% blocked.
%
% Case A:   k *  ........    / (s-p1)
% Case B:   k

%  Case A & B:
if (numel(p)==0) ||  any(p ~= 0)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

% Case 1:   k / s
%           C(s) = I/s

% Compute the inverse function
I = k;
function P            = P_CT_InvFcn(~,~,k)
%% ZPK to P

% Case 1:   k
%           C(s) = P

% Compute the inverse function
P = k;


%---------------- Discrete-time ZPK to PIDF -------------------------------
function [P, I, D, N] = PID_DT_Parallel_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to PIDF

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (z-p1)(z-p2)
% Case B:   k *  ........    / (z-1)^2
% Case C:   k * (z-z1)(z-z2)
% Case D:   k * (z-z1)(z-z2) / (z-p1)

%  Case A:
if length(p(p ~= 1))==2
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

%  Case B:
%  Remove free integrators added if the compensator does currently
%  have a fixed component.  If there is a fixed component then error out
%  since the derivative time constant cannot be zero.
if any(p == 1)
    if length(p(p == 1))==1
        p(p == 1) = [];
        isintegrating = true;
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    isintegrating = false;
end

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);
[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);

% Check if non-integrating pole results in a non positive N
if numel(p) == 1
    if (n2==1 && p==-m2) % p*n2+m2==0
        N = inf;
    else
        N = (1-p)/(r2*(p*n2+m2));
        if N<=0   % N = 0 will give an integrating pole when n2 = 0.
            % N < 0 may result in 1+N*r2*n2==0 which may give NaN for PD
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
        end
    end
else
    N = [];
end

% ATTENTION: When k=0, there could be a discontinuity goin from ZPK to
% Gains to ZPK again.
% if k == 0
%     P = 0; I = 0; D = 0;
%     TunableParameters(6).Value = P;
%     TunableParameters(7).Value = I;
%     TunableParameters(8).Value = D;
%     return;
% end

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

% The following Zero/Pole configurations could be mapped back to a Parallel
% PIDF:

% Case 1:   k * (z-z1)(z-z2) / (z-1)(z-p2)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PIDF are nonzero, N is infinite n2=1 (can handle P = 0)
%           - PIDF are nonzero, N is finite (can handle P = 0)
%
% Case 2:   k * (z-z1)(z-z2) / (z-1)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1) + D/r2*(z-1)/(n2*z+m2)
%           PIDF are nonzero, N is infinite, n2=0 (can handle P = 0)
%
% Case 2.1: k * (z-z1) / (z-1)(z-p2)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PIDF are nonzero, N is infinite, and P*n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and n2 = 1 (can handle P=0)
%           - PIDF are nonzero, N is finite, and P*n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and (can handle P=0)
%
% Case 3:   k * (z-z1) / (z-p1)
%           C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PD are nonzero, I is zero, N is infinite, p1=-m2 (can handle P = 0)
%           - PD are nonzero, I is zero, N is finite (can handle P = 0)
%
% Case 4:   k * (z-z1) / (z-1)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1)
%           - PI are nonzero, D = 0, N can be anything, (can handle P = 0
%           with n1 = 1)
%           - PIDF are nonzero, N is infinite,P*n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and n2 = 0 (can handle P=0)
%
% Case 5:   k * (z-z1)
%           C(z) = P + D*(z-1)/r2/(n2*z+m2)
%           PD are nonzero, I is zero, N is infinite, n2=0 (can handle P =
%           0)
%
% Case 5.1: k / (z-1)(z-p2)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1) + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PIDF are nonzero, N is infinite, and P*n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and P*(m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2 = b1 = 0 and n2=1 (can handle P=0)
%           - PIDF are nonzero, N is finite, and P*n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and P*(m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2 = b1 = 0 (can handle P=0)
%
% Case 6:   k / (z-1)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1)
%           - PI are nonzero, D = 0, and P+I*r1*n1 = 0  (can handle P = 0 with n1 = 0)
%           - PIDF are nonzero, N is infinite,P*n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and P*(m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2 = b1 = 0 and n2 = 0 (can
%           handle P=0)
%
% Case 6.1: k / (z-p1)
%           PD are nonzero, I is zero, N is infinite, p1=-m2, P+D/r2=0, n2=1 (can handle P = 0)
%           PD are nonzero, I is zero, N is finite, P(1+N*r2*n2)+D*N=0 (can handle P = 0)
%
% Case 7:   k
%           P is nonzero, ID are zero, N can be anything (can handle P = 0)


% Compute the inverse function
switch numel(z)
    case 2
        z1=z(1);z2=z(2);
        b2 = k;
        b1 = -k*(real(z1+z2));
        b0 = k*real(z1*z2);
        if numel(p)==1 && isintegrating     % Case 1
            if (n2==1 && p==-m2) % p*n2+m2==0
                N = inf;
                I = (b2+b1+b0)/r1/(n1+m1)/(n2+m2);
                P = (b2-b0-I*r1*(n1*n2-m1*m2))/(n2+m2);
                D = r2*(b2-P*n2-I*r1*n1*n2);
            else
                I = (b2+b1+b0)/r1/(n1+m1)/(1-p);  % Note (1-p) cannot be zero, taken care of by the error message
                P = (b2-b0-I*r1*(n1+m1*p))/(1-p);
                D = (1+N*r2*n2)*(b2-P-I*r1*n1)/N; % N=0 is not possible due to the error message
            end
        elseif numel(p)==0 && isintegrating % Case 2
            N = inf;
            if n2==0
                I = (b2+b1+b0)/r1/(n1+m1)/(n2+m2);
                P = (b2-b0-I*r1*(n1*n2-m1*m2))/(n2+m2);
                D = r2*(b2-P*n2-I*r1*n1*n2);
            else
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            end
        else  % Case C and Case D are not allowed
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
    case 1
        z1=z(1);
        if numel(p) == 1 && isintegrating   % Case 2.1
            b2 = 0;
            b1 = k;
            b0 = -k*z1;
            if (n2==1 && p==-m2) % p*n2+m2==0
                N = inf;
                I = (b2+b1+b0)/r1/(n1+m1)/(n2+m2);
                P =( b2-b0-I*r1*(n1*n2-m1*m2))/(n2+m2);
                D = r2*(b2-P*n2-I*r1*n1*n2);
            else
                I = (b2+b1+b0)/r1/(n1+m1)/(1-p);  % Note (1-p) cannot be zero, taken care of by the error message
                P = (b2-b0-I*r1*(n1+m1*p))/(1-p);
                D = (1+N*r2*n2)*(b2-P-I*r1*n1)/N; % N=0 is not possible due to the error message
            end
        elseif numel(p) == 1                % Case 3
            if (n2==1 && p==-m2) % p*n2+m2==0
                N = inf;
                I = 0;
                P = (k-k*z1)/(n2+m2);
                D = r2*(k-P*n2);
            else
                I = 0;
                P = (1+N*r2*n2)*(k-k*z1)/(r2*N*(n2+m2));
                D = (1+N*r2*n2)*(k-P)/N;
            end
        elseif isintegrating                % Case 4
            I = (k-k*z1)/r1/(n1+m1);
            P = k-I*r1*n1;
            D = 0;
        else                                % Case 5
            if n2==0
                N = inf;
                D = r2*k;
                P = k*(1-z1);
                I = 0;
            else
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            end
        end
    case 0
        if numel(p) == 1 && isintegrating   % Case 5.1
            b2 = 0;
            b1 = 0;
            b0 = k;
            if (n2==1 && p==-m2) % p*n2+m2==0
                N = inf;
                I = (b2+b1+b0)/r1/(n1+m1)/(n2+m2);
                P = (b2-b0-I*r1*(n1*n2-m1*m2))/(n2+m2);
                D = r2*(b2-P*n2-I*r1*n1*n2);
            else
                I = (b2+b1+b0)/r1/(n1+m1)/(1-p);  % Note (1-p) cannot be zero, taken care of by the error message
                P = (b2-b0-I*r1*(n1+m1*p))/(1-p);
                D = (1+N*r2*n2)*(b2-P-I*r1*n1)/N; % N=0 is not possible due to the error message
            end
        elseif isintegrating                % Case 6
            I = k/r1/(n1+m1);
            P = -r1*n1*I;
            D = 0;
        elseif numel(p) == 1                % case 6.1
            if (n2==1 && p==-m2) % p*n2+m2==0
                N = inf;
                I = 0;
                P = k/(n2+m2);
                D = -r2*n2*P;
            else
                P = (1+N*r2*n2)*k/(N*r2*(n2+m2));
                D = -P*(1+N*r2*n2)/N;
                I = 0;
            end
        else                                % Case 7
            P = k;
            I = 0;
            D = 0;
        end
end
function [P, I, D, N] = PID_DT_Ideal_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to PIDF

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (z-p1)(z-p2)
% Case B:   k *  ........    / (z-1)^2
% Case C:   k * (z-z1)(z-z2)
% Case D:   k * (z-z1)(z-z2) / (z-p1)

%  Case A:
if length(p(p ~= 1))==2
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

%  Case B:
%  Remove free integrators added if the compensator does currently
%  have a fixed component.  If there is a fixed component then error out
%  since the derivative time constant cannot be zero.
if any(p == 1)
    if length(p(p == 1))==1
        p(p == 1) = [];
        isintegrating = true;
    else
        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
    end
else
    isintegrating = false;
end

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);
[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);

% Check if non-integrating pole results in a non positive N
if numel(p) == 1
    if (n2==1 && p==-m2) % p*n2+m2==0
        N = inf;
    else
        N = (1-p)/(r2*(p*n2+m2));
        if N<=0   % N = 0 will give an integrating pole when n2 = 0.
            % N < 0 may result in 1+N*r2*n2==0 which may give NaN for PD
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
        end
    end
else
    N = [];
end


% ATTENTION: When k=0, there could be a discontinuity goin from ZPK to
% Gains to ZPK again.
% if k == 0
%     P = 0; I = 0; D = 0;
%     TunableParameters(6).Value = P;
%     TunableParameters(7).Value = I;
%     TunableParameters(8).Value = D;
%     return;
% end

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

% The following Zero/Pole configurations could be mapped back to PIDF:

% Case 1:   k * (z-z1)(z-z2) / (z-1)(z-p2)
%           C(z) = P ( 1 + I * r1*(n1*z+m1)/(z-1) + D*N/(1+N*r2*(n2*z+m2)/(z-1) ) )
%           - PIDF are nonzero, N is infinite n2=1
%           - PIDF are nonzero, N is finite (can handle P = 0)
%
% Case 2:   k * (z-z1)(z-z2) / (z-1)
%           C(z) = P (1 + I * r1*(n1*z+m1)/(z-1) + D/r2*(z-1)/(n2*z+m2) )
%           PIDF are nonzero, N is infinite, n2=0 (can handle P = 0)
%
% Case 2.1: k * (z-z1) / (z-1)(z-p2)
%           C(z) = P (1 + I * r1*(n1*z+m1)/(z-1) + D*N/(1+N*r2*(n2*z+m2)/(z-1) ))
%           - PIDF are nonzero, N is infinite, and n2+I*r1*n1*n2+D/r2 = b2 = 0
%           and n2 = 1 (can handle P=0)
%           - PIDF are nonzero, N is finite, and b2 = 0 (can handle P=0)
%
% Case 3:   k * (z-z1) / (z-p1)
%           C(z) = P (1 + D*N/( 1+N*r2*(n2*z+m2)/(z-1) ))
%           - PD are nonzero, I = 0, N is infinite, n2=1,p1=-m2 (can handle P = 0)
%           - PD are nonzero, I = 0, N is finite (can handle P = 0)
%
% Case 4:   k * (z-z1) / (z-1)
%           C(z) = P (1 + I * r1*(n1*z+m1)/(z-1))
%           - PI are nonzero, D = 0, N can be anything, (can handle P = 0 )
%           - PIDF are nonzero, N is infinite, b2 = 0 and n2 = 0 (can
%           handle P=0) Note that this implies indirectly that D = 0
%
% Case 5:   k * (z-z1)
%           C(z) = P (1 + D*(z-1)/(r2*n2*z+r2*m2))
%           PD are nonzero, I is zero, N is infinite, n2=0
%
% Case 5.1: k / (z-1)(z-p2)
%           C(z) = P(1 + I * r1*(n1*z+m1)/(z-1) + D*N/(1+N*r2*(n2*z+m2)/(z-1) ))
%           - PIDF are nonzero, N is infinite, and b2 = 0 and b1 = 0 and n2=1 (can handle P=0)
%           - PIDF are nonzero, N is finite, and b2 = 0 and b1 = 0 (can handle P=0)
%
% Case 6:   k / (z-1)
%           C(z) = P (1 + I * r1*(n1*z+m1)/(z-1))
%           - PI are nonzero, D = 0, and 1+I*r1*n1 = 0  (can handle P)
%           - PIDF are nonzero, N is infinite, b2 = 0 and  b1 = 0 and n2 = 0 (can
%           handle P=0) This actually implies that D = 0 and hence same as
%           the previous case.
%
% Case 6.1: k / (z-p1)
%           C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PD are nonzero, I = 0, N is infinite, p1=-m2, 1+D/r2=0, n2=1 (can handle P = 0)
%           - PD are nonzero, I = 0, N is finite, (1+N*r2*n2)+D*N=0 (can handle P = 0)
%
% Case 7:   k
%           P is nonzero, ID are zero, N can be anything (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 2
        z1=z(1);z2=z(2);
        % Excule 1-z1*z2 == 0 because D becomes inf, and when both
        % discretization methods are Trapezoidal, then I could become inf
        if real(z1*z2) == 1
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
        end
        if numel(p)==1 && isintegrating     % Case 1
            if (n2==1 && p==-m2) % p*n2+m2==0
                %  b2 = n2+I*r1*n1*n2+D/r2;
                %  b1 = (m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2;
                %  b0 = -m2+I*r1*m1*m2+D/r2;
                
                % (b2 + b1 + b0)/b2 = I*r1*(n1+m1)*(n2+m2)/b2
                % (1-z1)*(1-z2) = I*r1*(n1+m1)*(n2+m2)/b2
                
                % (b2 - b0)/b2 = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b2
                % 1-z1*z2      = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b2
                % I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2))
                % where X = (1-z1*z2)/((1-z1)*(1-z2))
                
                if z1 == 1 || z2 == 1
                    I = 0;
                    b2 = (n2+m2)/(1-z1*z2);
                else
                    X = real((1-z1*z2)/((1-z1)*(1-z2)));
                    if abs((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2))<=sqrt(eps)*((n1+m1)*(n2+m2)*abs(X)+ abs((n1*n2-m1*m2)))
                        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
                    end
                    I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2));
                    b2 = I*r1*(n1+m1)*(n2+m2)/((1-z1)*(1-z2));
                end
                
                D  = r2*(b2 - n2 - I*r1*n1*n2);
                
                P = k/b2;   % From equations above, b2 ~= 0
                
                % This could be another approach, one would have to error
                % for the case when (P == 0 and k~=0)
                %
                % PI = (Pb2+Pb1+Pb0)/r1/(n1+m1)/(1-p);
                % P = (Pb2-Pb0-r1*PI*(n1+m1*p))/(1-p);
                % where
                %       Pb2 = k;
                %       Pb1 = -k*(real(z1+z2));
                %       Pb0 = k*real(z1*z2);
            else
                % b2 =  (1+a*n1+b)
                % b1 = -(1+c)-n1*a*c+m1*a-2*b)
                % b0 =  (c-a*m1*c+b)
                
                % (b2 + b1 + b0)/b2 = a*(n1+m1)*(1-c)/b2
                % (1-z1)*(1-z2) = a*(n1+m1)*(1-c)/b2
                
                % (b2 - b0)/b2 = ((1-c) + a*(n1+m1*c) )/b2
                % 1-z1*z2      = ((1-c) + a*(n1+m1*c) )/b2
                % a = (1-c)/((n1+m1)*(1-c)*X - (n1+m1*c))
                % where X = (1-z1*z2)/((1-z1)*(1-z2))
                % I = a/r1;
                
                if z1 == 1 || z2 == 1
                    a = 0;
                    I = a/r1;
                    b2 = (1-p)/(1-z1*z2);
                    % P*(1+b) * ( (z-1)*( z-(c+b)/(1+b) ) / ((z-1) * (z-c))
                else
                    X = real((1-z1*z2)/((1-z1)*(1-z2)));
                    if abs((n1+m1)*(1-p)*X - (n1+m1*p))<=sqrt(eps)*((n1+m1)*(1-p)*abs(X)+ abs((n1+m1*p)))
                        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
                    end
                    a = (1-p)/((n1+m1)*(1-p)*X - (n1+m1*p));
                    I = a/r1;
                    b2 = a*(n1+m1)*(1-p)/((1-z1)*(1-z2));
                end
                
                b  = b2 - 1 - a*n1;
                D = (1+N*r2*n2)*b/N;
                
                P = k/b2;   % From equations above, b2 ~= 0
                
            end
        elseif numel(p)==0 && isintegrating % Case 2
            if n2==0
                N = inf;
                %  b2 = n2+I*r1*n1*n2+D/r2;
                %  b1 = (m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2;
                %  b0 = -m2+I*r1*m1*m2+D/r2;
                
                % (b2 + b1 + b0)/b2 = I*r1*(n1+m1)*(n2+m2)/b2
                % (1-z1)*(1-z2) = I*r1*(n1+m1)*(n2+m2)/b2
                
                % (b2 - b0)/b2 = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b2
                % 1-z1*z2      = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b2
                % I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2))
                % where X = (1-z1*z2)/((1-z1)*(1-z2))
                
                if z1 == 1 || z2 == 1
                    I = 0;
                    b2 = (n2+m2)/(1-z1*z2);
                else
                    X = real((1-z1*z2)/((1-z1)*(1-z2)));
                    % The condition m2 = -(n1+m1)*X will only be satisfied
                    % for non finite z1 or z2. Therefore no need to check
                    % for a division by zero in the following equation for
                    % I                    
                    I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2));
                    b2 = I*r1*(n1+m1)*(n2+m2)/((1-z1)*(1-z2));
                end
                
                D  = r2*(b2 - n2 - I*r1*n1*n2);
                
                P = k/b2;   % b2 ~= 0
                
            else
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            end
        else  % Case C and Case D are not allowed
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
    case 1
        z1=z(1);
        if numel(p) == 1 && isintegrating   % Case 2.1
            if (n2==1 && p==-m2) % p*n2+m2==0
                %  b2 = n2+I*r1*n1*n2+D/r2;  (b2 = 0)
                %  b1 = (m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2;
                %  b0 = -m2+I*r1*m1*m2+D/r2;
                
                % (b2 + b1 + b0)/b1 = I*r1*(n1+m1)*(n2+m2)/b1
                % (1-z1)            = I*r1*(n1+m1)*(n2+m2)/b1
                
                % (b2 - b0)/b1 = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b1
                % z1          = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b1
                % I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2))
                % where X = z1/(1-z1)
                
                if z1 == 1
                    I = 0;
                    D = -r2*n2; % (b2 = 0)
                    b1 = m2+n2;
                else
                    X = z1/(1-z1);
                    if abs((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2))<=sqrt(eps)*((n1+m1)*(n2+m2)*abs(X)+ abs((n1*n2-m1*m2)))
                        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
                    end
                    I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2));
                    b1 = I*r1*(n1+m1)*(n2+m2)/(1-z1);
                    D = -r2*(n2+I*r1*n1*n2); % (b2 = 0)
                end
                
                P = k/b1;   % b1 ~= 0
                
            else
                % b2 =  (1+a*n1+b)   (b2 = 0)
                % b1 = -(1+c)-n1*a*c+m1*a-2*b
                % b0 =  (c-a*m1*c+b)
                
                % (b2 + b1 + b0)/b1 = a*(n1+m1)*(1-c)/b1
                % (1-z1)            = a*(n1+m1)*(1-c)/b1
                
                % (b2 - b0)/b1 = ((1-c) + a*(n1+m1*c) )/b1
                %  z1          = ((1-c) + a*(n1+m1*c) )/b1
                % a = (1-c)/((n1+m1)*(1-c)*X - (n1+m1*c))
                % where X = z1/(1-z1)
                % I = a/r1;
                
                if z1 == 1
                    I = 0;
                    b = -1;
                    b1 = 1-p;
                else
                    X = z1/(1-z1);
                    if abs((n1+m1)*(1-p)*X - (n1+m1*p))<=sqrt(eps)*((n1+m1)*(1-p)*abs(X)+ abs((n1+m1*p)))
                        ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
                    end
                    a = (1-p)/((n1+m1)*(1-p)*X - (n1+m1*p));
                    I = a/r1;
                    b1 = a*(n1+m1)*(1-p)/(1-z1);
                    b = (-(1+p)-n1*a*p+m1*a-b1)/2;
                end
                
                D = (1+N*r2*n2)*b/N;
                
                P = k/b1;   % b1 ~= 0
            end
        elseif numel(p) == 1                % Case 3
            if z1 == 1
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
            end
            I = 0;
            if (n2==1 && p==-m2) % p*n2+m2==0
                D = r2*(n2*z1+m2)/(1-z1);
                P = k*(1-z1)/(n2+m2);   % P = k/(n2+D/r2);
            else
                D = ((1+N*r2*n2)*z1-(1-N*r2*m2))/N/(1-z1);
                P = k*(1+N*r2*n2)*(1-z1)/(N*r2*(n2+m2)); % P = k*(1+N*r2*n2)/((1+N*r2*n2)+D*N);
            end
        elseif isintegrating                % Case 4
            if (n1==1 && z1==-m1) % n1*z1+m1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                I = (1-z1)/r1/(n1*z1+m1);
                P = k*(n1*z1+m1)/(m1+n1); % P = k/(1+I*r1*n1)
            end
            D = 0;
        else                                % Case 5
            if n2==0
                if z1 == 1
                    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN');
                end
                I = 0;
                N = inf;
                D = r2/(1-z1);
                P = k*r2/D;
            else
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            end
        end
    case 0
        if numel(p) == 1 && isintegrating   % Case 5.1
            % Pb2 = 0;
            % Pb1 = 0;
            % Pb0 = k;
            if (n2==1 && p==-m2) % p*n2+m2==0
                
                %  b2 = n2+I*r1*n1*n2+D/r2; (b2 = 0)
                %  b1 = (m2-n2)+I*r1*(n1*m2+m1*n2)-2*D/r2; (b1 = 0)
                %  b0 = -m2+I*r1*m1*m2+D/r2;
                
                % (b2 + b1 + b0)/b0 = I*r1*(n1+m1)*(n2+m2)/b0
                % 1                 = I*r1*(n1+m1)*(n2+m2)/b0
                
                % (b2 - b0)/b0 = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b0
                % -1           = ((n2+m2) + I*r1*(n1*n2-m1*m2))/b0
                % I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2))
                % where X = -1
                
                X = -1;
                I = (n2+m2)/r1/((n1+m1)*(n2+m2)*X - (n1*n2-m1*m2)); % The denominator here can never be zero
                b0 = I*r1*(n1+m1)*(n2+m2);
                
                D  = r2*(b0+m2-I*r1*m1*m2);
                P = k/b0;   % From equations above, b0 ~= 0
            else
                % b2 =  (1+a*n1+b)
                % b1 = -(1+c)-n1*a*c+m1*a-2*b)
                % b0 =  (c-a*m1*c+b)
                
                % (b2 + b1 + b0)/b0 = a*(n1+m1)*(1-c)/b0
                % 1                 = a*(n1+m1)*(1-c)/b0
                
                % (b2 - b0)/b0 = ((1-c) + a*(n1+m1*c) )/b0
                % -1           = ((1-c) + a*(n1+m1*c) )/b0
                % a = (1-c)/((n1+m1)*(1-c)*X - (n1+m1*c))
                % where X = -1
                % I = a/r1;
                
                X = -1;
                a = (1-p)/((n1+m1)*(1-p)*X - (n1+m1*p)); % The denominator here can never be zero
                I = a/r1;
                b0 = a*(n1+m1)*(1-p);
                
                b  = b0 - p + a*m1*p;
                D = (1+N*r2*n2)*b/N;
                
                P = k/b0;   % b0 ~= 0
            end
        elseif isintegrating                % Case 6
            D = 0;
            if n1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                I = -1/r1/n1;
                P = -k*n1/(n1+m1); % P = -k/(1-I*r1*m1)
            end
        elseif numel(p) == 1                % case 6.1
            I = 0;
            if (n2==1 && p==-m2) % p*n2+m2==0
                D = -r2*n2;
                P = k/(n2+m2);
            else
                D = -(1+N*r2*n2)/N;
                P = k*(1+N*r2*n2)/(r2*N*(n2+m2));
            end
        else                                % Case 7
            P = k;
            I = 0;
            D = 0;
        end
end
function [P, I]       = PI_DT_Parallel_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to PI

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (z-p1)
% Case B:   k *  (z-z1)

%  Case A:
if ~isempty(p) && p ~= 1
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
elseif p == 1
    isintegrating = true;
else
    isintegrating = false;
end
%  Case B:
if isempty(p) && ~isempty(z)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

% General approach is
%                  (P+r1*n1*I)*z - (P-m1*r1*I)
% P + I s^-1 -->  ------------------------
%                            z - 1

% The following Zero/Pole configurations could be mapped back to a Parallel
% PI:

% Case 4:   k * (z-z1) / (z-1)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1)
%           - PI are nonzero, (can handle P = 0 with n1 = 1)
%
% Case 6:   k / (z-1)
%           C(z) = P + I * r1*(n1*z+m1)/(z-1)
%           - PI are nonzero, and P+I*r1*n1 = 0  (can handle P = 0 with n1 = 0)
%
% Case 7:   k
%           P is nonzero, ID are zero, N can be anything (can handle P = 0)

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);

% Compute the inverse function
switch numel(z)
    case 1                              % Case 4
        z1 = z(1);
        I = (k-k*z1)/r1/(n1+m1);
        P = k-I*r1*n1;
    case 0
        if isintegrating                % Case 6
            I = k/r1/(n1+m1);
            P = -r1*n1*I;
        else                            % Case 7
            P = k;
            I = 0;
        end
end
function [P, I]       = PI_DT_Ideal_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to PI

% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (z-p1)
% Case B:   k *  (z-z1)

%  Case A:
if any(p ~= 1)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
elseif any(p == 1)
    isintegrating = true;
else
    isintegrating = false;
end

%  Case B:
if isempty(p) && ~isempty(z)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end


% General approach is
%                         (1+r1*n1*I)*z - (1-m1*r1*I)
% P (1 + I s^-1) --> P * -------------------------
%                                 z - 1

% There are nine main possible Zero/Pole configurations and 3 edge cases
% possible all are listed by the # of zeros:

% Case 4:   k * (z-z1) / (z-1)
%           C(z) = P (1 + I * r1*(n1*z+m1)/(z-1))
%           - PI are nonzero, N can be anything, (can handle P = 0 )
%
% Case 6:   k / (z-1)
%           C(z) = P (1 + I * r1*(n1*z+m1)/(z-1))
%           - PI are nonzero, and 1+I*r1*n1 = 0  (can handle P)
%
% Case 7:   k
%           P is nonzero, I is zero (can handle P = 0)

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);

% Compute the inverse function
switch numel(z)
    case 1 % Case 4
        z1 = z(1);
        if (n1==1 && z1==-m1) % n1*z1+m1==0
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        else
            I = (1-z1)/r1/(n1*z1+m1);
            P = k*(n1*z1+m1)/(m1+n1); % P = k/(1+I*r1*n1)
        end
    case 0
        if isintegrating % Case 6
            if n1==0
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            else
                I = -1/r1/n1;
                P = -k*n1/(n1+m1); % P = -k/(1-I*r1*m1)
            end
        else % Case 7
            P = k;
            I = 0;
        end
end
function [P, D, N]    = PD_DT_Parallel_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to PDF

[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);
if numel(p) == 1
    if (n2==1 && p==-m2) % p*n2+m2==0
        N = inf;
    else
        N = (1-p)/(r2*(p*n2+m2));
        if N<=0   % N = 0 will give an integrating pole when n2 = 0.
            % N < 0 may result in 1+N*r2*n2==0 which may give NaN for PD
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
        end
    end
else
    N = [];
end

% The following Zero/Pole configurations could be mapped back to a Parallel
% PDF:

% Case 3:   k * (z-z1) / (z-p1)
%           C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PD are nonzero, N is infinite, p1=-m2 (can handle P = 0)
%           - PD are nonzero, N is finite (can handle P = 0)
%
% Case 5:   k * (z-z1)
%           C(z) = P + D*(z-1)/r2/(n2*z+m2)
%           PD are nonzero, N is infinite, n2=0 (can handle P =
%           0)
%
% Case 6.1: k / (z-p1)
%           PD are nonzero, N is infinite, p1=-m2, P+D/r2=0, n2=1 (can handle P = 0)
%           PD are nonzero, N is finite, P(1+N*r2*n2)+D*N=0 (can handle P = 0)
%
% Case 7:   k
%           P is nonzero, ID are zero, N can be anything (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 1
        z1=z(1);
        if numel(p) == 1 % Case 3
            if (n2==1 && p==-m2) % p*n2+m2==0
                P = (k-k*z1)/(n2+m2);
                D = r2*(k-P*n2);
            else
                P = (1+N*r2*n2)*(k-k*z1)/(r2*N*(n2+m2));
                D = (1+N*r2*n2)*(k-P)/N;
            end
        else                                % Case 5
            if n2==0
                N = inf;
                D = r2*k;
                P = k*(1-z1);
            else
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            end
        end
    case 0
        if numel(p) == 1                % Case 6.1
            if (n2==1 && p==-m2) % p*n2+m2==0
                P = k/(n2+m2);
                D = -r2*n2*P;
            else
                P = (1+N*r2*n2)*k/(N*r2*(n2+m2));
                D = -P*(1+N*r2*n2)/N;
            end
        else                                % Case 7
            P = k;
            D = 0;
        end
end
function [P, D, N]    = PD_DT_Ideal_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to PDF

[r2,n2,m2] = getDTMethodCoeff(ctrlstruct.FilterMethod,Ts);

if numel(p) == 1
    if (n2==1 && p==-m2) % p*n2+m2==0
        N = inf;
    else
        N = (1-p)/(r2*(p*n2+m2));
        if N<=0   % N = 0 will give an integrating pole when n2 = 0.
            % N < 0 may result in 1+N*r2*n2==0 which may give NaN for PD
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidPIDFilter')
        end
    end
else
    N = [];
end

% Case 3:   k * (z-z1) / (z-p1)
%           C(z) = P (1 + D*N/( 1+N*r2*(n2*z+m2)/(z-1) ))
%           - PD are nonzero, N is infinite, n2=1,p1=-m2 (can handle P = 0)
%           - PD are nonzero, N is finite (can handle P = 0)
%
% Case 5:   k * (z-z1)
%           C(z) = P (1 + D*(z-1)/(r2*n2*z+r2*m2))
%           PD are nonzero, N is infinite, n2=0
%
% Case 6.1: k / (z-p1)
%           C(z) = P + D*N/( 1+N*r2*(n2*z+m2)/(z-1) )
%           - PD are nonzero, N is infinite, p1=-m2, 1+D/r2=0, n2=1 (can handle P = 0)
%           - PD are nonzero, N is finite, (1+N*r2*n2)+D*N=0 (can handle P = 0)
%
% Case 7:   k
%           P is nonzero, D is zero, N can be anything (can handle P = 0)

% Compute the inverse function
switch numel(z)
    case 1
        z1 = z(1);
        if z1==1
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
        if numel(p) == 1 % Case 3
            if (n2==1 && p==-m2) % p*n2+m2==0
                D = r2*(z1+m2)/(1-z1);
                P = k*(1-z1)/(1+m2);  % P = k/(1+D/r2);
            else
                D = ((1+N*r2*n2)*z1-(1-N*r2*m2))/N/(1-z1);
                P = k*(1+N*r2*n2)*(1-z1)/(N*r2*(n2+m2)); % P = k*(1+N*r2*n2)/((1+N*r2*n2)+D*N);
            end
        else % Case 5
            if n2==0
                N = inf;
                D = r2/(1-z1);
                P = k*r2/D;
            else
                ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
            end
        end
    case 0
        if numel(p) == 1 % case 6.1
            if (n2==1 && p==-m2) % p*n2+m2==0
                D = -r2;
                P = k/(1+m2);
            else
                D = -(1+N*r2*n2)/N;
                P = k*(1+N*r2*n2)/(r2*N*(n2+m2));
            end
        else % Case 7
            P = k;
            D = 0;
        end
end
function I            = I_DT_InvFcn(z,p,k,Ts,ctrlstruct)
%% ZPK to I
% The following cases will pass the constraints requirements but should be blocked.
%
% Case A:   k *  ........    / (z-p1)
% Case B:   k *  ........    / 1

%  Case A & B:
if (numel(p)==0) || (numel(p)==1 && p ~= 1)
    ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
end

[r1,n1,m1] = getDTMethodCoeff(ctrlstruct.IntegratorMethod,Ts);

% Case 1:   k * (z-z1) / (z-1)
%           C(z) = I * r1*(n1*z+m1)/(z-1)
%
% Case 2:   k  / (z-1)
%           C(z) = I * r1*(n1*z+m1)/(z-1)
%           n1=0

% Compute the inverse function
switch numel(z)
    case 1                                % Case 1
        z1 = z;
        if n1 == 0 || z1 ~= -m1
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        else
            I = k/r1;
        end
    case 0
        if n1 == 0
            I = k/r1;             % Case 2
        else
            ctrlMsgUtils.error('Slcontrol:controldesign:InvalidZPKtoPIDN')
        end
end
function P            = P_DT_InvFcn(z,p,k,Ts,ctrlstruct)  %#ok<INUSL,INUSD>
%% ZPK to P

% There are nine main possible Zero/Pole configurations and 3 edge cases
% possible all are listed by the # of zeros:

% Case 1:   k
%           C(z) = P

% Compute the inverse function
P = k;


% local functions
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