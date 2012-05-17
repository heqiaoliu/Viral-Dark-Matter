function answer = inputdlg(obj,prompt,title,defaultanswer,callback)
%inputdlg - Shows a DDG input dialog
%
% There are two modes of operation.  This first is blocking, and is similar
% to the MATLAB inputdlg function:
%   answer = obj.inputdlg(prompt,title,defaultanswer);
% If the dialog is cancelled, the return value is -1.  Otherwise it is a
% string.
%
% The second mode is non-blocking, and executes a callback when the dialog
% is closed.
%   d = obj.inputdlg(prompt,title,defaultanswer,callback);
% The supplied callback is called with one additional argument, which is
% the string entered by the user.  If the dialog is cancelled, the callback
% is NOT called.
%
% e.g.  answer = obj.inputdlg('Please enter your name:','Enter Name','');
%       disp(answer);
%
%       obj.inputdlg('Please enter your name:','Enter Name','',@disp);
%
% See also: inputdlg

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 17:46:07 $

s.Title = title;
s.Prompt = prompt;
s.DefaultAnswer = defaultanswer;
if nargin<5
    s.Callback = {};
else
    s.Callback = callback;
end
s.InputDlgAnswer = -1;
s.InputDlgMultiline = false;
obj.pDialogData = s;
d = DAStudio.Dialog(obj,'InputDialog','DLG_STANDALONE');
if nargin<5
    waitfor(d,'dialogTag','');
    answer = obj.pDialogData.InputDlgAnswer;
else
    answer = d;
end