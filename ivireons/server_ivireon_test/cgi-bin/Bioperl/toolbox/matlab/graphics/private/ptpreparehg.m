function pt = ptpreparehg( pt, h )
%PREPAREHG Method of PrintTemplate object that formats a Figure for output.
%   Input of PrintTemplate object and a Figure to modify on.
%   Figure has numerous properties modified to account for template settings.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.4.4.7 $  $Date: 2008/11/04 21:20:05 $

if (~useOriginalHGPrinting())
    error('MATLAB:Print:ObsoleteFunction', 'The function %s should only be called when original HG printing is enabled.', upper(mfilename));
end

if pt.DebugMode
    disp(sprintf('Preparing Figure %s', num2str(h)))
    pt
end

theAxes = findall( h, 'type', 'axes' );

% Output Axes with same tick MARKS as on screen
if pt.AxesFreezeTicks
    pt.tickState.handles = theAxes; 
    pt.tickState.values = get(theAxes, {'XTickMode','YTickMode','ZTickMode'} );
    set( pt.tickState.handles, {'XTickMode','YTickMode','ZTickMode'}, {'manual','manual','manual'})
end

% Output Axes with same tick LIMITS as on screen
if pt.AxesFreezeLimits
    pt.limState.handles = theAxes; 
    pt.limState.values = get(theAxes, {'XLimMode','YLimMode','ZLimMode'} );
    set( pt.limState.handles, {'XLimMode','YLimMode','ZLimMode'}, {'manual','manual','manual'})
end

