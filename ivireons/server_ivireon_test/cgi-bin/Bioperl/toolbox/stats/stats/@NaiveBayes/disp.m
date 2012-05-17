function disp(obj)
%DISP Display a NAIVEBAYES classifier object.
%   DISP(NB) prints a text representation of the NaiveBayes object NB, without
%   printing the object name.  In all other ways it's the same as leaving
%   the semicolon off an expression.
%
%   See also NAIVEBAYES, NAIVEBAYES/DISPLAY.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:18:48 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');
if (isLoose)
    fprintf('\n');
end

fprintf('Naive Bayes classifier with %d classes for %d dimensions.\n',...
    obj.LUsedClasses,obj.NDims);
if length(obj.Dist) < 10
   fprintf('Feature Distribution(s): ')
    for i = 1:length(obj.Dist)-1
       fprintf('%s, ', obj.Dist{i});
    end
   fprintf('%s\n',obj.Dist{end});
end

if obj.LUsedClasses < 10
    fprintf('Classes: ')
    for i = obj.NonEmptyClasses(1:end-1)
       fprintf('%s, ', obj.ClassNames{i});
    end
    fprintf('%s\n', obj.ClassNames{obj.NonEmptyClasses(end)});
end

if (isLoose)
    fprintf('\n');
end
