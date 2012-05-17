function this = VisualResizedEventData(hSource, eventName, container, size)
%VISUALRESIZEDEVENTDATA Construct a VISUALRESIZEDEVENTDATA object

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 22:47:54 $

this = uiscopes.VisualResizedEventData(hSource, eventName);

this.Container = container;
this.Size      = size;

% [EOF]
