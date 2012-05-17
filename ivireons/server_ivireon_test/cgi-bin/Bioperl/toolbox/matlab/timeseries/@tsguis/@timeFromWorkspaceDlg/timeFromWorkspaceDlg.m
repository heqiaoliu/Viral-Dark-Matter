function h = timeFromWorkspaceDlg(filename)

% Author: Rong Chen 
%  Copyright 2004-2009 The MathWorks, Inc.
%  $Revision: 1.1.6.9 $ $Date: 2009/10/29 15:23:22 $

% import com.mathworks.toolbox.timeseries.*;
import javax.swing.*;

h = tsguis.timeFromWorkspaceDlg;

%% Build HG components
% figure window
heightbtn=23;
heighttxt=18;    
heightedt=21;
heightcomb=18;
widthbtn=80;
separation=10;
leftratio=0.25;
bottomratio=0.3;
widthratio=0.5;
heightratio=0.4;
ScreenSize=get(0,'ScreenSize');
h.Figure=figure(...
        'WindowStyle','modal', ...
        'HandleVisibility', 'Callback', ...
        'Units', 'pixels', ...
        'Toolbar', 'None', ...
        'Menubar', 'None', ...
        'NumberTitle', 'off', ...
        'Resize', 'off', ...
        'Visible','off', ...
        'Position',[ScreenSize(3)*leftratio ...
                    ScreenSize(4)*bottomratio ...
                    ScreenSize(3)*widthratio ...
                    ScreenSize(4)*heightratio], ...
        'CloseRequestFcn', {@localFigClose h}, ...
        'IntegerHandle','off');
FigureDefaultColor=get(h.Figure,'Color');
% buttons
h.Handles.BTNselect = uicontrol('Parent', h.Figure, 'Position',[ScreenSize(3)*widthratio-3*widthbtn-3*separation, separation, widthbtn, heightbtn],...
    'Style', 'pushbutton','Callback', {@localSave h}, 'String','Select');
h.Handles.BTNcancel = uicontrol('Parent',h.Figure,'Position',[ScreenSize(3)*widthratio-2*widthbtn-2*separation, separation, widthbtn, heightbtn],...
    'Style', 'pushbutton','Callback', {@localCancel h},  'String','Cancel');
h.Handles.BTNhelp = uicontrol('Parent',h.Figure,'Position',[ScreenSize(3)*widthratio-widthbtn-separation, separation, widthbtn, heightbtn],...
    'Style', 'pushbutton','Callback', {@localHELP h}, 'String','Help');
% workspace browser
h.Handles.Browser = tsguis.tsvarbrowser;
h.Handles.Browser.typesallowed={'double','single','uint8','uint16','unit32','int8','int16','int32','cell'};
if ~isempty(filename)
    h.Handles.Browser.filename = filename;
    set(h.Figure, 'Name', xlate(sprintf('Select Time Vector From %s',filename)));
else
    set(h.Figure, 'Name', xlate('Select Time Vector From MATLAB Workspace Variable'));
end
h.Handles.Browser.open;
h.Handles.Browser.javahandle.setName('timeFromWsImportView');
s = JScrollPane(h.Handles.Browser.javahandle);
[~, h.Handles.jBrowser] = javacomponent(s,[separation, 80, ScreenSize(3)*widthratio-2*separation, ScreenSize(4)*heightratio-80-separation],h.Figure);
% assign the copy callback
set(handle(h.Handles.Browser.javahandle.getSelectionModel,'callbackproperties'),...
    'ValueChangedCallback',{@localWorkspaceSelect h});

% text, combo and edit box
huicTXTrowcolumn = uicontextmenu('Parent',h.Figure);
h.Handles.TXTrowcolumn = uicontrol('Parent',h.Figure,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',FigureDefaultColor,...
    'HorizontalAlignment','Right', ...
    'string','Time is arranged by : ', ...
    'UIContextMenu',huicTXTrowcolumn,...
    'Position',[separation ...
                45 ...
                120 ...
                heighttxt] ...
    );
