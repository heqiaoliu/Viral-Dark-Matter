function [success, exception, map] = validateMapExpression(this, mapExpression)
%VALIDATEMAPEXPRESSION Validate the mapexpression

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/23 18:44:11 $

if nargin < 2
    mapExpression = get(this, 'MapExpression');
end

success   = true;
exception = MException.empty;

try
    % In case user enters just "hot" instead of "hot(256)"
    % (or whatever colormap is chosen), we need to allow the
    % colormap function to "see" the current instance of mplay
    % as "gcf".  That's because the builtin colormap functions all
    % have an odd no-input-argument behavior: installing the colormap
    % into the "current" fig.
    oldShowHiddenHandles = get(0, 'ShowHiddenHandles');
    set(0, 'ShowHiddenHandles', 'on');
    map = evalin('base', mapExpression);
    set(0, 'ShowHiddenHandles', oldShowHiddenHandles);
    
catch exception
    
    map     = [];
    success = false;
    set(0, 'ShowHiddenHandles', oldShowHiddenHandles);
    exception = MException(exception.identifier, sprintf('%s\n\n%s', ...
        'Failed to evaluate colormap expression.', ...
        uiservices.cleanErrorMessage(exception)));
end

% [EOF]
