function answer = questdlg(obj,prompt,title,buttons,defaultanswer,callback)
%questdlg - Shows a DDG question dialog
%
% There are two modes of operation.  The first is blocking: the functions
% waits until the user has selected a value, and then return it.
%   answer = obj.questdlg(prompt,title,buttons,defaultanswer);
% buttons is a cell array of strings giving the labels for the buttons.
% defaultanswer is one of these labels, and identifies the button to be
%   given the focus initially.
% answer is a string, and is the label of the button clicked by the user.
%   If the user closes the dialog without clicking any button, answer is
%   empty.
%
% In the second mode of operation, the function returns immediately and a
% callback is executed when the user clicks a button.
%  d = obj.questdlg(prompt,title,buttons,defaultanswer,callback);
% The dialog handle is returned.  The supplied callback is called with one
% additional argument, which is the label of the button clicked by the
% user.  If the user closes the dialog without clicking any button, the
% callback is NOT called.
%
% e.g.  answer = obj.questdlg('Choose a color:','Color Selection',...
%                             {'Red','Blue','Green'},'Blue');
%       disp(answer);
%
%       obj.questdlg('Choose a color:','Color Selection',...
%                    {'Red','Blue','Green'},'Blue',@disp);
%
% See also: questdlg

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/03/30 23:56:04 $

s.Title = title;
s.Prompt = prompt;
s.Buttons = buttons;
if nargin>5
    s.Callback = callback;
else
    s.Callback = [];
end
% Supply a default response, for the case where the user closes the dialog
% without clicking any button.
s.QuestDlgValue = '';
obj.pDialogData = s;
d = DAStudio.Dialog(obj,'QuestionDialog','DLG_STANDALONE');
if isempty(defaultanswer)
    defaultanswer = buttons{1};
elseif ~ismember(defaultanswer,buttons)
    dependencies.assert(false,'Default answer must be one of the supplied names');
end
d.setFocus(['QuestDlg_' defaultanswer]);
if nargin<6
    waitfor(d,'dialogTag','');
    answer = obj.pDialogData.QuestDlgValue;
else
    answer = d;
end