uimenu(huicTXTrowcolumn,'Label','What''s This','Callback','tsDispatchHelp(''select_time_arranged'',''modal'')')

h.Handles.COMBrowcolumn = uicontrol('Parent',h.Figure,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',[{xlate('column')},{xlate('row')}],...
    'TooltipString',xlate('Select a ''Column'' if the time vector is stored in a column of this variable.  Vise Versa.'),...
    'Position',[separation+120+separation ...
                45+4 ...
                60 ...
                heightcomb], ...
    'Callback',{@localSwitchIndex h} ...
    );
if ~ismac
   set(h.Handles.COMBrowcolumn,'BackgroundColor',[1 1 1]);
end

huicTXTindex = uicontextmenu('Parent',h.Figure);
h.Handles.TXTindex = uicontrol('Parent',h.Figure,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',FigureDefaultColor,...
    'HorizontalAlignment','Right', ...
    'string',xlate('Column indices : '), ...
    'UIContextMenu',huicTXTindex,...
    'Position',[separation+120+separation+60+2*separation ...
                45 ...
                80 ...
                heighttxt] ...
    );
uimenu(huicTXTindex,'Label','What''s This','Callback','tsDispatchHelp(''select_time_column'',''modal'')')

h.Handles.COMBindex = uicontrol('Parent',h.Figure,...
    'style','popupmenu',...
    'Units', 'Pixels',...
    'String',' ',...
    'TooltipString',xlate('Select the column/row index'),...
    'Position',[separation+120+separation+60+2*separation+80+separation ...
                45+4 ...
                60 ...
                heightcomb] ...
    );
if ~ismac
   set(h.Handles.COMBindex,'BackgroundColor',[1 1 1]);
end

huicTXTindices = uicontextmenu('Parent',h.Figure);
h.Handles.TXTindices = uicontrol('Parent',h.Figure,...
    'style','text', ...
    'Units','Pixels',...
    'BackgroundColor',FigureDefaultColor,...
    'HorizontalAlignment','Right', ...
    'string',xlate('Row indices : '), ...
    'UIContextMenu',huicTXTindices,...
    'Position',[separation+120+separation+60+2*separation+80+separation+60+2*separation ...
                45 ...
                80 ...
                heighttxt] ...
    );
uimenu(huicTXTindices,'Label','What''s This','Callback','tsDispatchHelp(''select_time_rows'',''modal'')')

h.Handles.EDTindex = uicontrol('Parent',h.Figure,...
    'style','edit',...
    'Units', 'Pixels',...
    'BackgroundColor',[1 1 1], ...
    'HorizontalAlignment','Left', ...
    'TooltipString','Key in time points range, e.g [1:100]',...
    'Position',[separation+120+separation+60+2*separation+80+separation+60+2*separation+80+separation ...
                45+2 ...
                60 ...
                heightedt] ...
    );

%% Install default listeners
h.Listeners = handle.listener(h,h.findprop('Visible'),'PropertyPostSet',...
       @(es,ed) set(get(h,'Figure'),'Visible',get(h,'Visible')));

function localWorkspaceSelect(~,~, h)
info=h.Handles.Browser.getSelectedVarInfo;
if ~isempty(info)
    if info.objsize(2)==1
        set(h.Handles.COMBrowcolumn,'Value',1);
        localSwitchIndex([], [], h);
    elseif info.objsize(1)==1
        set(h.Handles.COMBrowcolumn,'Value',2);
        localSwitchIndex([], [], h);
    else
        set(h.Handles.COMBrowcolumn,'Value',1);
        localSwitchIndex([], [], h);
    end
end
% set default selection


