function outval = dfgetset(varname,inval)
%DFGETSET Get or set a distribution fitting persistent variable

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:13:19 $
%   Copyright 2001-2008 The MathWorks, Inc.

% Get handle to Distribution Fitting figure, usually required later on
oldval = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');
c = get(0,'Children');
dffig = findobj(c,'flat','Type','figure','Tag','Distribution Fitting Figure');
set(0,'ShowHiddenHandles',oldval);
if length(dffig)>1, dffig = dffig(1); end

% If asking for the figure itself, handle that now
if isequal(varname,'dffig')
   if isequal(nargin,1)
      if isequal(class(dffig),'figure')
         dffig = double(dffig);
      end
      outval = dffig;
   elseif ishghandle(inval) && isequal(get(inval,'Type'),'figure')
      set(inval,'Tag','Distribution Fitting Figure');
   end
   return
end

if nargin==1
   if isequal(varname,'dsdb')
      outval = getdsdb;
      return;
   elseif isequal(varname,'fitdb')
      outval = getfitdb;
      return
   end
end

% Some things need to persist, so they are root properties
if ismember(varname, ...
      {'thefitdb' 'thedsdb' 'classinstances' 'theoutlierdb' 'alldistributions'})
   propname = ['Distribution_Fitting_' varname];
   hroot = 0;
   if nargin==1
      outval = getappdata(hroot,propname);
   else
      setappdata(hroot,propname,inval);
   end

% For other properties, the figure must not be empty
elseif isempty(dffig)
   if nargout>0
      outval = [];
   end

% If the figure is not empty, set or get its property
else
   if nargin==1
      outval = getappdata(dffig,varname);
   else
      setappdata(dffig,varname,inval);
   end
end
