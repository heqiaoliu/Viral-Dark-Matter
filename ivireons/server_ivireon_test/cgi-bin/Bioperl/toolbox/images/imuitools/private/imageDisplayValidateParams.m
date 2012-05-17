function common_args = imageDisplayValidateParams(common_args)
%imageDisplayValidateParams Validate and set defaults of image display
%functions.
%   commonArgs = imageDisplayValidateParams(commonArgs) validate commonArgs
%   structure returned by imageDisplayParsePVPairs. Set default values for
%   unspecified parameters and validate specified parameters.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/26 14:25:14 $

% Make sure CData is numeric before going any further.
iptcheckinput(common_args.CData, {'numeric','logical'},...
    {'nonsparse'}, ...
    mfilename, 'I', 1);

if isempty(common_args.XData)
    common_args.XData = [1 size(common_args.CData,2)];
end

if isempty(common_args.YData)
    common_args.YData = [1 size(common_args.CData,1)];
end

% Validate XData YData
checkCoords(common_args.XData,'XDATA');
checkCoords(common_args.YData,'YDATA');

image_type = findImageType(common_args.CData,common_args.Map);

% validate CData and any user supplied Colormap
common_args.CData = validateCData(common_args.CData,image_type);
common_args.Map = validateMap(common_args.Map,common_args.Colormap,...
    image_type);

% we now only need a single 'Map' field, so we remove 'Colormap'
common_args = rmfield(common_args,'Colormap');

common_args.CDataMapping = getCDataMapping(image_type);

if strcmp(common_args.DisplayRange,'auto')
    common_args.DisplayRange = getAutoCLim(common_args.CData);
end

if strcmp(common_args.CDataMapping,'scaled')
    
    % set colormap if user did not provide one
    if isempty(common_args.Map)
        common_args.Map = gray(256);
    end

    if isempty(common_args.DisplayRange) || ...
            (common_args.DisplayRange(1) == common_args.DisplayRange(2))
        common_args.DisplayRange = getrangefromclass(common_args.CData);
    end
end

common_args.DisplayRange = checkDisplayRange(common_args.DisplayRange,mfilename);

%---------------------------------
function clim = getAutoCLim(cdata)

clim = double([min(cdata(:)) max(cdata(:))]);
        
%----------------------------------------------------
function [cdatamapping] = getCDataMapping(image_type)

cdatamapping = 'direct';

% cdatamapping is not relevant for RGB images, but we set it to something so
% we can call IMAGE with one set of arguments no matter what image type.

% May want to treat binary images as 'direct'-indexed images for display
% in HG which requires no map.
%
% For now, they are treated as 'scaled'-indexed images for display in HG.

switch image_type
    case {'intensity','binary'}
        cdatamapping = 'scaled';

    case 'indexed'
        cdatamapping = 'direct';

end

%-----------------------------------------------
function map = validateMap(map,user_cmap,image_type)

% use user supplied colormap if possible
if ~isempty(user_cmap)
    map = user_cmap;
end

% discard provided maps for truecolor images
if ~isempty(map) && strcmp(image_type,'truecolor');
    wid = sprintf('Images:%s:colormapWithTruecolor',mfilename);
    warning(wid,'%s','Ignoring ''Colormap'' parameter provided with a truecolor image.');
    map = [];
end

% colormap must be m-by-3 matrix of numeric
if ~isempty(map)
    if ~isequal(ndims(map),2) || ~isequal(size(map,2),3) || ~isnumeric(map)
        eid = sprintf('Images:%s:invalidColormap',mfilename);
        error(eid,'%s','Colormap must be an m-by-3 numeric matrix.')
    end
end

%-----------------------------------------------
function cdata = validateCData(cdata,image_type)

if ((ndims(cdata) > 3) || ((size(cdata,3) ~= 1) && (size(cdata,3) ~= 3)))
    eid = sprintf('Images:%s:unsupportedDimension',mfilename);
    error(eid, '%s', 'Unsupported dimension')
end

if islogical(cdata) && (ndims(cdata) > 2)
    eid = sprintf('Images:%s:expected2D',mfilename);
    error(eid, '%s', 'If input is logical (binary), it must be two-dimensional.');
end

% RGB images can be only be uint8, uint16, single, or double
if ( (ndims(cdata) == 3)   && ...
        ~isa(cdata, 'double') && ...
        ~isa(cdata, 'uint8')  && ...
        ~isa(cdata, 'uint16') && ...
        ~isa(cdata, 'single') )
    eid = sprintf('Images:%s:invalidRGBClass',mfilename);
    msg = 'RGB images must be uint8, uint16, single, or double.';
    error(eid,'%s',msg);
end

if strcmp(image_type,'indexed') && isa(cdata,'int16')
    eid = sprintf('Images:%s:invalidIndexedImage',mfilename);
    msg1 = 'An indexed image can be uint8, uint16, double, single, or ';
    msg2 = 'logical.';
    error(eid,'%s %s',msg1, msg2);
end

% Clip double and single RGB images to [0 1] range
if ndims(cdata) == 3 && ( isa(cdata, 'double') || isa(cdata,'single') )
    cdata(cdata > 1) = 1;
    cdata(cdata < 0) = 0;
end

% Catch complex CData case
if (~isreal(cdata))
    wid = sprintf('Images:%s:displayingRealPart',mfilename);
    warning(wid, '%s', 'Displaying real part of complex input.');
    cdata = real(cdata);
end

%----------------------------------------
function checkCoords(coords,coord_string)

iptcheckinput(coords, {'numeric'}, {'real' 'nonsparse' 'finite' 'vector'}, ...
    mfilename, coord_string, []);

if numel(coords) < 2
    eid = sprintf('Images:%s:need2Coords', mfilename);
    error(eid,'%s must be a 2-element vector.',coord_string);
end

%----------------------------------------
function imgtype = findImageType(img,map)

if (isempty(map))
    if ndims(img) == 3
        imgtype = 'truecolor';
    elseif islogical(img)
        imgtype = 'binary';
    else
        imgtype = 'intensity';
    end
else
    imgtype = 'indexed';
end
