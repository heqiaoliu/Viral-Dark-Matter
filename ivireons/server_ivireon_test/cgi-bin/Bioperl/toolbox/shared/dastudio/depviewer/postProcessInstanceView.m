%%
% Take a Instance View directed acyclic graph (DAG) and convert
% it to a tree
%
% roots:          the roots of the DAG
% inMdl:          the DAG 
% outMdl:         the DepView.Model to be filled in with the tree
% hideLibraries:  should libraries be hidden
function [] = postProcessInstanceView(roots, inMdl, outMdl, hideLibraries)

%   Copyright 2007-2009 The MathWorks, Inc.

    for i = 1:length(roots)
        node = roots(i);

        % If the root is a library node, set the sim mode to normal
        if(loc_isLibraryNode(node))
            node.configuredSimMode = 'Normal';
        end % if

        % For roots, the actual sim mode is the configured sim mode
        node.actualSimMode = node.configuredSimMode;

        copy = loc_copyNode(node, outMdl, '', '');
        loc_processNode(node, inMdl, copy, outMdl, '', '', {node.shortname});
    end % for

    if(hideLibraries)
        loc_removeLibraryNodes(outMdl);
    end % if

    % Add errors and warnings
    computeInstanceModeErrorsAndWarnings(outMdl);
end % postProcessInstanceView

%%
% Process the given node
%
% inSrc   - the node in the input model being processed
% inMdl   - the input model
% outSrc  - the node in the output model corresponding to inSrc
% outMdl  - the output model
% pattern - a pattern to match in block paths, to be replaced by replace
% replace - the string to replace pattern with
% parents - the models/libraries that reference this one on the path that
%           is currently being processed.  
%
% We need pattern and replace because blocks in libraries can be referenced
% in multiple places.  The nodes in the DAG have no notion of what context
% in which they are referenced.  When building the tree, we need to give 
% the nodes in library block the correct context (i.e., the path from the
% root model that references them).  Pattern should contain the path to
% blocks in library and replace should contain the path based on the model
% making the reference.
function [] = loc_processNode(inSrc, inMdl, outSrc, outMdl, pattern, replace, parents)
    edges = inSrc.getOutEdges();
    
    % Look at each edge leaving inSrc
    for i = 1:length(edges)
        inEdge = edges(i);
        
        % See what type of edge it is
        if(inEdge.resolveLink)
            % This is a resolve edge.  The block it points to is the root
            % of a tree that inSrc needs to be connected to
            assert(length(edges) == 1);

            % Get the node pointed to
            resolvedNode = inEdge.getEndElement();
            assert(length(resolvedNode) == 1);
            
            % Get the name of the object being referenced
            isModel = loc_isModelRefNode(inSrc);
            isLib   = loc_isLibraryNode(inSrc);
            assert(isModel ~= isLib);
            
            if(isModel)
                resolvedName = resolvedNode.shortname;
            else
                resolvedName = resolvedNode.longname;
            end % if
            
            % Check for circularity
            if(~ isempty(find(strcmp(resolvedName, parents) == 1, 1)))
                fullPath = [parents, resolvedName];
                index    = find(strcmp(resolvedName, parents) == 1, 1);

                msg = sprintf('Reference circularity detected:  %s', fullPath{index});
                index = index + 1;
                
                while(index <= length(fullPath))
                    msg = sprintf('%s, %s',...
                                  msg, fullPath{index});
                    index = index + 1;
                end % while
                 
                error('Simulink:DependencyViewer:InstanceModeCircularity', msg);
            end % if
            
            % No circularity
            myparents = [parents, resolvedName];
            
            % Get the edges that node points to.  The nodes these edges
            % point to is what inSrc needs to be connected to.
            resolvedEdges = resolvedNode.getOutEdges();

            if(isempty(resolvedEdges))
                inDests = [];
            else
                firstEdge = resolvedEdges(1);
                inDests = repmat(firstEdge.getEndElement(), 1, length(resolvedEdges));
                for j = 1:length(resolvedEdges)
                    nextEdge = resolvedEdges(j);
                    inDest = nextEdge.getEndElement();
                    assert(length(inDest) == 1);
                    inDests(j) = inDest;
                end % for
            end % if

            % For resolve links, we may need to change labels on 
            % the nodes in the tree
            if(isModel)
                % If the block making the reference is a model reference
                % block, then it a referencing a model.  This model
                % knows its context, so nothing needs to be replaced in
                % labels.
                pattern = '';
                replace = '';
            else
                % If the block making the reference is a library link, then
                % what is being referenced is a subsystem in a library.
                % The referenced blocks to not have the correct context, so
                % we need to replace the path to them by the path to the
                % block that is making the reference.
                
                % Only look for matches that the start of a string
                pattern = ['^', resolvedNode.longname]; 
                replace = outSrc.longname;
            end % if
        else
            % It is not a resolve edge.  The destination node is simply
            % the destination of the edges.
            inDests = inEdge.getEndElement();
            assert(length(inDests) == 1);
            
            myparents = parents;
        end % if
        
        % Create the edges in the output model
        for j = 1:length(inDests)
            inDest = inDests(j);
            
            % Create a node in the output model to correspond to inDest.
            outDest = loc_copyNode(inDest, outMdl, pattern, replace);
            
            % If the edge is a resolve edge, make sure the actual sim
            % mode gets copied appropriately.
            if(inEdge.resolveLink)
                outDest.actualSimMode = inSrc.actualSimMode;
            end % if
            
            % Create the edge
            loc_createDep(outSrc, outDest, outMdl);
            
            % Recurse and process inDest
            loc_processNode(inDest, inMdl, outDest, outMdl, pattern, replace, myparents);
        end % for
    end % for
