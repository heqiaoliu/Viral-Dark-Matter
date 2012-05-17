function [runtimeSize, margins] = getRuntimeSize(this)
    
    % Copyright 2010 The Mathworks, Inc
    
    vE = this.RuntimeViewExtents;
    if isempty(vE)
        vE = this.getRuntimeViewExtents();
    end
    
    orient = this.RuntimeOrientation;
    if isempty(orient)
        orient = this.getRuntimeOrientation();
    end
    
    calloutList = this.RuntimeCalloutList;
    if isempty(calloutList)
        calloutList = this.getRuntimeCalloutList();
    end
    hasCallouts = ~isempty(calloutList);
    
    switch this.SizeMode
        case 'scaled'
            maxSize = locGetSize(this, this.MaxSize, orient);
            [runtimeSize, margins] = locGetScaledSize(this, ...
                this.Zoom/100, ...
                maxSize, ...
                hasCallouts, ...
                vE);

        case 'fixed'
            fixedSize = locGetSize(this, this.FixedSize, orient);
            [runtimeSize, margins] = locGetFixedSize(this, ...
                fixedSize, ...
                hasCallouts, ...
                vE);
            
            % Resize to 100% if we are fixed, and non-tight (paper print behavior)
            if (~this.IsTight && ~this.IsExpandToFit)
                margins = locResizeViewToOrigSize( ...
                    runtimeSize, ...
                    margins, ...
                    vE);
            end
            
        otherwise %auto
            autoSize = locGetAutoSize(this, orient);
            [runtimeSize, margins] = locGetScaledSize(this, ...
                1, ...  % scale
                autoSize, ...
                hasCallouts, ...
                vE);
    end

 end

%-------------------------------------------------------------------------------
function out = locGetSize(this, in, orient)

    out = this.convertToPixels(in, this.Units);
    if ~strcmp(orient, 'portrait')
        % landscape, rotated
        out = fliplr(out);
    end

end

%-------------------------------------------------------------------------------
function [imgSize, margins]= locGetScaledSize(this, scale, maxSize, hasCallouts, vE)
    
    % Get scaled size
    srcSize = scale * vE.scale * vE.viewBox(3:4);
    
    % Get margins based on source size
    marginInfo = locGetMarginInfo(this, hasCallouts);
    margins = locGetMargins(srcSize, marginInfo);

    % Add frame and white space to get final size
    imgSize = srcSize + [(margins.left + margins.right), ...
                         (margins.top  + margins.bottom)];
   
    % Resize if we are too big
    [imgSize, margins] = locResizeToNotExceedMaxSize(...
        imgSize, margins, maxSize, marginInfo);
    
end

%-------------------------------------------------------------------------------
function [imgSize, margins] = locGetFixedSize(this, fixedSize, hasCallouts, vE)

    % Calculate tight size
    aspectRatio = vE.viewBox(3) / vE.viewBox(4);

    marginInfo = locGetMarginInfo(this, hasCallouts);

    % Do not count frame and white space to get tight size
    tWidth = (fixedSize(1) - marginInfo.Fixed.left - marginInfo.Fixed.right) ...
              / ( 1 + marginInfo.Variable.left + marginInfo.Variable.right); 
    tHeight = tWidth / aspectRatio;
    tightSrcSize = [tWidth tHeight];
    
    % Get new margin
    tightMargins = locGetMargins(tightSrcSize, marginInfo);
    
    % Add frame and white space to get final size
    tightSize = tightSrcSize + [(tightMargins.left + tightMargins.right), ...
                                (tightMargins.top  + tightMargins.bottom)];    
    
    % Resize if we are too big
    [tightSize, tightMargins] = locResizeToNotExceedMaxSize( ...
        tightSize, tightMargins, fixedSize, marginInfo);

    if this.IsTight
        imgSize = tightSize;
        margins = tightMargins;

    else
        % Caculate margins by subtracting out the tight size.  This will center
        % the source.
        imgSize = fixedSize;
        space = (fixedSize - tightSize)/2;
        margins.top    = space(2) + tightMargins.top;
        margins.left   = space(1) + tightMargins.left;
        margins.bottom = space(2) + tightMargins.bottom;
        margins.right  = space(1) + tightMargins.right;
    end
end    

