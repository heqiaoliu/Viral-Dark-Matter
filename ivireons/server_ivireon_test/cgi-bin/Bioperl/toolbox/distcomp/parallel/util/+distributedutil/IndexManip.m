%IndexManip Collection of private index manipulation functions to help with
%distributed, codistributed and codistributors.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/08 13:25:39 $

classdef IndexManip
    methods(Access = public, Static)
        function linIndA = minmaxIndToLinear(sizeA, dim, indA)
            %minmaxIndToLinear Convert index from min/max into a linear index
            % If indA is the index vector returned from calling either min or max, i.e.
            % [~, indA] = min(A, [], dim), and sizeA equals size(A), then
            %      linIndA = minmaxIndToLinear(sizeA, dim, indA)
            % returns the linear index into A that corresponds to indA.  I.e.,
            % A(linIndA(:)) equals min(A, [], dim).
            
            if ndims(indA) == 2 && (dim == 1 || dim == 2)
                % Optimization for the most common 2-D cases.
                
                % If, say, sizeA is [5, 10] and dim is 1, then indA is of length 10 and
                % it contains row-indices into A.  For i = 1:5, we therefore want to
                % get the linear indices corresponding to the index (indA(i), i).
                if dim == 1
                    %indA is the row index.
                    linIndA = sub2ind(sizeA, indA(:)', (1:sizeA(2)));
                else
                    %indA is the column index.
                    linIndA = sub2ind(sizeA, (1:sizeA(1))', indA(:));
                end
            else
                %General N-D
                %Construct input for sub2ind.
                % If, say, sizeA is [5, 10, 20] and dim is 3, then indA is of size
                % [5, 10].
                % For each index into indA, say i and j, we want to call
                % sub2ind(sizeA, i, j, indA(i, j)), but we want to do it in one
                % call to sub2ind.  First, we get the cell array that stores all
                % the indices into indA.  In our example, it would be {1:5, 1:10}.
                sizeIndAAsCell = num2cell(size(indA));
                inds = cellfun(@(idx) 1:idx, sizeIndAAsCell, 'UniformOutput', false);
                % Call ndgrid to get all combinations of the indices into indA as a cell
                % array.  In our example, it would be { repmat(1, 10, (1:5)'),
                % repmat(5, 1, (1:10)) }.
                % Preallocate Ind to get output from ndgrid into a cell array.
                Inds = cell(size(inds));
                [Inds{:}] = ndgrid(inds{:});
                % By adding indA into the dim'th position, we have the full N-D index
                % into A that corresponds to indA.
                Inds{dim} = indA;
                % Use sub2ind to convert the N-D index into a linear index.
                linIndA = sub2ind(sizeA, Inds{:});
            end
            
        end % End of minmaxIndToLinear.
        
        function linIndA = sortIndToLinear(dim, indA)
            %sortIndToLinear Convert index from sort into a linear index
            % If indA is the index vector returned from calling sort, i.e.
            % [~, indA] = sort(A, dim), then
            %      linIndA = sortIndexToLinearIndex(dim, indA)
            % returns the linear index into A that corresponds to indA.  I.e.,
            % A(linIndA) equals sort(A, dim).
            
            if ndims(indA) ~= 2 
                error('distcomp:IndexManip:sortIndToLinear:NotImplemented', ...
                    'Only matrices are supported.');
            end
            
            % Optimization for the most common 2-D cases.
            if dim == 1
                %indA is a matrix of row indices, and we provide the
                %column indices.
                cols = repmat((1:size(indA, 2)), size(indA, 1), 1);
                linIndA = sub2ind(size(indA), indA, cols);
            elseif dim == 2
                %indA is the column index and we provide the row
                %indices.
                rows = repmat((1:size(indA, 1))', 1, size(indA, 2));
                linIndA = sub2ind(size(indA), rows, indA);
            else % dim > ndims(A).
                 % Sort returns matrix of all ones, and the corresponding linear
                 % indices are 1:n.
                linIndA = reshape(1:numel(indA), size(indA));
            end
        end % End of sortIndToLinear.
    end
    
end
