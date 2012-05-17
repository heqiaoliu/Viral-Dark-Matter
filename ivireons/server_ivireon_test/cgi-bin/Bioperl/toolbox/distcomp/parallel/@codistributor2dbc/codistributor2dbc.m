%CODISTRIBUTOR2DBC   2D block-cyclic codistributor object 
%   The 2D block-cyclic codistributor can only be used for two dimensional
%   matrices. It distributes matrices along two subscripts over a rectangular
%   computational grid of labs in a blocked, cyclic manner. The 2D block-cyclic
%   codistributor is employed by the parallel matrix computation software
%   library called ScaLAPACK.
%  
%   Example: Look at how a small matrix is distributed using the 2D block-cyclic
%   distribution scheme.  For the purposes of the example, we choose the matrix
%   size such that each lab stores exactly one block.  
%       spmd
%           sz = codistributor2dbc.defaultBlockSize*codistributor2dbc.defaultLabGrid;
%           codistr = codistributor2dbc(codistributor2dbc.defaultLabGrid, ...
%                                       codistributor2dbc.defaultBlockSize, ...
%                                       codistributor2dbc.defaultOrientation, ...
%                                       sz);
%           [e1, f1] = codistr.globalIndices(1);
%           [e2, f2] = codistr.globalIndices(2);
%           fprintf('Lab %d stores elements [%d:%d, %d:%d].\n', ...
%                   labindex, e1, f1, e2, f2);
%       end 
%   When run on 4 labs, the matrix size is [128, 128], and this shows:
%       Lab 1 stores elements [1:64, 1:64].
%       Lab 2 stores elements [1:64, 65:128].
%       Lab 3 stores elements [65:128, 1:64].
%       Lab 4 stores elements [65:128, 65:128].
%   That is, the 128-by-128 matrix is split into 4 blocks, and they are divided
%   amongst the labs as:
%      |   Block stored on lab 1   |    Block stored on lab 2   |
%      |   Block stored on lab 3   |    Block stored on lab 4   |
%   
%   Example: We can see the cyclic nature of the distribution scheme when we
%   work with a larger matrix than in the previous example.
%       spmd
%           sz = 3*codistributor2dbc.defaultBlockSize*codistributor2dbc.defaultLabGrid;
%           codistr = codistributor2dbc(codistributor2dbc.defaultLabGrid, ...
%                                       codistributor2dbc.defaultBlockSize, ...
%                                       codistributor2dbc.defaultOrientation, ...
%                                       sz);
%           [e1, f1] = codistr.globalIndices(1);
%           rows = strtrim(sprintf('%d:%d ', [e1; f1]));
%           [e2, f2] = codistr.globalIndices(2);
%           cols = strtrim(sprintf('%d:%d ', [e2; f2]));
%           fprintf('Lab %d stores elements [%s, %s].\n', ...
%                    labindex, rows, cols);
%       end 
%   When run on 4 labs, the matrix is of size 384-by-384, and this shows:   
%       Lab 1 stores elements [1:64 129:192 257:320, 1:64 129:192 257:320].
%       Lab 2 stores elements [1:64 129:192 257:320, 65:128 193:256 321:384].
%       Lab 3 stores elements [65:128 193:256 321:384, 1:64 129:192 257:320].
%       Lab 4 stores elements [65:128 193:256 321:384, 65:128 193:256 321:384].
%
%   codistributor2dbc methods:
%     codistributor2dbc/codistributor2dbc  - Create 2D block-cyclic codistributor object
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
%   codistributor2dbc static methods and properties:
%     defaultBlockSize   - MATLAB's choice for ScaLAPACK block size
%     defaultLabGrid     - MATLAB's choice for computational grid
%     defaultOrientation - MATLAB's choice for ScaLAPACK orientation
%
%   codistributor2dbc object properties:
%     BlockSize   - Block size of a 2D block-cyclic codistributor
%     LabGrid     - Lab grid of a 2D block-cyclic codistributor 
%     Orientation - The orientation of lab grid of a 2D block-cyclic codistributor
%
%   See also CODISTRIBUTOR, CODISTRIBUTED, CODISTRIBUTOR1D.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.12.2.1 $  $Date: 2010/06/07 13:33:22 $

