function datacursormenus(hDCM,varargin)
%DATACURSORMENUS Add UIContextMenu items to datacursor
%
%  Author(s): Nan Li
%  Copyright 2008 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $  $Date: 2008/10/31 07:05:20 $

hCDC = get(hDCM, 'CurrentDataCursor');
if nargin > 1
    for i= 2:nargin
        switch lower(varargin{i-1})
            case 'fontsize'
                %---FontSize
                CM1 = uimenu(hCDC.UIContextMenu,'Label','FontSize','Tag','FontSize');
                uimenu(CM1,'Label','6', 'Tag','FontSize6', 'Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',6));
                uimenu(CM1,'Label','8', 'Tag','FontSize8', 'Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',8));
                uimenu(CM1,'Label','10','Tag','FontSize10','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',10));
                uimenu(CM1,'Label','12','Tag','FontSize12','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',12));
                uimenu(CM1,'Label','14','Tag','FontSize14','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',14));
                uimenu(CM1,'Label','16','Tag','FontSize16','Callback',{@LocalSelectMenu,'fontsize'},...
                    'UserData',struct('DataTip',hCDC,'FontSize',16));
                CH = get(CM1,'Children');
                set(findobj(CH,'flat','Tag',strcat('FontSize', num2str(get(hCDC, 'FontSize')))),'Checked','on');
                
            case 'alignment'
                %---Alignment
                CM1 = uimenu(hCDC.UIContextMenu,'Label',sprintf('Alignment'),'Tag','Alignment');
                uimenu(CM1,'Label',sprintf('Top-Right'), 'Tag',...
                    'AlignmentTR', 'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',hCDC,'H','left','V','bottom'));
                uimenu(CM1,'Label',sprintf('Top-Left'),...
                    'Tag', 'AlignmentTL', 'Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',hCDC,'H','right','V','bottom'));
                uimenu(CM1,'Label',sprintf('Bottom-Right'),...
                    'Tag', 'AlignmentBR','Callback',{@LocalSelectMenu,'alignment'},'Sep','on',...
                    'UserData',struct('DataTip',hCDC,'H','left','V','top'));
                uimenu(CM1,'Label',sprintf('Bottom-Left'),...
                    'Tag', 'AlignmentBL','Callback',{@LocalSelectMenu,'alignment'},...
                    'UserData',struct('DataTip',hCDC,'H','right','V','top'));
                
                CH = get(CM1,'Children');
                switch hCDC.Orientation
                    case 'top-right'
                        set(findobj(CH,'flat','Position',1),'Checked','on');
                    case 'top-left'
                        set(findobj(CH,'flat','Position',2),'Checked','on');
                    case 'bottom-right'
                        set(findobj(CH,'flat','Position',3),'Checked','on');
                    case 'bottom-left'
                        set(findobj(CH,'flat','Position',4),'Checked','on');
                end
                    
                %---Add a listener to the alignment property to set the menu
                 l = handle.listener(hCDC,hCDC.findprop('Orientation'),...
                     'PropertyPostSet',{@LocalUpdateAlignment, hCDC});
                 hCDC.addlistener(l)
                
            case 'movable'
                %---Movable
                CM1 = uimenu(hCDC.UIContextMenu,'Label',sprintf('Movable'),...
                    'Tag', 'Movable', ...
                    'Callback',{@LocalSelectMenu,'movable'},...
                    'UserData',struct('DataTip',hCDC));
                if     strcmpi(hCDC.Draggable,'on')
                    set(CM1,'Checked','on');
                else
                    set(CM1,'Checked','off');
                end
                
            case 'delete'
                %---Delete Menu
                CM1 = uimenu(hCDC.UIContextMenu,'Label',sprintf('Delete'),...
                    'Tag', 'Delete',...
                    'Callback',{@LocalSelectMenu,'delete'},...
                    'UserData',struct('DataTip',hCDC));
                
            case 'deleteall'
                %---Delete All Menu
                CM1 = uimenu(hCDC.UIContextMenu,'Label',sprintf('Delete all'),...
                    'Tag', 'Deleteall',...
                    'Callback',{@LocalSelectMenu,'deleteall'},...
                    'UserData',struct('DataTip',hDCM));
                
            case 'export'
                %---Export data cursor positiont to workspace
                CM1 = uimenu(hCDC.UIContextMenu,'Label',...
                    sprintf('Export Cursor Data to Workspace'),...
                    'Tag', 'Export',...
                    'Callback',{@LocalSelectMenu,'export'},...
                    'UserData',struct('DataTip',hDCM));
                
            case 'interpolation'
                %---Interpolation
                CM1 = uimenu(hCDC.UIContextMenu,'Label',sprintf('Interpolation'),...
                    'Tag','Interpolation');
                CM2 = uimenu(CM1,'Label',sprintf('Nearest'),...
                    'Tag', 'InterpolationOff',...
                    'Callback',{@LocalSelectMenu,'interpolation'},...
                    'UserData',struct('DataTip',hCDC,'Interpolate','off'));
                CM2 = uimenu(CM1,'Label',sprintf('Linear'),...
                    'Tag', 'InterpolationOn',...
                    'Callback',{@LocalSelectMenu,'interpolation'},...
                    'UserData',struct('DataTip',hCDC,'Interpolate','on'));
                CH = get(CM1,'Children');
                if strcmpi(hCDC.Interpolate,'on')
                    set(findobj(CH,'flat','Position',2),'Checked','on');
                else
                    set(findobj(CH,'flat','Position',1),'Checked','on');
                end
                
            otherwise
                disp([varargin{i-1},' is not a valid menu selection'])
        end
    end
