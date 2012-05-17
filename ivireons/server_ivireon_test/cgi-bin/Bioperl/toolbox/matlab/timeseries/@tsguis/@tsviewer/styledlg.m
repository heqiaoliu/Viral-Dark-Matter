function varargout = styledlg(this)
%STYLEDLG   Opens GUI managing system styles.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2009/09/28 20:28:30 $

PlotPrefFig = LocalCreateFig(this);
if nargout
    varargout = {PlotPrefFig};
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOCAL CALLBACKS
%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalOK(eventSrc,~,this)
%
H =  findobj(allchild(get(eventSrc,'Parent')),'tag','OKButton');
linestylegui = get(H,'parent');
LocalApply(linestylegui,this);
if strcmpi(get(eventSrc,'Tag'),'OKButton')
   set(get(eventSrc,'Parent'),'Visible','off');
end

%------------------------
% LOCALAPPLY
%------------------------
function LocalApply(eventSrc,this)
%
ud = get(eventSrc,'UserData');
%---Place current control values in the userdata
ud.Revert.ColorSystem=get(ud.Handles.ColorSystem,'Value');
ud.Revert.ColorInput=get(ud.Handles.ColorInput,'Value');

if ud.Revert.ColorSystem 
   this.StyleManager.SortByColor = 'response';
elseif ud.Revert.ColorInput 
   this.StyleManager.SortByColor = 'input';
else
   this.StyleManager.SortByColor = 'none';
end


ud.Revert.MarkSystem=get(ud.Handles.MarkSystem,'Value');
ud.Revert.MarkInput=get(ud.Handles.MarkInput,'Value');
if ud.Revert.MarkSystem 
   this.StyleManager.SortByMarker = 'response';
elseif ud.Revert.MarkInput
   this.StyleManager.SortByMarker = 'input';
else 
   this.StyleManager.SortByMarker = 'none';
end


ud.Revert.LineSystem=get(ud.Handles.LineSystem,'Value');
ud.Revert.LineInput=get(ud.Handles.LineInput,'Value');
if ud.Revert.LineSystem 
   this.StyleManager.SortByLineStyle = 'response';
elseif ud.Revert.LineInput 
   this.StyleManager.SortByLineStyle = 'input';
else 
   this.StyleManager.SortByLineStyle = 'none';
end


ud.Revert.NoSystem=get(ud.Handles.NoSystem,'Value');
ud.Revert.NoInput=get(ud.Handles.NoInput,'Value');
ud.Revert.ColorList =get(ud.Handles.ColorList,'Userdata');
ud.Revert.LineList  =get(ud.Handles.LineList,'Userdata');
ud.Revert.MarkerList=get(ud.Handles.MarkerList,'Userdata');
this.StyleManager.ColorList     = ud.Revert.ColorList;
this.StyleManager.LineStyleList = ud.Revert.LineList;
this.StyleManager.MarkerList    = ud.Revert.MarkerList;
% create the styles
makestyles(this.StyleManager);

set(ud.Parent,'UserData',this);
set(findobj(allchild(eventSrc),'tag','ApplyButton'),'Enable','off');

%------------------------
% LOCALRADIOCALLBACK
%------------------------
function LocalRadioCallback(eventSrc,eventData) %#ok<INUSD>
%
val=get(eventSrc,'Value');
ud=get(eventSrc,'UserData');
if val,
   set(ud.row,'Value',0);
   for ct=1:length(ud.column);
      indon=find(get(ud.column(ct),'Value'));
      if indon
         ud2=get(ud.column(ct),'UserData');
         set(ud.column(ct),'Value',0);
         set(ud2.nodist,'Value',1);
      end % if indon
   end % for ct
else
   set(eventSrc,'Value',1);
end % if/else val
set(findobj(allchild(get(eventSrc,'Parent')),'tag','ApplyButton'),'Enable','on');

