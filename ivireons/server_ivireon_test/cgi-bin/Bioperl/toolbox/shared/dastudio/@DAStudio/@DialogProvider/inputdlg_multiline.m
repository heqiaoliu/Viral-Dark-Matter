function answer = inputdlg_multiline(obj,prompt,title,defaultanswer,callback)
%inputdlg_multiline - Shows a multiline DDG input dialog
%
% Usage is identical to that of the "inputdlg" method, but the text area in
% the dialog accepts multiple lines of text.
%
%   answer = obj.inputdlg_multiline(prompt,title,defaultanswer);
%   d = obj.inputdlg_multiline(prompt,title,defaultanswer,callback);
%
% See also: inputdlg

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/05/14 17:46:08 $

s.Title = title;
s.Prompt = prompt;
s.DefaultAnswer = defaultanswer;
if nargin<5
    s.Callback = {};
else
    s.Callback = callback;
end
s.InputDlgAnswer = -1;
s.InputDlgMultiline = true;
obj.pDialogData = s;
d = DAStudio.Dialog(obj,'InputDialog','DLG_STANDALONE');
if nargin<5
    waitfor(d,'dialogTag','');
    answer = obj.pDialogData.InputDlgAnswer;
else
    answer = d;
end