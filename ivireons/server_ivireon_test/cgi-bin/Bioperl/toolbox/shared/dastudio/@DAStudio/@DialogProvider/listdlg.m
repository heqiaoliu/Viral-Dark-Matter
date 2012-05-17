function answer = listdlg(obj,prompt,title,liststring,iteminfo,callback)
%listdlg - Shows a DDG list dialog
%
% There are two modes of operation.  This first is blocking, and is similar
% to the MATLAB listdlg function.
%
%    answer = obj.listdlg(prompt,title,liststring,iteminfo);
%
% prompt is the first line of text in the dialog.
% title is the dialog title.
% liststring is a cell array of strings to be shown in the list
% iteminfo is optional and is a cell array of strings giving further
%    information about each item in the list.  The information is shown
%    below the list when that item is selected.  If not required, this
%    input can be empty.
% 
% answer is a string, or -1 if the dialog is dismissed without a selection
%   being made.
%
% The second mode is non-blocking, and executes a callback when the user
% chooses a string.
%    d = obj.inputdlg(prompt,title,liststring,iteminfo,callback);
%
% The supplied callback is called with one additional argument, which is
% the string selected by the user.  If the dialog is cancelled, the callback
% is NOT called.
%
% e.g.  answer = obj.listdlg('Choose a color:','Color Chooser',{'Red','Blue','Green'},[]);
%       disp(answer);
% 
%       answer = obj.listdlg('Choose a color:','Color Chooser',{'Red','Blue','Green'},...
%                                {'Makes everything red','Makes everything blue',...
%                                 'Makes everything green'});
%       disp(answer);
%
%       obj.listdlg('Choose a color:','Color Chooser',{'Red','Blue','Green'},[],@disp);
%
% See also: listdlg

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 17:46:09 $

s.Title = title;
s.Prompt = prompt;
s.ListString = liststring;
% Basic argument checking on the input that's easiest to get wrong
if ~isempty(iteminfo)
    assert(iscellstr(iteminfo));
    assert(numel(iteminfo)==numel(liststring));
end
s.ItemInfo = iteminfo;
if nargin<6
    s.Callback = {};
else
    s.Callback = callback;
end
s.ListDlgAnswer = -1;
obj.pDialogData = s;
d = DAStudio.Dialog(obj,'ListDialog','DLG_STANDALONE');
if nargin<6
    waitfor(d,'dialogTag','');
    answer = obj.pDialogData.ListDlgAnswer;
else
    answer = d;
end
