%EVAL Execute string with MATLAB expression.
%   EVAL(s), where s is a string, causes MATLAB to execute
%   the string as an expression or statement.
%
%   [X,Y,Z,...] = EVAL(s) returns output arguments from the
%   expression in string s.
%
%   The input strings to EVAL are often created by 
%   concatenating substrings and variables inside square
%   brackets. For example:
%
%   Generate a sequence of matrices named M1 through M12:
%
%       for n = 1:12
%          eval(['M' num2str(n) ' = magic(n)'])
%       end
%
%   Run a selected M-file script.
%   
%       D = {'odedemo'; 'sunspots'; 'fitdemo'};
%       n = input('Select a demo number: ');
%       eval(D{n})
%
%   See also FEVAL, EVALIN, ASSIGNIN, EVALC.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.10.4.6 $  $Date: 2009/03/30 23:41:00 $
%   Built-in function.
