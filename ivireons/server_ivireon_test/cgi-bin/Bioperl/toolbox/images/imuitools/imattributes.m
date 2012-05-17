function attributes = imattributes(varargin)
%IMATTRIBUTES Information about image attributes.
%   ATTRS = IMATTRIBUTES returns information about an image in the current
%   figure.  If the current figure doesn't contain an image, IMATTRIBUTES
%   returns an empty array.
%  
%   ATTRS = IMATTRIBUTES(HIMAGE) returns information about the image
%   specified by HIMAGE, a handle to an image object. IMATTRIBUTES gets the
%   attribute information by querying the image object's CData. 
%
%   IMATTRIBUTES returns image attribute information in ATTRS, a 4-by-2 or
%   6-by-2 cell array, depending on the image type. The first column of ATTRS
%   contains the name of the attribute as a text string (listed below). The 
%   second column contains the value of the attribute, also represented as 
%   a text string.
%
%   Attribute                 Description
%   ----------------------------------------------------------------------
%   'Width (columns)'         Number of columns in image
%
%   'Height (rows)'           Number of rows in image
%
%   'Class'                   Data type used by image, such as uint8
%                             NOTE: For images of type single or int16,
%                             IMATTRIBUTES returns class double, because
%                             image objects convert CData of these classes
%                             to class double.
%
%   'Image type'              One of the image types identified by the
%                             Image Processing Toolbox: 'intensity',
%                             'truecolor','binary', or 'indexed'
%
%   'Minimum intensity'       For intensity images, value represents lowest
%                             intensity value of any pixel. For indexed images,
%                             value represents lowest index value into colormap
%                             Not included for 'binary' or 'truecolor' images.
%
%   'Maximum intensity'       For intensity images, value represents highest
%                             intensity value of any pixel. For indexed images,
%                             value represents highest index value into colormap.
%                             Not included for 'binary' or 'truecolor' images.
%
%   ATTRIBUTES =  IMATTRIBUTES(IMGMODEL) returns information about the image
%   represented by the image model object, IMGMODEL. 
%
%   Examples
%   --------
%       % Retrieve attribute information from intensity image.
%       imshow('liftingbody.png');
%       attrs = imattributes
%
%       % Retrieve attribute information from image model.
%       h = imshow('gantrycrane.png');
%       im = imagemodel(h);
%       attrs = imattributes(im)
%
%   See also GETIMAGEMODEL, IMAGEMODEL.

%   Copyright 1993-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2008/12/22 23:47:12 $

imgModel = parseInputs(varargin{:});

if isempty(imgModel)
  attributes = [];
else
  [fnames,values] = getDetailsFromImagemodel(imgModel);
  attributes = [fnames values];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [names,valueStrings] = getDetailsFromImagemodel(imgModel)

% default
names = {'Width (columns)'
    'Height (rows)'
    'Class'
    'Image type'};

imageType = getImageType(imgModel);

valueStrings = {sprintf('%d',getImageWidth(imgModel))
    sprintf('%d',getImageHeight(imgModel))
    getClassType(imgModel)
    imageType};

if strcmp(imageType,'intensity') || strcmp(imageType,'indexed')

    if strcmp(imageType,'intensity')
        names{5} = 'Minimum intensity';
        names{6} = 'Maximum intensity';
    else
        names{5} = 'Minimum index';
        names{6} = 'Maximum index';
    end
    formatNumber = getNumberFormatFcn(imgModel);
    valueStrings{5} = formatNumber(getMinIntensity(imgModel));
    valueStrings{6} = formatNumber(getMaxIntensity(imgModel));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function im = parseInputs(varargin)

iptchecknargin(0,1,nargin,mfilename);

if nargin == 0
  f = get(0,'CurrentFigure');
  if isempty(f)
    im = [];
  else
    h = imhandles(f);
    if isempty(h)
      im = [];
    elseif numel(h) > 1
      wid = sprintf('Images:%s:multipleImageHandles',mfilename);
      msg = 'IMATTRIBUTES expected one image in the current figure.';
      msg2 = 'Using the first image.';
      warning(wid,'%s\n%s',msg,msg2);
      im = getimagemodel(h(1));
    else
      im = getimagemodel(h);
    end
  end
  
elseif ishghandle(varargin{1})
    if ~isscalar(varargin{1}) || ~ishghandle(varargin{1},'image')
        eid = sprintf('Images:%s:invalidImageHandle',mfilename);
        msg = 'HIMAGE must be a valid handle to an image object.';
        error(eid,'%s',msg);
    else
        im = getimagemodel(varargin{1});
    end

elseif strcmp(class(varargin{1}),'imagemodel')
    im = varargin{1};

else
    eid = sprintf('Images:%s:invalidInputArgument',mfilename);
    msg = 'The first input argument must be a valid image handle ';
    msg2 = 'or imagemodel object.';
    error(eid,'%s%s',msg,msg2);
end
