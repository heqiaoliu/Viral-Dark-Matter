function display(obj,objectname)
%DISPLAY Display a NaiveBayes object.
%   DISPLAY(NB) prints a text representation of the NaiveBayes object NB.
%   DISPLAY is called when a semicolon is not used to terminate a
%   statement.
%
%   DISPLAY(NB,OBJECTNAME) uses objectname as the object name.
%
%   See also NAIVEBAYES, NAIVEBAYES/DISP.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:49 $

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
