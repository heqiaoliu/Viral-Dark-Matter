%% Nonlinear Data-Fitting
% This example demonstrates fitting a nonlinear function to data
% using several Optimization Toolbox(TM) algorithms.

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/10 17:32:15 $

%% Problem Setup
% Consider the following data:

Data = ...
  [0.0000    5.8955
   0.1000    3.5639
   0.2000    2.5173
   0.3000    1.9790
   0.4000    1.8990
   0.5000    1.3938
   0.6000    1.1359
   0.7000    1.0096
   0.8000    1.0343
   0.9000    0.8435
   1.0000    0.6856
   1.1000    0.6100
   1.2000    0.5392
   1.3000    0.3946
   1.4000    0.3903
   1.5000    0.5474
   1.6000    0.3459
   1.7000    0.1370
   1.8000    0.2211
   1.9000    0.1704
   2.0000    0.2636];

%%
% Let's plot these data points.
t = Data(:,1);
y = Data(:,2);
% axis([0 2 -0.5 6])
% hold on
plot(t,y,'ro')
title('Data points')
% hold off

%%
% We would like to fit the function
%
%     y =  c(1)*exp(-lam(1)*t) + c(2)*exp(-lam(2)*t)
%
% to the data. 
%
%% Solution Approach Using |lsqcurvefit|
%
% The |lsqcurvefit| function solves this type of problem easily.
%
% To begin, define the parameters in terms of one variable x:
%
%  x(1) = c(1)
%  x(2) = lam(1)
%  x(3) = c(2)
%  x(4) = lam(2)
%
% Then define the curve as a function of the parameters x and
% the data t:

F = @(x,xdata)x(1)*exp(-x(2)*xdata) + x(3)*exp(-x(4)*xdata);

%%
% We arbitrarily set our initial point x0 as follows: c(1) = 1,
% lam(1) = 1, c(2) = 1, lam(2) = 0:

x0 = [1 1 1 0];

%% 
% We run the solver and plot the resulting fit.

[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,t,y)

hold on
plot(t,F(x,t))
hold off

%% Solution Approach Using |fminunc|
%
% To solve the problem using |fminunc|, we set the objective
% function as the sum of squares of the residuals.

Fsumsquares = @(x)sum((F(x,t) - y).^2);
opts = optimset('LargeScale','off');

[xunc,ressquared,eflag,outputu] = ...
    fminunc(Fsumsquares,x0,opts)
%%
% Notice that |fminunc| found the same solution as
% |lsqcurvefit|, but took many more function evaluations to do
% so. The parameters for |fminunc| are in the opposite order as
% those for |lsqcurvefit|; the larger lam is lam(2), not lam(1).
% This is not surprising, the order of variables is arbitrary.

fprintf(['There were %d iterations using fminunc,' ...
    ' and %d using lsqcurvefit.\n'], ...
    outputu.iterations,output.iterations)
fprintf(['There were %d function evaluations using fminunc,' ...
    ' and %d using lsqcurvefit.'], ...
    outputu.funcCount,output.funcCount)

%% Splitting the Linear and Nonlinear Problems
%
% Notice that the fitting problem is linear in the parameters
% c(1) and c(2). This means for any values of lam(1) and lam(2),
% we can use the backslash operator to find the values of c(1)
% and c(2) that solve the least-squares problem.
%
% We now rework the problem as a two-dimensional problem,
% searching for the best values of lam(1) and lam(2). The values
% of c(1) and c(2) are calculated at each step using the
% backslash operator as described above.

type fitvector

%%
% Solve the problem using |lsqcurvefit|, starting from a
% two-dimensional initial point lam(1), lam(2):

x02 = [1 0];
F2 = @(x,t) fitvector(x,t,y);

[x2,resnorm2,~,exitflag2,output2] = lsqcurvefit(F2,x02,t,y)

%%
% The efficiency of the two-dimensional solution is similar to
% that of the four-dimensional solution:

fprintf(['There were %d function evaluations using the 2-d ' ...
    'formulation, and %d using the 4-d formulation.'], ...
    output2.funcCount,output.funcCount)

%% Split Problem is More Robust to Initial Guess
%
% Choosing a bad starting point for the original four-parameter
% problem leads to a local solution that is not global. Choosing
% a starting point with the same bad lam(1) and lam(2) values
% for the split two-parameter problem leads to the global
% solution. To show this we re-run the original problem with a
% start point that leads to a relatively bad local solution, and
% compare the resulting fit with the global solution.

x0bad = [5 1 1 0];
[xbad,resnormbad,~,exitflagbad,outputbad] = ...
    lsqcurvefit(F,x0bad,t,y)

hold on
plot(t,F(xbad,t),'g')
legend('Data','Global fit','Bad local fit','Location','NE')
hold off

fprintf(['The residual norm at the good ending point is %f,' ...
   ' and the residual norm at the bad ending point is %f.'], ...
   resnorm,resnormbad)

displayEndOfDemoMessage(mfilename)
