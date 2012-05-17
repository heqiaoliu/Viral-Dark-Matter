function varargout = validate(hDlg)
%VALIDATE Returns true if this object is valid

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/11/16 22:34:41 $

b         = true;
exception = MException.empty;

% The 'Name' used to determine the tags, is the extension name, which can
% change depending on the subclass and how it was registered with the
% extmgr.  Get that name, to build the tag strings.
name = get(hDlg.getSource.Config, 'Name');

visStates = uiservices.pipeToCell(hDlg.getWidgetValue([name 'LineVisibilities']));
styles    = uiservices.pipeToCell(hDlg.getWidgetValue([name 'LineStyles']));
markers   = uiservices.pipeToCell(hDlg.getWidgetValue([name 'LineMarkers']));
colors    = uiservices.pipeToCell(hDlg.getWidgetValue([name 'LineColors']));

% Check that all the visStates are either 'on' or 'off'.
for indx = 1:length(visStates)
    if ~any(strcmp(visStates{indx}, {'on', 'off', ''}))
        b = false;
        [msg id] = uiscopes.message('InvalidVisibleState', visStates{indx});
        exception = MException(id, msg);
    end
end

% Check that all the styles are valid: - (default) : -. -- none
for indx = 1:length(styles)
    if ~any(strcmp(styles{indx}, [uiservices.getLineStyles {''}]));
        b = false;
        [msg id] = uiscopes.message('InvalidStyle', styles{indx});
        exception = MException(id, msg);
    end
end

% Check that all the markers are valid: . o x + * s d v ^ < > p h stem
for indx = 1:length(markers)
    if ~isempty(markers{indx}) && ...
            ~any(strncmp(markers{indx}, uiservices.getMarkers(true), length(markers{indx})))
        b = false;
        [msg id] = uiscopes.message('InvalidMarker', markers{indx});
        exception = MException(id, msg);
    end
end

% Check that all the colors are valid: b g r c m y k w
for indx = 1:length(colors)
    if ~any(strcmpi(colors{indx}, [uiservices.getColors {''}]))
        b = false;
        [msg id] = uiscopes.message('InvalidColor', colors{indx});
        exception = MException(id, msg);
    end
end

autodisplay = hDlg.getWidgetValue([name 'AutoDisplayLimits']);
if ~autodisplay
    % check xlim
    
    minXLim = hDlg.getWidgetValue([name 'MinXLim']);
    maxXLim = hDlg.getWidgetValue([name 'MaxXLim']);
    try
        minXLim = uiservices.evaluate(minXLim);
        maxXLim = uiservices.evaluate(maxXLim);
    catch exception
        b   = false;
    end
    
    if b && (isnan(minXLim) || isnan(maxXLim) || minXLim >= maxXLim)
        b = false;
        [msg id] = uiscopes.message('InvalidXLim');
        exception = MException(id, msg);
    end

end

cb = @(val) ~isscalar(val) || isnan(val) || isinf(val) || ~isreal(val);
if b
    [b, exception, minYLim] = uiservices.validateWidgetValue(hDlg, 'MinYLim', cb);
end
if b
    [b, exception, maxYLim] = uiservices.validateWidgetValue(hDlg, 'MaxYLim', cb);
end

% Check if the min and max limits make sense.
if b && minYLim >= maxYLim
    b = false;
    [msg id] = uiscopes.message('InvalidYLim');
    exception = MException(id, msg);
end

if nargout
    varargout = {b, exception};
elseif ~b
    rethrow(exception);
end

% [EOF]
