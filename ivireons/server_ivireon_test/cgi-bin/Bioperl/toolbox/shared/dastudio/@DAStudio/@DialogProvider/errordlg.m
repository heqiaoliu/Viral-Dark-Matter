function d = errordlg(obj,message,title,nonblocking)
%errordlg - Shows a DDG error dialog
%
% There are two modes of operation.  The first is blocking: the function
% does not return until the dialog is dismissed by the user.
%    obj.errordlg(message,title);
%
% The second mode is non-blocking.  The function returns immediately, with
% the dialog still visible.  The dialog handle is returned.
%   d = obj.errordlg(message,title,true);
%
% e.g. obj.errordlg('An error occurred','Error');
%      obj.errordlg('An error occurred','Error',true);
%
% See also: errordlg

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:55:56 $

s.Title = title;
s.Message = message;
obj.pDialogData = s;
d = DAStudio.Dialog(obj,'ErrorDialog','DLG_STANDALONE');
if nargin<4 || ~nonblocking
    % This will wait until the dialog is destroyed.
    waitfor(d,'dialogTag','');
    d = [];
end