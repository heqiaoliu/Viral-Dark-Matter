function initializePlot(this)
%Lay out the idnlarx plot figure.

% Copyright 2006-2008 The MathWorks, Inc.
% $Revision: 1.1.8.6 $ $Date: 2008/10/02 18:50:58 $

import com.mathworks.toolbox.ident.nlidutils.*;
fname = 'Nonlinear ARX Model Plot';

if (this.isGUI)
    f = plotpack.buildNLARXGUIFigureWindow(this);
else
    f = figure('Name',fname,'Visible','off', 'NumberTitle','off','tag','nlsitbfig_nlarx',...
    'IntegerHandle','off','units','char','renderer','zbuffer','PaperPositionMode','auto');
end

fpos = get(f,'pos');
this.Figure = f;
bckcol = 'w';
% output combo box and its panel
comboht = 1.54;
this.TopPanel = uipanel('parent',f,'units','char');
uicontrol('parent',this.TopPanel,'style','text','units','char',...
    'string','Select nonlinearity at output:','pos',[0.5 0.5 30 1],...
    'HorizontalAlignment','left','fontsize',8);

this.UIs.OutputCombo = uicontrol('parent',this.TopPanel,'style','popup','String',...
    this.getOutputComboString,'units','char','Tag','outputcombo',...
    'pos',[32 0.2 25 comboht],'BackgroundColor',bckcol);

thisy = this.getCurrentOutput;

this.MainPanels = []; 

localAssembleControlPanel(this,fpos,comboht,bckcol,thisy);

% collapse button
this.UIs.CollapseButton = uicontrol('parent',f,'style','pushbutton','string','>>',...
    'fontsize',8,'HorizontalAlignment','center','fontweight','bold',...
    'units','char','pos',[fpos(3)-4.7,fpos(4)-1.7,4,1.5],...
    'callback',@(es,ed)localCollapseButtonCallback(es,this),'tag','collapsebutton');

this.CenterPointTable = centerpointtable;
hcpt = handle(this.CenterPointTable.getOKButton,'callbackproperties');
hcpt.ActionPerformedCallback = {@localCenterPointOKCallback this};

set(this.UIs.OutputCombo,'callback',@(es,ed)localOutputComboSelection(this));
set(this.UIs.ApplyButton,'Callback',@(es,ed)localApplyButtonCallback(this));
set(this.UIs.CenterPointButton,'Callback',@(es,ed)localCenterPointButtonCallback(this));

if ~this.isGUI
    set(f,'toolbar','figure');
else
    this.attachListeners; % model related event handling
end

%--------------------------------------------------------------------------
function localAssembleControlPanel(this,fpos,comboht,bckcol,yname)
% assemble control panel
% yname: name of current output

f = this.Figure;
ht = 26;
u1width = 30;
p = [fpos(3)-u1width,fpos(4)-ht,u1width,ht];
this.ControlPanel = uipanel('parent',f,'units','char','BorderType','none','pos',p); %etchedin

cl = get(this.ControlPanel,'BackgroundColor'); set(f,'Color',cl);
cl1 = cl*0.95;
yloc = 2.5;
this.UIs.CurrentOutputLabel = uicontrol('parent',this.ControlPanel,'style','text',...
    'units','char','string','Output:','pos',[0.1,p(4)-yloc,u1width-1,1],...
    'HorizontalAlignment','left','BackgroundColor',cl1);
%background color
p1 = get(this.UIs.CurrentOutputLabel,'pos');
ax = axes('parent',this.ControlPanel,'xtick',[],'ytick',[],'units','char',...
    'pos',[0 p1(2)-0.5 p(3) yloc+0.7],'xcolor',cl1,'ycolor',cl1,...
    'color',cl1);

gap = 2.1;

% Regressor 1:
p2 = get(ax,'pos');
lab1 = uicontrol('parent',this.ControlPanel,'style','text',...
    'units','char','string','Regressor 1:','pos',[0.1 p2(2)-gap 22 1],...
    'HorizontalAlignment','left');

p3 = get(lab1,'pos');
x0 = 1;

Data = find(this.RegressorData,'OutputName',yname);

