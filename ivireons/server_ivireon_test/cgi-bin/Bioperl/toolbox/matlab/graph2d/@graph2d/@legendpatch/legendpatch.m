function h=legendpatch(varargin)
%LEGENDPATCH creates a patch for display in a legend
%  H=GRAPH2D.LEGENDPATCH creates a patch for display in a legend
%
%  See also LEGEND, GRAPH2D.LEGEND, GRAPH2D.LEGENDLINE

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.12.4.6 $  $Date: 2008/08/14 01:37:49 $

if (~isempty(varargin))
    h = graph2d.legendpatch(varargin{:}); % Calls built-in constructor
else
    h = graph2d.legendpatch;
end

h.PatchHandle=handle([]);
h.DisplayMarkerSize=6;

%set up FaceVertexCData and FaceVertexAlphaData so ---------
%nothing errors on interp/flat/faceted selections
h.FaceVertexCData=[0;1;1;0;0];
h.FaceVertexAlphaData=[0;1;1;0;0];

%set up listeners-----------------------------------------
cls       = classhandle(h);
clsLegend = classhandle(handle(h.Parent));

mirroredProperties = {
    'EdgeAlpha'
    'EdgeColor'
    'FaceAlpha'
    'FaceColor'
    'LineStyle'
    'LineWidth'
    'Marker'
    'MarkerEdgeColor'
    'MarkerFaceColor'
    'DisplayMarkerSize'
    };

l = handle.listener(h,...
    find(cls.properties,{'name'}, mirroredProperties),...
    'PropertyPostSet',...
    @changedStyle);

l(end+1) = handle.listener(h,cls.findprop('PatchHandle'),...
    'PropertyPostSet',@changedPatchHandle);


l(end+1) = handle.listener(h,cls.findprop('Tag'),...
    'PropertyPostSet',@changedTag);

l(end+1) = handle.listener(handle(h.Parent),clsLegend.findprop('LegendStrings'),...
    'PropertyPreSet',{@changedLegendString,h});

h.PropertyListeners = l;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedStyle(hProp,eventData)

if strcmpi(hProp.name,'DisplayMarkerSize')
    set(eventData.affectedObject.PatchHandle,...
        'MarkerSize',eventData.newValue);

    hLegend = get(eventData.affectedObject,'Parent');
    oldFontUnits = get(hLegend,'FontUnits');
    set(hLegend,'FontUnits','points');
    legendFontSize = get(hLegend,'FontSize');
    set(hLegend,'FontUnits',oldFontUnits);

    newValue=min(eventData.newValue,...
        legendFontSize/2);

    set(eventData.affectedObject,...
        'MarkerSize',newValue);

else
    set(eventData.affectedObject.PatchHandle,...
        hProp.name,eventData.newValue);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedStyleRemote(hProp,eventData,hLegendPatch)

if ~any(ishghandle(hLegendPatch))
    try
        rmappdata(double(eventData.affectedObject),'LegendPatch');
    catch err
    end
else
    if strcmpi(hProp.name,'MarkerSize')
        propName='DisplayMarkerSize';
    else
        propName=hProp.name;
    end

    set(hLegendPatch,...
        propName,eventData.newValue);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedTag(hProp,eventData)
%should update legend string whenever tag changes

hLine = eventData.affectedObject;
hLegend = handle(get(hLine,'Parent'));

if isa(hLegend,'graph2d.legend')
    try
        ud = hLegend.UserData;
        if ~isempty(ud.handles) && ~isempty(hPatch.PatchHandle)
            idx=find(double(ud.handles)==double(hLine.PatchHandle));

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
function changedLegendString(hProp,eventData,hPatch)
%should update legendline tag whenever legend string changes

hLegend = handle(eventData.affectedObject);
if isa(hLegend,'graph2d.legend')
    try
        ud = hLegend.UserData;
        if ~isempty(ud.handles) && ~isempty(hPatch.PatchHandle)
            idx = find(double(ud.handles)==double(hPatch.PatchHandle));

            if ~isempty(idx)
                idx = idx(1);
                newStrings=cellstr(eventData.newValue);
                set(hPatch,'tag',singleline(newStrings{idx}));
            end
        end
    catch
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changedPatchHandle(hProp,eventData)

hLegendPatch = eventData.affectedObject;
hDataPatch   = eventData.newValue;

%we only need to initialize DisplayMarkerSize here
set(hLegendPatch,'DisplayMarkerSize',...
    get(hDataPatch,'MarkerSize'));

%set up listeners
styleProps={
    'EdgeAlpha'
    'EdgeColor'
    'FaceAlpha'
    'FaceColor'
    'LineStyle'
    'LineWidth'
    'Marker'
    'MarkerEdgeColor'
    'MarkerFaceColor'
    'MarkerSize'
    'Visible'
    };

setappdata(double(hDataPatch),'LegendPatch',hLegendPatch);

patchClass = classhandle(handle(hDataPatch));
rListen = handle.listener(hDataPatch,...
    find(patchClass.properties,{'name'}, styleProps),...
    'PropertyPostSet',...
    {@changedStyleRemote,hLegendPatch});

hLegendPatch.LegendStyleListener = rListen;

%set CData and AlphaData so that interp/flat settings will
%be meaningful
cdat = get(hDataPatch,'CData');
if isempty(cdat)
    %Set this as the first index in the colormap.  I would like to set it as
    %white [1 1 1], but painters complains when given RGB CData.
    facecol = 1;
elseif size(cdat,3) == 1       % Indexed Color
    facecol = cdat(1,1,1);
elseif size(cdat,3) == 3 % RGB values
    facecol = reshape(cdat(1,1,:),1,3);
else
    facecol = 1;
end

xdat = get(hDataPatch,'XData');

if length(xdat) == 1
    hLegendPatch.FaceVertexCData    = facecol;
else
    hLegendPatch.FaceVertexCData    = [facecol;facecol;facecol;facecol;facecol];
end

try
    facealpha=get(hDataPatch,'FaceVertexAlphaData');
catch errFaceAlpha
    try
        facealpha=get(hDataPatch,'AlphaData');
    catch errAlpha
        facealpha=1;
    end
end

if length(facealpha)<1
    facealpha=1;
else
    facealpha=facealpha(1);
end

if length(xdat) == 1
    hLegendPatch.FaceVertexAlphaData= facealpha;
else
    hLegendPatch.FaceVertexAlphaData= [facealpha;facealpha;facealpha;facealpha;facealpha];
end

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
%converts \n delimited single-line text
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