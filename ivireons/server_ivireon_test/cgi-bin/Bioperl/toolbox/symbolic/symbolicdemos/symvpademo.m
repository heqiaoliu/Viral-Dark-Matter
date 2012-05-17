%% Variable Precision Arithmetic
% Demonstrate variable precision arithmetic with the
% Symbolic Math Toolbox(TM) product.
%
%  Copyright 1993-2007 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $  $Date: 2010/04/11 20:42:47 $

%%
% Compute 19/81 to 70 digits.  Notice the repeated pattern of digits.
% "vpa" stands for variable precision arithmetic.

vpa 19/81 70

%%
% Compute pi to 780 digits.  Notice the string of 9's near the end.

vpa pi 780

%%
% Compute exp(sqrt(163)*pi) to 30 digits.
vpa exp(sqrt(163)*pi) 30

%%
%
% The value might be an integer.

%%
% Compute the same value to 40 digits.

vpa exp(sqrt(163)*pi) 40

%%
%
% So, the value is close to, but not exactly equal to, an integer.

%%
% Compute 70 factorial with 200 digit arithmetic.

f = vpa('70!',200)

%%
%
% How many digits in 70!? 

find(char(f)=='.') - 1

%%
% Compute the eigenvalues of the fifth order magic square to 50 digits.

digits(50)
A = sym(magic(5))
e = eig(vpa(A))


displayEndOfDemoMessage(mfilename)