end % loc_processNode

%% 
function [] = loc_createDep(src, dest, model)
    dep   = model.createDependency();
    dep.connect(src, dest);
    
    isModel = loc_isModelRefNode(dest);
    isLib   = loc_isLibraryNode(dest);
    assert(isModel ~= isLib);
    
    if(isModel)
        switch src.actualSimMode
          case {'Accelerator', 'Processor-in-the-loop (PIL)',...
               'Software-in-the-loop (SIL)'}
                dest.actualSimMode = src.actualSimMode; 
                  
            case 'Normal'
                dest.actualSimMode = dest.configuredSimMode;
                
            otherwise
                assert(false, sprintf('Unknown mode ''%s''', src.actualSimMode));
        end % switch
    else
        % This is a library.
        dest.actualSimMode = src.actualSimMode;
    end % if
    
    assert(~ isempty(dest.actualSimMode));
end % loc_createDep

%%
function copiedNode = loc_copyNode(node, destMdl, pattern, replace)
    isModel = loc_isModelRefNode(node);
    isLib   = loc_isLibraryNode(node);
    assert(isModel ~= isLib);
    
    if(isModel)
        copiedNode = destMdl.createModelReferenceDepNode();
    else
        copiedNode = destMdl.createLibraryDepNode();
    end % if
    
    copiedNode.position          = node.position;
    copiedNode.size              = node.size;
    copiedNode.expanded          = node.expanded;
    copiedNode.displayLabel      = node.displayLabel;
    copiedNode.expanded          = node.expanded;
    copiedNode.isVisible         = node.isVisible;
    copiedNode.configuredSimMode = node.configuredSimMode;
    copiedNode.actualSimMode     = node.actualSimMode;
    copiedNode.dotID             = node.dotID;
    copiedNode.shortname         = node.shortname;
    copiedNode.pathOnDisk        = node.pathOnDisk;
    copiedNode.tooltipMessage    = node.tooltipMessage;
    copiedNode.hasWarning        = node.hasWarning;
    copiedNode.hasError          = node.hasError;

    copiedNode.longname          = regexprep(node.longname, pattern, replace);
    copiedNode.pathToHilite      = regexprep(node.pathToHilite, pattern, replace);
    copiedNode.pathToOpen        = regexprep(node.pathToOpen, pattern, replace);
end % loc_copyNode

%%
function isModelRef = loc_isModelRefNode(node)
    isModelRef = strcmp(class(node), 'DepViewer.ModelReferenceDepNode');
end % loc_isModelRefNode

%%
function isLibRef = loc_isLibraryNode(node)
    isLibRef = strcmp(class(node), 'DepViewer.LibraryDepNode');
end % loc_isModelRefNode

%%
% Removes library nodes, connecting parents to children
function [] = loc_removeLibraryNodes(model)
     nodes = model.getNodes();

     libNodes  = find(nodes, '-isa', 'DepViewer.LibraryDepNode');
     for i = 1:length(libNodes)
         libNode = libNodes(i);

         if(libNode.getInDegree() == 0)
             continue;
         end % if
         
         assert(libNode.getInDegree() == 1);

         inEdge = libNode.getInEdges();
         parentNode = inEdge.getStartElement();
         assert(length(parentNode) == 1);

         outEdges = libNode.getOutEdges();
         for j = 1:length(outEdges)
             outEdge   = outEdges(j);
             childNode = outEdge.getEndElement();
             assert(length(childNode) == 1);

             % Connect parent to child
             newDep = model.createDependency();
             newDep.connect(parentNode, childNode);

             % Disconnect the old out edge
             outEdge.disconnect();
             
             % Remove the old out edge
             model.removeNode(outEdge);
         end % for

         % Disconnect the old in edge
         inEdge.disconnect();
         
         % Remove the old inEdge
         model.removeNode(inEdge);

         % Remove the old node
         model.removeNode(libNode);
     end % for
end % loc_removeLibraryNodes
