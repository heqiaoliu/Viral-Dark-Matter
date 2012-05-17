function pVectorObjectDisplay(workers)
; %#ok Undocumented
%pDefaultVectorObjDisplay - display for vector output

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2010/03/01 05:20:26 $

% Allows user configuration of end of output spacing.
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

desc(1) = iCreateCol('Name',     @(o)o.Name,                 16, true);
desc(2) = iCreateCol('Hostname', @(o)o.Hostname,             12, true);
desc(3) = iCreateCol('Task',     @(o)num2str(o.CurrentTask),  8, true);
desc(4) = iCreateCol('Job',      @(o)num2str(o.CurrentJob),   8, true);

title = parallel.internal.createDimensionDisplayString(workers, 'Workers');
disp(parallel.internal.createVectorObjectDisplayTable(workers, desc, title));

if LOOSE
    disp(' ');
end
end


function col = iCreateCol(title, func, width, adjust)
col = struct('title', title, 'function', func, ...
             'width', width, 'adjust', adjust);
end