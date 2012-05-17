function h=imshow(varargin)
%IMSHOW Display image in Handle Graphics figure.  
%   IMSHOW(I) displays the grayscale image I.
%
%   IMSHOW(I,[LOW HIGH]) displays the grayscale image I, specifying the display
%   range for I in [LOW HIGH]. The value LOW (and any value less than LOW)
%   displays as black, the value HIGH (and any value greater than HIGH) displays
%   as white. Values in between are displayed as intermediate shades of gray,
%   using the default number of gray levels. If you use an empty matrix ([]) for
%   [LOW HIGH], IMSHOW uses [min(I(:)) max(I(:))]; that is, the minimum value in
%   I is displayed as black, and the maximum value is displayed as white.
%
%   IMSHOW(RGB) displays the truecolor image RGB.
%
%   IMSHOW(BW) displays the binary image BW. IMSHOW displays pixels with the
%   value 0 (zero) as black and pixels with the value 1 as white.
%
%   IMSHOW(X,MAP) displays the indexed image X with the colormap MAP.
%
%   IMSHOW(FILENAME) displays the image stored in the graphics file FILENAME.
%   The file must contain an image that can be read by IMREAD or
%   DICOMREAD. IMSHOW calls IMREAD or DICOMREAD to read the image from the file,
%   but does not store the image data in the MATLAB workspace. If the file
%   contains multiple images, the first one will be displayed. The file must be
%   in the current directory or on the MATLAB path.
%
%   HIMAGE = IMSHOW(...) returns the handle to the image object created by
%   IMSHOW.
%
%   IMSHOW(...,PARAM1,VAL1,PARAM2,VAL2,...) displays the image, specifying
%   parameters and corresponding values that control various aspects of the
%   image display. Parameter names can be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'Border'                 String that controls whether
%                            a border is displayed around the image in the
%                            figure window. Valid strings are 'tight' and
%                            'loose'.
%
%                            Note: There can still be a border if the image
%                            is very small, or if there are other objects
%                            besides the image and its axes in the figure.
%                               
%                            By default, the border is set to the value
%                            returned by
%                            IPTGETPREF('ImshowBorder').
%
%   'Colormap'               2-D, real, M-by-3 matrix specifying a colormap. 
%                            IMSHOW uses this to set the figure's colormap
%                            property. Use this parameter to view grayscale
%                            images in false color.
%
%   'DisplayRange'           Two-element vector [LOW HIGH] that controls the
%                            display range of a grayscale image. See above
%                            for more details about how to set [LOW HIGH].
%
%                            Including the parameter name is optional, except
%                            when the image is specified by a filename. 
%                            The syntax IMSHOW(I,[LOW HIGH]) is equivalent to
%                            IMSHOW(I,'DisplayRange',[LOW HIGH]).
%                            The parameter name must be specified when 
%                            using IMSHOW with a filename, as in the syntax
%                            IMSHOW(FILENAME,'DisplayRange'[LOW HIGH]).
%
%   'InitialMagnification'   A numeric scalar value, or the text string 'fit',
%                            that specifies the initial magnification used to 
%                            display the image. When set to 100, the image is 
%                            displayed at 100% magnification. When set to 
%                            'fit' IMSHOW scales the entire image to fit in 
%                            the window.
%
%                            On initial display, the entire image is visible.
%                            If the magnification value would create an image 
%                            that is too large to display on the screen,  
%                            IMSHOW warns and displays the image at the 
%                            largest magnification that fits on the screen.
%
%                            By default, the initial magnification is set to
%                            the value returned by
%                            IPTGETPREF('ImshowInitialMagnification').
%
%                            If the image is displayed in a figure with its
%                            'WindowStyle' property set to 'docked', then
%                            IMSHOW warns and displays the image at the
%                            largest magnification that fits in the figure.
%
%                            Note: If you specify the axes position (using
%                            subplot or axes), imshow ignores any initial
%                            magnification you might have specified and
%                            defaults to the 'fit' behavior.
%
%                            When used with the 'Reduce' parameter, only
%                            'fit' is allowed as an initial magnification.
%
%   'Parent'                 Handle of an axes that specifies
%                            the parent of the image object created
%                            by IMSHOW.
%
%   'Reduce'                 Logical value that specifies whether IMSHOW
%                            subsamples the image in FILENAME. The 'Reduce'
%                            parameter is only valid for TIFF images and
%                            you must specify a filename. Use this
%                            parameter to display overviews of very large
%                            images.
%
%   'XData'                  Two-element vector that establishes a
%                            nondefault spatial coordinate system by
%                            specifying the image XData. The value can
%                            have more than 2 elements, but only the first
%                            and last elements are actually used.
%
%   'YData'                  Two-element vector that establishes a
%                            nondefault spatial coordinate system by
%                            specifying the image YData. The value can
%                            have more than 2 elements, but only the first
%                            and last elements are actually used.
%
%   Class Support
%   -------------  
%   A truecolor image can be uint8, uint16, single, or double. An indexed
%   image can be logical, uint8, single, or double. A grayscale image can
%   be any numeric datatype. A binary image is of class logical.
%
%   If your grayscale image is single or double, the default display range is
%   [0 1]. If your image's data range is much larger or smaller than the default
%   display range, you may need to experiment with setting the display range to
%   see features in the image that would not be visible using the default
%   display range. For all grayscale images having integer types, the default
%   display range is [intmin(class(I)) intmax(class(I))].
%
%   If your image is int8, int16, uint32, int32, or single, the CData in
%   the resulting image object will be double. For all other classes, the
%   CData matches the input image class.
% 
%   Related Toolbox Preferences
%   ---------------------------  
%   You can use the IPTSETPREF function to set several toolbox preferences that
%   modify the behavior of IMSHOW:
%
%   - 'ImshowBorder' controls whether IMSHOW displays the image with a border
%     around it.
%
%   - 'ImshowAxesVisible' controls whether IMSHOW displays the image with the
%     axes box and tick labels.
%
%   - 'ImshowInitialMagnification' controls the initial magnification for
%     image display, unless you override it in a particular call by
%     specifying IMSHOW(...,'InitialMagnification',INITIAL_MAG).
%
%   For more information about these preferences, see the reference entry for
%   IPTSETPREF.
%   
%   Remarks
%   -------
%   IMSHOW is the toolbox's fundamental image display function, optimizing 
%   figure, axes, and image object property settings for image display. IMTOOL
%   provides all the image display capabilities of IMSHOW but also provides 
%   access to several other tools for navigating and exploring images, such as
%   the Pixel Region tool, Image Information tool, and the Adjust Contrast 
%   tool. IMTOOL presents an integrated environment for displaying images and
%   performing some common image processing tasks.
%
%   The imshow function is not supported when MATLAB is started with the
%   -nojvm option.
%
%   Examples
%   --------
%       % Display an image from a file
%       imshow('board.tif') 
%
%       % Display an indexed image
%       [X,map] = imread('trees.tif');
%       imshow(X,map) 
%
%       % Display a grayscale image 
%       I = imread('cameraman.tif');
%       imshow(I) 
%
%       % Display a grayscale image, adjust the display range
%       h = imshow(I,[0 80]);
%
%   See also IMREAD, IMTOOL, IPTPREFS, SUBIMAGE, TRUESIZE, WARP, IMAGE,
%            IMAGESC.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.18 $  $Date: 2008/12/22 23:47:31 $

  if ~isJavaFigure
      eid = sprintf('Images:%s:needJavaFigure',mfilename);
      error(eid,'%s requires Java to run.',upper(mfilename));
  end

  % translate older syntaxes
  varargin_translated = preParseInputs(varargin{:});
  % handle 'Reduce' syntax
  preparsed_varargin = processReduceSyntax(varargin_translated{:});
 
  [common_args,specific_args] = ...
      imageDisplayParseInputs({'Parent','Border','Reduce'},preparsed_varargin{:});
    
  cdata = common_args.CData;
  cdatamapping = common_args.CDataMapping;
  clim = common_args.DisplayRange;
  map = common_args.Map;
  xdata = common_args.XData;
  ydata = common_args.YData;
  initial_mag = common_args.InitialMagnification;
  
    
  if isempty(initial_mag)
    initial_mag = iptgetpref('ImshowInitialMagnification');
  else
    initial_mag = checkInitialMagnification(initial_mag,{'fit'},...
                                            mfilename,'INITIAL_MAG', ...
                                            []);
  end
    
  parent_specified = isfield(specific_args,'Parent');
  if parent_specified
      validateParent(specific_args.Parent)
  end
  
    new_figure = isempty(get(0,'CurrentFigure')) || ...
                 strcmp(get(get(0,'CurrentFigure'), 'NextPlot'), 'new');
       
  if parent_specified
      ax_handle = specific_args.Parent;
  elseif new_figure
      fig_handle = figure('Visible', 'off');
      ax_handle = axes('Parent', fig_handle);
  else
      ax_handle = newplot; 
  end
  fig_handle = ancestor(ax_handle,'figure'); 
  
  do_fit = strcmp(initial_mag,'fit');
  style = get(fig_handle,'WindowStyle');
  if ~do_fit && strcmp(style,'docked')
      wid = sprintf('Images:%s:magnificationMustBeFitForDockedFigure',mfilename);
      warning(wid,'%s%s','The initial magnification of the image is set to',...
              ' ''fit'' in a docked figure.');
      do_fit = true;
  end
  
  hh = basicImageDisplay(fig_handle,ax_handle,...
                         cdata,cdatamapping,clim,map,xdata,ydata);
  set(get(ax_handle,'Title'),'Visible','on');
  set(get(ax_handle,'XLabel'),'Visible','on');
  set(get(ax_handle,'YLabel'),'Visible','on');
  
  single_image = isSingleImageDefaultPos(fig_handle, ax_handle);
    
  border = getBorder(specific_args);
  is_border_tight = strcmp(border,'tight');
  if single_image && do_fit && is_border_tight 
      % Have the image fill the figure.
      set(ax_handle, 'Units', 'normalized', 'Position', [0 0 1 1]);
      axes_moved = true;

  elseif single_image && ~do_fit 
      initSize(hh,initial_mag/100,is_border_tight)
      axes_moved = true;          

  else
      axes_moved = false;
      
  end

  if axes_moved
      % The next line is so that a subsequent plot(1:10) goes back
      % to the default axes position. 
      set(fig_handle, 'NextPlot', 'replacechildren');
  end      
  
  if (nargout > 0)
    % Only return handle if caller requested it.
    h = hh;
  end
  
  if (new_figure)
      set(fig_handle, 'Visible', 'on');
  end

