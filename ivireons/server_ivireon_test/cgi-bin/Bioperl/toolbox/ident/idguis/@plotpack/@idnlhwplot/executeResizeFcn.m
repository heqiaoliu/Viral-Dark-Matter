function executeResizeFcn(this)
% resize function for idnlhw plot

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2007/02/06 19:52:30 $

f = this.Figure;
fpos = get(f,'pos');
u1 = this.TopPanel;
if strcmpi(get(u1,'vis'),'on')
    u1height = 105;
else
    u1height = 0;
end

u2 = this.MainPanels;
u2pos = hgconvertunits(f,get(u2(1),'pos'),'norm','pixels',f);
u2pos(4) = fpos(4)-u1height; 
set(u2,'pos',hgconvertunits(f,u2pos,'pix','norm',f));

if u1height~=0
    u1pos = hgconvertunits(f,get(u1,'pos'),'norm','pixels',f);
    u1pos(2) = u2pos(2)+u2pos(4);
    u1pos(4) = u1height;
    set(u1,'pos',hgconvertunits(f,u1pos,'pix','norm',f));
end

fposchar = hgconvertunits(f,fpos,get(f,'units'),'char',0);
set(this.UIs.LinearPlotTypeText,'pos',[fposchar(3)-22-20 0.5 23 1.54]);
set(this.UIs.LinearPlotTypeCombo,'pos',[fposchar(3)-22 0.82 20 1.54]);
set(this.UIs.CollapseButton,'pos',[fposchar(3)-4.7,fposchar(4)-1.7,4,1.5]);
