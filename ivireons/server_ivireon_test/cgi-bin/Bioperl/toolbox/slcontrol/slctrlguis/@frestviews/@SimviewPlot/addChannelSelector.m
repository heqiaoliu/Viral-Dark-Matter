function h = addChannelSelector(this)
%ADDCHANNELSELECTOR  Builds the channel selector for simview plot.

%   Author(s): Erman Korkut 31-Mar-2009
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/04/21 04:49:47 $


% Build selector
h = frestviews.ChannelSelector(this,this.CurrentChannel);

% Center dialog
centerfig(h.Handles.Figure,this.Figure);
