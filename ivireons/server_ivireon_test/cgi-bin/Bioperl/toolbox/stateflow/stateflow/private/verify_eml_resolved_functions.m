function ok = verify_eml_resolved_functions(targetId,resolvedFunctions)
%   Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.1.6.5 $
useBLAS=false;

if sf('feature','EML BlasSupport')
    useBLAS = target_code_flags('get',targetId,'blas');
end

ok = sf('Cg','verify_eml_resolved_functions',targetId,resolvedFunctions,useBLAS);