%------------------------
% LOCALLISTCALLBACK
%------------------------
function LocalListCallback(eventSrc,eventData) %#ok<INUSD>
%
me=eventSrc;
udfig = get(get(me,'Parent'),'UserData');
myTag=get(me,'Tag');
myVal=get(me,'Value');
myStr=get(me,'String');
LL=size(myStr,1);

load prefimag;
if myVal==1
   UpCdata = LocalProcessCData(moveupno);
   UpEnable = 'off';
   DnCdata = LocalProcessCData(movedn);
   DnEnable = 'on';
elseif myVal==LL
   UpCdata = LocalProcessCData(moveup);
   UpEnable = 'on';
   DnCdata = LocalProcessCData(movednno);
   DnEnable = 'off';
else
   UpCdata = LocalProcessCData(moveup);
   UpEnable = 'on';
   DnCdata = LocalProcessCData(movedn);
   DnEnable = 'on';
end

switch myTag,
   
case {'ColorList'}
   set(udfig.Handles.UpColor,'enable',UpEnable,'Cdata',UpCdata);
   set(udfig.Handles.DownColor,'enable',DnEnable,'Cdata',DnCdata);
case {'MarkerList'}
   set(udfig.Handles.UpMark,'enable',UpEnable,'Cdata',UpCdata);
   set(udfig.Handles.DownMark,'enable',DnEnable,'Cdata',DnCdata);
case {'LineList'}
   set(udfig.Handles.UpLine,'enable',UpEnable,'Cdata',UpCdata);
   set(udfig.Handles.DownLine,'enable',DnEnable,'Cdata',DnCdata);
   
end % switch myTag

set(findobj(allchild(get(eventSrc,'Parent')),'tag','ApplyButton'),'Enable','on');

%------------------------
% LOCALUPDOWNCALLBACK
%------------------------
%---Function to move an item up in the list
function LocalUpDownCallback(eventSrc,~,action)
%
switch action
case 'up'
   me=eventSrc;
   udfig =get(get(me,'Parent'),'UserData');
   myTag=get(me,'Tag');
   switch myTag,
      
   case {'UpColor'}
      myList=udfig.Handles.ColorList;
      Downbutton=udfig.Handles.DownColor;
   case {'UpMark'}
      myList=udfig.Handles.MarkerList;
      Downbutton=udfig.Handles.DownMark;
   case {'UpLine'}
      myList=udfig.Handles.LineList;
      Downbutton=udfig.Handles.DownLine;
      
   end % switch myTag
   
   myData=get(myList,'UserData');
   OrigStr=get(myList,'String');
   val=get(myList,'Value');
   NewStr=[OrigStr(1:val-2);OrigStr(val);OrigStr(val-1);OrigStr(val+1:end)];
   NewData=[myData(1:val-2,:);myData(val,:);myData(val-1,:);myData(val+1:end,:)];
   
   set(myList,'String',NewStr,'UserData',NewData,'Value',val-1);
   
   load prefimag
   movedn=LocalProcessCData(movedn); %#ok<NODEF>
   
   if (val-1)==1
      moveupno=LocalProcessCData(moveupno); %#ok<NODEF>
      set(me,'enable','off','Cdata',moveupno);
      set(Downbutton,'enable','on','Cdata',movedn);
   elseif val==size(myList,1),
      movednno=LocalProcessCData(movednno); %#ok<NODEF>
      set(Downbutton,'enable','off','Cdata',movednno);
      moveup=LocalProcessCData(moveup); %#ok<NODEF>
      set(me,'enable','on','Cdata',moveup);
   else
      set(Downbutton,'enable','on','Cdata',movedn);
   end

   set(findobj(get(me,'Parent'),'Tag','ApplyButton'),'enable','on');
   
   %---Functions to move an item down in the list
