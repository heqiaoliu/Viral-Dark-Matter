function [Hd, same] = design(this)
%DESIGN   Design given the current settings.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2009/10/16 06:38:09 $

same = false;

% Design based on the last applied state of the dialog, not its current
% state.  This is done because many of the widgets rendered by DDG need
% their mode set to "true" which updates them before we hit apply.
laState = get(this, 'LastAppliedState');

if isempty(laState)
    captureState(this);
    laState = get(this, 'LastAppliedState');
end

% The "Specs" is the evaluated version of the State.  It only includes the
% fields of the state which will be used for the design.
specs    = getSpecs(this, laState);
oldSpecs = get(this, 'LastAppliedSpecs');

% Get the design options.
designOpts    = getDesignOptions(this, laState);
oldDesignOpts = get(this, 'LastAppliedDesignOpts');

oldDesignOpts = fixupOldDesignOpts(oldDesignOpts);

% If the specs haven't changed, check the filter and just apply the fixed
% point settings.
if isequal(specs, oldSpecs) && isequal(designOpts, oldDesignOpts)
    
    % This is the same filter because the specifications are the same.
    same = true;
    
    Hd = get(this, 'LastAppliedFilter');
    
    % Always reapply the fixed point settings.  We aren't going to try to
    % optimize this because it is not very expensive.
    if ~isempty(Hd),
        if ~isempty(this.FixedPoint)
            applySettings(this.FixedPoint, Hd);
        end
        return;
    end
end

set(this, 'LastAppliedSpecs', specs, ...
    'LastAppliedDesignOpts',  designOpts);

[hfdesign, b, msg] = getFDesign(this, laState);

% If getFDesign fails, rethrow the error.
if ~b, error(msg); end

% Get the appropriate method string.
method = getSimpleMethod(this, laState);

Hd = design(hfdesign, method, designOpts{:});

if ~isempty(this.FixedPoint)
    applySettings(this.FixedPoint, Hd);
end

set(this, 'LastAppliedFilter', Hd);

% -------------------------------------------------------------------------
function designOpts = fixupOldDesignOpts(designOpts)

% Remove StopbandDecay when the StopbandShape is flat for backwards
% compatibility.  We do not want to redesign this filter because the
% settings are actually the same regardless of the StopbandDecay value.
indx = find(strcmp(designOpts, 'StopbandShape'));
if ~isempty(indx) && strcmpi(designOpts{indx+1}, 'flat')
    indx = find(strcmp(designOpts, 'StopbandDecay'));
    if ~isempty(indx)
        designOpts(indx:indx+1) = [];
    end
end

% [EOF]
