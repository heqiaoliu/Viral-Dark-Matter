function engageConnection_SourceSpecific(this)
%ENGAGECONNECTION_SOURCESPECIFIC Called by Source::enable method when a
%source is enabled. Overload for SrcMLStreaming.

% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/03/31 18:41:56 $

installDataHandler(this);

if strcmp(this.ErrorStatus,'failure')
    return
end

% At this point of instantiation, we have full cross-coupling of
% handle reference, i.e.,
%    h.data (the SrcMLStreaming object property) points to the new
%    DCS object,
% and
%    dcsObj.srcObj (explicit pointer to parent) now points to h
%    (the SrcMLStreaming object).

set(this.Application.getStatusControl('Rate'), 'Visible', 'off');

hFrame = this.Application.getStatusControl('Frame');
hFrame.Tooltip = this.DataHandler.getStatusControlTooltip('Frame');
this.FrameCountStatusBar = hFrame;

% [EOF]
