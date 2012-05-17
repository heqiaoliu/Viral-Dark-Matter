%CODISTRIBUTED Create a CODISTRIBUTED array from replicated data
%   
%   A codistributed array is divided into segments (called local parts), each 
%   residing in the workspace of a different lab.  Because each lab has its own 
%   portion of the array to work with, you can store larger arrays and process 
%   them more quickly.  The difference between codistributed and distributed 
%   arrays is subtle and a matter of perspective.  On the client, you access the 
%   array data using distributed arrays; from one of the labs you access the data 
%   using codistributed arrays.  Therefore, a CODISTRIBUTED array created and/or 
%   manipulated within the body of an SPMD block automatically becomes a 
%   DISTRIBUTED object upon exiting the SPMD block. 
%   
%   Codistributed arrays can be constructed in a number of ways: (1) the 
%   codistributed constructor acting on a replicated array (as in the following 
%   examples), (2) using one of the static constructor methods like 
%   CODISTRIBUTED.ONES, or (3) using the CODISTRIBUTED.BUILD method to create a 
%   large codistributed array from smaller variant local parts stored on each lab.  
%   
%   Example 1:
%   spmd
%         N = 1000;
%         X = magic(N);
%         D1 = codistributed(X);
%   end
%   
%   creates a 1000-by-1000 array D1 distributed using the default distribution
%   scheme.
%   
%   Example 2:
%   spmd
%         N = 1000;
%         X = magic(N);
%         D2 = codistributed(X, codistributor('1d', 1))
%   end
%   
%   creates a 1000-by-1000 array D2 distributed by rows (over its first
%   dimension).
%   
%   Many mathematical methods are defined for codistributed arrays.  Call 
%   METHODS('CODISTRIBUTED') to see a full listing.  The following lists 
%   contain only the intrinsic methods of codistributed arrays.   
%   
%   codistributed methods:
%   codistributed/codistributed - construct from local data
%   ISCODISTRIBUTED             - return true for codistributed arrays
%   GATHER                      - retrieve data from the labs to the client
%   classUnderlying             - return the class of the elements
%   isaUnderlying               - return true if elements are of a given class 
%   
%   codistributed static methods:
%   BUILD   - build a codistributed array from local parts
%   CELL    - build codistributed cell array
%   COLON   - build codistributed vector of form a:[d:]b
%   EYE     - build codistributed identity matrix
%   FALSE   - build codistributed array containing 'false'
%   INF     - build codistributed array containing 'Inf'
%   NAN     - build codistributed array containing 'NaN'
%   ONES    - build codistributed array containing ones
%   RAND    - build codistributed array containing rand
%   RANDN   - build codistributed array containing randn                  
%   SPALLOC - build empty sparse codistributed array               
%   SPEYE   - build sparse codistributed identity matrix
%   SPRAND  - build sparse codistributed array containing rand 
%   SPRANDN - build sparse codistributed array containing randn
%   TRUE    - build codistributed array containing 'true'
%   ZEROS   - build codistributed array containing zeros
%   
%   See also CODISTRIBUTED.ONES, CODISTRIBUTED.ZEROS, CODISTRIBUTED.BUILD,
%   CODISTRIBUTED.REDISTRIBUTE, CODISTRIBUTOR, CODISTRIBUTOR1D, CODISTRIBUTOR2DBC,
%   GATHER, DISTRIBUTED.
%   


%   Copyright 2008-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2010/02/25 08:02:31 $

