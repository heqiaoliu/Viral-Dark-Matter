function createLayout(this)
% create layout for edit range dialog

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:55:13 $

close(findobj(0,'type','figure','tag','nlident:rangedlg'))
Dlg = dialog('WindowStyle', 'modal','units','char','Name',...
    'Edit Range','tag','nlident:rangedlg','ButtonDownFcn','','resize','off',...
    'vis','off');
dpos = get(Dlg,'pos');
dpos(3:4) = [67 8];
set(Dlg,'pos',dpos);

tpos = [2, dpos(4)-1.5, dpos(3)-5, 1];
toptxt = uicontrol('parent',Dlg,'style','text','string','Edit Range:','units','char',...
    'pos',tpos,'HorizontalAlignment','Left');

edpos = [tpos(1), tpos(2)-3, dpos(3)-4, 1.54];
xed = uicontrol('parent',Dlg,'style','edit','string','[ ]','units','char',...
    'pos',edpos,'HorizontalAlignment','Left','BackgroundColor','w',...
    'tag','rangedlg:editbox');

if strcmpi(this.Type,'samples')
    set(xed,'string',int2str(this.PlotObj.NumSample))
end

% buttons
ht = 1.8; wid = 9; hm = 1; vm = 0.2;
helppos = [dpos(3)-1.4-wid, vm, wid, ht];
this.UIs.HelpBtn = uicontrol('parent',Dlg,'style','pushbutton','string','Help',...
    'units','char','pos',helppos);

closepos = [helppos(1)-hm-wid, vm, wid, ht];
this.UIs.CloseBtn = uicontrol('parent',Dlg,'style','pushbutton','string','Close',...
    'units','char','pos',closepos);

applypos = [closepos(1)-hm-wid, vm, wid, ht];
this.UIs.ApplyBtn = uicontrol('parent',Dlg,'style','pushbutton','string','Apply',...
    'units','char','pos',applypos);

this.Dialog = Dlg;
this.UIs.EditBox = xed;
this.UIs.TopLabel = toptxt;
this.setText;