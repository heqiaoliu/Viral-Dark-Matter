% Copyright 2007-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $

function computeInstanceModeErrorsAndWarnings(model)
    data = struct('model', {}, 'nodes', {});
    allNodes = model.getNodes();
    modelNodes = find(allNodes, '-isa', 'DepViewer.ModelReferenceDepNode');
    
    for i = 1:length(modelNodes)
        node = modelNodes(i);
        node.hasWarning     = false;
        node.hasError       = false;
        node.tooltipMessage = '';
        
        % If the actual and configured sim modes are not the same, then
        % this is a warning
        if(~isequal(node.actualSimMode, node.configuredSimMode))
            if any(strcmpi(node.configuredSimMode,...
                           {'software-in-the-loop (sil)',...
                            'processor-in-the-loop (pil)'}))
                node.hasError=true;
                node.tooltipMessage = sprintf('Error: %s mode is not allowed within %s mode.',...
                                              node.configuredSimMode, node.actualSimMode);
            else
                node.hasWarning = true;
                node.tooltipMessage = sprintf('Warning: Overridden to %s mode.', node.actualSimMode); 
            end
        end % if

        % Record normal mode models, to see if there are more than one
        % models configured for normal mode
        if(isequal(node.actualSimMode, 'Normal'))
            index = find(strcmp({data.model}, node.shortname), 1);

            if(isempty(index))
                index = length(data) + 1;
                data(index).model = node.shortname;
            end % if

            data(index).nodes = [data(index).nodes, node];
        end % if
    end % for
    
    % Now that all models have been looked at see if any models have more than
    % instance in normal mode (if multi-instance normal mode is disabled)
    if(~ slfeature('ModelReferenceMultiInstanceNormalMode'))
        for i = 1:length(data)
            nodes = data(i).nodes;
            
            if(length(nodes) > 1)
                for j = 1:length(nodes)
                    node = nodes(j);
                    
                    node.hasError = true;
                    node.tooltipMessage = sprintf('Error: Multiple instances in Normal mode.'); 
                end % for
            end % if
        end % for
    end
end % computeInstanceModeErrorsAndWarnings