case 'down'
   me=eventSrc;
   udfig = get(get(me,'Parent'),'UserData');
   myTag=get(me,'Tag');
   switch myTag,
      
   case {'DownColor'}
      myList=udfig.Handles.ColorList;
      Upbutton=udfig.Handles.UpColor;
   case {'DownMark'}
      myList=udfig.Handles.MarkerList;
      Upbutton=udfig.Handles.UpMark;
   case {'DownLine'}
      myList=udfig.Handles.LineList;
      Upbutton=udfig.Handles.UpLine;
      
   end % switch myTag
   
   myData=get(myList,'UserData');
   OrigStr=get(myList,'String');
   val=get(myList,'Value');
   
   NewStr=[OrigStr(1:val-1);OrigStr(val+1);OrigStr(val);OrigStr(val+2:end)];
   NewData=[myData(1:val-1,:);myData(val+1,:);myData(val,:);myData(val+2:end,:)];
   
   set(myList,'String',NewStr,'UserData',NewData,'Value',val+1);
   
   load prefimag
   moveup=LocalProcessCData(moveup); %#ok<NODEF>
   
   if (val+1)==size(OrigStr,1),
      movednno=LocalProcessCData(movednno); %#ok<NODEF>
      set(me,'enable','off','Cdata',movednno);
      set(Upbutton,'enable','on','Cdata',moveup);
   elseif val==1,
      set(Upbutton,'enable','on','Cdata',moveup);
   else
      set(Upbutton,'enable','on','Cdata',moveup);
   end
   
   set(findobj(get(me,'Parent'),'Tag','ApplyButton'),'enable','on');
   
end % switch action

%------------------------
% LOCALCANCEL
%------------------------
function LocalCancel(eventSrc,eventData,this) %#ok<INUSD>
%---Place original control values in their userdata 

ud = get(get(eventSrc,'Parent'),'UserData');
set(ud.Handles.ColorSystem,'Value',ud.Revert.ColorSystem);
set(ud.Handles.ColorInput,'Value',ud.Revert.ColorInput);

set(ud.Handles.MarkSystem,'Value',ud.Revert.MarkSystem);
set(ud.Handles.MarkInput,'Value',ud.Revert.MarkInput);

set(ud.Handles.LineSystem,'Value',ud.Revert.LineSystem);
set(ud.Handles.LineInput,'Value',ud.Revert.LineInput);

set(ud.Handles.NoSystem,'Value',ud.Revert.NoSystem);
set(ud.Handles.NoInput,'Value',ud.Revert.NoInput);

OldColData = ud.Revert.ColorList;
OldLineData = ud.Revert.LineList;
OldMarkData = ud.Revert.MarkerList;

LineString = {'solid';'dashed';'dash-dot';'dotted';'none'};
LineData = {'-';'--';'-.';':';'none'};
[~,IA,IB] = intersect(OldLineData,LineData);
OldLineStr = LineString(IB(IA));

set(ud.Handles.ColorList,'String',OldColData(:,2),'UserData',OldColData);
set(ud.Handles.MarkerList,'String',OldMarkData,'UserData',OldMarkData);
set(ud.Handles.LineList,'String',OldLineStr,'UserData',OldLineData);

%---return plots to original configuration
set(findobj(allchild(get(eventSrc,'Parent')),'tag','ApplyButton'),'Enable','off');
set(get(eventSrc,'Parent'),'Visible','off');

%------------------------
% LOCALDELETE
%------------------------
function LocalDelete(eventSrc,eventData) %#ok<INUSD>
%
this = get(get(eventSrc,'Parent'),'UserData');
if ~isempty(this)
    FigureMenu = this.HG.FigureMenu;
    set(FigureMenu.EditMenu.LineStyles,'UserData',[]);
end

%------------------------
% LOCALCREATEFIG
%------------------------
function a = LocalCreateFig(this)
% LOCALCREATEFIG creates the GUI for user to interact with the line style
% preferences.

LTIviewerFig = this.TreeManager.Figure;
ud = struct('Parent',LTIviewerFig,'Handles',[],'Revert',[]);

StdUnit = 'point';
UIColor = get(0,'DefaultUIControlBackground');

%---RadioButton Data
tmpvals = {this.StyleManager.SortByColor,this.StyleManager.SortByMarker,...
    this.StyleManager.SortByLineStyle};
