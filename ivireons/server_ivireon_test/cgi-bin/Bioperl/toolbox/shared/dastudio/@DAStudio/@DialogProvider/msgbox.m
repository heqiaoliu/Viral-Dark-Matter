function d = msgbox(obj,message,title,nonblocking)
%msgbox - Shows a DDG message box
%
% There are two modes of operation.  The first is blocking: the function
% does not return until the dialog is dismissed by the user.
%    obj.msgbox(message,title);
%
% The second mode is non-blocking.  The function returns immediately, with
% the dialog still visible.  The dialog handle is returned.
%   d = obj.msgbox(message,title,true);
%
% e.g. obj.msgbox('Something just happened','Message');
%      obj.msgbox('Something just happened','Message',true);
%
% See also: msgbox

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:01 $

s.Title = title;
s.Message = message;
obj.pDialogData = s;
d = DAStudio.Dialog(obj,'MessageBox','DLG_STANDALONE');
if nargin<4 || ~nonblocking
    % This will wait until the dialog is destroyed.
    waitfor(d,'dialogTag','');
    d = [];
end