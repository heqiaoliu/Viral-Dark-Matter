function disp(a)
%DISP Display a categorical array.
%   DISP(A) prints the categorical array A without printing the array name.
%   In all other ways it's the same as leaving the semicolon off an
%   expression, except that empty arrays don't display.
%
%   See also CATEGORICAL, CATEGORICAL/DISPLAY.

%   Copyright 2006 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/06/16 05:24:48 $

labs = [categorical.undefLabel a.labels];
s = evalc('disp(reshape(labs(a.codes+1),size(a.codes)))');
s(s=='''') = ' ';
fprintf(s);
