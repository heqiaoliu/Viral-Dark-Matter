function callbacks(this, arg, hDlg)
%HANDLEBUTTONS Handle buttons in hierarchy viewer.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2008/02/02 13:09:53 $

% Evaluate the callback, which is specified as a string.
feval(arg, this, hDlg);

% -------------------------------------------------------------------------
function load(this, hDlg) %#ok

if isa(this.CurrentObject, 'extmgr.Register');
    getPropertyDb(this.CurrentObject);
elseif isa(this.CurrentObject, 'extmgr.RegisterDb')
    fevalChild(this.CurrentObject, @(hChild) lclGetPropertyDb(hChild));
else
    error(generatemsgid('NoResources'), 'Can only load resources for Registrations.');
end

refresh(this, hDlg);

% -------------------------------------------------------------------------
function new(this, hDlg) %#ok

answer = inputdlg('Extension file name', 'Load extensions');
if isempty(answer)
    return;
end

answer = answer{1};

hl = extmgr.RegisterLib;
hl.getRegisterDb(answer);

refresh(this, hDlg);

% -------------------------------------------------------------------------
function select(this, hDlg) %#ok

% User clicked on a selection in the tree
% Get concatenated-string corresponding to this location
%   'top/child/subchild/node'
% Note: could be a numeric empty if no selection is made
%   (i.e., used to have one entry selected, then a click
%    is made that does not highlight any entry ... in this
%    case, [] is the widget value)
% We translate this to an empty STRING, which is the
% type of .dialogSelection
treeNodeStr = hDlg.getWidgetValue('treeView');
if isempty(treeNodeStr), treeNodeStr=''; end

% Pass the path (or empty string) via an object property
this.CurrentNode = treeNodeStr;
hDlg.refresh;  % Update the dialog

% -------------------------------------------------------------------------
function refresh(this, hDlg) %#ok

if ~isempty(hDlg)
    hDlg.refresh;
end

% -------------------------------------------------------------------------
function close(this, hDlg) %#ok

delete(hDlg);  % close dialog

% -------------------------------------------------------------------------
function lclGetPropertyDb(hRegister)

try
    getPropertyDb(hRegister);
catch e %#ok
    % NO OP
end

% [EOF]
