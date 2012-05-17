function showHistogramIfWide(ntx)
% Show the histogram display if the area is sufficiently wide.
% Otherwise show a messsage indicating area is too small.
%
% If display is too narrow for even the message to display,
% disable the message.  This is important, because we want to enable
% customers to make the display very narrow to show just the dialogs.
%
% When the histogram is no longer shown, disable the "sign line" property
% in the Options dialog.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:52 $

[~,histWidth] = getBodyPanelAndSize(ntx.dp);

% Test dimension of histogram
% If axis is too narrow, shut off visibility
tooNarrowForHisto = histWidth <= ntx.MinHistoWidth;
if tooNarrowForHisto && ntx.ShowHistogram
    % Hide histogram, show msg, disable sign line
    showHistogram(ntx,false);
    set(ntx.htNoHistoTxt,'vis','on');
    
elseif ~tooNarrowForHisto && ~ntx.ShowHistogram
    % Show histogram, hide msg, enable sign line
    showHistogram(ntx,true);
    set(ntx.htNoHistoTxt,'vis','off');
end

% Test dimension of "no histo" msg
ext = get(ntx.htNoHistoTxt,'ext');
tooNarrowForMsg = histWidth <= ext(3);
isMsgVis = strcmpi(get(ntx.htNoHistoTxt,'vis'),'on');
if tooNarrowForMsg && isMsgVis
    % Hide msg
    set(ntx.htNoHistoTxt,'vis','off');
elseif tooNarrowForHisto && ~tooNarrowForMsg && ~isMsgVis
    % Show msg
    set(ntx.htNoHistoTxt,'vis','on');
end

% In case signedness changed - say, from showing warning (unsigned on
% negative) to NOT showing warning, we must update the signed display
% We may have made histogram visible now, and a "stale" signed display may
% be present
updateNumericTypesAndSigns(ntx);
