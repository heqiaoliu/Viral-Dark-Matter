function updateFigUndoMenu(fig,newstring,redoOp,redoArgs,undoOp,undoArgs)

% Specify the undo/redo menu behavior on a single figure window.
% The varargin optionally indicates modification of
% to redo menu instead of the undo menu.

% Create command structure
cmd.Function = redoOp;
cmd.Name = newstring;
cmd.InverseFunction = undoOp;
cmd.Varargin = redoArgs;
cmd.InverseVarargin = undoArgs;

% Empty existing data actions from the figure undo stack since the Data
% Manager Action Panel has a stack depth of 1
datamanager.clearUndoRedo('include',fig);
uiundo(handle(fig),'function',cmd);
figtool_manager = getappdata(fig,'uitools_FigureToolManager');
schema.prop(figtool_manager.CommandManager.UndoStack(end),'DataTransaction','MATLAB array');