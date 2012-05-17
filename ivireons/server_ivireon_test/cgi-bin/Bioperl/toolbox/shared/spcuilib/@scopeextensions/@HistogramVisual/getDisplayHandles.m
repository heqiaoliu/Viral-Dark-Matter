function displayHandles = getDisplayHandles(this)
%GETDISPLAYLHANDLES Get the display handles. The visibility of these handles are turned off
% when the source is released.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $    $Date: 2010/03/31 18:41:29 $
    
% No action needed if NTX is featured "On". The NTX UI object takes care of
% setting the visible state of the visual. Once other sources are enabled,
% this will need to be revisited.
if this.NTXFeaturedOn
    displayHandles = [];
else
    displayHandles(1) = get(this,'Axes'); 
    if ishghandle(this.Legend)
        displayHandles(3) = get(this,'Legend');
    end

    displayHandles = [displayHandles, this.LineHandleRe(ishghandle(this.LineHandleRe)), ...
                      this.XTicktextObj(ishghandle(this.XTicktextObj)),...
                      this.xLabelTextObj(ishghandle(this.xLabelTextObj))];
end
    

    
