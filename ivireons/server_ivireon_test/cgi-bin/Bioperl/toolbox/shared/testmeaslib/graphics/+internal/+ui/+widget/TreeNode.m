classdef TreeNode < handle
    %TREENODE Represents a node of a hierarchical tree like data structure
    %
    %   A treeNode has a name and can contain children. Each child is also
    %   an object of TreeNode class. This class is used to represent tree
    %   data in the TreePanelController class.
    
    % Copyright 2010 The MathWorks, Inc.
    % $Revision: 1.1.6.2 $ $Date: 2010/03/22 04:20:29 $
    
    properties(SetAccess='private', GetAccess='public')
        % Name of the node - A node can have [] name or can be string.
        Name
        
        % an array of TreeNode objects that are children of this node.
        Children
        
        % logical - true to show container icon for the node, false to show
        % leaf icon
        IsContainer
    end
    
    methods
        function obj = TreeNode(name, isContainer)
            % OBJ = TREENODE(NAME, ISCONTAINER) create a tree node 
            %
            % NAME the name of the tree node, can be empty or a string.
            %
            % ISCONTAINER true if the tree node should display container
            % icon or leaf icon for this node
            
            assert(isempty(name) || ischar(name),...
                'Name must be empty or a string');
            
            obj.Name = name;
            
            obj.Children = internal.ui.widget.TreeNode.empty();
            
            obj.IsContainer = isContainer;
        end
        
        function addChild(obj, node)  
            % ADDCHILD(OBJ, NODE) adds NODE as a child of this node.
            %
            % NODE must be object of TreeNode class. It is appened to the
            % list of children of this class.
            
            assert(isa(node, 'internal.ui.widget.TreeNode'),...
                    'node must be a object of internal.ui.widget.TreeNode class.');
                
            obj.Children(end + 1) = node;
        end
    end
end

