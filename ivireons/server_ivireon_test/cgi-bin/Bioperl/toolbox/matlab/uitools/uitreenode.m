function node = uitreenode(varargin)
% This function is undocumented and will change in a future release

%   UITREENODE('v0', Value, Description, Icon, Leaf)
%   creates a tree node object for the uitree with the specified
%   properties. All properties must be specified for the successful
%   creation of a node object.
%
%   Value can be a string or handle represented by this node.
%   Description is a string which is used to identify the node.
%   Icon can be a qualified pathname to an image to be used as an icon
%   for this node. It may be set to [] to use default icons.
%   Leaf can be true or false to denote whether this node has children.
%
%   Example:
%     t = uitree('v0', 'Root', 'D:\')
%
%     %Creates a uitree widget in a figure window with which acts as a
%     %directory browser with the D: drive as the root node.
%
%     surf(peaks)
%     f = figure
%     t = uitree('v0', f, 'Root', 0)
%
%     %Creates a uitree object in the specified figure window which acts as
%     %a MATLAB hierarchy browser with the MATLAB root (0) as the root node.
%
%     root = uitreenode('v0', 'S:\', 'S', [], false);
%     t = uitree('v0', 'Root', root, 'ExpandFcn', @myExpfcn, ...
%                'SelectionChangeFcn', 'disp(''Selection Changed'')');
%
%     %Creates a uitree object with the specified root node and a custom
%     %function to return child nodes for any given node. myExpfcn is
%     %a user defined function on the MATLAB path.
%
%     % This function should be added to the path
%     % ---------------------------------------------
%     function nodes = myExpfcn(tree, value)
%
%     try
%         count = 0;
%         ch = dir(value);
%
%         for i=1:length(ch)
%             if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
%                 count = count + 1;
%                 if ch(i).isdir
%                     iconpath = [matlabroot, '/toolbox/matlab/icons/foldericon.gif'];
%                 else
%                     iconpath = [matlabroot, '/toolbox/matlab/icons/pageicon.gif'];
%                 end
%                 nodes(count) = uitreenode([value, ch(i).name, filesep], ...
%                     ch(i).name, iconpath, ~ch(i).isdir);
%             end
%         end
%     catch
%     end
%
%     if (count == 0)
%         nodes = [];
%     end
%     % ---------------------------------------------
%       
%   See also UITREE, UITABLE, JAVACOMPONENT

% Copyright 2003-2008 The MathWorks, Inc.

% If using the 'v0' switch, use the undocumented uitreenode explicitly.
if (usev0dialog(varargin{:}))
	[node] = uitreenode_deprecated(varargin{2:end});
else
    % Replace this with a call to the documented uitreenode when ready.
    warning('MATLAB:uitreenode:MigratingFunction', ...
            ['This undocumented function will be replaced in a future release.\n', ... 
            'To continue to use it, add ''v0'' as its first argument, followed by its normal calling sequence.']);
	[node] = uitreenode_deprecated(varargin{:});
end