classdef codistributed
    
    properties
        Local = [];
        Codistributor = [];
    end
    methods(Access = private, Static = true)
        function pDeployedCheck()
            if isdeployed    
                error('distcomp:codistributed:noCodistributedWhenDeployed', ...
                      ['In a deployed application codistributed arrays can only ', ...
                       'be used in a parallel job or inside an spmd block with ' ...
                       'an open matlabpool.']);
            end
        end

        function D = pConstructFromReplicated(varargin)
            try
                D = codistributed(varargin{:});
            catch E
                if strcmp(E.identifier, 'distcomp:codistributed:ArrayNotReplicated')
                    F = MException('distcomp:codistributed:ConstructFromReplicated:ArrayNotReplicated', ...
                                   ['Detected construction of a codistributed ' ...
                                    'array from a variant array.  Usually ' ...
                                    'this happens when you combine variant and '...
                                    'codistributed arrays in the same operation.'] );
                    throwAsCaller(F);
                else
                    rethrow(E);
                end
            end
        end
        function D = pDoBuildFromLocalPart(LP, codistr)
        % Private method to construct a codistributed array from a local part and
        % codistributor without any error checking or any deferral to the
        % codistributor.
            D = codistributed(LP, codistr, ...
                              'undocumented:ConstructFromLocalParts');
        end
        D = pBuildFromFcn(fcn, varargin)
        P = pCumop(fcn, A, dim) 
        C = pElementwiseBinaryOp(fcn, A, B)
        D = pElementwiseUnaryOp(fcn, A)
        D = pElementwiseUnaryOpWithCatch(fcn, A)
        [sizeVec, className, codistr, allowCommunication] = pParseBuildArgs(fcnName, argList)
        D = pReductionOpAlongDim(fcn, A, dim)
        D = pSprandAndSprandn(buildFcn, fcnName, m, n, density, varargin)
        pVerifyUsing1d(methodName, varargin);
        [cellOfLPs, targetDist] = pRedistSameSizeToSingleDist(inputCells)
    end % Private static methods

    methods (Static = true)
        d = colon(a, varargin);
        D = rand(varargin);
        D = randn(varargin);

        D = nan(varargin);
        function D = NaN(varargin)
            D = codistributed.pBuildFromFcn(@NaN, varargin{:}); %#ok<DCUNK>
        end
        D = zeros(varargin);
        D = ones(varargin);
        D = inf(varargin);
        function D = Inf(varargin)
            D = codistributed.pBuildFromFcn(@Inf, varargin{:}); %#ok<DCUNK>
        end
        D = true(varargin);
        D = false(varargin);

        D = cell(varargin);

        D = eye(varargin);
        D = spalloc(varargin);
        D = speye(varargin);
        D = sprand(varargin);
        D = sprandn(varargin);
        
        D = build(LP, codistr, noCommunication);
        D = loadobj(D);
    end % Public static methods
    
    methods ( Access = public, Hidden )
        [fcnH, userData] = getRemoteFromSPMD( obj )
    end % Public hidden methods
    
    methods
        function D = codistributed(varargin)
        % CODISTRIBUTED Create a codistributed array from replicated data
        % D = CODISTRIBUTED(X) distributes a replicated X using the default
        % codistributor. X must be a replicated array, namely it must have 
        % the same value on all labs. SIZE(D) is the same as SIZE(X).
        %
        % D = CODISTRIBUTED(X, CODISTR) distributes a replicated X using the
        % codistributor CODISTR. X must be a replicated array, namely it must 
        % have the same value on all labs. SIZE(D) is the same as SIZE(X).
        %
        % D = CODISTRIBUTED(X, SRCLAB) and D = CODISTRIBUTED(X, SRCLAB, CODISTR)
        % distribute a replicated array X that resides on SRCLAB, using the
        % codistributor CODISTR. If CODISTR is omitted, the default 
        % codistributor is used instead.  SIZE(D) is the same as SIZE(X). The 
        % array X must be defined on all labs but only the value from SRCLAB 
        % will be used to construct D.
        % 
        % D2 = CODISTRIBUTED(D1) where the input array D1 is already a 
        % codistributed array, returns the array D1 unmodified.
        %
        % D2 = CODISTRIBUTED(D1, CODISTR) where the input array D1 is already a
        % codistributed array, redistributes the array D1 with codistributor 
        % CODISTR.  This is the same as calling D2 = REDISTRIBUTE(D1, CODISTR).
        %
        % Example 1:
        % spmd
        %       N = 1000;
        %       X = magic(N);
        %       D1 = codistributed(X);
        % end
        % 
        % creates a 1000-by-1000 array D1 distributed using the default 
        % distribution scheme.
        % 
        % Example 2:
        % spmd
        %       N = 1000;
        %       X = magic(N);
        %       D2 = codistributed(X, codistributor('1d', 1))
        % end
        % 
        % creates a 1000-by-1000 array D2 distributed by rows (over its first
        % dimension).
        % 
        % See also CODISTRIBUTED, CODISTRIBUTED.ONES, CODISTRIBUTED.ZEROS, 
        % CODISTRIBUTED.BUILD, CODISTRIBUTED.REDISTRIBUTE, CODISTRIBUTOR.
            
            error(nargchk(0, 3, nargin, 'struct'));
            codistributed.pDeployedCheck(); %#ok<DCUNK> Calling a private static method.
            mpiInit;

            if nargin >= 1 && isa(varargin{1},'function_handle')
                error('distcomp:codistributed:noFunctionHandle',...
                      'Function handles cannot be distributed.');
            end

            % empty constructor required by load() and save()
            if 0 == nargin
                % Return a 0-by-0 double array.
                codistr = codistributor();
                srcLab = 0;
                X = [];
                [LP, codistr] = codistr.hBuildFromReplicatedImpl(srcLab, X);
                D.Local = LP;
                D.Codistributor = codistr;
                return;
            end

            % An undocumented short-cut necessary for codistributed.pDoBuildFromLocalPart.
            if nargin == 3 && ischar(varargin{end}) ...
                       && strcmp(varargin{end}, 'undocumented:ConstructFromLocalParts')
                L = varargin{1};
                dist = varargin{2};
                D.Local = L;
                D.Codistributor = dist;
                return;
            end

            X = varargin{1};
            try
                if isa(X, 'codistributed')
                    D = iCodistributedFromCodistributed(X, varargin{2:end});
                else
                    [LP, dist] = iCodistributedFromReplicated(X, varargin{2:end});
                    D.Local = LP;
                    D.Codistributor = dist;
                end
            catch e
                % Strip the stack off all errors.
                throw(e);
            end
        end % constructor
    end % methods
