function disp(obj)
%DISP Display a probability distribution object.
%   DISP(PD) prints a text representation of the probability distribution
%   PD, without printing the object name.  In all other ways it's
%   the same as leaving the semicolon off an expression.
%
%   See also PROBDISTUNIVKERNEL.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:08 $


isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if (isLoose)
    fprintf('\n');
end

disp@ProbDist(obj);

if ischar(obj.Kernel)
    fprintf('    %s = %s\n','Kernel',obj.Kernel);
else
    fprintf('    %s = %s\n','Kernel',func2str(obj.Kernel));
end
fprintf('    %s = %g\n','Bandwidth',obj.BandWidth);
if ischar(obj.Support.range)
    fprintf('    %s = %s\n','Support',obj.Support.range);
else
    fprintf('    %s = (%g, %g)\n','Support',obj.Support.range);
end

if (isLoose)
    fprintf('\n');
end
