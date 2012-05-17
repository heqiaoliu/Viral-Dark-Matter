function [tree, container] = uitree(varargin)
% This function is undocumented and will change in a future release

% UITREE creates a uitree component with hierarchical data in a figure window.
%   UITREE creates an empty uitree object with default property values in
%   a figure window.
%
%   UITREE('v0', 'PropertyName1', 'Value1', 'PropertyName2', 'Value2', ...)
%   creates a uitree object with the specified properties. The properties
%   that can be set are: Root, ExpandFcn, SelectionChangeFcn, Parent and
%   Position. The 'Root' property must be specified to successfully to
%   create a uitree. The other properties are optional.
%
%   UITREE('v0', figurehandle, ...) creates a uitree object in the figure
%   window specified by the figurehandle.
%
%   HANDLE = UITREE('v0', ...) creates a uitree object and returns its handle.
%
%   Properties:
%
%   Root - Root node for the uitree object. Could be handle to a HG
%   object, a string, an open block diagram name, or handle to a
%   UITREENODE object.
%   ExpandFcn - Node expansion function. String or function handle.
%   SelectionChangeFcn - Selection callback function. String or function
%   handle.
%   Parent - Parent figure handle. If not specified, it is the gcf.
%   Position: 4 element vector specifying the position.
%
%   DndEnabled: Boolean specifying if drag and drop is enabled (false).
%   MultipleSelectionEnabled: Boolean specifying if multiple selection is
%   allowed (false).
%   SelectedNodes: vector of uitreenodes to be selected.
%   Units: String - pixels/normalized/inches/points/centimeters.
%   Visible: Boolean specifying if table is visible.
%   NodeDroppedCallback: Callback for a drag and drop action.
%   NodeExpandedCallback: Callback for a node expand action.
%   NodeCollapsedCallback: Callback function for a node collapse action.
%   NodeSelectedCallback: Callback for a node selection action.
%
%
%   Examples:
%           t = uitree('v0', 'Root', 'D:\')
%
%       %Creates a uitree widget in a figure window with which acts as a
%       %directory browser with the D: drive as the root node.
%
%           surf(peaks)
%           f = figure
%           t = uitree('v0', f, 'Root', 0)
%
%       %Creates a uitree object in the specified figure window which acts as
%       %a MATLAB hierarchy browser with the MATLAB root (0) as the root node.
%
%           root = uitreenode('v0', 'S:\', 'S', [], false);
%           t = uitree('v0', 'Root', root, 'ExpandFcn', @myExpfcn, ...
%                     'SelectionChangeFcn', 'disp(''Selection Changed'')');
%
%       %Creates a uitree object with the specified root node and a custom
%       %function to return child nodes for any given node. myExpfcn is
%       %a function on the MATLAB path with the following code:
%
%       %This function should be added to your path
%       % ---------------------------------------------
%       function nodes = myExpfcn(tree, value)
%
%       try
%           count = 0;
%           ch = dir(value);
%
%           for i=1:length(ch)
%               if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
%                   count = count + 1;
%                   if ch(i).isdir
%                       iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
%                   else
%                       iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
%                   end
%                   nodes(count) = uitreenode([value, ch(i).name, filesep], ...
%                       ch(i).name, iconpath, ~ch(i).isdir);
%               end
%           end
%       catch
%           error('MyApplication:UnrecognizedNode', ...
%             ['The uitree node type is not recognized. You may need to ', ...
%             'define an ExpandFcn for the nodes.']);
%       end
%
%       if (count == 0)
%           nodes = [];
%     	end
%       % ---------------------------------------------
%
%   See also UITREENODE, UITABLE, PATH

%   Copyright 2003-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.24 $  $Date: 2010/05/20 02:30:11 $

%   Release: R14. This feature will not work in previous versions of MATLAB.

% If using the 'v0' switch, use the undocumented uitree explicitly.
if (usev0dialog(varargin{:}))
	[tree, container] = uitree_deprecated(varargin{2:end});
else
    % Replace this with a call to the documented uitree when ready.
    warning('MATLAB:uitree:MigratingFunction', ...
            ['This undocumented function will be replaced in a future release.\n', ... 
            'To continue to use it, add ''v0'' as its first argument, followed by its normal calling sequence.']);
	[tree, container] = uitree_deprecated(varargin{:});
end