end % imshow

%---------------------------------------------------------------------
function border = getBorder(specific_args)

  border_specified = isfield(specific_args,'Border');
  if ~border_specified
      border = iptgetpref('ImshowBorder');
  else
      valid_borders = {'loose','tight'};
      border = iptcheckstrs(specific_args.Border,valid_borders,mfilename,'BORDER',[]);
  end

end

%----------------------------------------------------------------------
function validateParent(h_parent)
     
     eid = sprintf('Images:%s:invalidAxes',mfilename);
     message = 'HAX must be a valid axes handle.';
     
     if ~ishghandle(h_parent)
         error(eid,message);
     end
     
     parentType = get(h_parent,'type');
     if ~strcmp(parentType,'axes')
         error(eid,message);
     end
end

%----------------------------------------------------------------------
function varargin_translated = preParseInputs(varargin)
% Catch old style syntaxes and warn, as well as validate uses of the
% 'Reduce' param/value pair

% Obsolete syntaxes:
%   IMSHOW(I,N) 
%   N is ignored, gray(256) is always used for viewing grayscale images.
%
%   IMSHOW(...,DISPLAY_OPTION) 
%   DISPLAY_OPTION is translated as follows:
%   'truesize'   -> 'InitialMagnification', 100
%   'notruesize' -> 'InitialMagnification', 'fit'
%
%   IMSHOW(x,y,A,...) 
%   x,y are translated to 'XData',x,'YData',y