end % classdef

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [LP, dist] = iCodistributedFromReplicated(X,varargin)
%CODISTRIBUTEdFROMREPLICATED   Distribute a replicated or variant array
%   Implements the following calls to the constructor.
%    -  X must be a replicated array for the following:
%       [LP, dist] = codistributedFromReplicated(X)
%       [LP, dist] = codistributedFromReplicated(X,DIST) 
%   - X may be a variant for the following:
%       [LP, dist] = codistributedFromReplicated(X, SRCLAB)
%       [LP, dist] = codistributedFromReplicated(X, SRCLAB, DIST) 

    % The following error should never be triggered since we are in an internal
    % function.
    error(nargchk(1, 3, nargin, 'struct'));

    switch(nargin)
      case 1
        srcLab = 0;
        dist = codistributor();
      case 2
        % The second argument could be a codistributed SRCLAB, so we need to gather it.
        gatheredArg = distributedutil.CodistParser.gatherIfCodistributed(varargin{1});         
        % Disambiguate between:
        % codistributedFromReplicated(X,DIST)
        % codistributedFromReplicated(X, SRCLAB)
        % Erroneous call
        if isa(gatheredArg, 'AbstractCodistributor')
            dist = gatheredArg;
            srcLab = 0;
        elseif distributedutil.CodistParser.isValidLabindex(gatheredArg)
            dist = codistributor();
            srcLab = gatheredArg;
        else
            error('distcomp:codistributed:invalidInput', ...
                  ['The CODISTRIBUTED constructor with two input ' ...
                   'arguments expects the second argument to be either a valid ' ...
                   'codistributor or an integer SRCLAB between 1 and numlabs.'])
        end
      case 3
         % codistributedFromReplicated(X, SRCLAB, DIST) 
        srcLab = distributedutil.CodistParser.gatherIfCodistributed(varargin{1});
        if ~distributedutil.CodistParser.isValidLabindex(srcLab)
            error('distcomp:codistributed:incorrectLabIndex', ...
                  ['When calling CODISTRIBUTED(X, SRCLAB, CODISTR) with X a ' ...
                   'regular array, the second argument must be an integer ' ...
                   'between 1 and numlabs.']);
        end
        dist = varargin{2};
        if ~isa(dist, 'AbstractCodistributor')
            error('distcomp:codistributed:replicatedCodistributor', ...
                  ['When calling CODISTRIBUTED(X, SRCLAB, CODISTR) with X a ' ...
                   'regular array, the third argument must be a codistributor.']);
        end
    end % switch
    [LP, dist] = dist.hBuildFromReplicatedImpl(srcLab, X);
end

function coD = iCodistributedFromCodistributed(coD, varargin)
    error(nargchk(1, 2, nargin, 'struct'));

    if nargin == 1
        return;
    end
    % 2 input arguments.  Second must be codistributor.
    codistr = varargin{1};
    if ~isa(codistr, 'AbstractCodistributor')
        error('distcomp:codistributed:conversionCodistributor', ...
              ['When calling CODISTRIBUTED(D, CODISTR) with D a codistributed ' ...
               'array, the second argument must be a codistributor.']);
    end  
    coD = redistribute(coD, codistr);
end
