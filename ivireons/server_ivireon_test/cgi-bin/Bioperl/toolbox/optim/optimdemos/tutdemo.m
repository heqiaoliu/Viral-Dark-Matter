%% Tutorial for the Optimization Toolbox(TM)
%
% This is a demonstration of the use of two nonlinear solvers and their
% options.
%   
% All the principles outlined in this demonstration apply to the other 
% nonlinear solvers, such as FGOALATTAIN, FMINIMAX, LSQNONLIN, and FSOLVE.
%
% The demo starts with minimizing an objective function, then proceeds to
% minimize the same function with additional parameters. After that, the 
% demo shows how to minimize the objective function when there is a 
% constraint, and finally shows how to get a more efficient and/or accurate
% solution by providing gradients or Hessian, or by changing some options. 
%
%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/02/08 22:38:43 $

%% Unconstrained Optimization Example
%
% Consider the problem of finding a minimum of the function:
%
% $$x\exp(-(x^2+y^2))+(x^2+y^2)/20.$$
%
% Plot the function to get an idea of where it is minimized
f = @(x,y) x.*exp(-x.^2-y.^2)+(x.^2+y.^2)/20;
ezsurfc(f,[-2,2])

%%
% The plot shows that the minimum is near the point (-1/2,0).
%
% Usually you define the objective function as a MATLAB file. For now, 
% this function is simple enough to define as an anonymous function:

fun = @(x) f(x(1),x(2));

%%
% Take a guess at the solution:

x0 = [-.5; 0];

%%
% Set optimization options to not use fminunc's default large-scale
% algorithm, since that algorithm requires the objective function
% gradient to be provided:

options = optimset('LargeScale','off');

%%
% View the iterations as the solver calculates:

options = optimset(options,'Display','iter');

%%
% Call fminunc, an unconstrained nonlinear minimizer:

[x, fval, exitflag, output] = fminunc(fun,x0,options);

%%
% The solver found a solution at:
uncx = x

%%
% The function value at the solution is:
uncf = fval

%%
% We will use the number of function evaluations as a measure of efficiency
% in this demo.
% The total number of function evaluations is: 

output.funcCount


%% Unconstrained Optimization with Additional Parameters
%
% We will now pass extra parameters as additional arguments
% to the objective function. We demonstrate two different ways 
% of doing this - using a MATLAB file, or using a nested
% function.

%%
% Consider the objective function from the previous section:
%
% $$f(x,y) = x\exp(-(x^2+y^2))+(x^2+y^2)/20.$$
%
% We parameterize the function with (a,b,c) in the following way:
%
% $$f(x,y,a,b,c) = (x-a)\exp(-((x-a)^2+(y-b)^2))+((x-a)^2+(y-b)^2)/c.$$
%
% This function is a shifted and scaled version of the original objective
% function. 
%
% Method 1: MATLAB file Function
%
% Suppose we have a MATLAB file objective function called |bowlpeakfun| 
% defined as:

type bowlpeakfun

%%
% Define the parameters:
a = 2;
b = 3;
c = 10;

%%
% Create an anonymous function handle to the MATLAB file:
f = @(x)bowlpeakfun(x,a,b,c)

%%
% Call fminunc to find the minimum:
x0 = [-.5; 0];
options = optimset('LargeScale','off');
[x, fval] = fminunc(f,x0,options)

%%
% Method 2: Nested Function
%
% Consider the following function that implements the objective as a nested
% function
type nestedbowlpeak
%%
% In this method, the parameters (a,b,c) are visible to the nested
% objective function called |nestedfun|.
% The outer function, |nestedbowlpeak|, calls fminunc and passes the
% objective function, |nestedfun|.
%%
% Define the parameters, initial guess, and options:
a = 2;
b = 3;
c = 10;
x0 = [-.5; 0];
options = optimset('LargeScale','off');
%%
% Run the optimization:
[x,fval] =  nestedbowlpeak(a,b,c,x0,options)

%%
% You can see both methods produced identical answers, so use whichever one you find most convenient.

%% Constrained Optimization Example: Inequalities
%
% Consider the above problem with a constraint:
%
% $$\mbox{minimize }x\exp(-(x^2+y^2))+(x^2+y^2)/20,$$
%
% $$\mbox{subject to }xy/2 + (x+2)^2 + (y-2)^2/2 \le 2.$$

%%
% The constraint set is the interior of a tilted ellipse.
% Look at the contours of the objective function plotted together with the
% tilted ellipse
f = @(x,y) x.*exp(-x.^2-y.^2)+(x.^2+y.^2)/20;
g = @(x,y) x.*y/2+(x+2).^2+(y-2).^2/2-2;
ezplot(g,[-6,0,-1,7])
hold on
ezcontour(f,[-6,0,-1,7])
plot(-.9727,.4685,'ro');
legend('constraint','f contours','minimum');
hold off

%%
% The plot shows that the lowest value of the objective function within the
% ellipse occurs near the lower right part of the ellipse. We are about to 
% calculate the minimum that was just plotted. Take a guess at the solution:

x0 = [-2 1];

%%
% Set optimization options: use the interior-point algorithm, and turn on 
% the display of results at each iteration:

options = optimset('Algorithm','interior-point','Display','iter');

%%
% Solvers require that nonlinear constraint functions give two outputs: one
% for nonlinear inequalities, the second for nonlinear equalities. So we
% write the constraint using the |deal| function to give both outputs:

gfun = @(x) deal(g(x(1),x(2)),[]);

