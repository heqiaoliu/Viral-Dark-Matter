function varargout = errordlg(ErrorStringIn,DlgName,Replace)
%ERRORDLG Error dialog box.
%  HANDLE = ERRORDLG(ERRORSTRING,DLGNAME) creates an error dialog box which
%  displays ERRORSTRING in a window named DLGNAME.  A pushbutton labeled OK
%  must be pressed to make the error box disappear.  
%
%  HANDLE = ERRORDLG(ERRORSTRING,DLGNAME,CREATEMODE) allows CREATEMODE
%  options that are the same as those offered by MSGBOX.  The default value
%  for CREATEMODE is 'non-modal'.
%
%  ErrorString will accept any valid string input but a cell array is
%  preferred.
%
%  ERRORDLG uses MSGBOX.  Please see the help for MSGBOX for a full
%  description of the input arguments to ERRORDLG.
%  
%   Example:
%       f = errordlg('This is an error string.', 'My Error Dialog');
%
%       f = errordlg('This is an error string.', 'My Error Dialog', 'modal');
%
%  See also DIALOG, HELPDLG, INPUTDLG, LISTDLG, MSGBOX,
%    QUESTDLG, WARNDLG.

%  Author: L. Dean
%  Copyright 1984-2006 The MathWorks, Inc.
%  $Revision: 5.24.4.4 $  $Date: 2006/10/10 02:27:29 $

NumArgIn = nargin;
if NumArgIn==0,
   ErrorStringIn = {'This is the default error string.'};
end

if NumArgIn<2,  DlgName = 'Error Dialog'; end
if NumArgIn<3,  Replace='non-modal'     ; end

% Backwards Compatibility
if ischar(Replace),
  if strcmp(Replace,'on'),
    Replace='replace';
  elseif strcmp(Replace,'off'),
    Replace='non-modal';
  end
end

if ischar(ErrorStringIn) && ~iscellstr(ErrorStringIn)
    ErrorString = cellstr(ErrorStringIn); 
else 
    ErrorString = ErrorStringIn; 
end
if ~iscellstr(ErrorString)
    error('MATLAB:errordlg:InvalidInput', 'Errorstring should be a string or cell array of strings');
end

ErrorStringCell = cell(1,length(ErrorString));
for i = 1:length(ErrorString)
    ErrorStringCell{i} = xlate(ErrorString{i});
end

handle = msgbox(ErrorStringCell,DlgName,'error',Replace);
if nargout==1,varargout(1)={handle};end
