%CODISTRIBUTOR1D 1D codistributor object for codistributed arrays
%   The 1D codistributor distributes arrays along a single specified dimension,
%   the distribution dimension, in a noncyclic, partitioned manner.
%   Conceptually, the overall global array could be reconstructed
%   by concatenating the various local parts along the distribution dimension.
%
%   Example: If an array is distributed across the second dimension, i.e., its
%   columns, each lab stores only some of the columns of the array.  The
%   Partition property of the codistributor specifies the number of columns
%   stored on each lab.  The Dimension property of 2 indicates distributed by
%   the second dimension, columns.
%    
%   Example: Look at how a 999-by-999 matrix is distributed by its columns using
%   the default partition.
%       spmd
%           N = 999;
%           codistr = codistributor1d(2, codistributor1d.unsetPartition, N]);
%           [e, f] = codistr.globalIndices(2);
%           fprintf('Lab %d stores columns %d:%d, a total of %d columns.\n', ...
%                    labindex, e, f, codistr.Partition(labindex) );
%       end
%   When run on 4 labs, this shows:
%       Lab 1 stores columns 1:250, a total of 250 columns.
%       Lab 2 stores columns 251:500, a total of 250 columns.
%       Lab 3 stores columns 501:750, a total of 250 columns.
%       Lab 4 stores columns 751:999, a total of 249 columns.
%
%   codistributor1d methods:
%     codistributor1d/codistributor1d  - Create 1D codistributor object
%     globalIndices    - Global indices for the local part corresponding to codistributor
%     isComplete       - Return true if codistributor has all of its information set
%     CELL    - Create codistributed cell array using codistributor
%     COLON   - Build codistributed arrays of the form j:d:k using codistributor
%     EYE     - Identity codistributed matrix using codistributor
%     FALSE   - False codistributed array using codistributor
%     INF     - Infinity codistributed array using codistributor
%     NAN     - Build codistributed array containing Not-a-Number using codistributor
%     ONES    - Ones codistributed array using codistributor
%     RAND    - codistributed array of uniformly distributed pseudorandom numbers using codistributor
%     RANDN   - codistributed array of normally distributed pseudorandom numbers using codistributor
%     SPALLOC - Allocate space for sparse codistributed matrix using codistributor
%     SPARSE  - Create sparse codistributed matrix using codistributor
%     SPEYE   - Overloaded to create a codistributed array
%     SPRAND  - Sparse uniformly distributed random codistributed matrix using codistributor
%     SPRANDN - Sparse normally distributed random codistributed matrix using codistributor
%     TRUE    - True codistributed array using codistributor
%     ZEROS   - Zeros codistributed array using codistributor
%
%   codistributor1d static methods and properties:
%     defaultPartition - Default partition across the labs
%     unsetDimension   - Value indicating unspecified distribution dimension
%     unsetPartition   - Value indicating unspecified distribution partition
%
%   codistributor1d object properties:
%     Dimension  - Distribution dimension of a codistributor
%     Partition  - Distribution partition of a codistributor
%
%   See also CODISTRIBUTOR, CODISTRIBUTED, CODISTRIBUTOR2DBC.

%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2010/05/03 16:06:09 $

