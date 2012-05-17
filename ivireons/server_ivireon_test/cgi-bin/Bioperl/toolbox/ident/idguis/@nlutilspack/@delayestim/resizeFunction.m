function resizeFunction(this)
% resize function for shape editor figure

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/03/13 17:24:07 $

fpos = get(this.Figure,'pos');
tppos = get(this.Panels.Top,'pos');
tppos(3) = fpos(3);
tppos(2) = fpos(4)-tppos(4);

set(this.Panels.Top,'pos',tppos);

bppos = get(this.Panels.Bottom,'pos');
bppos(3) = fpos(3);
set(this.Panels.Bottom,'pos',bppos);

wid = 9; hm = 0.75;
helppos = get(this.UIs.HelpBtn,'pos');
helppos(1) = bppos(3)-1.4-wid;

closepos = get(this.UIs.CloseBtn,'pos');
closepos(1) = helppos(1)-hm-wid;

insertpos = get(this.UIs.InsertBtn,'pos');
insertpos(1) = closepos(1)-hm-wid;

set(this.UIs.HelpBtn,'pos',helppos);
set(this.UIs.CloseBtn,'pos',closepos);
set(this.UIs.InsertBtn,'pos',insertpos);

delpos = get(this.UIs.DelayLabel,'pos');
set(this.UIs.DelayLabel,'pos',[delpos(1:2),fpos(3)-2,delpos(4)]);

midpos = [0, bppos(4), fpos(3), max(0.1,fpos(4)-tppos(4)-bppos(4))];
set(this.Panels.Main,'pos',midpos);

ipos = [0.5, midpos(4)-6.6, midpos(3)-1.5, 4];
set(this.TimeInfo.InstrLabel,'pos',ipos);
set(this.ImpulseInfo.InstrLabel,'pos',ipos);

axpos = [12,3,max(0.1,midpos(3)-14),max(ipos(2)-4,0.1)];
set(this.TimeInfo.Axes,'pos',axpos);
set(this.ImpulseInfo.Axes,'pos',[axpos(1:3),max(0.1,axpos(4)-1)]);

str = this.TimeInfo.Message;
str = textwrap(this.TimeInfo.InstrLabel,{str});
set(this.TimeInfo.InstrLabel, 'string',str); 

str = this.ImpulseInfo.Message;
str = textwrap(this.ImpulseInfo.InstrLabel,{str});
set(this.ImpulseInfo.InstrLabel, 'string',str); 
