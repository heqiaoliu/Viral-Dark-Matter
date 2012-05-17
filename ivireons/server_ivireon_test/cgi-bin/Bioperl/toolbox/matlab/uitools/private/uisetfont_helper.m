function fontstruct = uisetfont_helper(varargin)
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/12/15 08:54:02 $
[fontstruct,title,fhandle] = parseArgs(varargin{:});

fcDialog = UiDialog.UiFontChooser;
fcDialog.Title = title;
if ~isempty(fontstruct)
    fcDialog.InitialFont = fontstruct;
end

fontstruct = showDialog(fcDialog);

if  ~isempty(fhandle)
    setPointFontOnHandle(fhandle,fontstruct);
end

% Done. MCOS Object fcDialog cleans up and its java peer at the end of its
% scope(AbstractDialog has a destructor that every subclass
% inherits)
function [fontstruct,title,handle] = parseArgs(varargin)
handle = [];
fontstruct = [];
title = xlate('Font', '-s');
if nargin>2
    error('MATLAB:uisetfont:TooManyInputs',  'Too many input arguments.' ) ;
end
if (nargin==2)
    if ~ischar(varargin{2})
        error('MATLAB:uisetfont:InvalidParameter','Title should be of type string');
    end
    title = varargin{2};
end
if  (nargin>=1)
    if ishghandle(varargin{1})
        handle = varargin{1};
        fontstruct = getPointFontFromHandle(handle);
    elseif isstruct(varargin{1})
        fontstruct = varargin{1};
    elseif ischar(varargin{1})
        if (nargin > 1)
            error('MATLAB:uisetfont:InvalidParameterList','Title should be the second arg');
        end
        title = varargin{1};
    else
        error('MATLAB:uisetfont:InvalidParameter','The first arg should be a handle or struct or title string');
    end
end

%Given the dialog, user chooses to select or not select
function fontstruct = showDialog(fcDialog)
fcDialog.show;
fontstruct = fcDialog.SelectedFont;
if isempty(fontstruct)
    fontstruct = 0;
end


%Helper functions to convert font sizes based on the font units of the
%handle object
function setPointFontOnHandle(fhandle,fontstruct)
tempunits = get(fhandle,'FontUnits');
try
    set(fhandle,fontstruct);
catch
end
set(fhandle,'FontUnits',tempunits);

function fs = getPointFontFromHandle(fhandle)
tempunits = get(fhandle,'FontUnits');
set(fhandle, 'FontUnits', 'points');
fs = [];
try
    fs.FontName = get(fhandle, 'FontName');
    fs.FontWeight = get(fhandle, 'FontWeight');
    fs.FontAngle = get(fhandle, 'FontAngle');
    fs.FontUnits = get(fhandle, 'FontUnits');
    fs.FontSize = get(fhandle, 'FontSize');
catch
end
set(fhandle, 'FontUnits', tempunits);