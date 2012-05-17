function notification_listener(hObj, eventData, varargin)
%NOTIFICATION_LISTENER

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2009/08/29 08:32:08 $

NTypes = set(eventData, 'NotificationType');
NType  = get(eventData, 'NotificationType');

% hFVT = getcomponent(hObj, 'fvtool');

% Switch on the Notification type
switch NType
case NTypes{2}, % 'WarningOccurred'
    lclcheckwarning(hObj, eventData, varargin{:});
otherwise
    send(hObj, 'Notification', eventData);
end

% --------------------------------------------------------------
function lclcheckwarning(hObj, eventData, varargin)

if isa(eventData.Source, 'sigresp.abstractanalysis') && nargin < 3,
    
    % Cache the warnings thrown from filtresp.abstractresp objects for
    % later use.  We do this to prevent flicker in the axes.  These
    % warnings will be thrown when the axes is done drawing.
    frw = get(hObj, 'FiltRespWarnings');
    if isempty(frw),
        frw = eventData;
    else
        frw(end+1) = eventData;
    end
    set(hObj, 'FiltRespWarnings', frw);
else
    
    lstr = eventData.Data.WarningString;
    lid  = eventData.Data.WarningID;
    
    % If there is a warning to display, don't display the finished message
    lid = fliplr(strtok(fliplr(lid), ':'));
    
    if any(strcmpi(lid, {'syntaxchanged', 'NextPlotNew', 'usemethod'})) || ...
        ~isempty(findstr(lower(lstr), 'axes limit range too small')),
      return;
    else
      switch lower(lstr)
        case lower([xlate('Negative data ignored') '.']),
          eventData.Data.WarningString = 'Negative frequencies ignored when using log scale.';
      end
    end
    
    send(hObj, 'Notification', eventData);

end

% [EOF]
