function A = transposetemplate(A, transposeFcn)
% TRANSPOSETEMPLATE Template for TRANSPOSE and CTRANSPOSE
% transposeFcn is either @transpose or @ctranspose

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/12/03 19:00:49 $
 
    if ndims(A) > 2
        ME = MException(strcat('distcomp:codistributed:',...
                               func2str(transposeFcn), ...
                               ':matrixOnly'),...
                        '%s on ND codistributed arrays is not defined.', ...
                        upper(func2str(transposeFcn)) );
        throwAsCaller(ME)
    end

    codistr = getCodistributor(A);
    LP = getLocalPart(A);

    [LP, codistr] = codistr.hTransposeTemplateImpl(LP, transposeFcn); 

    A = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK>
end




