function removeVar(h,varID,mfilename,fcnname)
 
if ischar(varID)
   ind = find(strcmp(varID,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
       strcmp(fcnname,h.DebugFunctionNames));
else
   ind = varID;
end
h.SelectionTable(ind) = [];
h.VariableName(ind) = [];
h.DebugMFiles(ind) = [];
h.DebugFunctionNames(ind) = [];