regnames = cat(1,{Data.RegInfo.Name});
regnames = regnames(:);
this.UIs.Reg1Combo = uicontrol('parent',this.ControlPanel,'style','popup',...
    'String',regnames,'units','char','Tag','reg1combo',...
    'pos',[x0,p3(2)-comboht-0.5,p(3)-3*x0,comboht],'BackgroundColor',bckcol,...
    'Callback',@(es,ed)localRegComboCallback(es,this));

set(this.UIs.Reg1Combo,'Value',Data.ComboValue.Reg1);

p4 = get(this.UIs.Reg1Combo,'pos');
lab2 =  uicontrol('parent',this.ControlPanel,'style','text',...
    'units','char','string','Range:','pos',[x0 p4(2)-2 10 1],...
    'HorizontalAlignment','left');

p5 = get(lab2,'pos');
%data = h.RegressorData(h.CurrentOutputComboValue);
%val = sprintf('[%s]',num2str(data.Reg1.Range));

this.UIs.Reg1RangeEdit = uicontrol('parent',this.ControlPanel,'style','edit',...
    'String',this.getRegStr(yname,1),'units','char','Tag','reg1edit',...
    'pos',[p5(1)+p5(3)+0.1,p4(2)-comboht-0.5,p(3)-3*x0-p5(3)-0.5,comboht],...
    'HorizontalAlignment','left','BackgroundColor',bckcol); 

% Regressor 2:
p2a = get(this.UIs.Reg1RangeEdit,'pos');
lab1a = uicontrol('parent',this.ControlPanel,'style','text',...
    'units','char','string','Regressor 2:','pos',[0.1 p2a(2)-gap 22 1],...
    'HorizontalAlignment','left','BackgroundColor',cl1);

p3a = get(lab1a,'pos');
this.UIs.Reg2Combo = uicontrol('parent',this.ControlPanel,'style','popup',...
    'String',['<none>';regnames],'units','char','Tag','reg2combo',...
    'pos',[x0,p3a(2)-comboht-0.5,p(3)-3*x0,comboht],'BackgroundColor',bckcol,...
    'Callback',@(es,ed)localRegComboCallback(es,this));

set(this.UIs.Reg2Combo,'Value',Data.ComboValue.Reg2);

p4a = get(this.UIs.Reg2Combo,'pos');
lab2a =  uicontrol('parent',this.ControlPanel,'style','text',...
    'units','char','string','Range:','pos',[x0 p4a(2)-2 10 1],...
    'HorizontalAlignment','left','BackgroundColor',cl1);

p5a = get(lab2a,'pos');
%val = sprintf('[%s]',num2str(data.Reg2.Range));
this.UIs.Reg2RangeEdit = uicontrol('parent',this.ControlPanel,'style','edit',...
    'String',this.getRegStr(yname,2),'units','char','Tag','reg2edit',...
    'pos',[p5a(1)+p5a(3)+0.1,p4a(2)-comboht-0.5,p(3)-3*x0-p5a(3)-0.5,comboht],...
    'HorizontalAlignment','left','BackgroundColor',bckcol); 

if (Data.ComboValue.Reg2==1)
    set(this.UIs.Reg2RangeEdit,'Enable','off');
end

p6 = get(this.UIs.Reg2RangeEdit,'pos');

% put background color (axes)
ax2 = axes('parent',this.ControlPanel,'xtick',[],'ytick',[],'units','char',...
    'pos',[0 p6(2)-0.6 p(3) p5(2)-p6(2)],'xcolor',cl1,'ycolor',cl1,...
    'color',cl1);

% Remaining regressors:
p2b = get(ax2,'pos');
lab1b = uicontrol('parent',this.ControlPanel,'style','text',...
    'units','char','string','Remaining regressors:','pos',[0.1 p2b(2)-gap 25 1],...
    'HorizontalAlignment','left');
p3b = get(lab1b,'pos');
this.UIs.CenterPointButton = uicontrol('parent',this.ControlPanel,'style','pushbutton',...
    'String','Fix Values...','units','char','Tag','centerpt',...
    'pos',[x0*2.2,p3b(2)-comboht-1,p(4)-4.4*x0,comboht]);

