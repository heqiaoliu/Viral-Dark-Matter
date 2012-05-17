 function createTextBox(hThis,varargin)
% Create and set up a scribe rectangle

%   Copyright 2006-2009 The MathWorks, Inc.

% Since we cannot call super() from UDD, call a helper-method:
% Don't send varargin here, but rather call this method for setup purposes
hThis.createScribeObject2D;

% Define the shape type:
hThis.ShapeType = 'textbox';

% Create the main rectangle
pos = hThis.Position;
x1 = pos(1);
x2 = pos(1)+pos(3);
y1 = pos(2);
y2 = pos(2)+pos(4);
pz = 0;
[x,y,z]=meshgrid([x1,x2],[y1,y2],pz);
hThis.RectHandle = hg.surface('EdgeColor',hThis.EdgeColor,...
    'FaceAlpha',hThis.FaceAlpha,...
    'LineWidth',hThis.LineWidth,...
    'FaceColor','none',...
    'CData',NaN,...
    'FaceLighting','none',...
    'Parent',double(hThis),...
    'Interruptible','off',...
    'XData',x,'YData',y,'ZData',z,...
    'HandleVisibility','off','HitTest','off');

% Create the text
hFig = ancestor(hThis,'Figure');
pos = hgconvertunits(hFig,get(hThis,'Position'),get(hThis,'Units'),'pixels',hFig);
hThis.TextHandle = hg.text('Units','pixels',...
    'BackgroundColor','none',...
    'EdgeColor','none',...
    'Editing','off',...
    'Position',[pos(1) , pos(2)+pos(4) , 0],...
    'HorizontalAlignment',hThis.HorizontalAlignment,...
    'Margin',1,...
    'String',hThis.String, ...
    'VerticalAlignment',hThis.VerticalAlignment,...
    'Parent',double(hThis),...
    'Interruptible','off',...
    'HandleVisibility','off','HitTest','off');

% The Selection Handles must always be on top in the child order:
hChil = findall(double(hThis));
set(hThis,'Children',[hChil(4:end);hChil(2:3)]);

% Define the properties which should listen to the "Color" property
hThis.ColorProps{end+1} = 'TextColor';

% Set the Edge Color Property to correspond to the "Color" property of the
% line.
hThis.EdgeColorProperty = 'EdgeColor';
hThis.EdgeColorDescription = 'Edge Color';

% Set the Face Color Property to correspond to the "HeadColor" property of the
% line.
hThis.FaceColorProperty = 'BackgroundColor';
hThis.FaceColorDescription = 'Background Color';

% Set the Text Color Property to correspond to the "TextColor" property of the
% line.
hThis.TextColorProperty = 'TextColor';
hThis.TextColorDescription = 'Text Color';

%set up listeners
props = hThis.findprop('Position');
props(end+1) = hThis.findprop('String');
l = handle.listener(hThis,props, ...
    'PropertyPostSet', @localChangePosition);
hThis.PropertyListeners(end+1) = l;
% For font-related properties, listen to the raw string. Needed by print
% preview:
%hText = hThis.TextHandle;
props = hThis.findprop('FontAngle');
props(end+1) = hThis.findprop('FontName');
props(end+1) = hThis.findprop('FontSize');
props(end+1) = hThis.findprop('FontUnits');
props(end+1) = hThis.findprop('FontWeight');
props(end+1) = hThis.findprop('HorizontalAlignment');
props(end+1) = hThis.findprop('VerticalAlignment');
l = handle.listener(hThis,props, ...
    'PropertyPostSet', @localChangePosition);
hThis.PropertyListeners(end+1) = l;

% Deal with observing the position to update the "FitHeightToText" property
l = handle.listener(hThis,findprop(hThis,'Position'),...
    'PropertyPreSet',@localUpdateFitHeightToText);
hThis.PropertyListeners(end+1) = l;

% Deal with keeping track of the "Edit" state in order to dynamically
% resize the textbox.
l = handle.listener(hThis,findprop(hThis,'Editing'),...
    'PropertyPostSet',@localStartEdit);
hThis.PropertyListeners(end+1) = l;

% If the user sets the "FitHeightToText" or "FitBoxToText" properties, the
% object should update.
props = findprop(hThis,'FitHeightToText');
props(2) = findprop(hThis,'FitBoxToText');
l = handle.listener(hThis,props,'PropertyPostSet',@localUpdateBoxSize);
hThis.PropertyListeners(end+1) = l;

% Install a listener on the raw text string:
l = handle.listener(hThis.TextHandle,findprop(handle(hThis.TextHandle),'String'),...
    'PropertyPostSet', {@localChangeTextString,hThis});