end

% LocalUpdateAlignment %
function LocalUpdateAlignment(eventSrc,eventData,hCDC)

MenuChildren = get(hCDC.UIContextMenu,'Children');
CH1 = findobj(MenuChildren,'Tag','Alignment');

if ~isempty(CH1)
    CH = get(CH1,'Children');
    set(CH(:),'Checked','off');
    switch hCDC.Orientation
        case 'top-right'
            set(findobj(CH,'flat','Position',1),'Checked','on');
        case 'top-left'
            set(findobj(CH,'flat','Position',2),'Checked','on');
        case 'bottom-right'
            set(findobj(CH,'flat','Position',3),'Checked','on');
        case 'bottom-left'
            set(findobj(CH,'flat','Position',4),'Checked','on');
    end
end

% LocalSelectMenu %
function LocalSelectMenu(eventSrc,eventData,action)

Menu = eventSrc;
mud = get(Menu,'UserData');
h  = mud.DataTip;
switch lower(action)
    case 'fontsize'
        set(h,'FontSize',mud.FontSize);
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
        
    case 'alignment'
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
        if     strcmpi(mud.V,'top') && strcmpi(mud.H,'right')
            h.Orientation = 'bottom-left';
        elseif strcmpi(mud.V,'top') && strcmpi(mud.H,'left')
            h.Orientation = 'bottom-right';
        elseif strcmpi(mud.V,'bottom') && strcmpi(mud.H,'right')
            h.Orientation = 'top-left';
        elseif strcmpi(mud.V,'bottom') && strcmpi(mud.H,'left')
            h.Orientation = 'top-right';
        end
        
    case 'movable'
        if strcmpi(get(Menu,'Checked'),'on')
            h.Draggable = 'off';
            set(Menu,'Checked','off')
        else
            h.Draggable = 'on';
            set(Menu,'Checked','on')
        end
        
    case 'deleteall'
        removeAllDataCursors(h);
        return
        
    case 'delete'
        delete(h);
        return
        
    case 'interpolation'
        h.Interpolate = mud.Interpolate;
        %---Set current menu selection "checked"
        set(get(get(Menu,'Parent'),'Children'),'Checked','off');
        set(Menu,'Checked','on');
        
    case 'export'
        %Copy/Paste code from
        %matlab\toolbox\matlab\graphics\@graphics\@datacursormanager\create
        %UIContextMenu.m
        hFig = get(h, 'Figure');
        prompt={'Enter the variable name'};
        name='Export Cursor Data to Workspace';
        numlines=1;
        defaultanswer={get(h,'DefaultExportVarName')};
        %Don't overwrite the default variable name if it already exists:
        userAns = false;
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        exists = 0;
        if ~isempty(answer) && ischar(answer{1})
            exists = evalin('base', ['exist(''' answer{1} ''',''var'')']);
        end
        while exists && ~userAns
            warnMessage = sprintf(['A variable named "%s" already exists in the',...
                ' MATLAB Workspace.\nIf you continue, you will overwrite the instance',...
                ' of "%s" in your\nworkspace.'],...
                answer{1},answer{1});
            %This dialog window has bug in this release. We expect HG team 
            % to provide an external API. Whenever HG team fix this bug or
            % implement the API, we need change this code.
            %userAns = localUIPrefDiag(hFig, warnMessage, sprintf('Export Cursor Data to Workspace'),'DataCursorVariable');
            userAns = 1;
            if ~userAns
                answer=inputdlg(prompt,name,numlines,defaultanswer);
                if ~isempty(answer) && ischar(answer{1})
                    exists = evalin('base', ['exist(''' answer{1} ''',''var'')']);
                else
                    exists = 0;
                end
            end
        end
        if ~isempty(answer) && ischar(answer{1})
            datainfo = getCursorInfo(h);
            try
                assignin('base',answer{1},datainfo);
                set(h,'DefaultExportVarName',answer{1});
            catch ex
                id = ex.identifier;
                if strcmpi(id,'MATLAB:assigninInvalidVariable')
                    errordlg(sprintf('Invalid variable name "%s".',answer{1}),...
                        'Cursor Data Export Error');
                else
                    errordlg('An error occurred while saving the data.',...
                        'Cursor Data Export Error');
                end
            end
        end
end