classdef codistributor2dbc < TensorProductCodistributor
    properties(SetAccess = private)
        %BlockSize  Block size of a 2D block-cyclic codistributor
        %   codistr.BlockSize is the ScaLAPACK block size associated
        %   with the 2D block-cyclic codistributor codistr.
        %
        %   See also codistributor2dbc, codistributor2dbc.defaultBlockSize.
        BlockSize

        %LabGrid Lab grid of a 2D block-cyclic codistributor 
        %   codistr.LabGrid is the lab grid of a 2D block-cyclic codistributor
        %   codistr. The lab grid is the row vector of length 2, [nprow,
        %   npcol], used by the ScaLAPACK library.  The product of
        %   codistr.LabGrid must equal NUMLABS.  The default is given by
        %   codistributor2dbc.defaultLabGrid.
        %
        %   See also codistributor2dbc, codistributor2dbc.defaultLabGrid.
        LabGrid 

        %Orientation The orientation of lab grid of a 2D block-cyclic codistributor
        %   codistr.Orientation is the orientation of the lab grid of a 2D
        %   block-cyclic codistributor codistr.  The supported values are 
        %   'row' or 'col', which means that the labs are laid out in the 
        %   lab grid in either a row-wise or column-wise manner, respectively.
        %
        %   Example:  
        %      With Orientation equal to 'row' and LabGrid equal to [2, 3], the
        %      labs are laid out in the lab grid as follows:
        %      |   lab 1  |  lab 2   |  lab 3 |
        %      |   lab 4  |  lab 5   |  lab 6 |
        %
        %   See also codistributor2dbc, codistributor2dbc.defaultOrientation.
        Orientation 
     end

    methods(Access = private, Static = true)
        function ex = notImplemented(fcnstr)
            id = sprintf('distcomp:codistributor2dbc:%s:notImplemented', fcnstr);
            msg = sprintf('The method %s has not been implemented for 2D block-cyclic.', fcnstr);
            ex = MException(id, msg);
        end
    end

    methods (Access = private)
        function col = pLabindexToProcessorCol(codistr, labidx)
        % Map lab index into the column in the processor grid. 
            switch codistr.Orientation
              case 'row'
                col = mod(labidx - 1, codistr.LabGrid(2)) + 1;
              case 'col'
                col = ceil(labidx/codistr.LabGrid(1));
              otherwise
                error('distcomp:codistributor2dbc:pLabindexToProcessorCol:orientUnsupported', ...
                      'CODISTRIBUTOR2DBC does not support ''%s'' orientation.  Specify either ''row'' or ''col'' instead.', codistr.Orientation);
            end       
        end

        function row = pLabindexToProcessorRow(codistr, labidx)
        % Map lab index into the row in the processor grid.
            switch codistr.Orientation
              case 'row'
                row = ceil(labidx/codistr.LabGrid(2));
              case 'col'
                row = mod(labidx - 1, codistr.LabGrid(1)) + 1;
              otherwise
                error('distcomp:codistributor2dbc:pLabindexToProcessorRow:orientUnsupported', ...
                      'CODISTRIBUTOR2DBC does not support ''%s'' orientation.  Use either ''row'' or ''col'' instead.', codistr.Orientation);
            end
        end
        [data, isOnEdge] = pCatToEdgeOfLabGrid(codistr, data, dim)
        isOnEdge = pIsOnLabGridEdge(codistr, dim)
    end
    
    methods(Access = protected)
        function codistr = pTransposeCodistributor(codistr)
            sz = codistr.Cached.GlobalSize;
            labGrid = codistr.LabGrid;

            % (c)transpose without communication relies on transposing 
            % the labgrid and using the opposite orientation to set up 
            % the new codistributor.
            orient = codistr.Orientation;
            if strcmp(orient, 'row')
                altOrient = 'col';
            else
                altOrient = 'row';
            end

            codistr = codistributor2dbc([labGrid(2) labGrid(1)], ...
                                        codistr.BlockSize, ...
                                        altOrient, [sz(2), sz(1)]);
        end % End pTransposeCodistributor
    end
    
    % Implementation of hidden, abstract methods.
    methods(Hidden = true)
        [LP, codistr] = hBuildFromReplicatedImpl(codistr, srcLab, X)
        codistr = hBuildFromLocalPartImpl(codistr, LP, allowCommunication)
        [LP, codistr] = hColonImpl(codistr, a, d, b)
        [header, matrix] = hDispImpl(codistr, LP, varName, maxStrLen)
        localLinInd = hFindDiagElementsInLocalPart(codistr)
        X = hGatherImpl(codistr, LP, destLab)
        function codistr = hGetCompleteForSize(codistr, wantedGlobalSize)
        % Return a codistributor that is based on the input codistributor and matches
        % the desired global size.
            if ~codistr.isComplete() || ~isequal(codistr.Cached.GlobalSize, wantedGlobalSize)
                codistr = codistributor2dbc(codistr.LabGrid, codistr.BlockSize, ...
                                            codistr.Orientation, wantedGlobalSize);
            end
        end % End of hGetCompleteForSize.

        function dims = hGetDimensions(~)
            dims = [1, 2];
        end
        varargout = hGlobalIndicesImpl(codistr, dim, lab)
        tf = hIsGlobalIndexOnLab(codistr, dim, gIndexInDim, lab)
        function col = hLabindexToProcessorCol(codistr, labidx)
            col = codistr.pLabindexToProcessorCol(labidx);
        end
        function row = hLabindexToProcessorRow(codistr, labidx)
            row = codistr.pLabindexToProcessorRow(labidx);
        end
        szs = hLocalSize(codistr, labidx)
        [LPY, LPI, codistr] = hMinMaxImpl(codistr, fcnMinMax, LP, dim, wantI)

        function nlabs = hNumLabs(codistr)
            nlabs = prod(codistr.LabGrid);
        end

        [LP, codistr] = hReductionOpAlongDimImpl(codistr, fcn, LP, dim)
        [LP, codistr] = hSpallocImpl(codistr, m, n, nzmx)
        [LP, codistr] = hSparsifyImpl(codistr, fcn, LP)

        function hVerifySupportsSparse(~)
        % All 2D block-cyclic codistributors support sparse arrays, so we never
        % throw an error.
        end
    end % End of hidden, abstract methods.

    properties (Constant = true)
        %codistributor2dbc.defaultBlockSize    MATLAB's choice for ScaLAPACK block size
        %   BLKSIZE = codistributor2dbc.defaultBlockSize
        %
        %   Example:
        %      codistr = codistributor2dbc()
        %   returns a distribution scheme with codistr.BlockSize set to
        %   codistributor2dbc.defaultBlockSize.
        %
        %   See also codistributor2dbc, codistributor2dbc/defaultLabGrid,
        %   codistributor2dbc/defaultOrientation
        defaultBlockSize = 64;

        %codistributor2dbc.defaultOrientation    MATLAB's choice for ScaLAPACK orientation
        %    orient = codistributor2dbc.defaultOrientation
        %
        %   Example:
        %      codistr = codistributor2dbc()
        %   returns a distribution scheme with codistr.Orientation set to
        %   codistributor2dbc.defaultOrientation.
        %
        %   See also codistributor2dbc, codistributor2dbc/defaultLabGrid,
        %   codistributor2dbc/defaultBlockSize
        defaultOrientation = 'row';
    end % End of constant properties.

    methods(Static = true)
        labgrd = defaultLabGrid();
    end


    methods
        function A = codistributor2dbc(lbgrid, blksize, orientation, siz)
        %CODISTRIBUTOR2DBC   Create 2D block-cyclic codistributor object 
        %   The 2D block-cyclic codistributor can be used only for two dimensional
        %   arrays. It distributes arrays along two subscripts over a rectangular
        %   computational grid of labs in a blocked, cyclic manner. The 2D block-cyclic
        %   codistributor is employed by the ScaLAPACK parallel matrix computation 
        %   software library.
        %
        %   Each of the following forms a 2D block-cyclic codistributor object with
        %   its global size unspecified.  When provided, the lab grid, block size,
        %   and orientation are set to LBGRID, BLKSIZE, and ORIENT, respectively,
        %   otherwise they are set to their default values.  The resulting
        %   codistributor is incomplete as its global size is not specified.
        %   DIST = CODISTRIBUTOR2DBC()
        %   DIST = CODISTRIBUTOR2DBC(LBGRID)
        %   DIST = CODISTRIBUTOR2DBC(LBGRID, BLKSIZE)
        %   DIST = CODISTRIBUTOR2DBC(LBGRID, BLKSIZE, ORIENT)
        %   A codistributor constructed in this manner can then be used as an argument
        %   to other functions as a template codistributor when creating codistributed 
        %   arrays.
        %   The default values for the lab grid, block size, and orientation are given 
        %   by codistributor2dbc.defaultLabGrid, codistributor2dbc.defaultBlockSize,
        %   and codistributor2dbc.defaultOrientation, respectively.
        %
        %   DIST = CODISTRIBUTOR2DBC(LBGRID, BLKSIZE, ORIENT, GSIZE) forms a
        %   codistributor object that distributes arrays over lab grid LBGRID with
        %   block size BLKSIZE and the global size of the codistributed arrays being
        %   GSIZE.  The resulting codistributor object is complete and can therefore
        %   be used to build a codistributed array from its local parts with
        %   codistributed.build.
        %
        %   Example: Use a codistributor2dbc object to create an N-by-N matrix of ones.
        %   N = 1000;
        %   spmd
        %       codistr = codistributor2dbc();  
        %       D = codistributed.ones(N, codistr);
        %   end
        %
        %   Example: Use a fully specified codistributor2dbc object to create a trivial 
        %   N-by-N codistributed matrix from its local parts.  Then visualize which 
        %   elements are stored on lab 2.
        %   N = 1000;
        %   spmd
        %       codistr = codistributor2dbc(codistributor2dbc.defaultLabGrid, ...
        %                                   codistributor2dbc.defaultBlockSize, ...
        %                                   codistributor2dbc.defaultOrientation, ...
        %                                   [N, N]);
        %       localSize = [length(codistr.globalIndices(1)), length(codistr.globalIndices(2))]; 
        %       localPart = labindex*ones(localSize);
        %       D = codistributed.build(localPart, codistr);
        %   end
        %   spy(D == 2);
        %
        %   See also CODISTRIBUTOR, CODISTRIBUTED, CODISTRIBUTOR1D.

            % Error check lbgrid or provide default value.
            if nargin >= 1
                lbgrid = distributedutil.CodistParser.gatherIfCodistributed(lbgrid);
                if isValidLabGrid(lbgrid)
                    lbgrid = double(lbgrid);
                else
                    error('distcomp:codistributor2dbc:labGridInput',  ...
                          ['The lab grid must be a length 2 row-vector of positive integer-valued ', ...
                          'numeric values, whose product equals to NUMLABS.']);
                end
            else
                lbgrid = codistributor2dbc.defaultLabGrid();
            end

            % Error check blksize or provide default value.
            if nargin >= 2
                blksize = distributedutil.CodistParser.gatherIfCodistributed(blksize);
                if isValidBlockSize(blksize)
                    blksize = double(blksize);
                else
                    error('distcomp:codistributor2dbc:blockSizeInput', ...
                          'The block size must be a positive integer-valued numeric scalar.');
                end
            else
                blksize = codistributor2dbc.defaultBlockSize;
            end
            
            % Error check orientation or provide default value.
            if nargin >= 3
                orientation = distributedutil.CodistParser.gatherIfCodistributed(orientation);
                if ischar(orientation)
                    if any( strcmpi( orientation, {'row', 'col'} ) )
                        orientation = lower(orientation);
                    else
                        error('distcomp:codistributor2dbc:orientationInput', ...
                              ['The 2D block-cyclic scheme does not ', ...
                               'support ''%s'' orientation.  Use either ', ...
                               '''row'' or ''col'' orientation instead.'], ...
                              orientation);
                    end
                else
                    error('distcomp:codistributor2dbc:nonCharOrientation', ...
                          ['The orientation of the 2D block-cyclic scheme ',...
                           'should be a character string', ...
                           ' and not a %s.'], class(orientation) )
                end
            else
                orientation = codistributor2dbc.defaultOrientation;
            end                

            % Error check siz or provide default value.
            if nargin >= 4 && ~isempty(siz)
                siz = distributedutil.CodistParser.gatherIfCodistributed(siz);
                % Set the property so that we can benefit from all the error checking
                % performed in the parent class.
                A.Cached.GlobalSize = siz;
                siz = A.Cached.GlobalSize;
                if ~isValidSize(siz)
                    error('distcomp:codistributor2dbc:sizeInput', ... 
                          ['The global size must be a length 2 row-vector of ', ...
                           'non-negative integer-valued numeric values for ' ...
                           '2D block-cyclic scheme.']);
                end
            else
                siz = [];
            end                
            
            A.LabGrid = lbgrid;
            A.BlockSize = blksize;
            A.Orientation = orientation;
            A.Cached.GlobalSize = siz;
        end % End of codistributor2dbc.
    end % End of public methods block.
end