hThis.PropertyListeners(end+1) = l;

% Intall a property listener on the "Image" property:
l = handle.listener(hThis,hThis.findprop('Image'), ...
    'PropertyPostSet', @localChangeImage);
hThis.PropertyListeners(end+1) = l;

% Set properties passed by varargin
set(hThis,varargin{:});

%-------------------------------------------------------------------%
function localUpdateBoxSize(obj,evd) 
% When properties that maintain the box size are set to "on", resize the
% object.

hThis = evd.AffectedObject;
if strcmpi(evd.NewValue,'on')
    if strcmpi(obj.Name,'FitBoxToText')
        set(hThis.TextHandle,'String',hThis.String);
    end
    localResizeText(hThis,hThis.String);
end

%-------------------------------------------------------------------%
function localStartEdit(obj,evd) %#ok
% When we start editing, be sure to resize the text box.

hThis = evd.AffectedObject;
if strcmpi(evd.NewValue,'off')
    return;
end
if strcmpi(hThis.FitBoxToText,'off')
    return;
end
% We are going to install a listener on the Java edit field. If Java is
% not enabled, return early.
if ~usejava('awt')
    return;
end
% Create the listener:
hTextEdit = handle(com.mathworks.hg.peer.FigurePeer.getCurrentEdit);
if isempty(hTextEdit)
    return;
end
callback=handle(hTextEdit.getCallback);
if isempty(callback)
    return;
end
hThis.EditListener = handle.listener(callback,'delayed',{@localEditListenerCallback,hThis});

%-------------------------------------------------------------------%
function localEditListenerCallback(obj,evd,hThis) %#ok
% Called every time the edit string changes

% Get the new string
newStr = evd.JavaEvent.data;
% Convert the Java string array into a cell array.
str = cell(numel(newStr),1);
for i = 1:numel(newStr)
    str{i} = newStr(i).toCharArray';
end

if ~isscalar(str) && isempty(str{end})
    hThis.EndsWithNewLine = true;
else
    hThis.EndsWithNewLine = false;
end

% Resize the box:
if isempty(str{1}) && isscalar(str)
    str{1} = ' ';
end
localResizeText(hThis,str);

%-------------------------------------------------------------------%
function localUpdateFitHeightToText(hProp, eventData) %#ok
% When the user manually changes the position, turn off the
% "FitHeightToText" behavior.

hThis = eventData.affectedObject;
changedAspect = abs(hThis.Position - eventData.NewValue);
% If we are simply moving the textbox, don't turn off any existing
% behavior.
if all(changedAspect(3:4)<eps)
    return;
end
if ~hThis.UpdateInProgress && ~hThis.FigureResize
    hThis.FitHeightToText = 'off';
    hThis.FitBoxToText = 'off';
end

%-------------------------------------------------------------------%
function localChangeTextString(hProp, eventData, hThis) %#ok
% When the raw string changes (as the result of an edit), update the
% appropriate values

if ~hThis.UpdateInProgress
    hThis.UpdateInProgress = true;
    newString = hThis.TextHandle.String;
    if ~iscell(newString)
        newString = cellstr(newString);
    end
    if hThis.EndsWithNewLine
        hThis.EndsWithNewLine = false;
        newString = [newString;{''}];
        hThis.String = newString;
        hThis.TextHandle.String = newString;
    else
        hThis.String = newString;
    end
    localResizeText(hThis);
    hThis.EditListener = [];
    hThis.UpdateInProgress = false;
end

%-------------------------------------------------------------------%
function localChangeImage(hProp, eventData) %#ok
% Set the interior of a rectangle to be an image
% This should be in a set-function, but this appears to cause a SegV (in
% M-code at least).

hThis = eventData.affectedObject;
valueProposed = hThis.Image;
if ~isempty(hThis.RectHandle) && ishandle(hThis.RectHandle)
    faceHandle = double(hThis.RectHandle);
    if isempty(valueProposed)
        set(faceHandle,'FaceColor',hThis.BackgroundColor);
        textHandle = hThis.TextHandle;
        if ~isempty(textHandle) && ishandle(textHandle)
            set(textHandle,'BackgroundColor',hThis.BackgroundColor);
        end
        set(faceHandle,'CDataMapping','Scaled');
    else
        set(faceHandle,'FaceColor','texturemap',...
            'CDataMapping','Direct');
        % We need to flip the Y-Data of the image:
        valueProposed = valueProposed(end:-1:1,:,:);
        set(faceHandle,'CData',valueProposed);
        textHandle = hThis.TextHandle;
        if ~isempty(textHandle) && ishandle(textHandle)
            set(textHandle,'BackgroundColor','none');
        end
    end
