function pVectorObjectDisplay(obj)
; %#ok Undocumented
%pDefaultVectorObjDisplay - display for vector output

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.3 $  $Date: 2010/03/01 05:20:19 $

% Remove everything upto the '.' in the classname
classdesc = regexp(class(obj), '\w*$', 'once', 'match');

% to allow user configuration of end of output spacing
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

fprintf('\t%s\n', parallel.internal.createDimensionDisplayString(obj, classdesc));

if LOOSE
    disp(' ');
end
