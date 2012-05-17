%% Solving Equations
%
%  Copyright 1993-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2009/04/16 00:44:12 $

%%
% The "solve" and "dsolve" functions seek analytic solutions
% to algebraic and ordinary differential equations.

%%
%
% The first example is a simple quadratic.
% You can either find the zeros of a symbolic expression, without quotes:

syms a b c x
x = solve(a*x^2 + b*x + c);

%%
%
% Or, you can find the roots of an equation, given in quotes:

x = solve('a*x^2 + b*x + c = 0');

%%
%
% Both of these produce the same result:

x

%%
% The solution to a general cubic is:

x = solve('a*x^3 + b*x^2 + c*x + d')

pretty(x)

%%
% The statement

x = solve('p*sin(x) = r');

%%
%
% chooses 'x' as the unknown and returns

x

%%
% A system of two quadratic equations in two unknowns produces solution vectors.

[x,y] = solve('x^2 + x*y + y = 3','x^2 - 4*x + 3 = 0')

%%
% The solution can also be returned in a structure.

S = solve('x^2 + x*y + y = 3','x^2 - 4*x + 3 = 0')
S.x
S.y

%%
% The next example regards 'a' as a parameter and solves two
% equations for u and v.

[u,v] = solve('a*u^2 + v^2 = 0','u - v = 1')

%%
% Add a third equation and solve for all three unknowns.

[a,u,v] = solve('a*u^2 + v^2','u - v = 1','a^2 - 5*a + 6')

%%
% If an analytic solution cannot be found, "solve" returns a numeric solution.

digits(32)
[x,y] = solve('sin(x+y)-exp(x)*y = 0','x^2-y = 2')

%%
% Similar notation, with "D" denoting differentiation, is used
% for ordinary differential equations by the "dsolve" function.

y = dsolve('Dy = -a*y')

%%
% Specify an initial condition.

y = dsolve('Dy = -a*y','y(0) = 1')

%%
% The second derivative is denoted by "D2'.

y = dsolve('D2y = -a^2*y', 'y(0) = 1, Dy(pi/a) = 0')

%%
% A nonlinear equation produces two solutions in a vector.

y = dsolve('(Dy)^2 + y^2 = 1','y(0) = 0')


displayEndOfDemoMessage(mfilename)