end

%---------------------------------------------------------------------%
function localChangePosition(hProp, eventData, updateText) %#ok
% Update the position of the children

% DIsable tex/latex warnings to prevent too much information being
% output to the command window
warnState = warning('off','MATLAB:tex');
warnState(2) = warning('off','MATLAB:gui:latexsup:BadTeXString');

hThis = eventData.affectedObject;
if ~isa(hThis,'scribe.textbox')
    hThis = handle(get(hThis,'Parent'));
end

if ~hThis.UpdateInProgress
    hThis.UpdateInProgress = true;
    
    if nargin < 3
        updateText = true;
    end
    
    hFig = ancestor(hThis,'Figure');
    pos = hgconvertunits(hFig,get(hThis,'Position'),get(hThis,'units'),...
        'normalized',hFig);
    x1 = pos(1);
    x2 = pos(1)+pos(3);
    y1 = pos(2);
    y2 = pos(2)+pos(4);
    [x,y]=meshgrid([x1,x2],[y1,y2],0);
    set(double(hThis.RectHandle),'XData',x,'YData',y);
   
    % Update the text position
    sw = hThis.Margin;
    sh = hThis.Margin - 1;
    % pixels to adjust for text object visible position within their extent
    % (i.e. they sit a little low in the box)
    topadj = 2;

    % calculate outer rect to text margin to be used when editing is on
    dxy=0;

    pos = hgconvertunits(hFig,get(hThis,'Position'),get(hThis,'units'),...
        'points',hFig);
    X = pos(1) + pos(3)/2 + dxy;
    Y = pos(2) + pos(4)/2 + dxy;
    W = pos(3) - 2*dxy;
    H = pos(4) - 2*dxy;
    set(double(hThis.TextHandle),'units','points');

    switch (hThis.VerticalAlignment)
        case {'top','cap'}
            switch (hThis.HorizontalAlignment)
                case 'left'
                    set(double(hThis.TextHandle),'Position',[X-W/2+sw,Y+H/2-sh+topadj,0]);
                case 'right'
                    set(double(hThis.TextHandle),'Position',[X+W/2-sw,Y+H/2-sh+topadj,0]);
                case 'center'
                    set(double(hThis.TextHandle),'Position',[X,Y+H/2-sh+topadj,0]);
            end
        case {'bottom','baseline'}
            switch (hThis.HorizontalAlignment)
                case 'left'
                    set(double(hThis.TextHandle),'Position',[X-W/2+sw,Y-H/2+sh+topadj,0]);
                case 'right'
                    set(double(hThis.TextHandle),'Position',[X+W/2-sw,Y-H/2+sh+topadj,0]);
                case 'center'
                    set(double(hThis.TextHandle),'Position',[X,Y-H/2+sh+topadj,0]);
            end
        case 'middle'
            switch (hThis.HorizontalAlignment)
                case 'left'
                    set(double(hThis.TextHandle),'Position',[X-W/2+sw,Y+topadj,0]);
                case 'right'
                    set(double(hThis.TextHandle),'Position',[X+W/2-sw,Y+topadj,0]);
                case 'center'
                    set(double(hThis.TextHandle),'Position',[X,Y,0]);
            end
    end
    if updateText
        if ~isappdata(0,'BusyPrinting')       
            hThis.TextHandle.String = hThis.String;
            localResizeText(hThis);
        end
        hThis.UpdateInProgress = false;
    else
        % Typically called within a callback. For this reason, we must
        % manually update the selection handles.
        hThis.UpdateInProgress = false;
        hThis.updateSelectionHandles;
    end
end

% Restore tex/latex warnings which were disabled at the beginning of this
% function
warning(warnState); %#ok<WNTAG>

%-----------------------------------------------------------------------%
function localResizeText(hThis,str)

hFig = ancestor(hThis,'Figure');
if strcmpi(hThis.FitHeightToText,'off')
    doresize = false;
else
    doresize = true;
end

th=hThis.TextHandle;
t=double(th);

if nargin < 2
    str=cellstr(th.String);
else
    str = cellstr(str);
end

if isempty(str) || (isscalar(str) && isempty(str{1}))
    return;
end

% create cell array string to fit current box
sizes = localGetStrCellSizes(hThis,str);
% calc extra space in every width
onecharspace = double(localGetStrSize(hThis,{'A'}));
twocharspace = double(localGetStrSize(hThis,{'AA'}));
xspace = ((2*onecharspace(1)) - twocharspace(1))/2;
% initialize arrays and flags
dstr = cell(1,1);
ndlines = 0;
needxresize = false;
pos = hgconvertunits(hFig,get(hThis,'Position'),get(hThis,'units'),...
    'points',hFig);
