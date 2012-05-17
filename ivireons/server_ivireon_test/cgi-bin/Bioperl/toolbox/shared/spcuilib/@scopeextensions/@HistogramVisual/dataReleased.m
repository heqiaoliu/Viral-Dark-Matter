function dataReleased(this,~)
% DATARELEASED restore the UI when a source is disconnected. Restore the visual to its default state.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $     $Date: 2010/03/31 18:41:28 $

% No action needed if NTX is featured "On". The NTX UI object takes care of
% clearing the visual. Once other sources are enabled, this will need to be
% revisited.
if ~(this.NTXFeaturedOn)
    if any(ishghandle(this.LineHandleRe))
        delete(this.LineHandleRe(ishghandle(this.LineHandleRe)));
    end
    if ishghandle(this.Legend)
        set(this.Legend,'Visible','off');
    end
    set(this.Axes, 'Visible', 'off');
    % Reset the counter that is used to indicate if
    % update was called for the first time.
    this.Counter = 0;
    % Clear the cached Xlimits.
    this.PreviousXLim = [];
end

