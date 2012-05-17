function hnewmenu = addmenu(hFDA,varargin)
%ADDMENU Add a menu to the Filter Design & Analysis Tool (FDATool).
%   ADDMENU(H,POS,STRING) creates a menu, named STRING, at position POS
%   on the menu bar at the top of FDATool and returns a handle to it.  
%
%   ADDMENU(H,POS,STRING,CALLBACKS,TAGS,SEPARATORS,ACCELERATORS) creates
%   the menu and sets it properties. To add submenus (menus parented by menus), 
%   POS must be a vector and STRING must be a cell array. See the help for the 
%   ADDMENU function for more information.
%
%   EXAMPLES:
%   % #1 Add a "Tools" menu to the menubar 
%   hndl = addmenu(h,6,'Tool&s');
%
%   % #2 Add a "Tools" menu along with a "My Tool" submenu 
%   strs  = {'Tools','My Tool'};
%   cbs   = {'','disp(''Launch tool'');'};
%   tags  = {'tools','mytool'}; 
%   sep   = {'Off','Off'};
%   accel = {'','A'};
%   hndl  = addmenu(h,6,strs,cbs,tags,sep,accel);
%
%   % #3 Add a submenu "My Export" (6) to the "File"(1) menu
%   hndl = addmenu(h,[1 6],'My Export','disp(''Launch my export tool'');',...
%                    'myexport','Off','A');
%
%   % #4 Add a submenu in position 3 to the "Method"(4),"FIR"(1), "Window"(3) menu
%   hndl = addmenu(h,[4 1 3 5],'My Window','disp(''Compute my window'');',...
%          'mywindow','On','W');
%
%   See also FDRMMENU, ADDMENU, UIMENU

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/12/14 15:21:02 $ 

error(nargchk(3,9,nargin,'struct'));

% Handle to FDATool figure
hFig = get(hFDA,'figureHandle');

% Call the menu rendering engine 
hnewmenu = addmenu(hFig,varargin{:});

% [EOF]