NewPX = pos(1)+pos(3)/2;
NewPWidth = pos(3);
dims = size(sizes);

% When the text needs to be resized (as a result of the string changing),
% there are two options. If the "FitBoxToText" behavior is set, the textbox
% will be resized rather than the text. Otherwise, the text will be
% resized.
if strcmpi(hThis.FitBoxToText,'on')
    maxDims = [max(sizes(:,1)),sum(sizes(:,2))];
    % The edit box will always demand a bit more room, accomidate this:
    tempSize = localGetStrSize(hThis,{'m'});
    maxDims(1) = maxDims(1) + xspace + tempSize(1);
    maxDims = hgconvertunits(hFig,[0 0 maxDims],'Points','Pixels',hFig);
    maxDims = maxDims(3:4);
    maxDims = maxDims + 2*hThis.Margin;
    maxDims = hgconvertunits(hFig,[0 0 maxDims],'Pixels',hThis.Units,hFig);
    maxDims = maxDims(3:4);
    currPos = hThis.Position;
    sizeChange = currPos(3:4) - maxDims;
    % Depending on the alignment settings, different position properties
    % may need to change
    currPos(3) = maxDims(1);
    switch hThis.HorizontalAlignment
        case 'center'
            currPos(1) = currPos(1) + sizeChange(1)/2;
        case 'right'
            currPos(1) = currPos(1) + sizeChange(1);
    end
    currPos(4) = maxDims(2);
    switch hThis.VerticalAlignment
        case 'top'
            currPos(2) = currPos(2) + sizeChange(2);
        case 'middle'
            currPos(2) = currPos(2) + sizeChange(2)/2;
    end
    hThis.UpdateInProgress = true;
    set(hThis,'Position',currPos);
    hThis.UpdateInProgress = false;
    % update associated values
    eventData.affectedObject = hThis;
    localChangePosition([], eventData, false);    
else
    nwords = zeros(1,dims(1));
    for i=1:dims(1); % looping through input lines (Cells)
        tystr = dstr;
        tystr{ndlines+1} = str{i,:};
        tysize = localGetStrSize(hThis,tystr);
        if sizes(i,1)<(pos(3) - 2*hThis.Margin + xspace)
            % if width of cell is less than width of box
            % just pass it along;
            ndlines = ndlines+1;
            dstr{ndlines} = str{i,:};
        else
            % else split it (the cell) up over multiple lines
            % get char counts and extents of words
            [nwords(i),words] = localCellWords(str{i});
            w=1; %cell word count
            lw=1; %line word count
            llen=0; %line length
            lstr = ''; %line string
            newysize=false;
            while w<nwords(i)+1
                % get test string and its size (for x test)
                if lw==1
                    tstr = [lstr,words{w}];
                else
                    tstr = [lstr,' ',words{w}];
                end
                tsize = double(localGetStrSize(hThis,tstr));
                % y size test string
                if newysize
                    tystr = dstr;
                    tystr{ndlines+1} = tstr;
                    tysize = localGetStrSize(hThis,tystr);
                    newysize=false;
                end
                if tsize(1) > pos(3) - 2*hThis.Margin
                    % string size > width of textbox
                    if llen==0 || strcmpi(hThis.FirstEdit,'on')
                        % if first word in line or if first time box is being
                        % edited (grow box width), need to calculate a resize
                        % for width.
                        needxresize = true;
                        NewPX = max(NewPX,pos(1) + tsize(1)/2 + hThis.Margin);
                        NewPWidth = max(NewPWidth,tsize(1) + 2*hThis.Margin);
                        % set line string to test string and increment cell
                        % word index;
                        lstr = tstr;
                        w = w+1;
                        if strcmpi(hThis.FirstEdit,'on')
                            % firstedit is on need to continue in line loop,
                            % so set line length to current string width and
                            % increment line words counter.
                            llen = tsize(1);
                            lw = lw+1;
                            if w>nwords(i)
                                % last word in line, finish up line.
                                ndlines = ndlines+1;
                                clstr = lstr;
                                dstr{ndlines} = clstr;
                                lstr = '';
                                llen=0;
                                lw=1;
                                newysize=true;
                            end
                        end
                    end
                    if strcmpi(hThis.FirstEdit,'off')
                        % if firstedit is off then finish up the
                        % line.
                        ndlines = ndlines+1;
                        clstr = lstr;
                        dstr{ndlines} = clstr;
                        lstr = '';
                        llen=0;
                        lw=1;
                        newysize=true;
                    end
                else
                    % string still fits in width so may continue line loop.
                    % Set line length to current string width and line string
                    % to test string.
                    lstr = tstr;
                    llen = tsize(1);
                    if w==nwords(i)
                        % reached last word in cell, so finish up
                        ndlines = ndlines+1;
                        clstr = lstr;
                        dstr{ndlines} = clstr;
                        lstr = '';
                        llen=0;
                        lw=1;
                        newysize=true;
                    else
                        lw = lw+1;
                    end
                    w = w+1;
                end
            end
        end
    end

    ysize = max(tysize(2),onecharspace(2)) + 2*hThis.Margin;

    if doresize
        pos(2) = pos(2)+pos(4)-ysize;
        pos(4) = ysize;
        % update x size if needed
        if needxresize
            pos(1) = NewPX-NewPWidth/2;
            pos(3) = NewPWidth;
        end
        pos = hgconvertunits(hFig,pos,'points',get(hThis,'units'),hFig);
        set(hThis,'Position',pos);
    end
    % update associated values
    set(t,'String',dstr);
    hThis.UpdateInProgress = false;
    eventData.affectedObject = hThis;
    localChangePosition([], eventData, false);
