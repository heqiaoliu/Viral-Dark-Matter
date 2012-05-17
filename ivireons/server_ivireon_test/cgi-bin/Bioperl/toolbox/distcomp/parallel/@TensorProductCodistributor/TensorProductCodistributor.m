% TensorProductCodistributor Base class for both codistributor1d and
% codistributor2dbc (as well as any future codistributors that store 
% data on the labs in the same fashion).  It should contain all the 
% tensor product distribution-specific methods that codistributed 
% needs access to in order for all of its methods to work with a 
% distribution scheme of this type.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/05/03 16:06:06 $
classdef TensorProductCodistributor < AbstractCodistributor
    
    methods(Access = private)
        [LP, codistr] = pGenericTriLowerUpperImpl(codistr, LP, k, compareFcn)
    end
    
    methods(Hidden = true)
        [LP, codistr] = hBuildFromFcnImpl(codistr, fun, sizesDvec, className)
        function outCellLPs = hCellfunImpl(codistr, fcn, inCellLPs, trailingArgs, cellfunNargout) %#ok<MANU>
        % inCellLPs is a cell array of local parts all distributed according to 
        % codistr.  We will call the built-in cellfun (with any flags 
        % contained in trailingArgs) to apply fcn to these local parts. 
            outCellLPs = cell(1, cellfunNargout);
            [outCellLPs{:}] = cellfun(fcn, inCellLPs{:}, trailingArgs{:});
        end % End hCellfunImpl
        function clz = hClassUnderlyingImpl(codistr, LP) %#ok<MANU>
            clz = class(LP);
        end % End hClassUnderlyingImpl
        [LP, codistr] = hElementwiseBinaryOpImpl(codistr, fcn, codistrA, LPA, codistrB, LPB)
        function [LP, codistr] = hElementwiseUnaryOpImpl(codistr, fcn,  LP)
            LP = fcn(LP);
        end % End hElementwiseUnaryOpImpl
        [LP, codistr] = hEyeImpl(codistr, m, n, className)
        function names = hFieldnamesImpl(codistr, LP, optArg) %#ok<MANU>
            if ~isempty(optArg)
                names = fieldnames(LP, optArg);
            else 
                names = fieldnames(LP);
            end
        end % End hFieldnamesImpl

        function froNorm = hFrobeniusNormImpl(codistr, LP)  %#ok<MANU>
        % The temporary variable froNormLP is required because 
        % codistributor1d with distribution dimension > 2 create 3D
        % arrays that norm balks at.
            if isempty(LP)
                froNormLP = zeros(1, 1, class(LP));	 
            else	       
                froNormLP = norm(LP, 'fro');
            end	   
            froNorm = gop( @hypot, froNormLP );
        end % End hFrobeniusNormImpl
        
        function tf = hIsaUnderlyingImpl(codistr, LP, clz) %#ok<MANU>
            tf = isa(LP, clz);
        end % End hIsaUnderlyingImpl
        
        function tf = hIsequaltemplateImpl(codistr, F, inCellLPs) %#ok<MANU>
            % inCellLPs contains the LP of all arrays we are testing
            % equality of.  
            tf = gop(@and, F(inCellLPs{:}));
        end % End hIsequaltemplateImpl
        
        function tf = hIsrealImpl(codistr, LP) %#ok<MANU>
            tf = gop(@and, isreal(LP));
        end % End hIsrealImpl     
        
        function tf = hIssparseImpl(codistr, LP) %#ok<MANU>
            tf = issparse(LP);
        end % End hIssparseImpl
        
        matrixType = hIsTriangularImpl(codistr, LP)

        function exponentLP = hLog2Impl(codistr, LP, log2Nargout) %#ok<MANU>
            exponentLP = cell(1, log2Nargout);
            [exponentLP{:}] = log2(LP);
        end % End hLog2Imp
        
        function [LP, codistr] = hNum2CellNoDimImpl(codistr, LP)
            if ~isempty(LP)
                % Output of num2cell is of the same size as the input when it is
                % called with one non-empty input argument.
                LP = num2cell(LP);
            else
                % Special care is needed to ensure that the resulting LP is of the
                % correct size.  Calling num2cell(LP) would return a
                % 0-by-0 cell array, which might not be the same as
                % codistr.hLocalSize() calls for.
                LP = cell(codistr.hLocalSize());
            end
        end % End of hNum2CellNoDimImpl.

        function num = hNnzImpl(codistr, LP) %#ok<MANU>
            num = gplus(nnz(LP));
        end % End hNnzImpl     
        
        function amt = hNzmaxImpl(codistr, LP) %#ok<MANU>
            amt = gplus(nzmax(LP));
        end % End hNzmaxImpl
        
        [LP, codistr] = hSpeyeImpl(codistr, m, n)
                
        % hTransposeTemplateImpl Return the (c)transpose of the local part 
        % of the codistributed array based on the value of transposeFcn
        function [LP, codistr] = hTransposeTemplateImpl(codistr, LP, transposeFcn)
            codistr = codistr.pTransposeCodistributor();
            if ~isempty(LP)
                LP = transposeFcn(LP);
            else
                LP = distributedutil.Allocator.create(codistr.hLocalSize(), LP);
            end
        end % End hTransposeTemplateImpl
       
        [LP, codistr] = hTrilImpl(codistr, LP, k)
        [LP, codistr] = hTriuImpl(codistr, LP, k)
    end % End of hidden methods  
    
    % Abstract methods declared by this class.
    methods(Abstract, Hidden = true)
        % Implementation of global indices that is optimized for speed, perhaps at the
        % expense of input argument checking.  All input arguments are required
        % arguments.  This method can only be called on a completely specified
        % codistributor.
        varargout = hGlobalIndicesImpl(codistr, dim, lab)

        % Return the dimensions that this codistributor works with.  A tensor product
        % distribution scheme is completely specified by the global indices in
        % these dimensions.  The codistributor must be complete for calling this
        % method.
        dims = hGetDimensions(codistr);

        % hIsGlobalIndexOnlab Returns a logical vector of same length as index vector
        % gIndexInDim.  The logical vector is true for the values of gIndexInDim
        % such that specified lab stores some of the values which have the
        % global index gIndInDim in the dimension dim.
        tf = hIsGlobalIndexOnLab(codistr, dim, gIndexInDim, lab)

        % hLocalSize Return the size of the local part of the codistributed 
        % array.
        % This method can only be called on a completely specified 
        % codistributor.  The labindex is an optional input argument.
        szs = hLocalSize(codistr, labidx)
    end
    
    % Abstract, protected methods
    methods(Abstract, Access = protected)
        % pTransposeCodistributor() given the codistributor for matrix A, this 
        % function returns the codistributor for either A' or A.'. The 
        % implementation is left to the specific codistributors.
        codistr = pTransposeCodistributor(codistr);
    end
    
    methods 
        function D = Inf(varargin)
            try
                D = codistributed.Inf(varargin{:});
            catch E
                throw(E);
            end
        end % End of Inf.
        function D = NaN(varargin)
            try
                D = codistributed.NaN(varargin{:});
            catch E
                throw(E);
            end
        end % End of NaN.  
    end
    
end % End classdef


