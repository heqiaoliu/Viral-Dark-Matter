function highlightdtgroup(mdl, run, listname)
%HIGHLIGHTDTGROUP highlights all blocks that are in the same DTGroup
%
%   Author(s): V. Srinivasan
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/11/13 17:56:55 $

appdata = SimulinkFixedPoint.getApplicationData(mdl);
if(isempty(appdata)); return; end
bd = get_param(mdl, 'Object');
bd.hilite('off');
try
    results = appdata.dataset.getlist4id(fxptui.str2run(run), listname);
    sys = get_param(mdl, 'Object');
    open_system(mdl, 'force');
    for idx = 1:numel(results)
        try
            current_sys = results(idx).daobject.getParent;
        catch %#ok
              % invalid block object for this results, e.g. hidden buffer block, ignore this one
            continue;
        end
        if(~isequal(sys, current_sys))
            if ~isempty(current_sys) % Signal object has an empty parent
                sys = current_sys;
                open_system(sys.getFullName, 'force');
            end
        end
        try
            results(idx).daobject.hilite;
        catch e %#ok
            continue; % The object might not have a hilite method.
        end
    end
catch %#ok
      %consume errors if the attempted operations fail
end

% [EOF]
