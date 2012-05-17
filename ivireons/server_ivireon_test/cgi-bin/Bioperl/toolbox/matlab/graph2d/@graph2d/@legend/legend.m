function h=legend(varargin)
%LEGEND creates a	legend object
%  H=GRAPH2D.LEGEND creates a legend object
%
%  See also LEGEND

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.10.4.4 $  $Date: 2005/09/12 18:58:36 $ 

if (~isempty(varargin))
    h = graph2d.legend(varargin{:}); % Calls built-in constructor
else
    h = graph2d.legend;
end

% initialize property values -----------------------------

h.TextHandle = handle([]);
h.PositionMode = -111;
h.Interpreter = 'none';
h.LegendStrings={};
h.PosByLegendpos = 'off';

%set up listeners-----------------------------------------
cls=classhandle(h);

l       = handle.listener(h,cls.findprop('TextHandle'),...
			  'PropertyPostSet',@changedTextHandle);
l(end+1)= handle.listener(h,cls.findprop('Visible'),...
			  'PropertyPostSet',@changedPassOn);
l(end+1)= handle.listener(h,cls.findprop('PositionMode'),...
			  'PropertyPreSet',@changedPositionMode);
l(end+1)= handle.listener(h,cls.findprop('Position'),...
			  'PropertyPostSet',@changedPosition);

h.PropertyListeners = l;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedTextHandle(hProp,eventData)

textProps={'String'
    'FontAngle'
    'FontName'
    'FontSize'
    'FontUnits'
    'FontWeight'
    'Interpreter'};

%initialize properties ----------------------
hText=handle(eventData.newValue);
for i=1:length(textProps)
    set(eventData.affectedObject,...
        textProps{i},get(hText,textProps{i}));
end

%Create listeners for legend changes ------------------
legendClass = classhandle(eventData.affectedObject);

l=eventData.affectedObject.PropertyListeners;
for i=1:length(textProps)
    l(end+1)= handle.listener(eventData.affectedObject,...
        legendClass.findprop(textProps{i}),...
        'PropertyPostSet',...
        @changedText);
end
eventData.affectedObject.PropertyListeners = l;

%put a listener onto the text object's string and font properties --------
textClass = classhandle(hText);
tListener =        handle.listener(hText,textClass.findprop('String'),...
    'PropertyPostSet',@changedTextRemote);
for i=2:length(textProps)
    tListener(end+1) = handle.listener(hText,...
        textClass.findprop(textProps{i}),...
        'PropertyPostSet',...
        @changedTextRemote);
end
eventData.affectedObject.StringChangedListener = tListener;
setappdata(double(hText),'LegendObject',eventData.affectedObject);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedText(hProp,eventData)

newValue = eventData.newValue;

if strcmpi(hProp.name,'String')
    ud=eventData.affectedObject.UserData;
    
    oldLegendStrings = ud.lstrings;
    numLegendStrings = length(oldLegendStrings);
    
    %oldString = cellstr(get(eventData.affectedObject.TextHandle,'String'));
    oldString=cellstr(char(ud.lstrings));
    numOldString = length(oldString);
    newString = cellstr(eventData.newValue);
    numNewString = length(newString);
    
    
    if (numNewString == numOldString)
        if (numLegendStrings == numOldString)
            %all single-line
            newLegendStrings = newString;
        else
            newLegendStrings = oldLegendStrings;
            idx=1;
            %previously at least one multi-line
            for i=1:numLegendStrings
                legLen = size(newLegendStrings{i},1);
                newLegendStrings{i}=char(newString(idx:idx+legLen-1));
                idx=idx+legLen;
            end
        end
        ud.lstrings=cellstr(newLegendStrings);
        eventData.affectedObject.UserData=ud;
        newValue=cellstr(newValue);
    else
        newValue = oldString;
        set(eventData.affectedObject,'String',oldString);
        warning('MATLAB:legend:InvalidTask', 'Can not change string length.')
    end
end

set(eventData.affectedObject.TextHandle,...
   hProp.name,...
   newValue);

if ~strcmp(hProp.name,'FontUnits')
    %fontunits is a non-functional property that doesn't change
    %the way the legend looks.  don't need to redraw.
    legend('ResizeLegend',double(eventData.affectedObject));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedTextRemote(hProp,eventData)

hLegend = getappdata(eventData.affectedObject,'LegendObject');
set(hLegend,hProp.name,eventData.newValue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedPassOn(hProp,eventData)
%when this property is changed, pass the change on to
%all child objects.  Currently only used for "visible"

childObj=find(eventData.affectedObject);
set(childObj,hProp.name,eventData.newValue);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedPositionMode(hProp,eventData)

% a primary change in position mode will also cause a
% position change, firing the changedPosition
% listener, which should not in this case set
% the ud.legendpos value to that position.

currVal = eventData.affectedObject.PositionMode;

% don't set PosByLegendpos on if current value is
% the initial value (-111), because in this case
% there will be no call to resize legend (see below)
% to turn PosByLegendpos back off which would cause
% a primary change to legend position to be ignored.
if currVal ~= -111
    eventData.affectedObject.PosByLegendpos='on';
end

ud=eventData.affectedObject.UserData;
ud.legendpos=eventData.newValue;
eventData.affectedObject.UserData=ud;

if length(eventData.newValue)==1 && (currVal ~= -111)
    
    %this causes legend/DidLegendMove to return 0, which
    %we need in order to force a recalc after a manual move
    ud=eventData.affectedObject.UserData;
    oldUnits=get(eventData.affectedObject,'Units');
    set(eventData.affectedObject,'Units','Normalized');
    ud.LegendPosition=get(eventData.affectedObject,'Position');
    set(eventData.affectedObject,'Units',oldUnits);
    eventData.affectedObject.UserData=ud;
    
    legend('ResizeLegend',double(eventData.affectedObject));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedPosition(hProp,eventData)

% using set(l,pos) doesn't call legend, but
% ud fields LegendPosition and legendpos must be updated
ud=eventData.affectedObject.UserData;
oldUnits=get(eventData.affectedObject,'Units');
set(eventData.affectedObject,'Units','Normalized');
% UPDATE UD.LEGENDPOSITION
ud.LegendPosition=get(eventData.affectedObject,'Position');

% this keeps ud.legendpos from being set by a change in position
% caused by a change in legendpos, except when legendpos has a length
% of four so it really is a position.
if strcmp(eventData.affectedObject.PosByLegendpos,'off') || ...
        (strcmp(eventData.affectedObject.PosByLegendpos,'on') && ...
           length(eventData.affectedObject.PositionMode)==4)
        
    % this only gets set if the position change came
    % before the legendpos change.
    % UPDATE UD.LEGENDPOS
    ud.legendpos=get(eventData.affectedObject,'Position');
end
set(eventData.affectedObject,'Units',oldUnits);
eventData.affectedObject.UserData=ud;
eventData.affectedObject.PosByLegendpos='off';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%