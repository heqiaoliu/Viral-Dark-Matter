function display(a)
%DISPLAY Display a categorical array.
%   DISPLAY(A) prints the categorical array A.  DISPLAY is called when
%   a semicolon is not used to terminate a statement.
%
%   See also CATEGORICAL, CATEGORICAL/DISP.

%   Copyright 2006-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2009/06/16 05:24:51 $

isLoose = strcmp(get(0,'FormatSpacing'),'loose');

objectname = inputname(1);
if isempty(objectname)
    objectname = 'ans';
end

if isempty(a)
    if (isLoose), fprintf('\n'); end
    fprintf('%s = \n', objectname);
    if (isLoose), fprintf('\n'); end
    sz = size(a);
    if ndims(a) == 2
        fprintf('   Empty %s matrix: %d-by-%d\n',class(a),sz(1),sz(2));
    else
        fprintf('   Empty %s array: %d',class(a),sz(1));
        fprintf('-by-%d',sz(2:end));
        fprintf('\n');
    end
    if (isLoose), fprintf('\n'); end
elseif ndims(a) == 2
    if (isLoose), fprintf('\n'); end
    fprintf('%s = \n', objectname);
    disp(a)
else
    % Let the disp method do the real work, then look for the page headers,
    % things like '(:,:,1) =', and replace them with 'objectname(:,:,1) ='
    s = evalc('disp(a)');
    s = regexprep(s,'\([0-9:,]+\) =', [objectname '$0']);
    fprintf(s)
end
