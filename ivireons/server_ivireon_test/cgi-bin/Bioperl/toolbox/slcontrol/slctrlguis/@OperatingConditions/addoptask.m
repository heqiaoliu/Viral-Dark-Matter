function addoptask(diagram_name,project)
% ADDOPTASK Add an operating point task if needed.

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2008 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2008/12/04 23:27:20 $

% Create the operating conditions if Simulink Control Designer Exists;
% If the first node is not an operating task and it needs to be
% created add it.
children = getChildren(project);

% Check for operating point task nodes
if isempty(children) || (numel(find(children,'-class','OperatingConditions.OperatingConditionTask')) == 0)
    % Create a waitbar
    wb = waitbar(0,'Extracting Operating Points','Name','Control and Estimation Tools Manager');
    % Get the explorer frame
    FRAME = slctrlexplorer;

    try
        % Get the initial operating condition constraint data
        warnstate = warning;
        lastwarn('');
        warning off Slcontrollib:opcond:ModelHasNonDoubleRootPortInputDataTypes
        try
            opspec = operspec(diagram_name);
            [msg,msgid]=lastwarn;
            if strcmp(msgid,'Slcontrollib:opcond:ModelHasNonDoubleRootPortInputDataTypes')
                FRAME.postText(sprintf(' - %s',msg));
            end
            warning(warnstate)
        catch OperatingSpecException
            warning(warnstate)
            throw(OperatingSpecException)
        end        
        
    catch Ex
        % Post to frame that the model couldn't be compiled and that the user
        % should sync with the model.
        str = sprintf([' - The model %s could not be compiled to extract the operating ',...
            'point information.  Please sync the operating point information ',...
            'from the model before linearizing the model.'], diagram_name);
        FRAME.postText(str);

        % Create an empty operating specification object
        opspec = opcond.OperatingSpec;

        % Store the model name
        opspec.Model = diagram_name;
    end

    try
        % Create the operating condition task
        opcond_node = OperatingConditions.OperatingConditionTask(diagram_name,opspec);
    catch Ex
        close(wb)
        rethrow(Ex);
    end
    
    waitbar(0.9,wb)
    % Add the operating specifications node and add it to the project
    if isempty(children)
        project.addNode(opcond_node);
    else
        connect(opcond_node,project.down,'right')
    end

    FRAME.expandNode(opcond_node.getTreeNodeInterface)
    project.OperatingConditions = opcond_node;
    waitbar(1,wb)
    close(wb)
end
