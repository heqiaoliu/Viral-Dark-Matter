function executeResizeFcn(this)
% resize function for idnlarx plot figure

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:46 $

f = this.Figure;
set(this.Figure,'units','char'); %g334994
fpos = get(f,'pos');
u1 = this.ControlPanel;
u3 = this.TopPanel;
if strcmpi(get(u3,'vis'),'on')
    u3height = 2.2615;
else
    u3height = 0;
end
if strcmpi(get(u1,'vis'),'on')
    u1width = 30;
else
    u1width = 0;
end

u2 = this.MainPanels;
u2pos = hgconvertunits(f,get(u2(1),'pos'),'norm','char',f);
u2pos(3) = fpos(3)-u1width; 
u2pos(4) = fpos(4)-u3height;
set(u2,'pos',u2pos);
u3pos = [0,fpos(4)-u3height,fpos(3)-u1width,u3height];
set(u3,'pos',u3pos); %hgconvertunits(f,u3pos,'char','norm',f)

if u1width~=0
    u1pos(4) = 26;
    u1pos(2) = max(0.1,fpos(4)-u1pos(4));
    u1pos(3) = u1width;
    u1pos(1) = fpos(3)-u1width;
    set(u1,'pos',u1pos); 
end

set(this.UIs.CollapseButton,'pos',[fpos(3)-4.7,fpos(4)-1.7,4,1.5]);
