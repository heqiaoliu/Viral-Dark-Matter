%% Introduction
%
%  Copyright 1993-2008 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2009/07/06 20:59:47 $
%
% The Symbolic Math Toolbox(TM) software uses "symbolic objects" produced
% by the "sym" function.  For example, the statement

x = sym('x');

%%
%
% produces a symbolic variable named x.

%%
% You can combine the statements

a = sym('a'); t = sym('t'); x = sym('x'); y = sym('y');

%%
%
% into one statement involving the "syms" function.

syms a t x y

%%
% You can use symbolic variables in expressions and as arguments to
% many different functions.

r = x^2 + y^2

theta = atan(y/x)

e = exp(i*pi*t)

%%
% It is sometimes desirable to use the "simple" or "simplify" function
% to transform expressions into more convenient forms.

f = cos(x)^2 + sin(x)^2

f = simple(f)

%%
% Derivatives and integrals are computed by the "diff" and "int" functions.

diff(x^3)

int(x^3)

int(exp(-t^2))

%%
% If an expression involves more than one variable, differentiation and
% integration use the variable which is closest to 'x' alphabetically,
% unless some other variable is specified as a second argument.
% In the following vector, the first two elements involve integration
% with respect to 'x', while the second two are with respect to 'a'.

[int(x^a), int(a^x), int(x^a,a), int(a^x,a)]

%%
% You can also create symbolic constants with the sym function.  The
% argument can be a string representing a numerical value.  Statements
% like pi = sym('pi') and delta = sym('1/10') create symbolic numbers
% which avoid the floating point approximations inherent in the values
% of pi and 1/10.  The pi created in this way temporarily replaces the
% built-in numeric function with the same name.

pi = sym('pi')

delta = sym('1/10')

s = sym('sqrt(2)')

%%
% Conversion of floating point values to symbolic constants involves
% some consideration of roundoff error.  For example, with either of the
% following statements, the value assigned to t is not exactly one-tenth.

t = 1/10, t = 0.1

%%
% The technique for converting floating point numbers is specified by an
% optional second argument to the sym function.  The possible values of the
% argument are 'f', 'r', 'e' or 'd'.  The default is 'r'.

%%
% 'f' stands for 'floating point'.  All values are represented in the
% form (2^e+N*2^(e-52)) or -(2^e+N*2^(e-52)) where N and e are integers.
% This captures the floating point values exactly.

sym(t,'f')

%%
% 'r' stands for 'rational'.  Floating point numbers obtained by evaluating
% expressions of the form p/q, p*pi/q, sqrt(p), 2^q and 10^q for modest sized
% integers p and q are converted to the corresponding symbolic form.  This
% effectively compensates for the roundoff error involved in the original evaluation,
% but may not represent the floating point value precisely.

sym(t,'r')

%%
% If no simple rational approximation can be found, an expression of the form
% p*2^q with large integers p and q reproduces the floating point value exactly.

sym(1+sqrt(5),'r')

%%
% 'e' stands for 'estimate error'.  The 'r' form is supplemented by a term
% involving the variable 'eps' which estimates the difference between the
% theoretical rational expression and its actual floating point value.

sym(t,'e')

%%
% 'd' stands for 'decimal'.  The number of digits is taken from the current
% setting of DIGITS used by VPA.  Fewer than 16 digits loses some accuracy,
% while more than 16 digits may not be warranted.

digits(15)
sym(t,'d')

digits(25)
sym(t,'d')

%%
%
% The 25 digit result does not end in a string of 0's, but is an accurate
% decimal representation of the floating point number nearest to 1/10.

%%
% MATLAB(R) language vector and matrix notation extends to symbolic variables.

n = 4;

A = x.^((0:n)'*(0:n))

D = diff(log(A))


displayEndOfDemoMessage(mfilename)
