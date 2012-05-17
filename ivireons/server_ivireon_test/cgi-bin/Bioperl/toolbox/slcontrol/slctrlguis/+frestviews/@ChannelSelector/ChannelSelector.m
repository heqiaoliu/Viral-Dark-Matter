classdef (Hidden = true) ChannelSelector < handle
    % @ChannelSelector class definition
    % Author(s): Erman Korkut 31-Mar-2009
    % Revised:
    %   Copyright 2009 The MathWorks, Inc.
    %   $Revision: 1.1.8.3 $ $Date: 2009/07/18 15:54:55 $
    properties(SetAccess='public',GetAccess = 'public', SetObservable = true)
        ChannelSelection;
        Visible = 'off';
        Handles;
    end
    properties(SetAccess='private',GetAccess = 'private', SetObservable = true)
        InputNames;
        OutputNames;
        Parent;
        Name;
    end
    methods
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = ChannelSelector(Parent,ChannelSelection)
            if nargin == 0
                return
            end
            obj.Parent = Parent;
            obj.ChannelSelection = ChannelSelection;
            obj.Name = ctrlMsgUtils.message('Slcontrol:frest:strIOSelector');
            obj.InputNames = Parent.TimePlot.InputName;
            obj.OutputNames = Parent.TimePlot.OutputName;
            % Create the GUI
            build(obj)
            % Set the current selection
            set(obj.Handles.ToDropDown,'Value',obj.ChannelSelection(1));
            set(obj.Handles.FromDropDown,'Value',obj.ChannelSelection(2));            
        end
        function set.Visible(obj,value)
            LocalSetVisibility(obj,value)
            obj.Visible = value;
        end
        % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function build(obj)
            UIColor = get(0,'DefaultUIControlBackground');            
            % Set font size and weight
            if isunix
                FontSize = 10;
            else
                FontSize = 8;
            end
            FigPos = [20 20 320 120];
            % Figure
            ChannelFig=figure('Units','pixels',...
                'Position',FigPos,...
                'Number','off',...
                'IntegerHandle','off',...
                'HandleVisibility','Callback',...
                'Menu','none',...
                'Name',obj.Name,...
                'Color',UIColor,...
                'CloseRequestFcn',{@LocalHide obj},...
                'Visible','off',...
                'ResizeFcn',{@(x,y)layout(obj)},...
                'DockControls', 'off'); 
            % Static texts
            FromText = uicontrol(ChannelFig,...
                'Background',UIColor,...
                'Unit','normalized',...
                'HorizontalAlignment','right',...
                'Position',[1/20 7/10 1/5 1/4],...
                'Style','text',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strFrom'));
            ToText = uicontrol(ChannelFig,...
                'Background',UIColor,...
                'HorizontalAlignment','right',...
                'Unit','normalized',...
                'Position',[1/20 35/100 1/5 1/4],...
                'Style','text',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strTo'));
            % Drop-down boxes
            FromDropDown = uicontrol(ChannelFig,...
                'Background',[1 1 1],...
                'Unit','normalized',...
                'Position',[3/10 7/10 65/100 1/4],...
                'Style','popup',...
                'FontSize',FontSize, ...
                'String',obj.InputNames,...
                'callback',{@LocalDropDown obj});
            ToDropDown = uicontrol(ChannelFig,...
                'Unit','normalized',...
                'Background',[1 1 1],...
                'Position',[3/10 35/100 65/100 1/4],...
                'Style','popup',...
                'FontSize',FontSize, ...
                'String',obj.OutputNames,...
                'Callback',{@LocalDropDown obj});
            % Buttons
            CloseButton = uicontrol(ChannelFig,...
                'Background',UIColor,...
                'Unit','normalized',...
                'Position',[1/2 1/20 1/5 1/5],...
                'Style','pushbutton',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strRegularClose'),...
                'Callback',{@LocalHide obj});
            HelpButton = uicontrol(ChannelFig,...
                'Background',UIColor,...
                'Unit','normalized',...
                'Position',[3/4 1/20 1/5 1/5],...
                'Style','pushbutton',...
                'FontSize',FontSize, ...
                'String',ctrlMsgUtils.message('Slcontrol:frest:strRegularHelp'),...
                'Callback','scdguihelp(''simview_ios'');');  
            % Store handles
            obj.Handles = struct(...
                'Figure',ChannelFig,...
                'FromText',FromText,...
                'ToText',ToText,...
                'FromDropDown',FromDropDown,...
                'ToDropDown',ToDropDown,...
                'CloseButton',CloseButton,...
                'HelpButton',HelpButton);
            layout(obj);
        end
        function layout(obj)
            FigPos = get(obj.Handles.Figure,'Position');
            FigW = FigPos(3);
            FigH = FigPos(4);
            Pix2Norm = [FigW FigH FigW FigH];
            % Spacing values in pixels
            tgap = 10;
            bgap = 5;
            lgap = 5;
            rgap = 5;            
            % Get active figure area: Figure area minus gaps
            activeFigPos = [lgap,bgap,FigW-(lgap+rgap) FigH-(tgap+bgap)];
            activeFigW = activeFigPos(3);
            activeFigH = activeFigPos(4);
            % Define gaps between components in normalized units
            vertgap = 1/8; % Vertical space between From and To
            horzgap = 0.1; % Horizontal space between From and DropDown
            % Define size of components in normalized units.
            FromH = 1/4; % Ratio of height of from text box to the height of active figure area
            FromW = 0.15; % Ratio of width of from text box to the width of active figure area
            
            % Set the position of From and To text boxes:
            FromTextPos = [activeFigPos(1), activeFigH*(1-FromH), ...
                activeFigW*FromW, activeFigH*FromH];
            ToTextPos = [activeFigPos(1), activeFigH*(1-2*FromH-vertgap), ...
                activeFigW*FromW, activeFigH*FromH];
            set(obj.Handles.FromText,'Position',FromTextPos./Pix2Norm);
            set(obj.Handles.ToText,'Position',ToTextPos./Pix2Norm);
            % Set the position of the drop down boxes
            FromDropPos = [activeFigW*(FromW+horzgap), activeFigH*(1-FromH), ...
                activeFigW*(1-FromW-horzgap), activeFigH*FromH];
            ToDropPos = [activeFigW*(FromW+horzgap), activeFigH*(1-2*FromH-vertgap), ...
                activeFigW*(1-FromW-horzgap), activeFigH*FromH];
            set(obj.Handles.FromDropDown,'Position',FromDropPos./Pix2Norm);
            set(obj.Handles.ToDropDown,'Position',ToDropPos./Pix2Norm);
            % Set the position of the buttons
            ClosePos = [activeFigW*0.55, activeFigPos(2), ...
                activeFigW*0.2 activeFigH*0.22];
            HelpPos = [activeFigW*0.8, activeFigPos(2), ...
                activeFigW*0.2 activeFigH*0.22];
            set(obj.Handles.CloseButton,'Position',ClosePos./Pix2Norm);
            set(obj.Handles.HelpButton,'Position',HelpPos./Pix2Norm);
            % Check the dropdown box sizes and adjust strings if there is
            % not enough room.            
            dropLen = hgconvertunits(obj.Handles.Figure,...
                get(obj.Handles.FromDropDown,'Position'),...                
                'normalized','characters',obj.Handles.Figure);
            dropLen = floor(dropLen(3))-2; % Assuming that the arrow is 2 characters long
            LocalFitNamesInDropDowns(obj,dropLen);
        end
        
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalHide
%  Makes the I-O Selector figure invisible - callback for close button and
%  close window icon
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalHide(eventsrc,eventdata,obj)
obj.Visible = 'off';
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalDropDown
%  Updates the selected channel based on drop-down action
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalDropDown(eventsrc,eventdata,obj)
% Set the current selection of the object
obj.ChannelSelection(1) = get(obj.Handles.ToDropDown,'Value');
obj.ChannelSelection(2) = get(obj.Handles.FromDropDown,'Value');
% Then set the parent's current channel attribute
obj.Parent.CurrentChannel = obj.ChannelSelection;
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalSetVisibility
%  Sets the visibility of the I-O Selector figure
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalSetVisibility(obj,value)
set(obj.Handles.Figure,'Visible',value);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalFitNamesInDropDowns
%  Sets the names to appear in drop down boxs making sure that they fit or
%  they are properly truncated.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalFitNamesInDropDowns(obj,dropLen)
i_name = cell(size(obj.InputNames));
o_name = cell(size(obj.OutputNames));
for ct = 1:numel(obj.InputNames)
    if numel(obj.InputNames{ct}) < dropLen
        i_name{ct} = obj.InputNames{ct};
        continue;
    else
        i_name{ct} = LocalTruncateName(obj.InputNames{ct},dropLen);
    end
end
for ct = 1:numel(obj.OutputNames)
    if numel(obj.OutputNames{ct}) < dropLen
        o_name{ct} = obj.OutputNames{ct};
        continue;
    else
        o_name{ct} = LocalTruncateName(obj.OutputNames{ct},dropLen);
    end
end
% Set the drop down box names
set(obj.Handles.FromDropDown,'String',i_name);
set(obj.Handles.ToDropDown,'String',o_name);
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  LocalTruncateName
%  Truncate the block address in order to fit into drop down box. For
%  example, mdl/blk1/blk2/blk3/blk4 is truncated from one of the separators
%  adding three dots to the beginning, such as .../blk3/blk4.
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = LocalTruncateName(label,len)
% Revert the label for easier processing and search for separators
% Before search, replace //'s with __ not to get confused in the search.
sep = findstr(strrep(label(end:-1:1),'//','__'),'/'); 
if isempty(sep)
    % Nothing to truncate, return
    str = label;
    return;
else
    % Find the sepeator that would fit with three dots
    sepFit = find(sep < (len-3), 1, 'last' ); % SepFit'th separator from the end in original string can be fit
    sepFit = numel(sep)-sepFit+1; % SepFit'th separator from the beginning in original string can be fit
    % Write the string
    sep = findstr(strrep(label,'//','__'),'/');
    str = ['...' label(sep(sepFit):end)];    
end    
end


