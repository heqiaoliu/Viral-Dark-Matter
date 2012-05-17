function schema
% Defines properties for @axesgroup superclass

%   Author(s): P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2009/12/22 18:57:43 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axesgroup');

% General
schema.prop(c,'AxesStyle','handle');              % Axes style parameters (@axesstyle)
schema.prop(c,'EventManager','handle');           % Event coordinator (@eventmgr object)
schema.prop(c,'Grid','on/off');                   % Grid state (on/off)
schema.prop(c,'GridFcn','MATLAB array');          % Grid function (built-in grid if empty)
schema.prop(c,'GridOptions','MATLAB array');      % Grid options (struct)
schema.prop(c,'LabelFcn','MATLAB callback');      % Label building function
p = schema.prop(c,'LayoutManager','on/off');      % Layout manager (on -> uses resize fcn)
p.FactoryValue = 'on';
p = schema.prop(c,'LimitManager','on/off');       % Enable state for limit manager
p.FactoryValue = 'on';
schema.prop(c,'LimitFcn','MATLAB callback');      % Limit picker (ViewChanged callback)
p = schema.prop(c,'NextPlot','string');           % Hold mode [add|replace]
p.FactoryValue = 'replace';     
p = schema.prop(c,'Parent','MATLAB array');                 % Parent figure
p.SetFunction = @LocalConvertToHandle;
p = schema.prop(c,'Position','MATLAB array');     % Axes group position (in normalized units)
p.AccessFlags.Init = 'off';
schema.prop(c,'Size','MATLAB array');             % Size of axes grid
schema.prop(c,'Title','MATLAB array');            % Title string or cell array(for multiline title)
schema.prop(c,'TitleStyle','handle');             % Title style (@labelstyle handle)
p = schema.prop(c,'UIContextMenu','MATLAB array');          % Right-click menu root
p.SetFunction = @LocalConvertToHandle;
schema.prop(c,'Visible','on/off');                % Axis group visibility

% REVISIT: MATLAB array->string vector
% X axis
% Ncol := prod(Size([2 4]))
schema.prop(c,'XLabel','MATLAB array');           % X label (string or cell of length Size(4))
schema.prop(c,'XLabelStyle','handle');            % X label style (@labelstyle handle)
p = schema.prop(c,'XLimMode','MATLAB array');     % X limit mode [auto|manual]
% String vector of length the total number of columns in axis grid
p.SetFunction = @LocalXLimModeFilter;
p = schema.prop(c,'XLimSharing','string');        % X limit sharing [column|peer|all]
p.FactoryValue = 'column';
p = schema.prop(c,'XScale','MATLAB array');       % X axis scale (Ncol-by-1 string cell)
p.SetFunction = @LocalXScaleFilter;
p = schema.prop(c,'XUnits','MATLAB array');       % X units (string or cell of length Size(4))
p.SetFunction = @LocalXUnitFilter;
% RE: XUnits covers shared units such as time or frequency units. Use ColumnLabel 
%     to specify column-dependent units (e.g., input units)

% Y axis
% Nrow := prod(Size([2 4]))
schema.prop(c,'YLabel','MATLAB array');           % Y label (string or cell of length Size(3))
schema.prop(c,'YLabelStyle','handle');            % Y label style (@labelstyle handle)
p = schema.prop(c,'YLimMode','MATLAB array');     % Y limit mode [auto|manual]
% String vector of length the total number of rows in axis grid
p.SetFunction = @LocalYLimModeFilter;
p = schema.prop(c,'YLimSharing','string');        % Y limit sharing [row|peer|all]
p.FactoryValue = 'row';
schema.prop(c,'YNormalization','on/off');         % Y axis normalization
p = schema.prop(c,'YScale','MATLAB array');       % Y axis scale (Nrow-by-1 string cell)
p.SetFunction = @LocalYScaleFilter;
p = schema.prop(c,'YUnits','MATLAB array');       % Y units (string or cell of length Size(3))
p.SetFunction = @LocalYUnitFilter;
% RE: YUnits covers shared units such as mag or phase units. Use RowLabel 
%     to specify row-dependent units (e.g., output units)

% Private properties
p(1) = schema.prop(c,'Axes','MATLAB array');              % Nested @plotarray's
p(2) = schema.prop(c,'Axes2d','MATLAB array');            % Matrix of HG axes handles (virtual)
p(3) = schema.prop(c,'Axes4d','MATLAB array');            % 4D array of HG axes handles (virtual)
p(4) = schema.prop(c,'GridLines','handle vector');        % Grid lines
p(5) = schema.prop(c,'MessagePane','MATLAB array');       % Message pane (displayed at top of axesgroup)
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');  
p(5).AccessFlags.Serialize  = 'off';


p = schema.prop(c,'LimitListenersData','MATLAB array');        % ListenerManager Listeners related to limit manager
p = schema.prop(c,'LimitListeners','MATLAB array');        %  Virtual ListenerManager Listeners related to limit manager
p.GetFunction = @LocalGetLimitListenersValue;
set(p,'AccessFlags.PublicGet','on','AccessFlags.PublicSet','off');  

p = schema.prop(c,'ListenersData','MATLAB array');         % ListenerManager
p = schema.prop(c,'Listeners','MATLAB array');         % Virtual ListenerManager
p.GetFunction = @LocalGetListenersValue;
set(p,'AccessFlags.PublicGet','on','AccessFlags.PublicSet','off', ...
    'AccessFlags.PrivateSet','off');  