%-------------------------------------------------------------------------------
function autoSize = locGetAutoSize(this, orient)
    % Auto size is based off the src's paper type

    % Get paper type
    src = this.Source;
    if isa(src, 'Simulink.Object')
        paperType = src.PaperType;
    else % Stateflow.Object
        if isa(src, 'Stateflow.Chart')
            paperType = src.PaperType;
        else
            paperType = src.Chart.PaperType;
        end
    end

    paperSize = locGetPaperSize(this,paperType,orient);
                                 
    % Adjust for a one inch margin
    autoMargins = this.convertToPixels(1, 'inches');
    autoSize = paperSize - 2*autoMargins;
end

%-------------------------------------------------------------------------------
function paperSize = locGetPaperSize(this,paperType, orientation)
    switch lower(paperType)
        case 'usletter'
            paperSize = [8.5 11];
            paperUnits = 'inches';
        case 'uslegal'
            paperSize = [8.5 14];
            paperUnits = 'inches';
        case 'tabloid'
            paperSize = [11 17];
            paperUnits = 'inches';
        case 'a0'
            paperSize = [841 1189];
            paperUnits = 'mm';
        case 'a1'
            paperSize = [594 841];
            paperUnits = 'mm';
        case 'a2'
            paperSize = [420 594];
            paperUnits = 'mm';
        case 'a3'
            paperSize = [297 420];
            paperUnits = 'mm';
        case 'a4'
            paperSize = [210 297];
            paperUnits = 'mm';
        case 'a5'
            paperSize = [148 210];
            paperUnits = 'mm';
        case 'b0'
            paperSize = [1029 1456];
            paperUnits = 'mm';
        case 'b1'
            paperSize = [728 1028];
            paperUnits = 'mm';
        case 'b2'
            paperSize = [514 728];
            paperUnits = 'mm';
        case 'b3'
            paperSize = [364 514];
            paperUnits = 'mm';
        case 'b4'
            paperSize = [257 364];
            paperUnits = 'mm';
        case 'b5'
            paperSize = [182 257];
            paperUnits = 'mm';
        case 'arch-a'
            paperSize = [9 12];
            paperUnits = 'inches';
        case 'arch-b'
            paperSize = [12 18];
            paperUnits = 'inches';
        case 'arch-c'
            paperSize = [18 24];
            paperUnits = 'inches';
        case 'arch-d'
            paperSize = [24 36];
            paperUnits = 'inches';
        case 'arch-e'
            paperSize = [36 48];
            paperUnits = 'inches';
        case 'a'
            paperSize = [8.5 11];
            paperUnits = 'inches';
        case 'b'
            paperSize = [11 17];
            paperUnits = 'inches';
        case 'c'
            paperSize = [17 22];
            paperUnits = 'inches';
        case 'd'
            paperSize = [22 34];
            paperUnits = 'inches';
        case 'e'
            paperSize = [34 43];
            paperUnits = 'inches';
            
        otherwise
            error('DAStudio:Snapshot:UnknownPaperSize',...
                'Unknown paper size');
    end
    
    paperSize = this.convertToPixels(paperSize,paperUnits);
    
    % If not landscape, width is the height, height is the width.
    if ~strncmpi(orientation,'p',1)
        paperSize = fliplr(paperSize);
    end
end

%-------------------------------------------------------------------------------
function [newSize, newMargins] = locResizeToNotExceedMaxSize(origSize, origMargins, maxSize, marginInfo)
    % Resize image size to not exceed max size while maintaining source aspect
    % ratio.

    aspectRatio = (origSize(1) - origMargins.left - origMargins.right) ...
                   / (origSize(2) - origMargins.top - origMargins.bottom);

    if (origSize(1) > maxSize(1))
        newScale = (1 - marginInfo.Variable.left - marginInfo.Variable.right);
        scWidth  = maxSize(1) * newScale - marginInfo.Fixed.left - marginInfo.Fixed.right;
        scHeight = scWidth / aspectRatio;
        scaledSrcSize = [scWidth scHeight];
        
        newMargins = locGetMargins(scaledSrcSize, marginInfo);
        newWidth   = maxSize(1);
        newHeight  = scaledSrcSize(2) + newMargins.top + newMargins.bottom;
        newSize    = [newWidth newHeight];
    
    else
        newSize = origSize;
        newMargins = origMargins;

    end
        
    if (newSize(2) > maxSize(2))
        newScale = (1 - marginInfo.Variable.top - marginInfo.Variable.bottom);
        scHeight = maxSize(2) * newScale - marginInfo.Fixed.top - marginInfo.Fixed.bottom;
        scWidth  = scHeight * aspectRatio;
        scaledSrcSize = [scWidth scHeight];
        
        newMargins = locGetMargins(scaledSrcSize, marginInfo);
        newHeight  = maxSize(2);
        newWidth   = scaledSrcSize(1) + newMargins.left + newMargins.right;
        newSize    = [newWidth newHeight];
    end
    