RBvals = [strcmpi('Response',tmpvals) all(strcmpi('None',tmpvals));...
          strcmpi('Input',tmpvals) all(strcmpi('None',tmpvals))];
RBtags = [{'ColorSystem'},{'MarkSystem'},{'LineSystem'},{'NoSystem'};
   {'ColorInput'},{'MarkInput'},{'LineInput'},{'NoInput'}];

%---Look for old Color/Line/Marker Orders
ColList = get(this.StyleManager,'ColorList');
ColStr = cat(1,ColList(:,2));
MarkerStr = get(this.StyleManager,'MarkerList');
MarkerStr = cat(1,MarkerStr(:,1));
LineUd = get(this.StyleManager,'LineStyleList');
LineUd = cat(1,LineUd(:,1));
Ltemp = {'-';'--';'-.';':';'none'};
LStemp = {'solid';'dashed';'dash-dot';'dotted';'none'};
[~,~,IB] = intersect(LineUd,Ltemp);
LineStr = LStemp(IB);

%%%-Open original figure-%%%
a = figure(...
   'Name',xlate('Line Styles'),...
   'MenuBar','none',...
   'NumberTitle','off',...
   'IntegerHandle','off',...
   'HandleVisibility','callback',...
   'Resize','off',...
   'DeleteFcn',@LocalDelete,...
   'Unit',StdUnit,...
   'Position',[50 22.5 369 285],...
   'Visible','off',...
   'Color',UIColor,...
   'Tag','PlotPrefs',...
   'DockControls', 'off');

%---Position figure within LTI Viewer bounds
centerfig(a,LTIviewerFig);
set(a,'Visible','on');

% Add window Options
ButtonStrings=[{'OK'};{'Cancel'};{'Help'};{'Apply'}];
ButtonCallback={{@LocalOK this};...
      {@LocalCancel this};...
      {'tsDispatchHelp(''tsgui_linestyles'',''modal'');'};...
   {@LocalOK this}};
ButtonTags=[{'OKButton'};{'CloseButton'};{'HelpButton'};{'ApplyButton'}];

for ct=4:-1:1
   Buttons(ct) = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'Position',[8+((ct-1)*91) 5 79 20], ...
      'String',ButtonStrings{ct}, ...
      'Callback',ButtonCallback{ct}, ...
      'BackgroundColor',UIColor, ...
      'Tag',ButtonTags{ct});
end  
set(Buttons(3),'Callback','tsDispatchHelp(''tsgui_linestyles'',''modal'');');
set(Buttons(4),'Enable','off');

% Add Frames
FramePositions=[{[8 163 352 118]};
   {[9 30 352 128]};
   {[17 270-40 304 1]};
   {[105 171+47-40 1 132-47]};
   {[17 244-40 334 1]};
   {[17 218-40 334 1]};
   {[164 171+47-40 1 132-47]};
   {[222 171+47-40 1 132-47]};
   {[282 171+47-40 1 132-47]}];

for ctFrame=1:length(FramePositions)
   Frames(ctFrame) = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'Position',FramePositions{ctFrame}, ...
      'BackgroundColor',UIColor, ...
      'Style','frame'); %#ok<AGROW>
end   

%%%-Add text-%%%
OrderText=[{'Color Order'};{'Marker Order'};{'Line Style Order'}];
OrderTag =[{'ColorOrderText'};{'MarkerOrderText'};{'LineOrderText'}];
for ctOrder=1:length(OrderText);
   uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'Position',[52+((ctOrder-1)*110) 136 86 14], ...
      'String',OrderText{ctOrder}, ...
      'horiz','left', ...
      'Tag',OrderTag{ctOrder}, ...
      'BackgroundColor',UIColor, ...
      'Style','text');
end

uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[116 305-40 132 14], ...
   'String','Distinguish by:', ...
   'Tag','DistinquishText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[109 279-40 44 14], ...
   'String','Color', ...
   'Tag','ColorText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[169 279-40 48 14], ...
   'String','Marker', ...
   'Tag','MarkerText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[224 279-40 58 14], ...
   'String','Line Style', ...
   'Tag','LineText', ...
   'BackgroundColor',UIColor, ...
   'Style','text');
b = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'Position',[292 279-40 55 14], ...
   'String','No Distinction', ...
   'Tag','NoText', ...
   'BackgroundColor',UIColor, ...
   'Style','text'); %#ok<*NASGU>

DifferentText=[{'Time Series'};{'Columns'}];
DifferentTag=[{'SystemText'};{'InputText'}];
for ctText = 1:length(DifferentText),
   b = uicontrol('Parent',a, ...
      'Unit',StdUnit, ...
      'HorizontalAlignment','left', ...
      'Position',[21 249-((ctText-1)*26)-40 48 15], ...
      'String',DifferentText{ctText}, ...
      'Tag',DifferentTag{ctText}, ...
      'BackgroundColor',UIColor, ...
      'Style','text');
end

%%%-Add radio buttons-%%%
for ctRow=1:2,
   for ctCol = 1:4,
      % Need a space string for focus highlighting (508)
      ud.Handles.(RBtags{ctRow,ctCol}) = uicontrol('Parent',a, ...
         'Unit',StdUnit, ...
         'Position',[125+((ctCol-1)*61) 249-((ctRow-1)*26)-40 20 18], ...
         'Style','radiobutton', ...
         'Callback',@LocalRadioCallback, ...
         'String',' ',...
         'Value',RBvals(ctRow,ctCol), ...
         'BackgroundColor',UIColor, ...
         'Tag',RBtags{ctRow,ctCol});
      ud.Revert.(RBtags{ctRow,ctCol}) = RBvals(ctRow,ctCol);
   end, % for ctCol
end % for ctRow

%%%-Set radio button userdata-%%%

%---ColorSystem
set(ud.Handles.ColorSystem,'UserData',struct('value',1, ...
   'row',[ud.Handles.MarkSystem,ud.Handles.LineSystem,ud.Handles.NoSystem], ...
   'column',ud.Handles.ColorInput,...
   'nodist',ud.Handles.NoSystem));
%---ColorInput
set(ud.Handles.ColorInput,'UserData',struct('value',0, ...
   'row',[ud.Handles.MarkInput,ud.Handles.LineInput,ud.Handles.NoInput], ...
   'column',ud.Handles.ColorSystem, ...
   'nodist',ud.Handles.NoInput));

%---MarkSystem
set(ud.Handles.MarkSystem,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorSystem,ud.Handles.LineSystem,ud.Handles.NoSystem], ...
   'column',ud.Handles.MarkInput, ...
   'nodist',ud.Handles.NoSystem));
%---MarkInput
set(ud.Handles.MarkInput,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorInput,ud.Handles.LineInput,ud.Handles.NoInput], ...
   'column',ud.Handles.MarkSystem, ...
   'nodist',ud.Handles.NoInput));


%---LineSystem
set(ud.Handles.LineSystem,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorSystem,ud.Handles.MarkSystem,ud.Handles.NoSystem], ...
   'column',ud.Handles.LineInput, ...
   'nodist',ud.Handles.NoSystem));
%---LineInput
set(ud.Handles.LineInput,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorInput,ud.Handles.MarkInput,ud.Handles.NoInput], ...
   'column',ud.Handles.LineSystem, ...
   'nodist',ud.Handles.NoInput));

%---NoSystem
set(ud.Handles.NoSystem,'UserData',struct('value',0, ...
   'row',[ud.Handles.ColorSystem,ud.Handles.MarkSystem,ud.Handles.LineSystem], ...
   'column',[],'nodist',[]));
%---NoInput
set(ud.Handles.NoInput,'UserData',struct('value',1, ...
   'row',[ud.Handles.ColorInput,ud.Handles.MarkInput,ud.Handles.LineInput], ...
   'column',[],'nodist',[]));

