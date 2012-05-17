function h=legendline(varargin)
%LEGENDLINE creates a line for display in a legend
%  H=GRAPH2D.LEGENDLINE creates a line for display in a legend
%
%  See also LEGEND, GRAPH2D.LEGEND, GRAPH2D.LEGENDPATCH

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.13.4.6 $  $Date: 2008/08/14 01:37:48 $

if (~isempty(varargin))
    h = graph2d.legendline(varargin{:}); % Calls built-in constructor
else
    h = graph2d.legendline;
end

h.LineHandle=handle([]);
h.LegendMarkerHandle=handle([]);

%set up listeners-----------------------------------------
cls       = classhandle(h);
clsLegend = classhandle(handle(h.Parent));

l        = handle.listener(h,cls.findprop('LineStyle'),...
    'PropertyPostSet',@changedStyle);
l(end+1) = handle.listener(h,cls.findprop('Color'),...
    'PropertyPostSet',@changedStyle);
l(end+1) = handle.listener(h,cls.findprop('LineWidth'),...
    'PropertyPostSet',@changedStyle);
l(end+1) = handle.listener(h,cls.findprop('Visible'),...
    'PropertyPreSet', @changedStyle);

l(end+1) = handle.listener(h,cls.findprop('DisplayMarker'),...
    'PropertyPostSet',@changedMarkerStyle);
l(end+1) = handle.listener(h,cls.findprop('DisplayMarkerSize'),...
    'PropertyPostSet',@changedMarkerStyle);
l(end+1) = handle.listener(h,cls.findprop('DisplayMarkerEdgeColor'),...
    'PropertyPostSet',@changedMarkerStyle);
l(end+1) = handle.listener(h,cls.findprop('DisplayMarkerFaceColor'),...
    'PropertyPostSet',@changedMarkerStyle);

l(end+1) = handle.listener(h,cls.findprop('LineHandle'),...
    'PropertyPostSet',@changedLineHandle);
l(end+1) = handle.listener(h,cls.findprop('LegendMarkerHandle'),...
    'PropertyPostSet',@changedLegendMarkerHandle);
l(end+1) = handle.listener(h,cls.findprop('Tag'),...
    'PropertyPostSet',@changedTag);

l(end+1) = handle.listener(h,cls.findprop('XData'),...
    'PropertyPreSet', @changedCoord);
l(end+1) = handle.listener(h,cls.findprop('YData'),...
    'PropertyPreSet', @changedCoord);

l(end+1) = handle.listener(handle(h.Parent),...
    clsLegend.findprop('LegendStrings'),...
    'PropertyPreSet',{@changedLegendString,h});

h.PropertyListeners = l;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedStyle(hProp,eventData)

if ~strcmpi(hProp.name,'Visible')
    set(eventData.affectedObject.LineHandle,...
        hProp.name,eventData.newValue);
end

if ~strcmpi(hProp.name,'LineStyle')
    set(eventData.affectedObject.LegendMarkerHandle,...
        hProp.name,eventData.newValue);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedMarkerStyle(hProp,eventData)

propName=hProp.name(length('Display')+1:end);

if strcmp(propName,'MarkerSize')
    hLegend = get(eventData.affectedObject,'Parent');
    oldFontUnits = get(hLegend,'FontUnits');
    set(hLegend,'FontUnits','points');
    legendFontSize = get(hLegend,'FontSize');
    set(hLegend,'FontUnits',oldFontUnits);

    newValue=min(eventData.newValue,...
        legendFontSize);
else
    newValue=eventData.newValue;
end

try
    set(eventData.affectedObject.LegendMarkerHandle, propName,newValue);
catch err
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedStyleRemote(hProp,eventData,hLegendLine)

if isempty(hLegendLine) || ~ishghandle(hLegendLine)
    try
        rmappdata(double(eventData.affectedObject),'LegendStyleListener');
    catch err
    end
else
    if strncmp('Marker',hProp.name,length('Marker'))
        propName=strcat('Display',hProp.name);
    else
        propName=hProp.name;
    end

    set(hLegendLine,...
        propName,eventData.newValue);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedTag(hProp,eventData)
