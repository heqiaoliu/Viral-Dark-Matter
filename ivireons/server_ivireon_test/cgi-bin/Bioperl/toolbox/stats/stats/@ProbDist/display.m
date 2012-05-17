function display(obj,objectname)
%DISPLAY Display a probability distribution object.
%   DISPLAY(PD) prints a text representation of the ProbDist
%   object PD.  DISPLAY is called when a semicolon is not used to
%   terminate a statement.
%
%   DISPLAY(PD,OBJECTNAME) uses OBJECTNAME as the object name.
%
%   See also ProbDist, ProbDist/DISP.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:19:01 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');
if nargin<2
     objectname = inputname(1);
end
if isempty(objectname)
    objectname = 'ans';
end

if (isLoose)
    fprintf('\n');
end
fprintf('%s = \n', objectname);
disp(obj)

if (isLoose)
    fprintf('\n');
end