function localSwitchIndex(~,~, h)
info=h.Handles.Browser.getSelectedVarInfo;
if ~isempty(info)
    if get(h.Handles.COMBrowcolumn,'Value')==1
        % time vector is a column
        length=info.objsize(2);
        huicTXTindex = uicontextmenu('Parent',h.Figure);
        uimenu(huicTXTindex,'Label','What''s This','Callback','tsDispatchHelp(''select_time_column'',''modal'')')
        set(h.Handles.TXTindex,'String',xlate('Column index : '),'UIContextMenu',huicTXTindex);
        huicTXTindices = uicontextmenu('Parent',h.Figure);
        uimenu(huicTXTindices,'Label','What''s This','Callback','tsDispatchHelp(''select_time_rows'',''modal'')')
        set(h.Handles.TXTindices,'String',xlate('Row indices : '),'UIContextMenu',huicTXTindices);
        set(h.Handles.COMBindex,'String',mat2cell((1:length)',ones(length,1),1),'Value',1); %#ok<MMTC>
        set(h.Handles.EDTindex,'String',['1:' num2str(info.objsize(1))]);
    else
        length=info.objsize(1);
        huicTXTindex = uicontextmenu('Parent',h.Figure);
        uimenu(huicTXTindex,'Label','What''s This','Callback','tsDispatchHelp(''select_time_row'',''modal'')')
        set(h.Handles.TXTindex,'String',xlate('Row index : '),'UIContextMenu',huicTXTindex);
        huicTXTindices = uicontextmenu('Parent',h.Figure);
        uimenu(huicTXTindices,'Label','What''s This','Callback','tsDispatchHelp(''select_time_columns'',''modal'')')
        set(h.Handles.TXTindices,'String',xlate('Column indices : '),'UIContextMenu',huicTXTindices);
        set(h.Handles.COMBindex,'String',mat2cell((1:length)',ones(length,1),1),'Value',1); %#ok<MMTC>
        set(h.Handles.EDTindex,'String',['1:' num2str(info.objsize(2))]);
    end
end


function flag=IsTimeFormat(rawdata)
% ISTIMEFORMAT check time format of a single cell

% input parameters should be in Cell Array format
% output:   between 0~31: standard MATLAB supported date/time format
%           -1: double values
%           NaN: string or other cases

flag=NaN;
if iscell(rawdata)
    rawdata=cell2mat(rawdata);
end
if ischar(rawdata)
    % a string
    try
        timeValue=datenum(rawdata);
        if timeValue==floor(timeValue)
            % date only
            flag=1;
        elseif isequal(rawdata,datestr(timeValue,13))
            % time only
            flag=13;
        elseif isequal(rawdata,datestr(timeValue,14))
            % time only
            flag=14;
        elseif isequal(rawdata,datestr(timeValue,15))
            % time only
            flag=15;
        elseif isequal(rawdata,datestr(timeValue,16))
            % time only
            flag=16;
        else
            % date+time
            flag=0;
        end
    catch me %#ok<NASGU>
    end
elseif isnumeric(rawdata)
    flag=-1;
end


function localFigClose(~,~, h)

h.OutputValue=[];
h.OutputValueFormat=NaN;
h.OutputString='';
uiresume(h.Figure);
delete(h.Figure)



function localSave(~,~, h)

info=h.Handles.Browser.getSelectedVarInfo;
if ~isempty(info)
    if get(h.Handles.COMBrowcolumn,'Value')==1
        try
            range=eval(get(h.Handles.EDTindex,'String'));
            if ~isempty(h.Handles.Browser.filename)
                tmp=load(h.Handles.Browser.filename,info.varname); %#ok<NASGU>
                h.OutputValue=eval(['tmp.' info.varname '(' get(h.Handles.EDTindex,'String') ',' num2str(get(h.Handles.COMBindex,'Value')) ')']);
                h.OutputValueFormat=IsTimeFormat(eval(['tmp.' info.varname '(' num2str(range(1)) ',' num2str(get(h.Handles.COMBindex,'Value')) ')']));
            else
                h.OutputValue=evalin('base',[info.varname '(' get(h.Handles.EDTindex,'String') ',' num2str(get(h.Handles.COMBindex,'Value')) ')']);
                h.OutputValueFormat=IsTimeFormat(evalin('base',[info.varname '(' num2str(range(1)) ',' num2str(get(h.Handles.COMBindex,'Value')) ')']));
            end
        catch me %#ok<NASGU>
            errordlg('Invalid time vector selected.','Time Series Tools');
            return;
        end
        if isnumeric(h.OutputValue)
            h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
            '      Start Time : ', num2str(h.OutputValue(1)) '      End Time : ' num2str(h.OutputValue(end))]);
        elseif ischar(h.OutputValue)
            h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
            '      Start Time : ', h.OutputValue(1,:) '      End Time : ' h.OutputValue(end,:)]);
        elseif iscell(h.OutputValue)
            tmpValue=[];
            try
                tmpValue=cell2mat(h.OutputValue);
            catch me %#ok<NASGU>
                if all(cellfun('isclass',h.OutputValue,'char'))
                    h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
                    '      Start Time : ', h.OutputValue{1,:} '      End Time : ' h.OutputValue{end,:}]);
                end
            end
            if isnumeric(tmpValue) && ~isempty(tmpValue)
                h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
                '      Start Time : ', num2str(tmpValue(1)) '      End Time : ' num2str(tmpValue(end))]);
            elseif ischar(tmpValue) && ~isempty(tmpValue)
                h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
                '      Start Time : ', tmpValue(1,:) '      End Time : ' tmpValue(end,:)]);
            end
        end
    else
        try
            range=eval(get(h.Handles.EDTindex,'String'));
            if ~isempty(h.Handles.Browser.filename)
                tmp=load(h.Handles.Browser.filename,info.varname); %#ok<NASGU>
                h.OutputValue=eval(['tmp.' info.varname '(' num2str(get(h.Handles.COMBindex,'Value')) ',' get(h.Handles.EDTindex,'String') ')'] );
                h.OutputValueFormat=IsTimeFormat(eval(['tmp.' info.varname '(' num2str(get(h.Handles.COMBindex,'Value')) ',' num2str(range(1)) ')'] ));
            else
                h.OutputValue=evalin('base',[info.varname '(' num2str(get(h.Handles.COMBindex,'Value')) ',' get(h.Handles.EDTindex,'String') ')']);
                h.OutputValueFormat=IsTimeFormat(evalin('base',[info.varname '(' num2str(get(h.Handles.COMBindex,'Value')) ',' num2str(range(1)) ')']));
            end
        catch me %#ok<NASGU>
            errordlg('Invalid time vector selected.','Time Series Tools');
            return;
        end
        if isnumeric(h.OutputValue)
            h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
            '      Start Time : ', num2str(h.OutputValue(1)) '      End Time : ' num2str(h.OutputValue(end))]);
        elseif ischar(h.OutputValue)
            h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
            '      Start Time : ', h.OutputValue(1,:) '      End Time : ' h.OutputValue(end,:)]);
        elseif iscell(h.OutputValue)
            tmpValue=[];
            try
                tmpValue=cell2mat(h.OutputValue);
            catch me %#ok<NASGU>
                if all(cellfun('isclass',h.OutputValue,'char'))
                    h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
                    '      Start Time : ', h.OutputValue{1,:} '      End Time : ' h.OutputValue{end,:}]);
                end
            end
            if isnumeric(tmpValue) && ~isempty(tmpValue)
                h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
                '      Start Time : ', num2str(tmpValue(1)) '      End Time : ' num2str(tmpValue(end))]);
            elseif ischar(tmpValue) && ~isempty(tmpValue)
                h.OutputString=sprintf('\n%s',['  Variable Name : ' info.varname '      Length : ' num2str(length(range)) ...
                '      Start Time : ', tmpValue(1,:) '      End Time : ' tmpValue(end,:)]);
            end
        end
    end
end

uiresume(h.Figure);
delete(h.Figure);


function localCancel(~,~, h)

h.OutputValue=[];
h.OutputString='';
uiresume(h.Figure);
delete(h.Figure);

function localHELP(~,~,~)
% callback for the HELP button

helpdlg(sprintf('%s\n\n%s\n\n%s\n\n%s\n\n%s',...
    xlate('Define time vector from a workspace variable :'),...
    xlate('Step 1: highlight the variable from the table and define the length in the edit box'), ...
    xlate('Step 2: click the Select button')),...
    'Help');



