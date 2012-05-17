function disp(obj)
%DISP Display a probability distribution object.
%   DISP(PD) prints a text representation of the probability distribution
%   PD, without printing the object name.  In all other ways it's
%   the same as leaving the semicolon off an expression.
%
%   See also ProbDistUnivParam, ProbDist.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/16 00:19:18 $


isLoose = strcmp(get(0,'FormatSpacing'),'loose');

if (isLoose)
    fprintf('\n');
end

disp@ProbDist(obj);

for j=1:numel(obj.ParamNames);
    fprintf('    %s = %g\n',obj.ParamNames{j},obj.Params(j));
end

if (isLoose)
    fprintf('\n');
end
