function selectedColor = uisetcolor_helper(varargin)
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/12/15 08:54:00 $
[rgbColorVector,title,fhandle] = parseArgs(varargin{:});

ccDialog = UiDialog.UiColorChooser;
ccDialog.Title = title;
if ~isempty(rgbColorVector)
    ccDialog.InitialColor = rgbColorVector;
end

selectedColor = showDialog(ccDialog);

if (~isempty(rgbColorVector) && ~(size(selectedColor,2)==3))
    selectedColor = rgbColorVector;
end

if  ~isempty(fhandle)
    try
        set(fhandle,'Color',selectedColor);
    catch
        try
            set(fhandle,'ForeGroundColor',selectedColor);
        catch
            try
                set(fhandle,'BackGroundColor',selectedColor);
            catch
            end
        end
    end

end
% Done. MCOS Object ccDialog cleans up and its java peer at the end of its
% scope(AbstractDialog has a destructor that every subclass
% inherits)

function [rgbColorVector,title,handle] = parseArgs(varargin)
handle = [];
rgbColorVector = [];
title = 'Color';
if nargin>2
    error('MATLAB:uisetcolor:TooManyInputs',  'Too many input arguments.' ) ;
end
if (nargin==2)
    if ~ischar(varargin{2})
        error('MATLAB:uisetcolor:InvalidParameter','Second argument (dialog title) must be a string.');
    end
    title = varargin{2};
end
if  (nargin>=1)
    if (isscalar(varargin{1}) && ishghandle(varargin{1}))
        handle = varargin{1};
        rgbColorVector = getrgbColorVectorFromHandle(handle);
    elseif (~ischar(varargin{1}) && isnumeric(varargin{1})) 
        rgbColorVector = varargin{1};
    elseif ischar(varargin{1})
        if (nargin > 1)
            error('MATLAB:uisetcolor:InvalidParameterList','Title should be the second arg');
        end
        title = varargin{1};
    else
        error('MATLAB:uisetcolor:InvalidParameter','The first arg should be a handle or vector or title string');
    end
end

%Given the dialog, user chooses to select or not select
function rgbColorVector = showDialog(ccDialog)
ccDialog.show;
rgbColorVector = ccDialog.SelectedColor;
if isempty(rgbColorVector)
    rgbColorVector = 0;
end


%Helper functions to extract color(rgbColorVector) from the given handle


function rgbValue = getrgbColorVectorFromHandle(fhandle)
rgbValue = [0 0 0];
try
    rgbValue = get(fhandle,'color');
catch
    try
        rgbValue = get(fhandle,'foregroundcolor');
    catch
        try
            rgbValue = get(fhandle,'backgroundcolor');
        catch
        end
    end
end