% try
if pt.VersionNumber > 1
    allAxes   = findall(h, 'type', 'axes');
    ok = true(size(allAxes));
    for k=1:length(allAxes)
        if isappdata(allAxes(k),'NonDataObject')
            ok(k) = false;
        else
            bh = hggetbehavior(allAxes(k),'DataDescriptor','-peek');
            if ~isempty(bh) && ~get(bh,'Enable')
                ok(k) = false;
            end
        end
    end
    allAxes = allAxes(ok);
    allText = findall(h, 'type', 'text');
    i=1;
    while i<=length(allText)
        if isa(handle(get(allText(i),'parent')), 'scribe.legend')
            allText(i) = [];
            continue;
        end
        i = i+1;
    end
    allLine = findall(h, 'type', 'line');
    allImages = findall(allAxes, 'type', 'image');
    allLights = findall(allAxes, 'type', 'light');
    allPatch  = findall(allAxes, 'type', 'patch');
    allSurf   = findall(allAxes, 'type', 'surface');
    allRect   = findall(allAxes, 'type', 'rectangle');
    allFont   = [allText; allAxes];
    allColor  = [allLine; allText; allAxes; allLights];
    allMarker = [allLine; allPatch; allSurf];
    allEdge   = [allPatch; allSurf; allRect];
    allCData  = [allImages; allSurf];
    allLineObj = [allLine;allEdge;allAxes;allText];
    hgdata.AllAxes = allAxes;
    hgdata.AllText = allFont;
    hgdata.AllPrimitiveText = allText;
    hgdata.AllLine = allLine; 
    hgdata.AllColor = allColor;
    hgdata.AllMarker = allMarker;
    hgdata.AllEdge = allEdge;
    hgdata.AllCData = allCData;
    hgdata.AllLineObj = allLineObj;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Set text properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    try
        err = 0;
        %Font name
        if isfield(pt, 'FontName') && ~isempty(pt.FontName)    
            hgdata.fontname = LocalGetAsCellArray(allFont, 'FontName');
            set(allFont, 'FontName', pt.FontName);
        end
        %Font size
        if isfield(pt, 'FontSizeType')
            hgdata.fontsize = LocalGetAsCellArray(allFont, 'FontSize');
            if strcmp(pt.FontSizeType, 'scale')            
                fontsize = cell2mat(hgdata.fontsize);
                fontsize = fontsize*pt.FontSize/100.0;
                set(allFont, {'FontSize'}, num2cell(fontsize));
            elseif strcmp(pt.FontSizeType, 'fixed')
                set(allFont, 'FontSize', pt.FontSize);
            end
        end
        %Font weight
        if isfield(pt, 'FontWeight') && ~isempty(pt.FontWeight)
            hgdata.fontweight = LocalGetAsCellArray(allFont, 'FontWeight');
            set(allFont, 'FontWeight', pt.FontWeight);
        end
        %Font angle
        if isfield(pt, 'FontAngle') && ~isempty(pt.FontAngle)
            hgdata.fontangle = LocalGetAsCellArray(allFont, 'FontAngle');
            set(allFont, 'FontAngle', pt.FontAngle);
        end
        %Font color
        if isfield(pt, 'FontColor') && ~isempty(pt.FontColor)
            hgdata.fontcolor = LocalGetAsCellArray(allFont, 'Color');
            set(allFont, 'Color', pt.FontColor);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Set line properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Line style
        if isfield(pt, 'LineStyle') && ~isempty(pt.LineStyle)
            hgdata.linestyle = LocalGetAsCellArray(allLine, 'LineStyle');
            if (strcmp(pt.LineStyle, 'cycle'))
                allstyles = {'--', '-', ':', '-.'};
                for i=1:length(allLine)
                    index = mod(i-1, length(allstyles)) + 1;
                    if ~strcmp(get(allLine(i), 'LineStyle'), 'none')
                        set(allLine(i), 'LineStyle', allstyles{index});
                    end
                end
            else
                set(allLine,'LineStyle',pt.LineStyle);
            end
        end
        %Line width & min width
        hgdata.linewidth = LocalGetAsCellArray(allLineObj, 'LineWidth');
        linewidth = cell2mat(hgdata.linewidth);
        if isfield(pt, 'LineWidthType')
            if strcmp(pt.LineWidthType, 'scale')
                linewidth = linewidth*pt.LineWidth/100.0;
            elseif strcmp(pt.LineWidthType, 'fixed')
                linewidth(:) = pt.LineWidth;
            end
        end
        if isfield(pt, 'LineMinWidth') && pt.LineMinWidth>=0    
            indices = (linewidth < pt.LineMinWidth);
            linewidth(indices) = pt.LineMinWidth;    
        end
        set(allLineObj, {'LineWidth'}, num2cell(linewidth));

        %Line color
        if isfield(pt, 'LineColor') && ~isempty(pt.LineColor)    
            hgdata.linecolor = LocalGetAsCellArray(allLineObj, 'Color');
            set(allLineObj, 'Color', pt.LineColor);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set the grayscale & other colors (if required)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %compute and set gray colormap
        if isfield(pt,'DriverColor')    
            if pt.DriverColor == 1 && isfield(pt, 'GrayScale') && pt.GrayScale==1
                oldcmap = get(h,'Colormap');
                newgrays = 0.30*oldcmap(:,1) + 0.59*oldcmap(:,2) + 0.11*oldcmap(:,3);
                newcmap = [newgrays newgrays newgrays];
                hgdata.colormap = oldcmap;    
                set(h, 'Colormap', newcmap);

                hgdata.Color = LocalUpdateColors(allColor, 'Color');
                hgdata.XColor = LocalUpdateColors(allAxes, 'XColor');
                hgdata.YColor = LocalUpdateColors(allAxes, 'YColor');
                hgdata.ZColor = LocalUpdateColors(allAxes, 'ZColor');
                hgdata.MarkerEdgeColor = LocalUpdateColors(allMarker, 'MarkerEdgeColor');
                hgdata.MarkerFaceColor = LocalUpdateColors(allMarker, 'MarkerFaceColor');
                hgdata.EdgeColor = LocalUpdateColors(allEdge, 'EdgeColor');
                hgdata.FaceColor = LocalUpdateColors(allEdge, 'FaceColor');
                hgdata.PrimitiveTextBackgroundColor = LocalUpdateColors(allText, 'BackgroundColor');
                hgdata.CData = LocalUpdateColors(allCData, 'CData');
            end
        end

        if strcmp('off', get(h,'InvertHardcopy')) && isfield(pt, 'BkColor') && ~isempty(pt.BkColor)          
            hgdata.BkColor = get(h, 'Color');
            if any(pt.BkColor == '[')
                pt.BkColor = str2num(pt.BkColor);
            end
            set(h, 'Color', pt.BkColor');
        end
    catch ex
        err = 1;
    end

    pt.v2hgdata = hgdata;
        
    % If there's a failure, still propegate the error up. But roll back all
    % changes made to the figure FIRST.
    if err
        ptrestorehg( pt, h );
        rethrow( ex );
    end
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = LocalGetAsCellArray(h, prop)
res = get(h, prop);
if length(h) == 1
    res = {res};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function gray = LocalMapToGray1(color)
gray = color;
if ischar(color)
  switch color(1)
   case 'y'
    color = [1 1 0];
   case 'm'
    color = [1 0 1];
   case 'c'
    color = [0 1 1];
   case 'r'
    color = [1 0 0];
   case 'g'
    color = [0 1 0];
   case 'b'
    color = [0 0 1];
   case 'w'
    color = [1 1 1];
   case 'k'
    color = [0 0 0];
  end
end
if ~ischar(color)
  gray = 0.30*color(1) + 0.59*color(2) + 0.11*color(3);
end

function newArray = LocalMapToGray(inArray)
n = length(inArray);
newArray = cell(n,1);
for k=1:n
  color = inArray{k};
  if ~isempty(color)
    color = LocalMapToGray1(color);
  end
  if isempty(color) || ischar(color)
    newArray{k} = color;
  else
    newArray{k} = [color color color];
  end
end

function newArray = LocalMapCData(inArray)
n = length(inArray);
newArray = cell(n,1);
for k=1:n
  color = inArray{k};
  if (ndims(color) == 3) && isa(color,'double')
    gray = 0.30*color(:,:,1) + 0.59*color(:,:,2) + 0.11*color(:,:,3);
    color(:,:,1) = gray;
    color(:,:,2) = gray;
    color(:,:,3) = gray;
  end
  newArray{k} = color;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function oldvalue = LocalUpdateColors(inArray, prop)
oldvalue = LocalGetAsCellArray(inArray,prop);
if (~isempty(oldvalue))
  if strcmp(prop,'CData') 
    newvalue = LocalMapCData(oldvalue);
  else
    newvalue = LocalMapToGray(oldvalue);
  end
  set(inArray,{prop},newvalue);
end