%should update legend string whenever tag changes

hLine = eventData.affectedObject;
hLegend = handle(get(hLine,'Parent'));

if isa(hLegend,'graph2d.legend')
    try
        ud=hLegend.UserData;
        if ~isempty(ud.handles) && ~isempty(hLine.LineHandle)
            idx=find(double(ud.handles)==double(hLine.LineHandle));

            if ~isempty(idx)
                idx=idx(1);
                newString=multiline(eventData.newValue);
                if ~strcmp(ud.lstrings{idx},newString)
                    ud.lstrings{idx}=newString;
                    set(hLegend,'UserData',ud);
                    legend('ResizeLegend',double(hLegend));
                end
            end
        end
    catch err
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLegendString(hProp,eventData,hLine)
%should update legendline tag whenever legend string changes

hLegend = handle(eventData.affectedObject);
if isa(hLegend,'graph2d.legend')
    try
        ud = hLegend.UserData;
        if ~isempty(ud.handles) && ~isempty(hLine.LineHandle)
            idx = find(double(ud.handles)==double(hLine.LineHandle));

            if ~isempty(idx)
                idx = idx(1);
                newStrings=cellstr(eventData.newValue);
                set(hLine,'tag',singleline(newStrings{idx}));
            end
        end
    catch err
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedCoord(hProp,eventData)

xData=eventData.affectedObject.XData;
yData=eventData.affectedObject.YData;

set(eventData.affectedObject.LegendMarkerHandle,...
    'XData',mean(xData),'YData',mean(yData));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedCoordMarker(hProp,eventData)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedLineHandle(hProp,eventData)

%initialize display properties appropriately

hLegend = eventData.affectedObject;
hLine   = eventData.newValue;

styleProps={
    'LineStyle'
    'Color'
    'LineWidth'
    'Marker'
    'MarkerSize'
    'MarkerEdgeColor'
    'MarkerFaceColor'
    'Visible'
    };

setappdata(hLine,'LegendLine',hLegend);

lineClass = classhandle(handle(hLine));
interestedProperties = find(lineClass.properties,{'name'}, styleProps);
rListen = handle.listener(hLine,...
    interestedProperties,...
    'PropertyPostSet',...
    {@changedStyleRemote,hLegend});
eventData.affectedObject.LegendStyleListener = rListen;

%because of the way the legend handle is being created in
%legend.m, we don't have to initialize the legend line's properties here

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  changedLegendMarkerHandle(hProp,eventData)

%need to initialize display marker values
hMarker = handle(eventData.newValue);
hLine   = handle(eventData.affectedObject);

hLine.DisplayMarker         = hMarker.Marker;
hLine.DisplayMarkerSize     = hMarker.MarkerSize;
hLine.DisplayMarkerEdgeColor= hMarker.MarkerEdgeColor;
hLine.DisplayMarkerFaceColor= hMarker.MarkerFaceColor;

setappdata(double(hMarker),'LegendLineHandle',hMarker);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tOut=singleline(tIn)
%converts cellstrs and 2-d char arrays to
%\n-delimited single-line text

if ischar(tIn)
    if size(tIn,1)>1
        nRows=size(tIn,1);
        cr=char(10);
        cr=cr(ones(nRows,1));
        tIn=[tIn,cr]';
        tOut=tIn(:)';
        tOut=tOut(1:end-1); %remove trailing \n
    else
        tOut=tIn;
    end
elseif iscellstr(tIn)
    tOut=singleline(char(tIn));
else
    tOut='';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tOut=multiline(tIn)
%converts \n,\m,\n\m delimited single-line text
%to 2-d char arrays

tOut={};
tIn=strrep(tIn,[char(10),char(13)],char(10));
tIn=strrep(tIn,char(13),char(10));

while ~isempty(tIn)
    [tOut{end+1},tIn]=strtok(tIn,char(10));
    if isempty(tOut{end})
        tOut=tOut(1:end-1);
    end
end
tOut=char(tOut);

