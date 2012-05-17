function hasMatrixInput = checkRootInportDimensions(InportInfo)
     for i=1:length(InportInfo)
         if iscell(InportInfo{i})
            hasMatrixInput = Sldv.DataUtils.checkRootInportDimensions(InportInfo{i});             
         elseif isfield(InportInfo{i},'Dimensions')
             hasMatrixInput = ~isscalar(InportInfo{i}.Dimensions);
         else
             hasMatrixInput = false;
         end            
         if hasMatrixInput
            break;
         end
     end    
end