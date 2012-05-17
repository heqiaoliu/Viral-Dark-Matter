function pVectorObjectDisplay(jobManagers)
; %#ok Undocumented
%pDefaultVectorObjDisplay - display for vector output

% Copyright 2006-2010 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2010/03/01 05:20:12 $

% Allows user configuration of end of output spacing.
LOOSE = strcmp(get(0, 'FormatSpacing'), 'loose');

desc(1) = iCreateCol('Name',     @(o)o.Name,                   16, true);
desc(2) = iCreateCol('Hostname', @(o)o.Hostname,               12, true);
desc(3) = iCreateCol('Workers',  @(o)num2str(o.ClusterSize),    7, true);
desc(4) = iCreateCol('Jobs',     @(o)iJobsHelper(o),            7, true);
desc(5) = iCreateCol('UserName', @(o)o.UserName,                8, true);
desc(6) = iCreateCol('Security', @(o)num2str(o.SecurityLevel),  8, true);

title = parallel.internal.createDimensionDisplayString(jobManagers, 'Job Managers');
disp(parallel.internal.createVectorObjectDisplayTable(jobManagers, desc, title));

if LOOSE
    disp(' ');
end
end


function col = iCreateCol(title, func, width, adjust)
col = struct('title', title, 'function', func, ...
             'width', width, 'adjust', adjust);
end

function numJobsStr = iJobsHelper(obj)
[p, q, r, f] = obj.findJob;
sep = '|';
numJobsStr = [num2str(length(p)) sep num2str(length(q)) sep ...
              num2str(length(r)) sep num2str(length(f))];
end
