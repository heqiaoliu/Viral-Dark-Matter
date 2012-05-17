function centerfigonfig(hFDA, hmsg)
%CENTERFIGONFIG Center figure on top of FDATool.
%   CENTERFIGONFIG(hFDA,hFig) Center figure window associated with
%   hFig on FDATool associated with hFDA.

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:41:58 $ 

hFig = get(hFDA,'FigureHandle');

set(hFig,'units','pix');
figPos = get(hFig,'pos');
figCtr = [figPos(1)+figPos(3)/2 figPos(2)+figPos(4)/2];

set(hmsg,'units','pix');
msgPos = get(hmsg,'position');
msgCtr = [msgPos(1)+msgPos(3)/2 msgPos(2)+msgPos(4)/2];

movePos = figCtr - msgCtr;

new_msgPos = msgPos;
new_msgPos(1:2) = msgPos(1:2) + movePos;
set(hmsg,'Position',new_msgPos);

% [EOF] centerfigonfig.m
