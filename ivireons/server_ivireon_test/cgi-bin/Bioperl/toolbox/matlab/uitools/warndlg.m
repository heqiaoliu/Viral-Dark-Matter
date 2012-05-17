function varargout = warndlg(WarnString,DlgName,Replace)
%WARNDLG Warning dialog box.
%  HANDLE = WARNDLG(WARNSTRING,DLGNAME) creates an warning dialog box
%  which displays WARNSTRING in a window named DLGNAME.  A pushbutton
%  labeled OK must be pressed to make the warning box disappear.
%  
%  HANDLE = WARNDLG(WARNSTRING,DLGNAME,CREATEMODE) allows CREATEMODE options
%  that are the same as those offered by MSGBOX.  The default value
%  for CREATEMODE is 'non-modal'.
%
%  WarnString will accept any valid string input but a cell 
%  array is preferred.
%
%  WARNDLG uses MSGBOX.  Please see the help for MSGBOX for a
%  full description of the input arguments to WARNDLG.
%
%   Examples:
%       f = warndlg('This is an warning string.', 'My Warn Dialog');
%
%       f = warndlg('This is an warning string.', 'My Warn Dialog', 'modal');
%
%  See also DIALOG, ERRORDLG, HELPDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG.

%  Author: L. Dean
%  Copyright 1984-2006 The MathWorks, Inc.
%  $Revision: 5.24.4.4 $  $Date: 2006/10/10 02:28:11 $

if nargin==0,
   WarnString = 'This is the default warning string.';
end
if nargin<2,
   DlgName = 'Warning Dialog';
end
if nargin<3,
   Replace = 'non-modal';
end

if ischar(WarnString) && ~iscellstr(WarnString)
    WarnString = cellstr(WarnString);
end
if ~iscellstr(WarnString)
    error('MATLAB:warndlg:InvalidWarnStringInput', 'WarnString should be a string or cell array of strings');
end

WarnStringCell = cell(1,length(WarnString));
for i = 1:length(WarnString)
    WarnStringCell{i} = xlate(WarnString{i});
end

handle = msgbox(WarnStringCell,DlgName,'warn',Replace);

if nargout==1,varargout(1)={handle};end
