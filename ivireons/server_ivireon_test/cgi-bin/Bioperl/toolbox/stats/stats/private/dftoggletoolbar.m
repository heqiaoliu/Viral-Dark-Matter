function dftoggletoolbar(varargin)
%TOGGLETOOLBAR Toggle distribution fit plot toolbar on or off

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:19 $
%   Copyright 2003-2008 The MathWorks, Inc.

if (nargin>0 && ishghandle(varargin{1}) && ...
                isequal(get(varargin{1},'Type'),'figure'))
   dffig = varargin{1};
else
   dffig = gcbf;
end

tbstate = get(dffig,'toolbar');
h = findall(dffig,'Type','uitoolbar');
if isequal(tbstate,'none') || isempty(h)
   % Create toolbar for the first time
   set(dffig,'toolbar','figure');
   dfadjusttoolbar(dffig);
elseif nargin>1 && isequal(varargin{2},'on')
   % Hide toolbar
   set(h,'Visible','on');
else
   % Show toolbar
   set(h,'Visible','off');
end
