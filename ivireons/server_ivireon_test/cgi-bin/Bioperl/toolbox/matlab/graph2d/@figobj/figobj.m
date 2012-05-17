function fObj = figobj(varargin)
%FIGOBJ/FIGOBJ Make figobj object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2005 The MathWorks, Inc. 
%   $Revision: 1.17.4.2 $  $Date: 2005/09/12 18:58:29 $

switch nargin
case 0
   fObj.Class = 'figobj';
   fObj.SavedState = [];
   fObj.Notes = [];
   fObj.Date = [];
   fObj.DragObjects = [];
   fObj.aChild = [];
   fObj.Origin = [];
   fObj.SavedPosition = [];
   fObj = class(fObj,'figobj',scribehgobj);
   return
case 1
   HG = varargin{1};
   set(HG,...
           'ResizeFcn','doresize(gcbf)',...
           'KeyPressFcn','dokeypress(gcbf)');
otherwise
   HG = figure(varargin{:},...
           'ResizeFcn','doresize(gcbf)',...
           'KeyPressFcn','dokeypress(gcbf)');
end

hgObj = scribehgobj(HG);

t = clock;
fObj.Class = 'figobj';
fObj.SavedState = [];
fObj.Notes = [];
fObj.Date = [int2str(t(2)) '/' int2str(t(3)) '/' int2str(t(1))];
u = uimenu(...
        'Parent',HG,...
        'Visible','off',...
        'HandleVisibility','off',...
        'Tag','ScribeHGBinObject');
fObj.DragObjects = scribehandle(hgbin(u));
fObj.aChild = u;

% Default origin is LL for lower left. Use subsasgn to change to UL.
fObj.Origin = 'LL';
savedunits = get(HG,'Units');
if ~strcmpi(savedunits,'pixels');
   set(HG,'Units','pixels')
   fObj.SavedPosition = get(HG,'Position');
   set(HG,'Units',savedunits);
else
   fObj.SavedPosition = get(HG,'Position');
end


fObj = class(fObj,'figobj',hgObj);
