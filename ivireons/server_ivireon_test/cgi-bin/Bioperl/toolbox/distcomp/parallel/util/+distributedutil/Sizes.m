%Sizes Collection of utility functions about array sizes.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/04/15 23:00:51 $

classdef Sizes

    methods ( Access = public, Static )
        function dim = firstNonSingletonDimension(sz)
        %   firstNonSingletonDimension(sz) returns the first nonsingleton
        %   dimension in the size vector sz.
        %
        %   By convention, the first nonsingleton dimension is DIM is 1 for
        %   scalars.
            dim = find(sz ~= 1, 1);
            if isempty(dim)
                dim = 1;   %X is a scalar
            end
        end % End of firstNonSingletonDimension.

        function dim = lastNonSingletonDimension(sz)
        %   lastNonSingletonDimension(sz) returns the last nonsingleton
        %   dimension in the size vector sz.
        %
        %   By convention, the last nonsingleton dimension is 2 for scalars and
        %   vectors.
            dim = find(sz ~= 1, 1, 'last');
            if isempty(dim)
                dim = 2;   %X is a scalar
            end
        end % End of lastNonSingletonDimension.

        function sz = removeTrailingOnes(sz)
        % sz = removeTrailingOnes(sz) Remove any trailing ones from size vector.
            
            lastNonSingleton = distributedutil.Sizes.lastNonSingletonDimension(sz);
            % Remove all ones that are after that last non-singleton dim
            % in dimensions > 2.
            sz(max(2, lastNonSingleton)+1:end) = [];
        end

        function tf = isSquareEmptyMatrix(sz)
        % True for 0-by-0 empty matrix
        % tf = isempty(A) && ndims(A) == 2 && size(A,1) == size(A,2);
            tf = length(sz) == 2 && all(sz == 0);
        end % End of isSquareEmptyMatrix.
    end
   
end
