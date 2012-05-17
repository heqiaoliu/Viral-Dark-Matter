function complete = isComplete(codistr)
%isComplete Return true if codistributor has all of its information set
%   If codistr is a codistributor object, isComplete(codistr) returns true if
%   and only if codistr has all of its fields set.  This can be done by
%   specifying values to all of the optional arguments when constructing the
%   codistributor.  This has also been done for all codistributors that are
%   obtained from a codistributed array.
%
%   Example:
%     spmd
%         codistr1 = codistributor2dbc();
%         isComplete(codistr1)  % Returns false.
%     end
%
%     spmd
%         D = codistributed.rand(1000, codistr1);
%         codistr2 = getCodistributor(D);
%         isComplete(codistr2)  % Returns true.
%     end
%
%   See also codistributor2dbc, codistributed/getCodistributor.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:00:16 $

%  Implementation for codistributor2dbc.

% Only need to check size, because everything else is set once the global size
% is specified.
complete = ~isempty(codistr.Cached.GlobalSize);
     
end % End of isComplete.
