function sl_customization(cm)
% This is an sl_customization to add custom objectives, for details, see the documentation.

% Copyright 2006-2009 The MathWorks, Inc.
% $Revision 1.1.2.1 $

% The following three linds are required
objCustomizer = cm.ObjectiveCustomizer;
objCustomizer.addCallbackObjFcn(@addObjectives);
objCustomizer.callbackFcn{end}();

end

% Callback function to add custom objectives to the ObjectiveCustomizer,
% these new objectives will be in addition to the 4 pre-defined objectives
function addObjectives

% create the first custom objective
obj = rtw.codegenObjectives.Objective('ID1');
obj.setObjectiveName('my very 1st objective');
% add parameters to the objective
obj.addParam('GenerateReport', 'on');
obj.addParam('MatFileLogging', 1);
obj.addParam('SuppressErrorStatus', 'Off');
obj.addParam('OptimizeBlockIOStorage', 'Off');
obj.addParam('EfficientFloat2IntCast', 'Off');
obj.addParam('InlineInvariantSignals', 'Off');
% add checks to the objective
obj.addCheck('mathworks.codegen.CodeGenSanity');
obj.addCheck('mathworks.design.UnconnectedLinesPorts');
obj.addCheck('mathworks.design.RootInportSpec');
obj.addCheck('mathworks.design.Update');
% register the objective
obj.register();


% second custom objective
obj = rtw.codegenObjectives.Objective('ID2');
obj.setObjectiveName('my 2nd objective');
obj.addParam('MatFileLogging', 'On');
obj.addParam('OptimizeBlockIOStorage', 'Off');
obj.addParam('EfficientFloat2IntCast', 'Off');
obj.addParam('InlineInvariantSignals', 'Off');
obj.addCheck('mathworks.design.OutputSignalSampleTime');
obj.addCheck('mathworks.design.MergeBlkUsage');
obj.addCheck('mathworks.design.InitParamOutportMergeBlk');
obj.excludeCheck('mathworks.codegen.SolverCodeGen');
obj.register();


% custom objective defined by using inheritance
obj = rtw.codegenObjectives.Objective('ID3', 'Traceability');
obj.setObjectiveName('my traceability');
obj.modifyInheritedParam('GenerateTraceReportSf', 'Off');                                  % modify the setting only
obj.removeInheritedParam('ConditionallyExecuteInputs');                                    % remove the parameter
obj.addParam('MatFileLogging', 'On');                                             % add a new parameter
obj.addCheck('mathworks.codegen.SWEnvironmentSpec');        % modify the setting only
obj.removeCheck('mathworks.codegen.CodeInstrumentation');                    % remove the check
obj.addCheck('mathworks.design.MergeBlkUsage');                               % add a new check
obj.register();
                                                                                  
% custom objective defined by using inheritance based on another custom objective
obj = rtw.codegenObjectives.Objective('ID4', 'ID3');
obj.setObjectiveName('my 4th objective');
obj.removeInheritedParam('MatFileLogging');  
obj.modifyInheritedParam('GenerateTraceReportSf', 0);                                      % modify the setting only
obj.modifyInheritedParam('GenerateTraceReport', 0);
obj.register();

end


