function [LP, codistr] = hSparsifyImpl(codistr, fcn, LP)
; %#ok<NOSEM> % Undocumented

%   Implementation of hSparsifyImpl for codistributor1d.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/08/29 08:23:25 $

if codistr.Dimension > 2
    % Redistribute to have Dimension <= 2.  This changes the local part to be a
    % matrix on all labs, and allows us to call the "sparsifying" function on
    % it.
    destCodistr = codistributor1d(codistributor1d.unsetDimension, ...
                                  codistributor1d.unsetPartition, ...
                                  codistr.Cached.GlobalSize);
    LP = distributedutil.Redistributor.redistribute(codistr, LP, destCodistr);
    codistr = destCodistr;
end

LP = fcn(LP);

end % End of hSParsifyImpl.
