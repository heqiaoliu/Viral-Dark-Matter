function schema = PatternWizardMenu(callbackinfo) %#ok<INUSD>
    % Stateflow menu customization for the Stateflow pattern wizard.

%   Copyright 2008-2009 The MathWorks, Inc.

    schema = sl_container_schema;
    schema.label = '&Patterns';
    schema.childrenFcns = {@i_Decisions,...
                           @i_Loops,...
                           @i_Switches,...
                           @i_Custom_Add,...
                           @i_Custom_Save
                          };    
end

function schema = i_Decisions(callbackinfo)   
    % Add 'Add Pattern' item
    schema = sl_container_schema;
    schema.label = 'Add &Decision';
    schema.state = i_computeState(callbackinfo);
    schema.childrenFcns = {@i_AddIfThen,...
                           @i_AddIfThenElse,...
                           @i_AddIfThenElseIf,...
                           @i_AddIfThenElseIfElse,...
                           @i_AddIfThenElseifElseifElse,...
                           @i_AddNestedIf...
                          };    
end

function schema = i_Loops(callbackinfo)    
    schema = sl_container_schema;
    schema.label = 'Add &Loop';
    schema.state = i_computeState(callbackinfo);
    schema.childrenFcns = {@i_AddFor ,...
                           @i_AddWhile,...
                           @i_AddDoWhile,...
                          };    
end

function schema = i_Switches(callbackinfo)  
    schema = sl_container_schema;
    schema.label = 'Add &Switch';
    schema.state = i_computeState(callbackinfo);
    schema.childrenFcns = {@i_AddSwitch2,...
                           @i_AddSwitch3,...
                           @i_AddSwitch4...
                          };
end

