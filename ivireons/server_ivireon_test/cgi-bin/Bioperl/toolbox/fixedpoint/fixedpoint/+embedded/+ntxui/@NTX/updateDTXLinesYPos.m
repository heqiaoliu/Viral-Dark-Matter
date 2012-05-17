function updateDTXLinesYPos(ntx)
% Set height of WordSpan line (yws) to be just below the wordspan text,
% and above the frac/int text.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:58 $

% Leave additional 15% of text height as a vertical gutter between
% wordspan text and wordspan line.
psave = get(ntx.htWordSpan,'pos'); % save for wander bug-fix
set(ntx.htWordSpan,'units','data');
ext = get(ntx.htWordSpan,'extent'); % extent of text, in data units
yws = ext(2) - 0.15*ext(4);  % yBottom, minus 15% of yHeight
set(ntx.htWordSpan,'units','char','pos',psave);

% Retain yWordSpan for other scaling code
ntx.yWordSpan = yws;

% Update word span, radix, threshold lines
ylim = get(ntx.hHistAxis,'ylim');    % height in data units
set([ntx.hlUnder ntx.hlOver],'ydata',[0 ylim(2)]);
set(ntx.hlWordSpan,'ydata',[yws yws]);

% Height of radix line must be conditionally set,
% based on where threshold cursors are located
updateRadixLineYExtent(ntx);
