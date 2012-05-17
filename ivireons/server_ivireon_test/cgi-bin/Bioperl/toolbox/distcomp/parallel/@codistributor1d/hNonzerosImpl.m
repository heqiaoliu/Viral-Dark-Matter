function [LP, codistr] = hNonzerosImpl(codistr, LP)
% hNonzerosImpl:  Implementation of nonzeros for codistributor1d 

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/11 15:40:26 $
    
% if codistributor is 1D but not distributed in the appropriate 
% dimension to allow trivial computation, fix it
    if codistr.Dimension ~= length(codistr.Cached.GlobalSize) 
        destCodistr = codistributor1d(length(codistr.Cached.GlobalSize), ...
                                      codistributor1d.defaultPartition(codistr.Cached.GlobalSize(end)), ...
                                      codistr.Cached.GlobalSize);
        LP = distributedutil.Redistributor.redistribute(codistr, LP, destCodistr);
    end
    % perform trivial nonzeros computation and send results back as a column vector
    LP = nonzeros(LP);
            
    part = gcat(length(LP));
    sz = [sum(part), 1];
    dim = 1;
    codistr = codistributor1d(dim, part, sz);
end % End of hNonzerosImpl.