new_args = {};
num_args = nargin;

if (num_args == 0)
    eid = sprintf('Images:%s:tooFewArgs',mfilename);
    error(eid,'%s\n%s','IMSHOW expected at least 1 input argument',...
          'but was called instead with 0 input arguments.')
end

if (num_args > 1) && ischar(varargin{end}) 
    % IMSHOW(...,DISPLAY_OPTION)

    str = varargin{end};
    strs = {'truesize', 'notruesize'};
    try
        % If trailing string is not 'truesize' or 'notruesize' jump to
        % catch block and pass trailing string argument to regular input
        % parsing so error will come from that parsing code.
        option = iptcheckstrs(str, strs, mfilename,'DISPLAY_OPTION', nargin);

        % Remove old argument
        varargin(end) = [];  
        num_args = num_args - 1;
    
        % Translate to InitialMagnification
        new_args{1} = 'InitialMagnification';
        if strncmp(option,'truesize',length(option))
            new_args{2} = 100;
            msg1 = 'IMSHOW(...,''truesize'') is an obsolete syntax. ';
            msg2 = 'Use IMSHOW(...,''InitialMagnification'',100) instead.';
        
        else
            new_args{2} = 'fit';
            msg1 = 'IMSHOW(...,''notruesize'') is an obsolete syntax. ';
            msg2 = 'Use IMSHOW(...,''InitialMagnification'',''fit'') instead.';
        
        end

        wid = sprintf('Images:%s:obsoleteSyntaxDISPLAY_OPTION',mfilename);        
        warning(wid,'%s\n%s',msg1,msg2)
    catch ME %#ok<NASGU>
        % Trailing string did not match 'truesize' or 'notruesize' let regular
        % parsing deal with it.
        
        % We are ignoring the error from iptcheckstrs if a valid syntax was
        % used.
    end
