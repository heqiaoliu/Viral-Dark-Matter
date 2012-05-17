function result = model_reference_rtw_target(relevantMachineName)
   if ~strcmp(lower(get_param(relevantMachineName,'BlockDiagramType')),'library')
      mdlTarget = get_param(relevantMachineName,'ModelReferenceTargetType');
      result = strcmpi(mdlTarget, 'RTW');
   else
      result = 0;
   end
       
       