%%%-Add order listboxes - up/down button in the right order for 508
load prefimag
moveupno=LocalProcessCData(moveupno); %#ok<NODEF>
movedn=LocalProcessCData(movedn); %#ok<NODEF>
ud.Handles.ColorList = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'BackgroundColor',[1 1 1], ...
   'ForegroundColor',[0 0 0], ...
   'Position',[51 35 75 98], ...
   'String',ColStr, ...
   'UserData',ColList, ...
   'Style','listbox', ...
   'Callback',@LocalListCallback, ...
   'Tag','ColorList', ...
   'Value',1);
ud.Revert.ColorList=ColList;
ud.Handles.UpColor = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Cdata',moveupno, ...
   'Unit',StdUnit, ...
   'Position',[25 85 25 23], ...
   'enable','off', ...
   'UserData',[{'r'};{'b'};{'g'};{'c'};{'m'};{'y'};{'k'}], ...
   'callback',{@LocalUpDownCallback 'up'}, ...
   'Tag','UpColor');
ud.Handles.DownColor = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Cdata',movedn, ...
   'Unit',StdUnit, ...
   'Position',[25 57 25 23], ...
   'callback',{@LocalUpDownCallback 'down'}, ...
   'Tag','DownColor');
ud.Handles.MarkerList = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'BackgroundColor',[1 1 1], ...
   'ForegroundColor',[0 0 0], ...
   'Position',[165 35 66 98], ...
   'String',MarkerStr, ...
   'UserData',MarkerStr, ...
   'Style','listbox', ...
   'Callback',@LocalListCallback, ...
   'Tag','MarkerList', ...
   'Value',1);
ud.Revert.MarkerList=MarkerStr;
ud.Handles.UpMark = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[140 85 25 23], ...
   'Cdata',moveupno, ...
   'UserData',[{'none'};{'o'};{'x'};{'+'};{'*'};{'s'};{'d'};{'p'};{'h'}], ...
   'enable','off', ...
   'FontName','courier',...
   'callback',{@LocalUpDownCallback 'up'}, ...
   'Tag','UpMark');
ud.Handles.DownMark = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[140 57 25 23], ...
   'Cdata',movedn, ...
   'callback',{@LocalUpDownCallback 'down'}, ...
   'FontName','courier',...
   'Tag','DownMark');
ud.Handles.LineList = uicontrol('Parent',a, ...
   'Unit',StdUnit, ...
   'BackgroundColor',[1 1 1], ...
   'ForegroundColor',[0 0 0], ...
   'Position',[276 35 75 98], ...
   'String',LineStr, ...
   'UserData',LineUd, ...
   'Style','listbox', ...
   'Callback',@LocalListCallback, ...
   'Tag','LineList', ...
   'Value',1);
ud.Revert.LineList=LineUd;
ud.Handles.UpLine = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[251 85 25 23], ...
   'enable','off', ...
   'UserData',[{'-'};{'--'};{'-.'};{':'}], ...
   'callback',{@LocalUpDownCallback 'up'}, ...
   'Cdata',moveupno, ...
   'Tag','UpLine');
ud.Handles.DownLine = uicontrol('Parent',a, ...
   'BackgroundColor',UIColor, ...
   'Unit',StdUnit, ...
   'Position',[251 57 25 23], ...
   'Cdata',movedn, ...
   'callback',{@LocalUpDownCallback 'down'}, ...
   'Tag','DownLine');

set(a,'UserData',ud);

%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalProcessCData %%%
%%%%%%%%%%%%%%%%%%%%%%%%%
function cdata = LocalProcessCData(cdata)

bgc=255*get(0,'DefaultUIcontrolBackgroundColor');

%remove NAN's out and replace with BGC
nanIndex=find(isnan(cdata(:,:,1)));
if ~isempty(nanIndex)
   for k=1:3
      cLayer=cdata(:,:,k);
      cLayer(nanIndex)=ones(1,length(nanIndex))*bgc(k);
      cdata(:,:,k)=cLayer;
   end
end

cdata=uint8(cdata);