end

if (num_args==3 || num_args==4) && ...
            isvector(varargin{1}) && isvector(varargin{2}) && ...
            isnumeric(varargin{1}) && isnumeric(varargin{2})             
    % IMSHOW(x,y,...)

    % Translate to IMSHOW(...,'XData',x,'YData',y)
    p = length(new_args);
    new_args{p+1} = 'XData';
    new_args{p+2} = varargin{1};
    new_args{p+3} = 'YData';
    new_args{p+4} = varargin{2};
    
    % Remove old arguments
    varargin(1:2) = [];
    num_args = num_args - 2;

    wid = sprintf('Images:%s:obsoleteSyntaxXY',mfilename);            
    msg1 = 'IMSHOW(x,y,...) is an obsolete syntax. ';
    msg2 = 'Use IMSHOW(...,''XData'',x,''YData'',y) instead.';    
    warning(wid,'%s%s',msg1,msg2)
end

if num_args == 2 && (numel(varargin{2}) == 1)
    % IMSHOW(I,N)

    wid = sprintf('Images:%s:obsoleteSyntaxN',mfilename);                
    msg1 = 'IMSHOW(I,N) is an obsolete syntax. Your grayscale ';
    msg2 = 'image will be displayed using 256 shades of gray.';
    warning(wid,'%s%s',msg1,msg2)

    % Remove old argument
    varargin(2) = [];
end

varargin_translated = {varargin{:}, new_args{:}};

end


function preparsed_varargin = processReduceSyntax(varargin)
% Handles the 'Reduce' P/V pair in IMSHOW syntaxes.  We have to preparse
% this particular P/V pair before we call imageDisplayParseInputs.

preparsed_varargin = varargin;

% Ignore first position if filenane is a string, looking for p/v pairs.
str_loc = cellfun('isclass',varargin,'char');
str_loc(1) = false;
first_param_loc = find(str_loc,1);
if isempty(first_param_loc)
    return
end

% scan input args looking for 'Reduce' related args
[reduce,xdata,ydata,initmag] = scanArgsForReduce(varargin,...
    first_param_loc);

if reduce
    
    % Make sure we have no parameter conflicts
    checkForReduceErrorConditions(initmag,varargin{:});
    
    % get filename and file info
    filename = varargin{1};
    image_info = imfinfo(filename);
    if numel(image_info) > 1
        image_info = image_info(1);
        wid = sprintf('Images:%s:multiframeFile',mfilename);
        warning(wid,...
            'Can only display one frame from this multiframe file: %s.',...
            filename);
    end
    
    try
        % find sample factor
        [usableWidth usableHeight] = getUsableScreenSize;

        sampleFactor = max(ceil(image_info.Width / usableWidth), ...
            ceil(image_info.Height / usableHeight));
        
        sampled_rows = getReduceSampling(image_info.Height,sampleFactor);
        sampled_cols = getReduceSampling(image_info.Width,sampleFactor);

        [imageData, colormap] = imread(filename, 'PixelRegion', ...
            {[sampled_rows(1) sampleFactor sampled_rows(end)], ...
            [sampled_cols(1) sampleFactor sampled_cols(end)]});
        
        % if we subsample and initmag is not 'fit', warn
        initmag_is_fit = ~isempty(initmag) && strcmpi(initmag,'fit');
        if sampleFactor > 1 && ~initmag_is_fit
            wid = sprintf('Images:%s:reducingImage',mfilename);
            msg = sprintf('Displaying subsampled image (reduced to %s%%).',...
                makeDataPercentString(sampleFactor));
            warning(wid,'%s',msg);
        end
        
        % if we have read an intensity image, do not supply empty map
        if isempty(colormap)
            preparsed_varargin = {imageData,varargin{2:end}};
        else
            preparsed_varargin = {imageData,colormap,varargin{2:end}};
        end
        
    catch %#ok<CTCH>
        eid = sprintf('Images:%s:unableToReduce',mfilename);
        error(eid,'%s is not able to reduce the image %s',...
            mfilename,filename);
    end
    
    % we slightly modify the X & Y Data to take into account the sampling
    % of the image
    new_xdata = adjustXYData(xdata,image_info.Width,sampled_cols);
    p = length(preparsed_varargin);
    preparsed_varargin{p+1} = 'XData';
    preparsed_varargin{p+2} = new_xdata;
    
    new_ydata = adjustXYData(ydata,image_info.Height,sampled_rows);
    p = length(preparsed_varargin);
    preparsed_varargin{p+1} = 'YData';
    preparsed_varargin{p+2} = new_ydata;
    