% Events
schema.event(c,'DataChanged');   % Change in data content (triggers redraw)
schema.event(c,'ViewChanged');   % Change in view content (triggers limit update)
schema.event(c,'PreLimitChanged');   % Issued prior to call to limit picker
schema.event(c,'PostLimitChanged');  % Change in axis limits or scales


%------------------ Local Functions ----------------------------------

function Value = LocalXLimModeFilter(this,Value)
% Correctly formats XlimMode settings
Size = this.Size;
if ~all(strcmpi(Value,'auto') | strcmpi(Value,'manual'))
    ctrlMsgUtils.error('Controllib:plots:LimModeProperty1','XLimMode')
else
   [Value,BadInputFlag] = LocalFormat(Value,Size([2 4]));
   if BadInputFlag
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties3','XLimMode')
   end
   % Check compatibility with XLimSharing
   if (strcmp(this.XLimSharing,'all') & Size(2)*Size(4)>1 & ~isequal(Value{:})) | ...
         (strcmp(this.XLimSharing,'peer') & Size(2)>1 & ...
         ~isequal(Value,repmat(Value(1:Size(4)),[Size(2) 1])))
     ctrlMsgUtils.error('Controllib:plots:axesgroupProperties2','XlimMode','XLimSharing')
   end
end


function Value = LocalYLimModeFilter(this,Value)
% Correctly formats YlimMode settings
Size = this.Size;
if ~all(strcmpi(Value,'auto') | strcmpi(Value,'manual'))
    ctrlMsgUtils.error('Controllib:plots:LimModeProperty1','YLimMode')
else
   [Value,BadInputFlag] = LocalFormat(Value,Size([1 3]));
   if BadInputFlag
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties3','YLimMode')
   end
   % Check compatibility with YLimSharing
   if (strcmp(this.YLimSharing,'all') & Size(1)*Size(3)>1 & ~isequal(Value{:})) | ...
         (strcmp(this.YLimSharing,'peer') & Size(1)>1 & ...
         ~isequal(Value,repmat(Value(1:Size(3)),[Size(1) 1])))
     ctrlMsgUtils.error('Controllib:plots:axesgroupProperties2','YlimMode','YLimSharing')
   end
end


function Value = LocalXScaleFilter(this,Value)
% Correctly formats XScale value
if ~all(strcmpi(Value,'linear') | strcmpi(Value,'log'))
    ctrlMsgUtils.error('Controllib:plots:ScaleProperty2','XScale')
else
   [Value,BadInputFlag] = LocalFormat(Value,this.Size(2:2:end));
   if BadInputFlag
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties3','XScale')
   end
end


function Value = LocalYScaleFilter(this,Value)
% Correctly formats YScale value
if ~all(strcmpi(Value,'linear') | strcmpi(Value,'log'))
    ctrlMsgUtils.error('Controllib:plots:ScaleProperty2','YScale')
else
   [Value,BadInputFlag] = LocalFormat(Value,this.Size(1:2:end));
   if BadInputFlag
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties3','YScale')
   end
end


function Value = LocalXUnitFilter(this,Value)
% Correctly formats XUnit settings (must be cell array of same length as subgrid col size)
Size = this.Size;
if Size(4)==1
   % No subgrid along column -> XUnit is a string
   if iscellstr(Value) & isequal(size(Value),[1 1])
      Value = Value{1};
   elseif ~ischar(Value)
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties1','XUnit')
   end
else
   % Multi-column subgrid: XUnit is a cell
   [Value,BadInputFlag] = LocalFormat(Value,Size(4));
   if BadInputFlag
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties3','XUnit')
   end
end


function Value = LocalYUnitFilter(this,Value)
% Correctly formats YUnit settings (must be cell array of same length as subgrid row size)
Size = this.Size;
if Size(3)==1 
   % No subgrid along column -> YUnit is a string
   if iscellstr(Value) & isequal(size(Value),[1 1])
      Value = Value{1};
   elseif ~ischar(Value) & ~isequal(Size,[2 1 1 1])
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties1','YUnit')
   end
else
   [Value,BadInputFlag] = LocalFormat(Value,Size(3));
   if BadInputFlag
       ctrlMsgUtils.error('Controllib:plots:axesgroupProperties3','YUnit')
   end
end


function [Value,BadInput] = LocalFormat(Value,Sizes)
% Format string input
BadInput = false;
Sizes = [Sizes 1];
if ischar(Value), 
   Value = {Value}; 
end
switch length(Value)
case 1
   Value = Value(ones(1,prod(Sizes)),1);
case Sizes(2)
   % Specified for subgrid
   Value = repmat(Value(:),[Sizes(1) 1]);
case prod(Sizes)
   % Fully specified
   Value = Value(:);
otherwise
   BadInput = true;
end


function StoredValue = LocalGetLimitListenersValue(this,StoredValue)
if isempty(this.LimitListenersData)
    this.LimitListenersData = controllibutils.ListenerManager;
end
StoredValue = this.LimitListenersData;

function StoredValue = LocalGetListenersValue(this,StoredValue)
if isempty(this.ListenersData)
    this.ListenersData = controllibutils.ListenerManager;
end
StoredValue = this.ListenersData;


function Value = LocalConvertToHandle(this,Value)
% Converts to handle
Value = handle(Value);

