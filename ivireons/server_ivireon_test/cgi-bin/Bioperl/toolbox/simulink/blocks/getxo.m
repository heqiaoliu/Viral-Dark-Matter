function [X0] = getxo(a,b,c,d,u,y,DFLAG)
%GETXO Compute the initial states for a state space.
%   GETX0 is used by Linear Systems blocks in the Extras block library.
%   The blocks:
%
%     Zero-Pole with Initial States
%     Zero-Pole with Initial Outputs
%     State-Space with Initial Outputs
%     Transfer Fcn with Initial States
%     Transfer Fcn with Initial Outputs
%     Discrete Zero-Pole with Initial States
%     Discrete Zero-Pole with Initial Outputs
%     Discrete Transfer Fcn with Initial States
%     Discrete Transfer Fcn with Initial Outputs
%
%   allow you to provide initial conditions or initial outputs to Transfer
%   Function, Zero-Pole-Gain, and State Space blocks.

%   Copyright 1990-2005 The MathWorks, Inc.
%   $Revision: 1.12.2.2 $

% get the relevant matrix sizes
[m,n] = size(a);
[n,p] = size(b);
[q,n] = size(c);

%
% Build the A and B matrices for the linear programming routine
% simlp.m
%
% Note that there is a set of equality constraints set by the
% cx+du = y equations.
%
if (DFLAG == 0)                         % Is it a continuous system
  A = [   zeros(q,1)    c  ;
        -1*ones(m,1)    a  ;
        -1*ones(m,1)   -a ];
else                                    % It is a discrete system
  A = [   zeros(q,1)    c            ;
        -1*ones(m,1)    (a - eye(m)) ;
        -1*ones(m,1)    (eye(m) - a) ];
end

B = [  y - d * u   ;
          -b * u   ;
           b * u  ];

%
% Now the first element of the state vector is lambda,  the slack variable,
% and the rest is the x vector of the equations.
%
% So now we can do the optimization for the function f'*[lambda;x] where
% f is a 1 followed by a zero for each state, i.e. lambda
%
f = [1 zeros(1,n)];
[X,lam,how] = simlp(f(:),A,B(:),[],[],[],q,0);
X0 = X(2:end);

%
% Check whether we have found X0 such that y = c*X0+d*u
%
if (~strcmp(how,'ok'))
    DAStudio.error('Simulink:blocks:noSolutionFound',how);
else
    tol = 1024*sqrt(eps);
    ey = abs(c*X0 + d*u - y);
    if (any(ey > tol))
        ya = abs(y);
        ya(y == 0) = tol;
        if (any(ey > 0.1*ya))                      % Error greater than 10 percent
            DAStudio.error('Simulink:blocks:wrongSolutionFound',sprintf('%g',cond(a)))
        elseif (any(ey > 0.01*ya))                 % Error greater than 1 percent
            DAStudio.warning('Simulink:blocks:wrongSolutionFound',sprintf('%g',cond(a)))
        end
    end
end
