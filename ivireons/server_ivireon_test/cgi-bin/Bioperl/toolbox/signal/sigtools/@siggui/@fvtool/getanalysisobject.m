function h = getanalysisobject(hObj, tag, new, hPrm)
%GETANALYSISOBJECT Return the specified analysis object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/10/07 20:25:08 $

if nargin < 2, tag = get(hObj, 'Analysis'); end
if nargin < 3, new = false; end

if new,
    h = [];
else
    h = getcomponent(hObj, 'fvtool_tag', tag);
end

% If the selected analysis doesn't exist.  Create it.
if isempty(h),
    
    info = get(hObj, 'AnalysesInfo');
    
    if nargin < 4
        hPrm = get(hObj, 'Parameters');
        reuse = true;
    else
        reuse = false;
    end
    
    % Create the new object using the filters and parameters stored.
    opts = {hObj.Filters, hPrm};
    if iscell(info.(tag).fcn),
        h = feval(info.(tag).fcn{:}, opts{:});
    else
        h = feval(info.(tag).fcn, opts{:});
    end
    
    oldprm = get(hObj, 'Parameters');
    allprm = union(getparameter(h, '-all'), oldprm);
    
    % Find all the new parameters and make them use their saved defaults
    newprm = setdiff(allprm, oldprm);
    if ~isempty(newprm), usedefault(newprm, 'fvtool'); end
    
    if reuse,
        set(hObj, 'Parameters', allprm);
    end
    
    % Add a special tag property so that we can find the analysis again.
    p = schema.prop(h, 'fvtool_tag', 'string');
    set(h, 'fvtool_tag', tag);
    set(p, 'Visible', 'Off');
%     set(p, 'Visible', 'Off', 'AccessFlags.PublicSet', 'Off'); %xxx
%     undo/redo fix
    
    % When the new flag is passed in we don't want to save the object.
    if ~new,
        addcomponent(hObj, h);
    end
end

% [EOF]
