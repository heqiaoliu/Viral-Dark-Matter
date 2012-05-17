function result = model_reference_sim_target(relevantMachineName)
   if ~strcmp(lower(get_param(relevantMachineName,'BlockDiagramType')),'library')
      mdlTarget = get_param(relevantMachineName,'ModelReferenceTargetType');
      result = strcmpi(mdlTarget, 'SIM');
   else
      result = 0;
   end
