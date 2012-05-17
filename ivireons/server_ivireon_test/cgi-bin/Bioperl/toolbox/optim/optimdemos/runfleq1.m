function [fval, exitflag, output, x] = runfleq1
% RUNFLEQ1 demonstrates 'HessMult' option for FMINCON with linear
% equalities.
% Documentation example.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/29 12:47:50 $

problem = load('fleq1');   % Get V, Aeq, beq
V = problem.V; Aeq = problem.Aeq; beq = problem.beq;
n = 1000;             % problem dimension
xstart = -ones(n,1); xstart(2:2:n,1) = ones(length(2:2:n),1); % starting point
options = optimset('GradObj','on','Hessian','on','HessMult',@(Hinfo,Y)hmfleq1(Hinfo,Y,V) ,...
    'Display','iter','TolFun',1e-9); 
[x,fval,exitflag,output] = fmincon(@(x)brownvv(x,V),xstart,[],[],Aeq,beq,[],[], ...
                                    [],options);
