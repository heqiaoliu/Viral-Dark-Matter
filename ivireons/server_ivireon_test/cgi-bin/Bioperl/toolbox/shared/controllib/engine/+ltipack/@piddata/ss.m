function [SSDATA,SingularFlag] = ss(PID)
% Conversion to @ssdata

%   Author(s): Rong Chen
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision $  $Date: 2010/02/08 22:47:22 $
SingularFlag = false;

% convert to internal parameterization
[P, I, D, T] = utGetPIDT(PID);
% get sample time
Ts = abs(PID.Ts);
% compute matrices
e = [];
if Ts==0
    if I==0
        % no integrator
        a = []; b = zeros(0,1); c = zeros(1,0); d = P; 
    else 
        % integrator --> a=0, b=1, c=1, d=0
        a = 0; b = 1; c = I; d = P; 
    end
    if D~=0 
        % has derivative
        if T==0
            % ideal derivative --> a=eye(2), b=[0;-1], c=[1 0], d=0, e=[0 1;0 0]
            e = blkdiag(eye(size(a)), [0 1;0 0]);
            a = blkdiag(a, eye(2)); b = [b; 0; -1]; c = [c D 0]; 
        else
            % filter s/(Ts+1) --> a=-1/T, b=-1/T, c=1/T, d = 1/T
            a = blkdiag(a, -1/T); b = [b; -1/T]; c = [c D/T]; d = d + D/T; 
        end
    end
else
    if I==0
        % no integrator
        a = []; b = zeros(0,1); c = zeros(1,0); d = P;
    else 
        % integrator: a=0, b=1, c=Ts, d={0,Ts,Ts/2}
        a = 1;  b = 1;  c = Ts*I;
        switch PID.IFormula
            case 'F'
                d = P;
            case 'B'
                d = Ts*I+P;
            case 'T'                
                d = Ts/2*I+P;
        end
    end
    if D~=0 
        % has derivative
        % For the derivative filter s/(Ts+1) we have following ss models
        % corresponding to different formulas:
        % FE: a=1-Ts/T, b=-Ts/T, c=1/T, d=1/T
        % BE: a=1-Ts/(T+Ts), b=-Ts/(T+Ts), c=1/(T+Ts), d=1/(T+Ts)            
        % TR: a=1-Ts/(T+Ts/2), b=-Ts/(T+Ts/2), c=1/(T+Ts/2), d=1/(T+Ts/2)
        % Note that when T=0 for FE, or T+Ts=0 for BE, or T+Ts/2=0 for TR,
        % the discretization result becomes simply (z-1)/Ts, which requires
        % a descriptor system as follows
        % (z-1)/Ts: a=eye(2), b=[0;-1], c=[1/Ts 0], d = -1/Ts, e=[0 1;0 0]
        switch PID.DFormula
            case 'F'
                alpha = 0;
            case 'B'
                alpha = Ts;
            case 'T'     
                alpha = Ts/2;
        end
        if (T+alpha)==0
            e = blkdiag(eye(size(a)), [0 1;0 0]);
            a = blkdiag(a, eye(2)); 
            b = [b; 0; -1]; 
            c = [c D/Ts 0]; 
            d = d - D/Ts; 
        else
            aux1 = Ts/(T+alpha);  
            aux2 = D/(T+alpha);
            a = blkdiag(a, 1-aux1); 
            b = [b; -aux1]; 
            c = [c , aux2]; 
            d = d + aux2; 
        end
    end
end
SSDATA = ltipack.ssdata(a,b,c,d,e,PID.Ts);

