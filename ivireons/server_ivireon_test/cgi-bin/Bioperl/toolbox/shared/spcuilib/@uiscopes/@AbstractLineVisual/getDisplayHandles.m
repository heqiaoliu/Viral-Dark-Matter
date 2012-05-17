function displayHandles = getDisplayHandles(this)
%GETDISPLAYHANDLES Get the displayHandles.

%   Author(s): J. Schickler
%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/03/31 18:43:51 $

% Return the axes and line handles.
% Cast to doubles in case the elements of the array are objects instead
% of handles as is the case in HG2
displayHandles = [double(this.Axes) this.Legend double(this.Lines) this.InsideXTicks this.InsideYTicks];
displayHandles = displayHandles(ishghandle(displayHandles));

% [EOF]
