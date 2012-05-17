function varargout = globalIndices(D, dim, lab)
%globalIndices Global indices for the local part of a codistributed array
%   The global indices for the local part of a codistributed array is the
%   index range in a given dimension for the associated codistributed array on
%   a particular lab.  It is important to understand the underlying
%   distribution scheme of the codistributed array before calling the
%   globalIndices method for the following reasons:
%   
%   - If an array uses the '1d' distribution, one can get a complete
%     understanding of which labs store which elements of the array by calling
%     globalIndices for the distribution dimension of the array.
%   
%   - If an array uses the '2dbc' distribution, one needs to call
%     globalIndices for both the 1st and 2nd dimension to be able to deduce
%     which elements reside on which lab.
%   
%   - Although the globalIndices method is supported both for '1d' and '2dbc'
%     distribution schemes, it is possible that future distribution schemes
%     may not be able to support this method.
%   
%   With one output argument, K = globalIndices(D, DIM, LAB) returns a vector
%   K such that the specified lab stores information about some or all of the
%   elements with index K in the DIM-th dimension, i.e.  D(...,K, ...).  The
%   third argument of LAB is optional, and it defaults to LABINDEX.
%   
%   With two output arguments, [E,F] = globalIndices(D, DIM, LAB) returns two
%   integers E and F such that the specified lab stores information about some
%   or all of the elements with index in the range E:F in the DIM-th
%   dimension, i.e.  D(...,E:F,...).  The third argument of LAB is optional,
%   and it defaults to LABINDEX.
%   
%   Example: 
%   % with numlabs = 4
%   spmd
%      D = codistributed.zeros(2, 22, codistributor('1d',2,[6 6 5 5]));
%      if labindex == 1
%         KLab1 = globalIndices(D, 2);     % returns KLab1 = 1:6.
%      elseif labindex == 2
%         [ELab2, FLab2] = globalIndices(D, 2); % returns ELab2 = 7, FLab2 = 12.
%      end
%      KLab3 = globalIndices(D, 2, 3);     % returns KLab3 = 13:17.
%      [ELab4, FLab4] = globalIndices(D, 2, 4); % returns ELab4 = 18, FLab4 = 22.
%   end
%   
%   On exiting the example spmd block above, KLab1, ELab2, and FLab2 are variant 
%   arrays, while KLab3, ELab4, and FLab4 are replicated.    
%   
%   See also codistributed/getLocalPart, codistributed/getCodistributor.


%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/12 17:29:01 $

error(nargchk(2, 3, nargin, 'struct'));

if ~isa(D, 'codistributed')
    error('distcomp:globalIndices:firstInput', ...
          'First argument must be a codistributed array.')
end

if nargin < 3
    lab = labindex;
end

% Defer everything to the codistributor, including the error checking of the
% arguments.
dist = getCodistributor(D);
[varargout{1:nargout}] = dist.globalIndices(dim, lab);

end % End of globalIndices.