%%
% Call the nonlinear constrained solver. There are no linear equalities or 
% inequalities or bounds, so pass [ ] for those arguments:

[x,fval,exitflag,output] = fmincon(fun,x0,[],[],[],[],[],[],gfun,options);

%%
% A solution to this problem has been found at:

x 

%%
% The function value at the solution is: 

fval

%%
% The total number of function evaluations was: 

Fevals = output.funcCount

%%
% The inequality constraint is satisfied at the solution.

[c, ceq] = gfun(x)

%%
% Since c(x) is close to 0, the constraint is "active," meaning 
% the constraint affects the solution.
% Recall the unconstrained solution was found at

uncx

%%
% and the unconstrained objective function was found to be

uncf

%%
% The constraint moved the solution, and increased the objective by

fval-uncf

%% Constrained Optimization Example: User-Supplied Gradients
%
% Optimization problems can be solved more efficiently and accurately if
% gradients are supplied by the user. This demo shows how this may be
% performed. We again solve the inequality-constrained problem
%
% $$\mbox{minimize }x\exp(-(x^2+y^2))+(x^2+y^2)/20,$$
%
% $$\mbox{subject to }xy/2 + (x+2)^2 + (y-2)^2/2 \le 2.$$

%%
% To provide the gradient of f(x) to fmincon, we write the
% objective function in the form of a MATLAB file:

type onehump

%%
% The constraint and its gradient are contained in
% the MATLAB file tiltellipse:

type tiltellipse 

%%
% Make a guess at the solution:

x0 = [-2; 1];

%%
% Set optimization options: we continue to use the same algorithm
% for comparison purposes. 

options = optimset('Algorithm','interior-point');

%%
% We also set options to use the gradient information in the objective
% and constraint functions. Note: these options MUST be turned on or
% the gradient information will be ignored.

options = optimset(options,'GradObj','on','GradConstr','on');

%%
% There should be fewer function counts this time, since fmincon does not
% need to estimate gradients using finite differences. 

options = optimset(options,'Display','iter');

%%
% Call the solver:

[x,fval,exitflag,output] = fmincon(@onehump,x0,[],[],[],[],[],[], ...
                                   @tiltellipse,options);

%%
% fmincon estimated gradients well in the previous example,
% so the iterations in the current example are similar.
%
% The solution to this problem has been found at:

xold = x 

%%
% The function value at the solution is: 

minfval = fval

%%
% The total number of function evaluations was: 

Fgradevals = output.funcCount

%%
% Compare this to the number of function evaluations without gradients:

Fevals

%% Changing the Default Termination Tolerances
%
% This time we solve the same constrained problem
%
% $$\mbox{minimize }x\exp(-(x^2+y^2))+(x^2+y^2)/20,$$
%
% $$\mbox{subject to }xy/2 + (x+2)^2 + (y-2)^2/2 \le 2,$$
%%
% more accurately by overriding the default termination criteria
% (options.TolX and options.TolFun). We continue to use gradients.
% The default values 
% for fmincon's interior-point algorithm are
% options.TolX = 1e-10, options.TolFun = 1e-6.
%
% Override two default termination criteria:
% termination tolerances on X and fval.

options = optimset(options,'TolX',1e-15,'TolFun',1e-8);      

%%
% Call the solver:

[x,fval,exitflag,output] = fmincon(@onehump,x0,[],[],[],[],[],[], ...
                                   @tiltellipse,options);
                               
%%
% We now choose to see more decimals in the solution, in order to see more
% accurately the difference that the new tolerances make.

format long

%%
% The optimizer found a solution at:

x

%%
% Compare this to the previous value:

xold

%%
% The change is

x - xold

%%
% The function value at the solution is: 

fval 

%%
% The solution improved by

fval - minfval
%%
% (this is negative since the new solution is smaller)
%
% The total number of function evaluations was: 

output.funcCount

%%
% Compare this to the number of function evaluations 
% when the problem is solved with user-provided gradients but
% with the default tolerances:

Fgradevals

%% Constrained Optimization Example with User-Supplied Hessian
% If you give not only a gradient, but also a Hessian, solvers are even
% more accurate and efficient.
% 
% fmincon's interior-point solver takes a Hessian matrix as a separate 
% function (not part of the objective function). The Hessian function
% H(x,lambda) should evaluate the Hessian of the Lagrangian; see the User's
% Guide for the definition of this term.
%
% Solvers calculate the values lambda.ineqnonlin and lambda.eqlin; your
% Hessian function tells solvers how to use these values.
%
% In this problem we have but one inequality constraint, so the Hessian is:

type hessfordemo

%%
% In order to use the Hessian, you need to set options appropriately:

options = optimset('Algorithm','interior-point','GradConstr','on',...
    'GradObj','on','Hessian','user-supplied','HessFcn',@hessfordemo);
%%
% The tolerances have been set back to the defaults.
% There should be fewer function counts this time.

options = optimset(options,'Display','iter');

%%
% Call the solver:

[x,fval,exitflag,output] = fmincon(@onehump,x0,[],[],[],[],[],[], ...
                                   @tiltellipse,options);
                               
%%
% There were fewer, and different iterations this time.
%
% The solution to this problem has been found at:

x 

%%
% The function value at the solution is: 

fval 

%%
% The total number of function evaluations was: 

output.funcCount

%%
% Compare this to the number using only gradient evaluations, with the same
% default tolerances:

Fgradevals

displayEndOfDemoMessage(mfilename)