end

%-------------------------------------------------------------------------------
function margins = locGetMargins(srcSize, marginInfo)

    ws = marginInfo.WhiteSpace;
    cs = marginInfo.CalloutSpace;
    sysRectSize = srcSize + [(ws.left + ws.right + cs), ...
                             (ws.top + ws.bottom + cs)];
    
    margins.top    = marginInfo.Fixed.top    + marginInfo.Variable.top    * sysRectSize(2);
    margins.left   = marginInfo.Fixed.left   + marginInfo.Variable.left   * sysRectSize(1);
    margins.bottom = marginInfo.Fixed.bottom + marginInfo.Variable.bottom * sysRectSize(2);
    margins.right  = marginInfo.Fixed.right  + marginInfo.Variable.right  * sysRectSize(1);
end

%-------------------------------------------------------------------------------
function marginInfo = locGetMarginInfo(this, hasCallouts)

    % Account for white space between frame or sys
    whiteSpace = this.convertToPixels(this.WhiteSpace, this.Units);
    WhiteSpaceStruct.top    = whiteSpace(1);
    WhiteSpaceStruct.left   = whiteSpace(2);
    WhiteSpaceStruct.bottom = whiteSpace(3);
    WhiteSpaceStruct.right  = whiteSpace(4); 
    
    % Account for callout space
    if hasCallouts
        marginInfo.CalloutSpace = this.convertToPixels(this.CalloutSpace, this.Units);
    else
        marginInfo.CalloutSpace = 0;
    end

    % Get frame information
    frameFile = '';
    if this.AddFrame
        frameFile = this.FrameFile;
    end
    frameObj = DAStudio.Frame('FrameFile', frameFile);
    frameMarginInfo = frameObj.FrameInfo;
    
    % Fixed
    marginInfo.Fixed.top = WhiteSpaceStruct.top ...
                           + marginInfo.CalloutSpace ...
                           + frameMarginInfo.PaperMargin.top;
    marginInfo.Fixed.left = WhiteSpaceStruct.left ...
                            + marginInfo.CalloutSpace ...
                            + frameMarginInfo.PaperMargin.left;
    marginInfo.Fixed.bottom = WhiteSpaceStruct.bottom ...
                              + marginInfo.CalloutSpace ...
                              + frameMarginInfo.PaperMargin.bottom;
    marginInfo.Fixed.right = WhiteSpaceStruct.right ...
                             + marginInfo.CalloutSpace ...
                             + frameMarginInfo.PaperMargin.right;
    
    % Variable
    marginInfo.Variable = frameMarginInfo.Frame;
    
    % Whitespace
    marginInfo.WhiteSpace = WhiteSpaceStruct;
end

%-------------------------------------------------------------------------------
function margins = locResizeViewToOrigSize(runtimeSize, margins, viewExtent)
    
    srcSize.width = runtimeSize.width - margins.left - margins.right;
    srcSize.height = runtimeSize.height - margins.top - margins.bottom;
    
    unScaleViewSize.width = viewExtent.width * viewExtent.scale;
    unScaleViewSize.height = viewExtent.height * viewExtent.scale;

    diff.width = srcSize.width - unScaleViewSize.width;
    diff.height = srcSize.height - unScaleViewSize.height;
    
    if (diff.width > 0) && (diff.height > 0)
        margins.top    = margins.top    + diff.height/2;
        margins.left   = margins.left   + diff.width/2;
        margins.bottom = margins.bottom + diff.height/2;
        margins.right  = margins.right  + diff.width/2;
    end
   
end