% Apply button
p7 = get(this.UIs.CenterPointButton,'pos');
this.UIs.ApplyButton = uicontrol('parent',this.ControlPanel,'style','pushbutton',...
    'String','Apply','units','char','Tag','applybtn',...
    'pos',[x0*5,p7(2)-comboht-0.5-gap,p(4)-10*x0,comboht*1.1]);

% Put background color (axes)
% p8 = get(this.UIs.ApplyButton,'pos');
% axes('parent',this.ControlPanel,'xtick',[],'ytick',[],'units','char',...
%     'pos',[0 p8(2)-0.5 p(3) p8(4)+1],'xcolor',cl1,'ycolor',cl1,...
%     'color',cl1);


%--------------------------------------------------------------
function localCollapseButtonCallback(es,this)

str = get(es,'String');
if strcmp(str,'>>')
    str = '<<';
    set(this.ControlPanel,'vis','off');
    set(get(this.ControlPanel,'Children'),'vis','off')
else
    str = '>>';
    set(this.ControlPanel,'vis','on');
    set(get(this.ControlPanel,'Children'),'vis','on')
end

set(es,'String',str);
this.executeResizeFcn;

%---------------------------------------------------------------
function localOutputComboSelection(this,varargin)

set(this.Figure,'units','char'); %g334994

Ind = get(this.UIs.OutputCombo,'Value');

if Ind==this.Current.OutputComboValue
    return;
else
    this.Current.OutputComboValue = Ind;
    retainRegNames = false;
    %this.refreshControlPanel(retainRegNames);
    this.showPlot(retainRegNames);
end

%-----------------------------------------------------------------
function localApplyButtonCallback(this)
%input validation and updating database

status = localValidateEntries(this);
if ~status
    return
end

%this.refreshCurrentPlot;
this.generateRegPlot(false); %isNew=false

%--------------------------------------------------------------------------
function status = localSetRegEdit(this,data,Name)

status = true;
if strcmp(Name,'Reg1')
    editbox = this.UIs.Reg1RangeEdit;
    selInd = data.ComboValue.Reg1;    
else
    editbox = this.UIs.Reg2RangeEdit;
    if strcmpi(get(editbox,'enable'),'off')
        return
    end
    selInd = data.ComboValue.Reg2-1;
end

% selInd is the index of the active regressor showing in combo box; find
% the corresponding regressor info struct index;
regInd = find(strcmp({data.RegInfo.Name},data.ActiveRegressors{selInd}));

range = data.RegInfo(regInd).Range;

try
    val = ['[',get(editbox,'String'),']'];
    val = evalin('base',val);
    if localIsValidRange(val)
        range = val;
    else
        errordlg('Invalid value or range. Enter finite [Min Max] values for range. Reverting to old values.',...
            'IDNLARX Model Plot','modal')
        set(editbox,'String',sprintf('[%s]',num2str(range)));
        status = false;
        return
    end
catch E
    errordlg(sprintf('%s\nReverting to old value.',idlasterr(E)),'IDNLARX Model Plot','Modal')
    set(editbox,'String',sprintf('[%s]',num2str(range)));
    status = false;
    return
end

data.RegInfo(regInd).Range = range;

%--------------------------------------------------------------------------
function boo = localIsValidRange(val)

boo = false;

if ~isempty(val) && isnumeric(val) && all(isfinite(val)) && isreal(val) && isfloat(val)
    if ((numel(val)==2) && val(2)>val(1)) %|| (numel(val)>2 && all(diff(val)>0))
        boo = true;
    end
end

%--------------------------------------------------------------------------
function localRegComboCallback(es,this)

tag = get(es,'tag');
v = get(es,'value');
thisy = this.getCurrentOutput;
data = find(this.RegressorData,'OutputName',thisy);

if strcmp(tag,'reg1combo')
    data.ComboValue.Reg1 = v;
    set(this.UIs.Reg1RangeEdit,'string',this.getRegStr(thisy,1));
