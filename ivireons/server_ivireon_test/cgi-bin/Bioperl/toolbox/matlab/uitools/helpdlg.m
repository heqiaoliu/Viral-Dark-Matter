function varargout = helpdlg(HelpString,DlgName)
%HELPDLG Help dialog box.
%  HANDLE = HELPDLG(HELPSTRING,DLGNAME) displays the 
%  message HelpString in a dialog box with title DLGNAME.  
%  If a Help dialog with that name is already on the screen, 
%  it is brought to the front.  Otherwise a new one is created.
%
%  HelpString will accept any valid string input but a cell
%  array is preferred.
%
%   Example:
%       h = helpdlg('This is a help string','My Help Dialog');
%
%  See also DIALOG, ERRORDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG, WARNDLG.

%  Author: L. Dean
%  Copyright 1984-2006 The MathWorks, Inc.
%  $Revision: 5.16.4.4 $  $Date: 2006/10/10 02:27:37 $

if nargin==0,
   HelpString ={'This is the default help string.'};
end
if nargin<2,
   DlgName = 'Help Dialog';
end

if ischar(HelpString) && ~iscellstr(HelpString)
    HelpString = cellstr(HelpString);
end
if ~iscellstr(HelpString)
    error('MATLAB:helpdlg:InvalidHelpStringInput', 'HelpString should be a string or cell array of strings');
end

HelpStringCell = cell(1,length(HelpString));
for i = 1:length(HelpString)
    HelpStringCell{i} = xlate(HelpString{i});
end

handle = msgbox(HelpStringCell,DlgName,'help','replace');

if nargout==1,varargout(1)={handle};end