function schema = i_AddFor(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&For...';
    schema.callback = @i_AddForCallback;
end

function i_AddForCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {...
              'Description:',...
              'Initializer expression (index=0):',...
              'Loop test expression (index<MAX):',...        
              'Counting expression (index++):',...
              'For loop body \{action\}:'
    };
    dlgTitle = 'Stateflow Pattern: for(index=0; index<N; index++) {action}';
    defStr = {'','','','',''};    
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_forloop_');            
        for i=1:length(ids)
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{5}) && strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{5}))
                elseif( ~isempty(inputStr{4}) &&  strcmp(currObj.LabelString, '{index++}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{4}))
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '[index<MAX]'))
                    i_SetLabelString(currObj, ['[' inputStr{3} ']'])
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '{index=0}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{2}))
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddWhile(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&While...';
    schema.callback = @i_AddWhileCallback;
end

function i_AddWhileCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description: ','While condition:','Do action:'};
    dlgTitle = 'Stateflow Pattern: While(condition) {Do action}';    
    defStr = {'','',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr,options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_while_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{2} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddDoWhile(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&DoWhile...';
    schema.callback = @i_AddDoWhileCallback;
end

function i_AddDoWhileCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description:','Do action:','While condition:'};
    dlgTitle = 'Stateflow Pattern: Do{action} While (condition) ';    
    defStr = {'','',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);
 
    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_dowhile_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{2}))
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{3} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddIfThen(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&If...';
    schema.callback = @i_AddIfThenCallback;
end

function i_AddIfThenCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description:','If condition:','If action:'};
    dlgTitle = 'Stateflow Pattern: IF';    
    defStr = {'','',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_if_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{2} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddIfThenElse(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = 'If-&Else...';
    schema.callback = @i_AddIfThenElseCallback;
end

function i_AddIfThenElseCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description:','If condition:','If action:','Else action:'};
    dlgTitle = 'Stateflow Pattern: IF-ELSE';    
    defStr = {'','','',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_ifelse_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{4}) &&  strcmp(currObj.LabelString, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{4}))
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, [ '[' inputStr{2} ']' ])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddIfThenElseIf(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = 'If-E&lseif...';
    schema.callback = @i_AddIfThenElseIfCallback;
end

function i_AddIfThenElseIfCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description:','If condition:','If action:',...
              'Elseif condition:','Else action:'};
    dlgTitle = 'Stateflow Pattern: IF-ELSEIF';    
    defStr = {'','','', '',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_ifelseif_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{5}) &&  strcmp(currObj.LabelString, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{5}))
                elseif( ~isempty(inputStr{4}) &&  strcmp(currObj.LabelString, '[condition2]'))
                    i_SetLabelString(currObj, ['[' inputStr{4} ']' ])
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{2} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddIfThenElseIfElse(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = 'If-Elsei&f-Else...';
    schema.callback = @i_AddIfThenElseIfElseCallback;
end

function i_AddIfThenElseIfElseCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description:','If condition:','If action:',...
              'Elseif condition:','Elseif action:', 'Else action:'};
    dlgTitle = 'Stateflow Pattern: IF-ELSEIF-ELSE';    
    defStr = {'','', '','','',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_ifelseifelse_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{6}) &&  strcmp(currObj.LabelString, '{action3}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{6}))                    
                elseif( ~isempty(inputStr{5}) &&  strcmp(currObj.LabelString, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{5}))
                elseif( ~isempty(inputStr{4}) &&  strcmp(currObj.LabelString, '[condition2]'))
                    i_SetLabelString(currObj, ['[' inputStr{4} ']'])
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))                    
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{2} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))                    
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddIfThenElseifElseifElse(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = 'If-El&seif-Elseif-Else...';
    schema.callback = @i_AddIfThenElseifElseifElseCallback;
end

function i_AddIfThenElseifElseifElseCallback(callbackinfo) 
    options=i_GetOptions;
    prompt = {'Description:','If condition:','If action:',...
              'Elseif condition:','Elseif action:', 'Elseif condition:',...
              'Elseif action:','Else action:'};
    dlgTitle = 'Stateflow Pattern: IF-ELSEIF-ELSEIF-ELSE';    
    defStr = {'','', '','','','','',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_ifelseifelseifelse_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if strcmp(currObj.LabelString, '')
                elseif strcmp(currObj.LabelString, '?')
                elseif( ~isempty(inputStr{8}) &&  strcmp(currObj.LabelString, '{action4}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{8}))
                elseif( ~isempty(inputStr{7}) &&  strcmp(currObj.LabelString, '{action3}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{7}))
                elseif( ~isempty(inputStr{6}) &&  strcmp(currObj.LabelString, '[condition3]'))
                    i_SetLabelString(currObj, ['[' inputStr{6} ']'])
                elseif( ~isempty(inputStr{5}) &&  strcmp(currObj.LabelString, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{5}))
                elseif( ~isempty(inputStr{4}) &&  strcmp(currObj.LabelString, '[condition2]'))
                    i_SetLabelString(currObj, ['[' inputStr{4} ']'])
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{2} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddNestedIf(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&Nested-If...';
    schema.callback = @i_AddNestedIfCallback;
end

function i_AddNestedIfCallback(callbackinfo) 
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
    prompt = {'Description:','If condition:',...
              'If action:','Nested-if condition:','Nested-if action:'};
    dlgTitle = 'Stateflow Pattern: Nested IF';    
    defStr = {'','','', '',''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt,dlgTitle,1,defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_nestedif_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                if( ~isempty(inputStr{5}) && strcmp(currObj.LabelString, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{5}))
                elseif( ~isempty(inputStr{4}) &&  strcmp(currObj.LabelString, '[condition2]'))
                    i_SetLabelString(currObj, ['[' inputStr{4} ']'])
                elseif( ~isempty(inputStr{3}) &&  strcmp(currObj.LabelString, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{3}))
                elseif( ~isempty(inputStr{2}) &&  strcmp(currObj.LabelString, '[condition1]'))
                    i_SetLabelString(currObj, ['[' inputStr{2} ']'])
                elseif( ~isempty(inputStr{1}) &&  strcmp(currObj.LabelString, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

% =======================================================================
% Switch pattern wizards
% =======================================================================

function schema = i_AddSwitch2(callbackinfo) %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&2 Cases and default ...';
    schema.callback = @i_AddSwitch2Callback;
end

function i_AddSwitch2Callback(callbackinfo) 
    options = i_GetOptions;  %% xxx i_AddNestedIfCallback is different -- why?
    prompt = {...
              'Description',...
              'Switch expression',...
              'First case label',...
              'First case body',...
              'Second case label',...
              'Second case body',...
              'Default case body'...
             };
    dlgTitle = 'Stateflow Pattern: switch (dispatch) { case N: action ... }';
    defStr = {'', '', '', '', '', '', ''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt, dlgTitle, 1, defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_switch2_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                labelStr = currObj.LabelString;
                dispatchExpr = inputStr{2};
               if strcmp(labelStr, '')
                elseif strcmp(labelStr, '?')
                elseif( ~isempty(inputStr{7}) &&  strcmp(labelStr, '{defaultAction}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{7}));
                elseif( ~isempty(inputStr{6}) &&  strcmp(labelStr, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{6}));
                elseif( ~(isempty(inputStr{5}) && isempty(dispatchExpr)) &&  strcmp(labelStr, '[case2]'))
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{5}));
                elseif( ~isempty(inputStr{4}) &&  strcmp(labelStr, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{4}));
                elseif( ~isempty(inputStr{3}) &&  strcmp(labelStr, '[case1]'))
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{3}));
                elseif( ~isempty(inputStr{1}) &&  strcmp(labelStr, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddSwitch3(callbackinfo) %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&3 Cases and default ...';
    schema.callback = @i_AddSwitch3Callback;
end

function i_AddSwitch3Callback(callbackinfo) 
    options = i_GetOptions;
    prompt = {...
              'Description',...
              'Switch expression',...
              'First case label',...
              'First case body',...
              'Second case label',...
              'Second case body',...
              'Third case label', ...
              'Third case body', ...
              'Default case body'...
             };
    dlgTitle = 'Stateflow Pattern: switch (dispatch) { case N: action ... }';
    defStr = {'', '', '', '', '', '', '', '', ''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt, dlgTitle, 1, defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_switch3_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                labelStr = currObj.LabelString;
                dispatchExpr = inputStr{2};
                if strcmp(labelStr, '')
                elseif strcmp(labelStr, '?')
                elseif strcmp(labelStr, '{defaultAction}')
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{9}));
                elseif strcmp(labelStr, '{action3}')
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{8}));
                elseif strcmp(labelStr, '[case3]')
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{7}));
                elseif strcmp(labelStr, '{action2}')
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{6}));
                elseif strcmp(labelStr, '[case2]')
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{5}));
                elseif strcmp(labelStr, '{action1}')
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{4}));
                elseif strcmp(labelStr, '[case1]')
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{3}));
                elseif strcmp(labelStr, '/*comment*/')
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function schema = i_AddSwitch4(callbackinfo) %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = '&4 Cases and default...';
    schema.callback = @i_AddSwitch4Callback;
