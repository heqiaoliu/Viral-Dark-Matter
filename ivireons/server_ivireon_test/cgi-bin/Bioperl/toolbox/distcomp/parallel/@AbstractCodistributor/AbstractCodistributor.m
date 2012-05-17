%AbstractCodistributor Base class for all codistributors.  It should contain all
%the distribution-specific methods that codistributed needs access to in order
%for all of its methods to work with a distribution scheme.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.7.2.1 $  $Date: 2010/06/10 14:25:35 $
classdef AbstractCodistributor

    properties(SetAccess = protected)
        Cached = struct('GlobalSize', []);
    end

    % Set functions
    methods
        function obj = set.Cached(obj, cached)
        % Ensure that Cached.Global size is either empty or a valid size vector 
        % in MATLAB.
            if ~(isscalar(cached) && isstruct(cached) ...
                 && isfield(cached, 'GlobalSize') )
                error('distcomp:codistributor:invalidCachedData', ...
                      'Invalid cached data.');
            end

            if isempty(cached.GlobalSize)
                % Early bailout of error checking.  It is ok to have an 
                % unspecified global size.
                obj.Cached = cached;
                return;
            end

            if ~isrow(cached.GlobalSize)
                error('distcomp:codistributor:GlobalSizeNotVector', ...
                      'The global size must be a row vector.');
            end
            
            if ~(isnumeric(cached.GlobalSize) ...
                 && all(cached.GlobalSize == fix(cached.GlobalSize)))
                error('distcomp:codistributor:GlobalSizeNotSizeVec', ...
                      'The global size must be a vector of integers.');
            end
            % Always store the size as doubles.
            cached.GlobalSize = double(cached.GlobalSize);

            if length(cached.GlobalSize) == 1
                % Size vectors must be of length 2.
                error('distcomp:codistributor:GlobalSizeVectorTooShort', ...
                        'The global size should be a vector of length at least two.');                
            elseif length(cached.GlobalSize) > 2
                % They never have extraneous 1's at the end.
                cached.GlobalSize = distributedutil.Sizes.removeTrailingOnes(cached.GlobalSize);
            end
            obj.Cached = cached;                
        end % End of set.Cached.
    end

    % Define methods that are useful for implementers of this interface as 
    % protected and static.
    methods(Access = protected, Static)
        
        %pDispNamesAndValues(names, values) Display names and values as if they
        % were the field names and field values of a struct.
        % names and values must be cell arrays of strings, and they must be 
        % of equal length.
        %
        % Derived classes may find this method useful in their disp method.
        function pDispNamesAndValues(names, values)
            maxlen = max(cellfun(@(x) length(x), names));
            % MATLAB struct display puts 4 spaces at the left margin, followed 
            % by the field names.
            charsToColon = maxlen + 4;
            for i = 1:length(names)
                fprintf(['%', num2str(charsToColon), 's: %s\n'], ...
                        names{i}, values{i});
            end
        end

        % pWeightedSplit Divide a non-negative integer into pieces according to
        % weights
        % splitValues = pWeightedSplit(VALUE, WEIGHT) Split an integer VALUE >= 0
        % into a vector of integers splitValues using the weights provided
        % in WEIGHTS.  The length of splitValues equals the length of
        % WEIGHT, and sum(splitValues) equals VALUE.  The sum of WEIGHT
        % must be > 0 and all its elements must be >= 0.
        function splitValues = pWeightedSplit(value, weight)

            weight = weight/sum(weight);
            % We would get a perfect division of the value if we were to allow
            % fractions.
            fracVal = value*weight;
            % Allocate based on the integer portions.
            splitValues = floor(fracVal);

            % Look at the integers that are left.
            valLeft = value - sum(splitValues);

            % Allocate the remaining integers based on the fractional portions 
            % we have not yet addressed.  We address the fractional portions
            % according to order.
            fracVal = fracVal - splitValues;
            [~, ind] = sort(fracVal);

            % The labs where fractional portion is the largest get an additional 
            % 1 integer.
            ind = ind(end-valLeft + 1:end);
            splitValues(ind) = splitValues(ind) + 1;
        end

        % Throws an error if dim and lab are not valid input arguments for the
        % globalIndices method.  Error is thrown as caller.
        function pVerifyGlobalIndicesArgs(dim, lab)
            % Neither input may be codistributed.
            if isa(dim, 'codistributed') || isa(lab, 'codistributed')
                ex = MException(...
                    'distcomp:codistributor:globalIndices:InvalidCodistributed', ...
                    'Dimension and lab index must not be codistributed arrays.');
                throwAsCaller(ex);
            end

            % dim can be any valid dimension (including > ndims)
            if ~isscalar(dim) || ~isPositiveIntegerValuedNumeric(dim)
                ex = MException(...
                    'distcomp:codistributor:globalIndices:InvalidDimension', ...
                    ['Dimension must be a positive, integer-valued ' ...
                     'numeric scalar.']);
                throwAsCaller(ex);
            end
            % lab must be a valid labindex, i.e. >= 1 and <= numlabs.
            if ~distributedutil.CodistParser.isValidLabindex(lab)
                ex = MException(...
                    'distcomp:codistributor:globalIndices:InvalidLabIndex', ...
                      'Lab index must be a scalar between 1 and NUMLABS.');
                throwAsCaller(ex);
            end
        end
    end % End of protected, static methods.

    
    methods(Abstract, Hidden = true)
        % hBuildFromFcnImpl Construct a full-blown local part and the 
        % corresponding codistributor object from input arguments.  The input is
        % basically very compact representation of the matrix to create.
        %
        % sizesDvec is a non-empty vector of the global size of the matrix
        % className is either an empty string, or the name of a class
        % fcn is the function handle to the build function: zeros, ones, rand, 
        % sparse, cell, ...
        % The function handle must be invoked as fcn(sz1, sz2, ...)
        [LP, codistr] = hBuildFromFcnImpl(codistr, fcn, sizesDvec, className)

        % hBuildFromLocalPartImpl The method performs all necessary error 
        % checking on the local part LP and codistributor codistr, and return the
        % fully specified codistributor.
        %
        % buildOption is an enum of type distributedutils.BuildOption.
        codistr = hBuildFromLocalPartImpl(codistr, LP, buildOption)

        % hBuildFromReplicatedImpl Create the local part and the codistributor 
        % from the input.
        %
        % The matrix X contains the entire data to put into the
        % codistributed array.  If srcLab is 0, X is replicated, otherwise
        % it is the lab index of the lab that stores the full matrix X.
        [LP, codistr] = hBuildFromReplicatedImpl(codistr, srcLab, X)
        
        % hCellfunImpl Implementation of the cellfun method.
        outCellLPs = hCellfunImpl(codistr, fcn, inCellLPs, trailingArgs, cellfunNargout)

        % hClassUnderlyingImpl Returns the class of the data stored in the local
        % part.
        clz = hClassUnderlyingImpl(codistr, LP)
        
        % hColonImpl Implementation of the colon method.
        [LP, codistr] = hColonImpl(codistr, a, d, b)        
       
        % hDispImpl The implementation of the disp method on the codistributed
        % array.
        %
        % varName is the variable name to use.
        % maxStrLen is an approximate maximum length of the output display.
        %
        % header is the variable with the indexing expression and matrix is
        % the actual data.  The disp method only uses matrix, display uses
        % both.  The string matrix is formatted according to the
        % FormatSpacing setting, whereas header is not.
        [header, matrix] = hDispImpl(codistr, LP, varName, maxStrLen)

        % hElementwiseBinaryOpImpl Performs a binary operation on each of the 
        % elements.
        % 1) If codistrA is non-empty, it must be identical to codistr.
        % 2) If codistrB is non-empty, it must be identical to codistr.
        % 3) codistrA and codistrB must not both be empty.
        % 4) If codistrA is not empty, LPA represents the corresponding local
        %    part, otherwise, i.e. when codistrA is empty, LPA is a replicated 
        %    scalar.  Same rules apply for codistrB and LPB.
        [LP, codistr] = hElementwiseBinaryOpImpl(codistr, fcn, codistrA, LPA, codistB, LPB)

        % hElementwiseUnaryOpImpl Performs a unary operation on each of the 
        % elements of the local part.
        [LP, codistr] = hElementwiseUnaryOpImpl(codistr, fcn, LP)

        % hEyeImpl Implementation of the eye function.  
        % m and n have the same meaning as for eye, and they must both be
        % specified.  className must be a valid class name or the empty
        % string.
        [LP, codistr] = hEyeImpl(codistr, m, n, className)

        % hFieldnamesImpl Get structure field names of codistributed array.
        % optArg is either empty or the optional '-full' argument to fieldnames 
        names = hFieldnamesImpl(codistr, LP, optArg)
        
        % hFrobeniusNormImpl Calculates the frobenius norm given the local part.
        froNorm = hFrobeniusNormImpl(codistr, LP)
        
        % hGatherImpl Gather into a single array
        %
        % The destLab must be specified.  A value of 0 means to return the
        % gathered array on all labs, otherwise return [] on all labs except
        % destLab.
        X = hGatherImpl(codistr, LP, destLab)

        % hGetCompleteForSize Return a complete codistributor that is consistent with
        % the given global size.  It is permissible for this method to throw an
        % error should this not be possible.
        codistr = hGetCompleteForSize(codistr, wantedGlobalSize)

        % globalIndices has exactly the same calling syntax as globalIndices on
        % codistributed.  One can conceive of distributions schemes cannot
        % support the global indices method with the function signature that we
        % use.  Both 1D and 2DBC can, but if we were for example to distribute
        % the different diagonals to the different labs, we would not be able to
        % support globalIndices.  In that case, the method would always throw an
        % error.
        varargout = globalIndices(codistr, dim, lab)

        % hIsaUnderlyingImpl Tests the 'isa' for the data stored in the local 
        % part.
        tf = hIsaUnderlyingImpl(codistr, LP, clz)
        
        % hIsequaltemplateImpl Tests the contents of inCellLPs to be sure 
        % that they are equal.  This test is based on the function 'F', which 
        % will either be @isequal or @isequalwithequalnans.  
        tf = hIsequaltemplateImpl(codistr, F, inCellLPs)
        
        % hIsrealImpl Tests 'isreal' for the entire matrix given the local part.
        tf = hIsrealImpl(codistr, LP)
        
        % hIssparseImpl Tests 'issparse' for the data stored in the local part.
        tf = hIssparseImpl(codistr, LP)
        
        % hIsTriangularImpl Tests an entire matrix for triangularity given
        % the local part.  matrixType is a character indicating whether the
        % matrix is lower, upper, or not triangular; or that it is diagonal
        % or zero.
        matrixType = hIsTriangularImpl(codistr, LP)
        
        % hLog2Impl Calls 'log2' for the data stored in the local part 
        % to calculate LP = F .* 2.^E (returned in the order [F, E]).  If there is 
        % only one output argument, it should return Y such that LP = 2.^Y.
        exponentLP = hLog2Impl(codistr, LP, log2Nargout)

        % hMinMaxImpl Calculate min or max of an array along a dimension.
        % Size in dim must be > 1, and dim must be <= number of dimensions of
        % array.  LPY is the min/max of the array, fcnMinMax is either @min
        % or @max, and if wantI is true, LPI is index vector storing the
        % indices of the min/max.  If wantI is false, LPI equals [].
        [LPY, LPI, codistr] = hMinMaxImpl(codistr, fcnMinMax, LP, dim, wantI)

        % hNum2CellNoDimImpl Implementation of num2cell without any dimension 
        % arguments.  The overall array must not be empty.
        [LP, codistr] = hNum2CellNoDimImpl(codistr, LP);

        % hNumLabs Returns the number of labs this codistributor was created 
        % for.
        nlabs = hNumLabs(codistr)

        % hNnzImpl Returns the number of nonzeros in the entire matrix given the
        % local part.
        num = hNnzImpl(codistr, LP)       
        
        % hNzmaxImpl Returns the amount of storage for nonzero elements required 
        % by the entire matrix given the local part.
        amt = hNzmaxImpl(codistr, LP) 
        
        % hReductionOpAlongDimImpl Perform one of the reduction operations that 
        % take an optional dimension argument.
        %
        % dim is the dimension along which to perform the operation.  It is
        % either a valid dimension or 0, meaning the default dimension.  fcn
        % must be a function handle to a reduction function and must support
        % taking either 1 or 2 arguments (array, or array+dimension,
        % respectively): @all, @any, @prod, @sum, ...
        [LP, codistr] = hReductionOpAlongDimImpl(codistr, fcn, LP, dim)

        % hSpallocImpl Implementation of the spalloc static method for 
        % codistributed arrays.
        %
        % m, n, nzmx have exactly the same meaning as for the MATLAB
        % function spalloc.
        % Note: One must call hVerifySupportsSparse before calling this
        % method.
        [LP, codistr] = hSpallocImpl(codistr, m, n, nzmx)

        % hSparsifyImpl Perform a "sparsifying" operation on array.  
        % The fcn input argument is a function handle to a vectorized function that
        % takes one input and returns one output.  The input may be either full
        % or sparse, the output must be sparse and of the same class and size as
        % the input. For example, fcn could be @sparse or @spones.  
        % The codistributor and local part must correspond to a codistributed
        % matrix.
        % Note: It is not necessary to call hVerifySupportsSparse before
        % calling this method as this method is expected to be able to handle
        % the input it is given.
        [LP, codistr] = hSparsifyImpl(codistr, fcn, LP)

        % hSparseBuildImpl Implementation of the sparse(rows, cols, coDdnzs, ...)
        % instance method for codistributed arrays.
        % See also hSparsifyImpl.
        % [LP, codistr] = hSparseBuildImpl(rows, cols, coDdnzs, m, n, nzmx)

        % hSpeyeImpl Implementation of speye(m, n)
        % Note: One must call hVerifySupportsSparse before calling this
        % method.
        [LP, codistr] = hSpeyeImpl(codistr, m, n)

        % hTrilImpl Implementation of the tril function.  
        % Requires only the local part and codistributor of the input
        % matrix
        [LP, codistr] = hTrilImpl(codistr, LP, k)
        
        % hTriuImpl Implementation of the triu function.  
        % Requires only the local part and codistributor of the input
        % matrix
        [LP, codistr] = hTriuImpl(codistr, LP, k)

        %hVerifySupportsSparse Throw a a descriptive MException if
        %codistributor does not support sparse arrays.  Error is
        %thrown as caller.
        hVerifySupportsSparse(codistr)
    end
    
    methods (Hidden = true)

        %hCell2MatCheck(codistr, LP, dims) Return true if and only if
        %hCell2MatImpl(codistr, LP, dims) is supported.
        function tf = hCell2MatCheck(codistr, LP) %#ok<MANU,INUSD>
            tf = false;
        end

        function [LP, codistr] = hCell2MatImpl(codistr, LP) %#ok<INUSD>
            error('distcomp:codistributor:Cell2matUnsupported', ...
                      'CELL2MAT is not yet supported with %s.',...
                  class(codistr));
        end

        % hDiagCheck Returns a boolean flag that answers the question "The 
        % implementation function hDiag*Impl is a valid function for the 
        % codistributor, codistr".  This will be overloaded to return "true"
        % for any codistributor that supports diag.
        function tf = hDiagCheck(codistr) %#ok<MANU>
            tf = false;
        end % End of hDiagCheck
        
        % hDiagMatToVecImpl Implementation of the diag method with matrix 
        % input and vector output.
        function [vecLP, vecDist] = hDiagMatToVecImpl(codistr, matLP, k)   %#ok<STOUT,INUSD>
            error('distcomp:codistributor:DiagUnsupported', ...
                  '%s does not currently support the DIAG function.', class(codistr));
        end

        % hDiagVecToMatImpl Implementation of the diag method with vector 
        % input and matrix output.
        function [matLP, matDist] = hDiagVecToMatImpl(codistr, vecLP, k) %#ok<INUSD,STOUT>        
            error('distcomp:codistributor:DiagUnsupported', ...
                  '%s does not currently support the DIAG function.', class(codistr));
        end

        % hNonzerosCheck Returns a boolean flag that answers the question "The 
        % implementation function hNonzerosImpl is a valid function for the 
        % codistributor, codistr".  This will be overloaded to return "true"
        % only for supported codistributors.
        function tf = hNonzerosCheck(codistr) %#ok<MANU>
            tf = false;
        end % End of hNonzerosCheck
        
        % hNonzerosImpl Returns a vector of nonzeros that appear in the codistributed
        % matrix.  Order matters.  If the codistributed matrix is A, then the result is 
        % assumed to be ordered in agreement with the output V of [I, J, V] = find(A)
        % AbstractCodistributor sets the default behavior to throw an error.  This function
        % should be overloaded by any codistributor for which hNonzerosCheck returns true.
        function [LP, codistr] = hNonzerosImpl(codistr, LP)  %#ok<INUSD>
            error('distcomp:codistributor:NonzerosUnsupported', ...
                      '%s does not currently support the NONZEROS function.', class(codistr));
        end % End of hNonzerosImpl
        
           
        %hNum2CellWithDimCheck(codistr, LP, dims) Return true if and only if
        %hNum2CellWithDimImpl(codistr, LP, dims) is supported.
        function tf = hNum2CellWithDimCheck(codistr, LP, dims) %#ok<MANU,INUSD> 
            tf = false;
        end

        % hNum2CellWithDimImpl(codistr, LP, dims) Implementation of num2cell with dimension
        % arguments.  The dimensions must be non-empty, unique, sorted and
        % between 1 and ndims of the array.  The overall array must not be empty.
        function [LP, codistr] = hNum2CellWithDimImpl(codistr, LP, dims) %#ok<INUSD>
            error('distcomp:codistributor:Num2cellUnsupported', ...
                      'NUM2CELL is not yet fully supported with %s.',...
                  class(codistr));
        end
       
    end % End of hidden functions.  These may be over-ridden by subclasses.
    
    methods (Abstract)
        % iscomplete = isComplete(codistr) Return whether all information is
        % available.
        %    Returns true if and only if the codistributor has all of its
        %    information set.  This allows some operations to be done
        %    without requiring any global communication.
        D = Inf(varargin)
        iscomplete = isComplete(codistr)
        D = NaN(varargin)
    end % End of publicly visible abstract methods.
end
