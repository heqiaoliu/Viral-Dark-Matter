function ut_ResetPSpecs(loopdata) 
% UT_RESETPSPECS  Utility function to force recreation of any stale
% ParameterSpec object.
%
% Function is needed as workaround to geck 162245 which causes errors with
% undo of pzgroup deletion.
 
% Author(s): A. Stothert 08-Dec-2005
% Copyright 2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/01/26 01:46:50 $

for ct_C = 1:numel(loopdata.C);
   for ct_PZGroup = 1:numel(loopdata.C(ct_C).PZGroup)
      pzGroup = loopdata.C(ct_C).PZGroup(ct_PZGroup);
      pSpec   = pzGroup.getParameterSpec;
      if ~ishandle(pSpec) || ~ishandle(pSpec.getID)
         %pSpec is stale, force recreation
         pzGroup.resetParameterSpec;
      end
   end
end