end

end


function [reduce,xdata,ydata,initmag] = scanArgsForReduce(varargin,...
    first_param_loc)
% Make initial pass through param list.  Check for presence of 'Reduce'
% param/value pair as well as user provided X/YData and InitMag.

reduce = false;
xdata = [];
ydata = [];
initmag = [];
isParam = @(arg,param) ~isempty(strmatch(lower(arg),{param}));
for i = first_param_loc:2:numel(varargin)-1

    % check for provided x/y data
    if isParam(varargin{i},'xdata')
        xdata = varargin{i+1};
    end
    if isParam(varargin{i},'ydata')
        ydata = varargin{i+1};
    end

    % check for initial magnification
    if isParam(varargin{i},'initialmagnification')
        initmag = varargin{i+1};
    end

    % check for reduce
    if isParam(varargin{i},'reduce');
        reduce = varargin{i+1};
        iptcheckinput(reduce,{'numeric','logical'},{'nonempty'},...
            mfilename,'Reduce', i+1);
    end
end

end


function checkForReduceErrorConditions(initmag,varargin)
% checks for several error conditions that can occur with uses of 'Reduce'
% parameter.

% Check for the IMSHOW(FILENAME,...) syntax
filename_syntax = ischar(varargin{1});
if ~filename_syntax
    eid = sprintf('Images:%s:badReduceSyntax',mfilename);
    error(eid,'The Reduce parameter requires a filename syntax');
end
filename = varargin{1};

% Check for supplied 'InitialMagnification' param/value pair
if ~isempty(initmag)
    if isnumeric(initmag)
        eid = sprintf('Images:%s:incompatibleParameters',mfilename);
        error(eid,...
            'When showing reduced image initialMagnification can only be ''fit''');
    end
end

% Verify input file is a TIFF file for Reducing
image_info = imfinfo(filename);
image_info = image_info(1);
if ~strcmpi(image_info.Format,'tif');
    eid = sprintf('Images:%s:badReduceFormat',mfilename);
    error(eid,'The Reduce parameter is only available for TIFF images');
end

end


function string_value = makeDataPercentString(sampleFactor)
% generates magnification string with significant digits that change based
% on the magnitude

actual_val = 100 / sampleFactor;
if actual_val < 1
    string_value = sprintf('%.2f',actual_val);
elseif actual_val < 10
    string_value = sprintf('%.1f',actual_val);
else
    string_value = sprintf('%d',round(actual_val));
end

end


function [usableWidth usableHeight] = getUsableScreenSize
% returns the width and height of the usable screen area.  Assumes 'Border'
% is loose for simplicity

% get the size of screen and the figure decorations
wa = getWorkArea;
p = figparams;

% compute usable area
usableWidth = wa.width - p.horizontalDecorations - p.looseBorderWidth;
usableHeight = wa.height - p.verticalDecorations - p.looseBorderHeight;
  
end


function new_data = adjustXYData(default_data,image_dim,samples)
% adjusts the X and Y data to account for sub sampling.

% provide default XYData if none was specified
if isempty(default_data)
    default_data = [1 image_dim];
end

% verify x/ydata is 2-element numeric
if ~isequal(numel(default_data),2) || ~isnumeric(default_data)
    eid = sprintf('Images:%s:invalidXYData', mfilename);
    error(eid,'XData/YData must be a 2-element vector.');
end

% adjust the endpoints of the X/YData to account for clipped pixels
spatial_to_pixel_ratio = (default_data(2) - default_data(1)) / (image_dim - 1);

% start clipping
first_pixel = samples(1);
removed_pixels = first_pixel - 1;
removed_spatial_units = removed_pixels * spatial_to_pixel_ratio;
first_spatial_coord = default_data(1) + removed_spatial_units;

% end clipping
last_pixel = samples(end);
removed_pixels = image_dim - last_pixel;
removed_spatial_units = removed_pixels * spatial_to_pixel_ratio;
last_spatial_coord = default_data(2) - removed_spatial_units;

new_data = [first_spatial_coord last_spatial_coord];

end