else
    data.ComboValue.Reg2 = v;
    if v>1
        set(this.UIs.Reg2RangeEdit,'string',this.getRegStr(thisy,2),...
            'enable','on');
    else
        set(this.UIs.Reg2RangeEdit,'Enable','off')
    end
end

%--------------------------------------------------------------------------
function localCenterPointButtonCallback(this)
% show the centerpoint table

[status,data] = localValidateEntries(this);
if ~status
    return
end

%thisy = this.getCurrentOutput;
[cpt,othersId] = localFindCenterPt(data);

if isempty(othersId)
   msgbox(sprintf('No other regressors for output "%s".',data.OutputName),'Fix Values Warning');
   return
end

cptToShow = cpt(othersId);
regnames = cat(1,{data.RegInfo.Name});
regnames = regnames(:);
regnames = regnames(othersId);
tabledata = cell(length(regnames),2);

for k = 1:length(regnames)
    tabledata(k,:) = {regnames{k},cptToShow(k)};
end

tabledata = nlutilspack.matlab2java(tabledata,'matrix');
this.CenterPointTable.getTableModel.setData(tabledata,0,length(regnames)-1);
%awtinvoke(this.CenterPointTable,'refreshTable()');
this.CenterPointTable.refreshTable; %EDT method

%--------------------------------------------------------------------------
function localCenterPointOKCallback(es,ed,this)
% call back to OK button of centerpoint table dialog
% update center point values for current output for "other" regressors

thisy = this.getCurrentOutput;
data = find(this.RegressorData,'OutputName',thisy);
[cpt,othersId] = localFindCenterPt(data);

tabledata = cell(this.CenterPointTable.getTableModel.getData);
val = cell2mat(tabledata(:,2));

if ~all(isfinite(val))
    errordlg('NaNs/Infs are not allowed for centerpoint values and will be ignored.',...
        'Invalid Center Point Specification');
    %return
    cptToShow = cpt(othersId);
    [nanind,a] = find(~isfinite(val));
    val(nanind) = cptToShow(nanind);
end

cpt(othersId) = val;
cptcell = num2cell(cpt);

% todo: this causes segV on Linux:
%[data.RegInfo.CenterPoint] = deal(cptcell{:});
% workaround:
for k = 1:length(cptcell)
    data.RegInfo(k).CenterPoint = cptcell{k};
end

%h.RegressorData(Ind).CenterPoint = cpt;
javaMethodEDT('setVisible',this.CenterPointTable,false);

%--------------------------------------------------------------------------
function [status,data] = localValidateEntries(this)
% validate combo box selections and edit box entries

%status = true;
thisy = this.getCurrentOutput;
data = find(this.RegressorData,'OutputName',thisy);

Ind1 = get(this.UIs.Reg1Combo,'Value');
Ind2 = get(this.UIs.Reg2Combo,'Value');
if Ind1==(Ind2-1)
    status = false;
    errordlg(sprintf('%s\n%s',...
        'Same regressor can not be selected for both plot axes.',...
        'Change Regressor 1 or Regressor 2 selection.'),'IDNLARX Model Plot','modal')
    return
end

data.ComboValue.Reg1 = Ind1;
data.ComboValue.Reg2 = Ind2;
status = localSetRegEdit(this,data,'Reg1');
if Ind2~=1
    data.is2D = false;
    status = localSetRegEdit(this,data,'Reg2');
else
    data.is2D = true;
end

%--------------------------------------------------------------------------
function [cpt,id] = localFindCenterPt(data)
% return a vector of all centerpoints for current regressor data object
% also return the indices of "other" regressors that show up in center
% point table

[dum,actRegInd] = ismember(data.ActiveRegressors,{data.RegInfo.Name});

cpt = cat(1,data.RegInfo(actRegInd).CenterPoint);
Lr = length(cpt);
selInd = data.ComboValue.Reg1;
%regInd = find(strcmp({data.RegInfo.Name},data.ActiveRegressors{selInd}));
selInd2 = data.ComboValue.Reg2-1;
if (selInd2~=0)
    %regInd2 = find(strcmp({data.RegInfo.Name},data.ActiveRegressors{selInd2}));
    selInd = [selInd,selInd2];
end
id = setdiff(1:Lr,selInd);