classdef codistributor1d < TensorProductCodistributor
    % This class maintains the following private invariants:
    % 1) Sparsity of the local parts must match across all the labs
    % 2) size(LocalPart, codistr.Dimension) must equal 
    %    codistr.Partition(labindex).  
    % 3) In all dimensions other than codistr.Dimension, size(LocalPart, dim) must
    %    be the same across all the labs.
    % 4) The local parts must be the panels of the codistributed array:
    %    The sum of size(LocalPart, codistr.Dimension) across the labs must equal 
    %    the global size of the codistributed array in that dimension.
    % 5) All of the above must be consistent with the MATLAB convention that 
    %    for an array X, size(X, n) equals 1 if n > ndims(X).
    % 
    % Consequences of the above:  
    %    
    % a) LocalPart must be of size 0 in the distribution dimension when
    %    codistr.Partition(labindex) == 0.  
    % b) Take a particular example: numlabs is 2, global size is [5, 5],
    %    codistr.Dimension is 3.  Then codistr.Partition is either [1, 0] or [0, 1].
    %    If codistr.Partition is [1, 0], lab 1 has LocalPart of size [5, 5], and lab
    %    2 has LocalPart of size [5, 5, 0].
    % c) To generalize b), if codistr.Dimension exceeds the number of dimensions 
    %    of the codistributed array (i.e. length(codistr.Cached.GlobalSize), 
    %    the following must hold true:
    %    i)   codistr.Partition is 1 on exactly one lab, 0 on all other labs.
    %    ii)  On the lab where codistr.Partition is 1, ndims(LocalPart) equals the
    %         number of dimensions of the codistributed array.
    %    iii) On the lab where codistr.Partition is 0, ndims(LocalPart) equals
    %         codist.Dimension.
    properties(SetAccess = private)
        %Dimension  Distribution dimension of a codistributor
        %   codistr.Dimension is the distribution dimension of a codistributor1d object
        %   codistr.  
        %
        %   Example: If the distribution dimension is 2, the corresponding
        %   codistributed array is distributed by columns (dimension 2), and
        %   each lab only stores some of the columns of the array.  The number
        %   of columns stored on each lab is given by codistr.Partition.
        %
        %   See also codistributor1d/Partition, codistributor1d/unsetDimension.
        Dimension

        %Partition  Distribution partition of a codistributor
        %   codistr.Partition is the distribution partition of a codistributor1d object
        %   codistr.  
        %
        %   See also codistributor1d/Dimension, codistributor1d/unsetPartition, 
        %   codistributor1d/defaultPartition.
        Partition
    end

    methods(Access = private)
        function localK = pConvertGlobalDiagToLocal(codistr, globalK, labIndx)
        % This function computes the local diagonal number for lab number 
        % labIndx given the global diagonal number and the codistributor 
        % of the matrix of interest.  The variable labIndx can be a scalar
        % or a vector of lab indices.  If it is a vector, then localK will be 
        % a column vector with the same length as labIndx and globalK is 
        % equivalent to localK(i) on lab labIndx(i).
        % 
        % This function is valid for any natural number distribution dimension 
        % (codistr.Dimension == {1, 2, 3, 4, ...}) so long as 
        % numel(codistr.Cached.GlobalSize) == 2.

            cumPart = [0; cumsum(codistr.Partition')];
            if codistr.Dimension == 2
                localK = globalK - cumPart(labIndx);
            else
                localK = globalK + cumPart(labIndx);
            end    
        end % End of pConvertGlobalDiagToLocal
    end

    methods(Access = protected)
        function codistr = pTransposeCodistributor(codistr)
            sz = codistr.Cached.GlobalSize;
            dim = codistr.Dimension;

            if dim < 3
                % For dim = 1 or 2, (c)transpose modifies the 
                % codistr dimension.  
                dim = 3 - dim;
            end

            codistr = codistributor1d(dim, codistr.Partition, [sz(2), sz(1)]);
        end % End pTransposeCodistributor
    end
    
    % Implementation of abstract instance methods.
    methods(Hidden = true)
        [LP, codistr] = hBuildFromReplicatedImpl(codistr, srcLab, X)
        codistr = hBuildFromLocalPartImpl(codistr, LP, allowCommunication)

        function tf = hCell2MatCheck(codistr, LP) %#ok<MANU,INUSD>
            tf = true;
        end

        [LP, codistr] = hCell2MatImpl(codistr, LP)
        [LP, codistr] = hColonImpl(codistr, a, d, b)
        function tf = hDiagCheck(codistr) %#ok<MANU>
            tf = true;
        end % End of hDiagCheck.
        [vecLP, vecDist] = hDiagMatToVecImpl(codistr, matLP, k)
        [matLP, matDist] = hDiagVecToMatImpl(codistr, vecLP, k)        
        [header, matrix] = hDispImpl(codistr, LP, varName, maxStrLen)
        localLinInd = hFindDiagElementsInLocalPart(codistr)
        X = hGatherImpl(codistr, LP, destLab)

        function codistr = hGetCompleteForSize(codistr, wantedGlobalSize)
        % Return a codistributor that is based on the input codistributor and matches
        % the desired global size.
            if ~codistr.isComplete() ...
                    || ~isequal(codistr.Cached.GlobalSize, wantedGlobalSize)
                codistr = codistributor1d(codistr.Dimension, ...
                                          codistr.Partition, ...
                                          wantedGlobalSize);
            end
        end % End of hGetCompleteForSize.
        
        function dims = hGetDimensions(codistr)
            dims = codistr.Dimension;
        end
        varargout = hGlobalIndicesImpl(codistr, dim, lab)
        tf = hIsGlobalIndexOnLab(codistr, dim, gIndexInDim, lab)
        szs = hLocalSize(codistr, labidx)
        [LPY, LPI, codistr] = hMinMaxImpl(codistr, fcnMinMax, LP, dim, wantI)
        
        function tf = hNonzerosCheck(codistr) %#ok<MANU>
            tf = true;
        end % End of hNonzerosCheck.
        
        [LP, codistr] = hNonzerosImpl(codistr, LP)        

        function tf = hNum2CellWithDimCheck(codistr, LP, dim) %#ok<MANU,INUSD>
            tf = true;
        end % End of hNum2CellWithDimCheck.

        [LP, codistr] = hNum2CellWithDimImpl(codistr, LP, dims)

        function nlabs = hNumLabs(codistr)
            nlabs = numel(codistr.Partition);
        end

        [LP, codistr] = hReductionOpAlongDimImpl(codistr, fcn, LP, dim)
        [LP, codistr] = hSpallocImpl(codistr, m, n, nzmx)
        [LP, codistr] = hSparsifyImpl(codistr, fcn, LP)
        hVerifySupportsSparse(codistr)
    end

    properties (Constant = true)
        %unsetDimension Value indicating unspecified distribution dimension
        %   DIM = codistributor1d.unsetDimension returns the special
        %   value used by codistributor1d to indicate that a distribution
        %   dimension has not been specified.
        %
        %   Example:
        %       codistr = codistributor1d();
        %    returns a distribution scheme such that the value of
        %    codistr.Dimension equals codistributor1d.unsetDimension
        %
        %   See also codistributor1d, codistributor1d/unsetPartition,
        %   codistributor1d/defaultPartition.
        unsetDimension = 0;

        %unsetPartition Value indicating unspecified distribution partition
        %   DIM = codistributor1d.unsetDimension returns the special
        %   value used by codistributor1d to indicate that a distribution
        %   partition has not been specified.
        %
        %   Example:
        %       codistr = codistributor1d();
        %    returns a distribution scheme such that the value of
        %    codistr.Partition equals codistributor1d.unsetPartition
        %
        %   See also codistributor1d, codistributor1d/defaultPartition,
        %   codistributor1d/unsetDimension.
        unsetPartition = [];
    end % End of constant properties.

    % Public, static functions.
    methods(Static = true)
        par = defaultPartition(len);
    end % End of public, static methods.

    methods
        function dist = codistributor1d(varargin)
        %CODISTRIBUTOR1D   Create 1D codistributor object for codistributed arrays
        %   The 1D codistributor distributes arrays along a single, specified 
        %   distribution dimension, in a noncyclic, partitioned manner.
        %
        %   Each of the following forms a 1D codistributor object with its global
        %   size unspecified.  When provided, the distribution dimension and
        %   partition are set to DIM and PART, respectively, otherwise they are
        %   unspecified.  The resulting codistributor is incomplete because its
        %   global size is not specified.
        %   DIST = CODISTRIBUTOR1D() 
        %   DIST = CODISTRIBUTOR1D(DIM)
        %   DIST = CODISTRIBUTOR1D(DIM, PART)
        %   A codistributor constructed in this manner can then be used as an argument to
        %   other functions as a template codistributor when creating codistributed
        %   arrays.
        %
        %   DIST = CODISTRIBUTOR1D(DIM, PART, GSIZE) forms a codistributor object with
        %   distribution dimension DIM, distribution partition PART, and global size
        %   of its codistributed arrays GSIZE.  The resulting codistributor object is 
        %   complete and can therefore be used to build a codistributed array from its
        %   local parts with codistributed.build.
        %   If DIM equals codistributor1d.unsetDimension, the distribution dimension of 
        %   DIST is derived from GSIZE and is set to be the last non-singleton 
        %   dimension.  Similarly, if PART equals codistributor1d.unsetPartition, the 
        %   distribution partition of DIST is set to be the default partition for that 
        %   global size and distribution dimension.
        %
        %   The local part on lab LABIDX of a codistributed array using such a
        %   codistributor is of size GSIZE in all dimensions except DIM, where the
        %   size is PART(LABIDX). The local part has the same class and attributes
        %   as the overall codistributed array. Conceptually, the overall global
        %   array could be reconstructed by concatenating the various local parts
        %   along dimension DIM.
        %
        %   Example: Use a codistributor1d object to create an N-by-N matrix of ones,
        %   distributed by rows.
        %   N = 1000;
        %   spmd
        %       codistr = codistributor1d(1);  % 1 specifies first dimension (rows).
        %       D = codistributed.ones(N, codistr);
        %   end
        %
        %   Example: Use a fully specified codistributor1d object to create a trivial
        %   N-by-N codistributed matrix from its local parts.  Then visualize which 
        %   elements are stored on lab 2.
        %   N = 1000;
        %   spmd
        %       codistr = codistributor1d(codistributor1d.unsetDimension, ...
        %                                 codistributor1d.unsetPartition, ...
        %                                 [N, N]);  
        %       localSize = [N, N];
        %       localSize(codistr.Dimension) = codistr.Partition(labindex);
        %       localPart = labindex*ones(localSize);
        %       D = codistributed.build(localPart, codistr);
        %   end
        %   spy(D == 2);
        %
        %   See also CODISTRIBUTOR, CODISTRIBUTED, CODISTRIBUTOR2DBC.

            error(nargchk(0, 3, nargin, 'struct'));
            try
                [dim, part, gsize] = iParseConstructorArgs(varargin{:});
            catch e
                throw(e);
            end

            % Set the property so that we can benefit from all the error checking performed
            % in the parent class.
            dist.Cached.GlobalSize = gsize;
            % Get it again.  We then have a valid MATLAB size vector.
            gsize = dist.Cached.GlobalSize;
            % At this point, we have values for dim, part and gsize.  The values
            % are either the user-provided values or the raw default
            % values.  We can do better because if gsize is specified,
            % and either dimension or partition are unspecified, we
            % fill in those values.
            if ~isempty(gsize)
                if dim == codistributor1d.unsetDimension
                    dim = distributedutil.Sizes.lastNonSingletonDimension(gsize);
                end
                % Calculate the expected size in the distribution dimension.  
                if dim <= length(gsize)
                    expSizeInDim = gsize(dim);
                else
                    % The distribution dimension exceeds the number of 
                    % dimensions of the array.
                    expSizeInDim = 1;
                end
                if isequal(part, codistributor1d.unsetPartition)
                    % Set partition to be the default for this length in the 
                    % distribution dimension.
                    part = codistributor1d.defaultPartition(expSizeInDim);
                else
                    % Error check partition against the global size.  
                    if sum(part) ~= expSizeInDim
                        error('distcomp:codistributed:codistributedFunction:parMatchSizeDim', ...
                              ['The sum of the distribution partition must be ' ...
                               'equal to the global size in the distribution dimension.']);
                    end
                end
            end
            dist.Dimension = dim;
            dist.Partition = part;
        end
    end
end

function [dim, part, gsize] = iParseConstructorArgs(dim, part, gsize)
% Parse the arguments passed to the codistributor1d constructor, perform basic
% error checking on them individually, and provide the default values.

% Error check dim, or fill in default value.
if nargin >= 1
    dim = distributedutil.CodistParser.gatherIfCodistributed(dim);
    if ~isequal(dim,  codistributor1d.unsetDimension) ...
            && ~isValidDistributionDimension(dim)
        error('distcomp:codistributor1d:distributionDimensionInput', ...
              ['Distribution dimension must be a positive',...
              ' integer-valued numeric scalar.'])
    end
else
    dim = codistributor1d.unsetDimension;
end

% Error check part, or fill in default value.
if nargin >= 2
    part = distributedutil.CodistParser.gatherIfCodistributed(part);
    if ~isequal(part, codistributor1d.unsetPartition) ...
            && ~isValidDistributionPartition(part)
        error('distcomp:codistributor1d:distributionPartitionInput', ...
              ['Distribution partition must be a length NUMLABS row-vector of ', ...
              'non-negative integer-valued numeric values.'])
    end
else
    part = codistributor1d.unsetPartition;
end

% Error check gsize, or fill in default value.
if nargin >= 3
    gsize = distributedutil.CodistParser.gatherIfCodistributed(gsize);
    if ~isempty(gsize) && ~isPositiveIntegerValuedNumeric(gsize, true)
        error('distcomp:codistributor1d:sizeInput',  ...
              ['The global size must be a row-vector of non-negative ', ...
              'integer-valued numeric values for ''1d'' scheme.'])
    end
else
    gsize = [];
end
end % End of iParseConstructorArgs.
