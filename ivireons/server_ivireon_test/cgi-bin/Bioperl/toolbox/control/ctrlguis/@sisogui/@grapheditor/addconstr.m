function addconstr(Editor, Constr)
%ADDCONSTR  Add Generic constraint to editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.12.4.3 $  $Date: 2005/11/15 00:51:24 $

% Initialize
Constr.Zlevel = Editor.zlevel('constraint');
Constr.ButtonDownFcn = {@LocalButtonDownFcn, Constr, Editor};
Constr.TextEditor = plotconstr.tooleditor(Editor.ConstraintEditor,Editor);

% Install listeners
% RE: After prop. init. for trouble-free undo, and before activation to 
%     enable pre-set listener on Activated
Constr.initialize;

% Activate (renders constraint and targets constr. editor)
Constr.Activated = 1;



% --------------------------- Local Functions ----------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalButtonDownFcn
% Purpose:  Sets the ButtonDown callback for constraint objects.
% ----------------------------------------------------------------------------%
function LocalButtonDownFcn(hSrc, event, Constr, Editor)

if ~strcmp(Editor.EditMode,'idle')
    % Redirect buttondown event to Editor
    Editor.mouseevent('bd',get(hSrc,'parent'));
else
    % Process locally
    Constr.mouseevent('bd',hSrc);
end