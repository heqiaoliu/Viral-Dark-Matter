%Redistributor Collection of undocumented utility functions that redistribute codistributed arrays.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/09/23 13:59:32 $
classdef Redistributor

    methods (Access = private, Static)

        function tf = pIs1DOnOneLab(codistr)
        %pIs1DHighDim Returns true iff input codistributor is codistributor1d with the
        %entire array on a single lab.
            tf = isa(codistr, 'codistributor1d') && nnz(codistr.Partition) == 1;
        end % End of pIs1DHighDim.
    end

    methods (Access = public, Static)
        % The entry point that handles all possible to- and from- distribution 
        % schemes.
        [LPB, codistrB] = redistribute(codistr, LP, destCodistr)

        BLP = redistributeInto(Acodistr, ALP, Bcodistr, BLP)
    end
        
end
