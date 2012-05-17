function disp(obj)
%DISP Display a probability distribution object.
%   DISP(PD) prints a text representation of the probability distribution
%   PD, without printing the object name.  In all other ways it's
%   the same as leaving the semicolon off an expression.
%
%   See also ProbDist, ProbDist/DISPLAY.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:00 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if (isLoose)
    fprintf('\n');
end

fprintf('%s distribution\n',obj.DistName);

if (isLoose)
    fprintf('\n');
end
