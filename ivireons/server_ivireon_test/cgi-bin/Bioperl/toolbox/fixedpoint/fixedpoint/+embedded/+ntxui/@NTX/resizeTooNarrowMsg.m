function resizeTooNarrowMsg(ntx)
% Update position of message indicating the body is too narrow to display
% application UI (histogram).

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $     $Date: 2010/03/31 18:21:47 $

[hBodyPanel,hist_dx,hist_dy] = getBodyPanelAndSize(ntx.dp);
bpos = get(hBodyPanel,'pos');
ht = ntx.htNoHistoTxt;
ext = get(ht,'ext');
x0 = bpos(1)+hist_dx/2-ext(3)/2; % x coord to start message
y0 = hist_dy/2-ext(4)*2/3;
set(ht,'pos',[x0, y0, ext(3:4)]);