end

function i_AddSwitch4Callback(callbackinfo) 
    options = i_GetOptions;
    prompt = {...
              'Description',...
              'Switch expression',...
              'First case label',...
              'First case body',...
              'Second case label',...
              'Second case body',...
              'Third case label', ...
              'Third case body', ...
              'Fourth case label', ...
              'Fourth case body', ...
              'Default case body'...
             };
    dlgTitle = 'Stateflow Pattern: switch (dispatch) { case N: action ... }';
    defStr = {'', '', '', '', '', '', '', '', '', '', ''};
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    inputStr = inputdlg(prompt, dlgTitle, 1, defStr, options);
    if ~isempty(inputStr)
        [modelH, csrc, ids] = i_LoadPattern('sf_pw_switch4_');            
        for i=1:length(ids)                 
            currObj = idToHandle(sfroot, ids(i));
            if strcmp(class(currObj), 'Stateflow.Transition')
                labelStr = currObj.LabelString;
                dispatchExpr = inputStr{2};
                if strcmp(labelStr, '')
                elseif strcmp(labelStr, '?')
                elseif( ~isempty(inputStr{11}) && strcmp(labelStr, '{defaultAction}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{11}));
                elseif( ~isempty(inputStr{10}) && strcmp(labelStr, '{action4}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{10}));
                elseif( ~isempty(inputStr{9}) && strcmp(labelStr, '[case4]'))
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{9}));
                elseif( ~isempty(inputStr{8}) && strcmp(labelStr, '{action3}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{8}));
                elseif( ~(isempty(inputStr{7}) && isempty(dispatchExpr)) && strcmp(labelStr, '[case3]'))
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{7}));
                elseif( ~isempty(inputStr{6}) && strcmp(labelStr, '{action2}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{6}));
                elseif( ~isempty(inputStr{5}) && strcmp(labelStr, '[case2]'))
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{5}));
                elseif( ~isempty(inputStr{4}) && strcmp(labelStr, '{action1}'))
                    i_SetLabelString(currObj, i_ConvertToAction(inputStr{4}));
                elseif( ~isempty(inputStr{3}) && strcmp(labelStr, '[case1]'))
                    i_SetLabelString(currObj, i_MakeSwitchCase(dispatchExpr, inputStr{3}));
                elseif( ~isempty(inputStr{1}) && strcmp(labelStr, '/*comment*/'))
                    i_SetLabelString(currObj, i_InsertComment(inputStr{1}))
                end
            end
        end
        i_PastePattern(modelH, csrc, dst, callbackinfo);
    end
end

function caseExpr = i_MakeSwitchCase(dispatchExpr, constantExpr)
    % construct the Stateflow expression corresponding to the switch case
    %  dispatchExpr: expression on whose value we dispatch
    %  constantExpr: label for particular case
    % e.g., in switch(x) { case 1: ... }
    %  dispatchExpr = 'x' and constantExpr = '1'.
    caseExpr = ['[' dispatchExpr ' == ' constantExpr ']'];
end

function fullPath = i_GetFullPathToSfPattern(pattern)
    % returns the path to a shipping SF pattern.
    scriptPath = mfilename('fullpath');
    scriptDir = fileparts(scriptPath);
    scriptDir = fileparts(scriptDir); % go up two levels
    fullPath = fullfile(scriptDir, 'patterns', pattern);
end

%{
% i_AddPattern is called by the various callbacks with user requested
% pattern as the only argument
function i_AddPattern(pattern, dst, cbInfo)
    try
        fullPath = i_GetFullPathToSfPattern(pattern);
        h = load_system(fullPath);
        bd = get_param(h, 'Object');
        m = bd.find('-isa', 'Stateflow.Machine');
        csrc = m.find('-isa','Stateflow.Chart');

        % Copy over the stuff using the 'Copy' method. Same thing used from
        % the menu bar.
        objCh = csrc(1).find('-isa','Stateflow.Object','-not','-isa','Stateflow.Event',...
                             '-not','-isa','Stateflow.Target','-not','-isa','Stateflow.Data',...
                             '-not','-isa','Stateflow.Chart');
        ids = zeros(size(objCh));
        for i=1:length(objCh)
            ids(i) = objCh(i).Id;
        end
        sf('Select', csrc.Id, ids);
        sf('Copy', csrc.Id);

        cdst = dst.find('-isa','Stateflow.Chart');
        % G553611: selection list may not be a chart. handle this
        if(isempty(cdst))
            cdst = dst(1).Chart;
        end
        i_paste(cdst.id, cbInfo);
        
        close_system(h, 0);
    catch %#ok<CTCH>
        errordlg(DAStudio.message('Stateflow:patternwiz:ErrorAddingPattern'), 'Add Pattern Error', 'modal');
    end
end
%}

function [modelH, csrc, ids] = i_LoadPattern(pattern)
    modelH = 0.0;
    csrc = [];
    ids = [];
    try
        fullPath = i_GetFullPathToSfPattern(pattern);
        modelH = load_system(fullPath);
        bd = get_param(modelH, 'Object');
        m = bd.find('-isa', 'Stateflow.Machine');
        csrc = m.find('-isa','Stateflow.Chart');

        % Copy over the stuff using the 'Copy' method. Same thing used from
        % the menu bar.
        objCh = csrc(1).find('-isa','Stateflow.Object','-not','-isa','Stateflow.Event',...
                             '-not','-isa','Stateflow.Target','-not','-isa','Stateflow.Data',...
                             '-not','-isa','Stateflow.Chart');
        ids = zeros(size(objCh));
        for i=1:length(objCh)
            ids(i) = objCh(i).Id;
        end
        sf('Select', csrc.Id, ids);
    catch %#ok<CTCH>
        errordlg(DAStudio.message('Stateflow:patternwiz:ErrorAddingPattern'), 'Add Pattern Error', 'modal');
    end
end
      
function i_PastePattern(modelH, copyFromChartUdd, pasteToUddObjs, cbInfo)
    try
        i_copyAndPaste(copyFromChartUdd, pasteToUddObjs, cbInfo);
        close_system(modelH, 0);
    catch %#ok<CTCH>
        errordlg(DAStudio.message('Stateflow:patternwiz:ErrorAddingPattern'), 'Add Pattern Error', 'modal');
    end
end

function options=i_GetOptions
    options.Resize='on';
    options.WindowStyle='modal';
    options.Interpreter='tex';
end
% ================================================================================
% Stuff for custom patterns
% ================================================================================
function schema = i_Custom_Add(callbackinfo)     
    schema = sl_action_schema;
    schema.label = 'Add &Custom';
    schema.state = i_computeState(callbackinfo);
    schema.callback = @i_BrowseAddPatternCustom;    
end

% Add 'Save to Pattern' item
function schema = i_Custom_Save(callbackinfo)     %#ok<INUSD>
    schema = sl_action_schema;
    schema.label = 'Save Pattern';
    schema.callback = @i_BrowseSavePatternCustom;                             
end

function dirname = i_GetCustomPatternDir
    dirname = sfpref('PatternWizardCustomDir');
    if ~ischar(dirname) || ~isdir(dirname)
        uiwait(warndlg(DAStudio.message('Stateflow:patternwiz:ChooseCustomPatternDir')));
        dirname = uigetdir('Pick a directory for storing custom patterns');
        if ischar(dirname) && isdir(dirname)
            % save it for further use.
            sfpref('PatternWizardCustomDir', dirname);
        end
    end
end

function fullPath = i_GetPathToCustomPattern(patternName)
    % returns the full path to a pattern stored in the user's custom
    % patterns directory.

    dirname = i_GetCustomPatternDir();
    if isdir(dirname)
        fullPath = fullfile(dirname, patternName);
    else
        fullPath = '';
    end
end

function i_BrowseSavePatternCustom(callbackinfo)     
    if ~strcmp(get_param(bdroot, 'Dirty'), 'on')
        src=i_GetSelection(callbackinfo);
        if i_Custom_isAnySFObjSelected(src)

            customDir = i_GetCustomPatternDir();
            [FileName, Path] = uiputfile(fullfile(customDir, '*.mdl'),'Save Pattern As');
            % XXX: It would be nice if we could detect whether the Path
            % chosen now and customDir are the same. Unfortunately, with
            % things like network paths, symlinks etc, this is a hard
            % problem to solve reliably.

            if (FileName)
                modelName = strrep(FileName, '.mdl', '');
                try
                    new_system(modelName);
                    sfBlk = strcat(modelName, '/Chart');
                    load_system('sflib');
                    add_block('sflib/Chart', sfBlk);
                    i_SavePatternCustom(src, modelName, callbackinfo);
                    save_system(modelName, fullfile(Path, FileName));
                    close_system(modelName);
                catch %#ok<CTCH>
                    errordlg(DAStudio.message('Stateflow:patternwiz:UnableToCreatePattern'), ...
                                              'Save Pattern', 'modal');
                    disp(DAStudio.message('Stateflow:patternwiz:FindLoadedModelsTip'));
                end
            end
        end
    else
        % XXX: Why is this really annoying thing necessary? Cannot find a
        % valid reason for it having to save a model!
        errordlg(DAStudio.message('Stateflow:patternwiz:UnsavedChangesError') ,'Save Pattern', 'modal');
    end
end

function i_BrowseAddPatternCustom(callbackinfo)     
    dst=i_GetSelection(callbackinfo);
    i_clearSelection(callbackinfo);

    customDir = i_GetCustomPatternDir();
    d = dir(fullfile(customDir, '*.mdl'));
    str = {d.name};
    if ~isempty(str)
        for i=1:length(str)
            str{i} = strrep(str{i},'.mdl','');
        end
        [s,v] = listdlg('PromptString','Select a Custom Pattern:',...
                        'SelectionMode','single',...
                        'ListString',str); %#ok<NASGU>

        if ~isequal(s,[])
            filename = str{s};
            i_AddPatternCustom(filename, dst, callbackinfo);
        end
    else
        errordlg(DAStudio.message('Stateflow:patternwiz:NoSavedPatternsFound'), ...
                                  'Browse Patterns error', 'modal');
    end
end

function isSFObjSelected = i_Custom_isAnySFObjSelected(dst)
    if isempty(dst.find('-isa', 'Stateflow.Chart'))
        isSFObjSelected=1;
    else
        errordlg(DAStudio.message('Stateflow:patternwiz:SelectAndTryAgain'), ...
                                  'Add Pattern Error', 'modal');
        isSFObjSelected=0;
    end
end

function i_AddPatternCustom(pattern, dst, callbackinfo)
    try
        % load the selected pattern from the custom_patterns folder which
        % is located one directory level above where sl_customization is
        % located
        fullPath = i_GetPathToCustomPattern(pattern);
        h = load_system(fullPath);
        
        % If the custom pattern has already been opened by the user, do not
        % attempt to close it. It might have unsaved changes etc. g472302
        closeSrc = 1;
        if strcmpi(get_param(h, 'open'), 'on')
            closeSrc = 0;
        end
        
        bd = get_param(h, 'Object');
        m = bd.find('-isa', 'Stateflow.Machine');
        csrc = m.find('-isa','Stateflow.Chart');

        if isempty(csrc)
            % check for model without any charts
            errStr = DAStudio.message('Stateflow:patternwiz:ModelHasNoSFCharts', pattern);
            errordlg(errStr,'Add Pattern Warning','modal'); 
            return;
            % check for model without more than one chart
        elseif length(csrc) > 1
            warnStr = DAStudio.message('Stateflow:patternwiz:MoreThanOneSFChart', pattern);
            msgbox(warnStr, 'Add Pattern Warning', 'warn', 'modal');
        end

        % filter-out non-graphical objects from clipboard
        objCh = csrc(1).find('-isa','Stateflow.Object','-not','-isa','Stateflow.Event',...
                             '-not','-isa','Stateflow.Target','-not','-isa','Stateflow.Data',...
                             '-not','-isa','Stateflow.Chart');
                   
        % Check for model with empty chart
        if length(objCh) <= 1
            errStr = DAStudio.message('Stateflow:patternwiz:ModelContainsEmptyChart', csrc(1).Name);
            errordlg(errStr,'Add Pattern Warning','modal'); 
        end
                         
        ids = zeros(length(objCh),1);
        for i=1:length(objCh)
            ids(i) = objCh(i).Id;
        end
        sf('Select', csrc.Id, ids);
        i_copyAndPaste(csrc, dst, callbackinfo);
        
        if closeSrc
            close_system(h, 0);
        end
    catch %#ok<CTCH>
        errordlg(DAStudio.message('Stateflow:patternwiz:ErrorAddingPattern'), 'Add Pattern Error', 'modal');
    end
end

% Callback to Save pattern
function i_SavePatternCustom(src, modelName, callbackinfo)
    rt=sfroot;
    cdst = rt.find('-isa', 'Stateflow.Machine', '-and','Name',modelName); 
    cdst_C = cdst.find('-isa','Stateflow.Chart'); 
    objCh = src;  
    cb=sfclipboard;
    cb.copy(objCh(1:end));
    i_paste(cdst_C.id, callbackinfo);
end
% ================================================================================
% Helper functions
% ================================================================================
function str=i_InsertComment(inputStr)
    % Convert the string into a C style string if its not empty
    if ~isempty(inputStr)
        str=sprintf('/* %s */\n',inputStr);
    else
        str='';
    end
end

function str=i_ConvertToAction(inputStr)
    % Add a semi-colon to the end only if there isn't already one.
    % If the string is already empty, we just return an empty string.
    if ~isempty(inputStr)
        if inputStr(end) ~= ';'
            str = ['{' inputStr ';}'];
        else
            str = ['{' inputStr '}'];
        end
    else
        str = '';
    end
end

function retval = i_GetSelection(cbInfo)
    % Gets the current selection. If no graphical items are selected,
    % returns the current editor.
    ctxEditor = i_getCurrentEditor(cbInfo);
    
    if( slfeature('SLGlueBigSwitch') ) % New editor
        selectionObjs = cbInfo.studio.App.getActiveEditor.getSelection;
        selection = zeros(1, selectionObjs.size);
        for i=1:selectionObjs.size
            selection(i) = double(selectionObjs(i).backendId);
        end
    else
        selection = sf('SelectedObjectsIn', ctxEditor);
    end 
    
    if isempty(selection)
        retval = ctxEditor;
    else
        retval = selection;
    end
    retval = idToHandle(sfroot, retval);
end

function i_SetLabelString(o, str)
    % Sets the label of an object.
    % We use the sf API rather than UDD to preserve the Undo stack.
    sf('set', o.Id, '.labelString', str);
end

function state = i_computeState(cbInfo)
    % Computes wether to show this menu or not. 
    if sf('IsChartEditorIced', i_getCurrentEditor(cbInfo))
        state = 'Disabled';
    else
        state = 'Enabled';
    end
end

function i_clearSelection(cbInfo)
    if( slfeature('SLGlueBigSwitch') ) % New editor
        cbInfo.studio.App.getActiveEditor.clearSelection;
    else
        sf('Select', i_getCurrentEditor(cbInfo), []); % Reset selection list
    end
end

function ctxEditor = i_getCurrentEditor(cbInfo)
    if( slfeature('SLGlueBigSwitch') ) % New editor
        subviewerId = double(cbInfo.studio.App.getActiveEditor.getDiagram.backendId);
        if( sf('get', subviewerId, '.isa') ~= 1 ) % Not chart
            ctxEditor = sf('get', subviewerId, '.chart');
        else
            ctxEditor = subviewerId;
        end
    else % Old editor
        ctxEditor = sf('CurrentEditorId');
    end
end

function i_paste(pasteId, cbInfo)
    sfc = Stateflow.Clipboard;
    if( slfeature('SLGlueBigSwitch') ) % New editor
        subviewer = cbInfo.studio.App.getActiveEditor.getDiagram;
        chart = subviewer.model.getRootDeviant;
        trans = M3I.Transaction(chart);
        pasteObjUdd = idToHandle(sfroot, double(subviewer.backendId) );
        sfc.pasteTo( pasteObjUdd );
        trans.commit;
    else
        pasteObjUdd = idToHandle(sfroot, pasteId );
        sfc.pasteTo( pasteObjUdd );
    end    
end

function i_copyAndPaste(copyFromChartUdd, pasteToUddObjs, cbInfo)
    sfc = Stateflow.Clipboard;
    sfc.copy( copyFromChartUdd.editor.selectedObjects );

    % G553611: selection list may not contain a chart
    chartUddObj = pasteToUddObjs.find('-isa','Stateflow.Chart');
    if(isempty(chartUddObj))
        chartUddObj = pasteToUddObjs(1).Chart;
    end

    i_paste(chartUddObj.id, cbInfo);
end