end

%----------------------------------------------------------------------%
function size=localGetStrSize(hThis,str)
% gets extents of textbox with whole string

hFig = ancestor(hThis,'Figure');
t = localGetTempText(hFig);

warnState = warning('off','MATLAB:tex');
set(t,...
    'FontAngle',hThis.FontAngle,...
    'FontName',hThis.FontName,...
    'FontWeight',hThis.FontWeight,...
    'String',str,...
    'Interpreter',hThis.Interpreter);
% be sure to set font units and size in correct order
set(t,'FontUnits',hThis.FontUnits)
set(t,'FontSize',hThis.FontSize)
set(t,'Units','points');
normext = get(t,'extent');
warning(warnState);
size(1) = normext(3);
size(2) = normext(4); 

%----------------------------------------------------------------------%
function sizes=localGetStrCellSizes(hThis,str)
% gets x and y extents of strings in textbox
% string cell array.

if isempty(str)
    return;
end

dims = size(str);
ncells = dims(1);

% Get a dummy text object
hFig = ancestor(hThis,'Figure');
t = localGetTempText(hFig);
warnState = warning('off','MATLAB:tex');
set(t,...
    'FontAngle',hThis.FontAngle,...
    'FontName',hThis.FontName,...
    'FontWeight',hThis.FontWeight,...
    'Margin',1,...
    'Interpreter',hThis.Interpreter);
% be sure to set font units and size in correct order
set(t,'FontUnits',hThis.FontUnits)
set(t,'FontSize',hThis.FontSize)
set(t,'units','points');
sizes = zeros(ncells,2);
for i=1:ncells
    % create an invisible text box with string
    % If the string is empty, give some space in case the next line is not
    % empty.
    if ~isempty(str{i})
        set(t,'String',str{i});
    else
        set(t,'String','m');
    end
    normext = get(t,'extent');
    sizes(i,1) = normext(3);
    sizes(i,2) = normext(4); 
end
warning(warnState);

%---------------------------------------------------------------------%
function t = localGetTempText(hFig)
% Returns a dummy text object parented to the scribe axes

hPar = graph2dhelper('findScribeLayer',hFig);
t = getappdata(double(hPar),'ScribeTestText');
if isempty(t) || ~ishandle(t)
    t=text('Units','points',...
        'Visible','off',...
        'HandleVisibility','off',...
        'Editing','off',...
        'Position',[0,0,0],...
        'Margin',1,...
        'Serializable','off',...
        'Parent',double(hPar));
    setappdata(double(hPar),'ScribeTestText',t);
end

%----------------------------------------------------------------------%
function [nw,w]=localCellWords(str)
% Breaks up a string into a cell array where each word is a cell

spaces = isspace(str(:));
nrun=0;
nw=0;
w=cell(1,1);
for j=1:length(spaces)
    if spaces(j)==0
        if nrun==0
            nw = nw+1;
        end
        nrun = nrun+1;
        w{nw}(nrun)=str(j);
    elseif  (j>1 && strcmpi(str(j-1),'.')) || ...
            (j>1 && strcmpi(str(j-1),'''')) || ...
            (j>1 && strcmpi(str(j-1),'?')) || ...
            (j>1 && strcmpi(str(j-1),'!'))
        nrun = nrun + 1;
        w{nw}(nrun)=str(j);
    else
        nrun=0;
    end
end
