classdef RandStream < handle
%RANDSTREAM Random number stream.
%   (Pseudo)random numbers in MATLAB come from one or more random number
%   streams.  The simplest way to generate arrays of random numbers is to use
%   RAND, RANDN, or RANDI.  These functions all rely on the same stream of
%   uniform random numbers, known as the default stream.  You can create other
%   streams that act separately from the default stream, and you can use their
%   RAND, RANDN, or RANDI methods to generate arrays of random numbers.  You can
%   also create a random number stream and make it the default stream.
%
%   To create a single random number stream, use either the RandStream
%   constructor or the RandStream.CREATE factory method.  To create multiple
%   independent random number streams, use RandStream.CREATE.
%
%   STREAM = RandStream.getDefaultStream returns the default random number
%   stream, i.e., the one currently used by the RAND, RANDI, and RANDN
%   functions.
%
%   PREVSTREAM = RandStream.setDefaultStream(STREAM) returns the current default
%   stream, and designates the random number stream STREAM as the new default to
%   be used by the RAND, RANDI, and RANDN functions.
%
%   A random number stream S has properties that control its behavior.  Access or
%   assign to a property using P = S.Property or S.Property = P.
%
%   RandStream properties:
%      Type          - (Read-only) identifies the type of generator algorithm
%                      used by the stream.
%      Seed          - (Read-only) the seed value used to create the stream.
%      NumStreams    - (Read-only) the number of streams created at the same
%                      time as the stream.
%      StreamIndex   - (Read-only) the stream's index among the group of streams
%                      in which it was created.
%      State         - the internal state of the generator.  You should not depend
%                      on the format of this property, or attempt to improvise a
%                      property value.  The value you assign to S.State must be a
%                      value read from S.State previously.  Use RESET to return a
%                      stream to a predictable state without having previously read
%                      from the State property.
%      Substream     - the index of the substream to which the stream is
%                      currently set.  The default is 1.  Multiple substreams are
%                      not supported by all generator types.
%      RandnAlg      - the current algorithm used by RANDN(S, ...) to generate
%                      normal pseudorandom values, one of 'Ziggurat' (the
%                      default), 'Polar', or 'Inversion'.
%      Antithetic    - a logical value indicating whether S generates antithetic
%                      uniform pseudorandom values, that is, the usual values
%                      subtracted from 1.  The default is false.
%      FullPrecision - a logical value indicating whether S generates values
%                      using its full precision.  Some generators are able to
%                      create pseudorandom values faster, but with fewer random
%                      bits, if FullPrecision is false.  The default is true.
%  
%   The sequence of pseudorandom numbers produced by a random number stream S is
%   determined by the internal state of its random number generator.  Saving and
%   restoring the generator's internal state via the 'State' property allows you
%   to reproduce output.
%
%   Examples:
%
%      Create three independent streams:
%         [s1,s2,s3] = RandStream.create('mrg32k3a','NumStreams',3);
%         r1 = rand(s1,100000,1); r2 = rand(s2,100000,1); r3 = rand(s3,100000,1);
%         corrcoef([r1,r2,r3])
%
%      Create only one stream from a set of three independent streams:
%         s2 = RandStream.create('mrg32k3a','NumStreams',3,'StreamIndices',2);
%
%      Reset the generator for the default stream that underlies RAND, RANDI,
%      and RANDN back to the beginning to reproduce previous results:
%         reset(RandStream.getDefaultStream);
%
%      Save and restore the default stream's state to reproduce the output of
%      RAND:
%         defaultStream = RandStream.getDefaultStream;
%         savedState = defaultStream.State;
%         u1 = rand(1,5)
%         defaultStream.State = savedState;
%         u2 = rand(1,5) % contains exactly the same values as u1
%
%      Return RAND, RANDI, and RANDN to their default initial settings:
%         s = RandStream.create('mt19937ar','seed',5489);
%         RandStream.setDefaultStream(s);
%
%      Replace the default stream with a stream whose seed is based on CLOCK, so
%      RAND will return different values in different MATLAB sessions.  NOTE: It
%      is usually not desirable to do this more than once per MATLAB session.
%         s = RandStream.create('mt19937ar','seed',sum(100*clock));
%         RandStream.setDefaultStream(s);
%
%      Select the algorithm that RANDN uses:
%         defaultStream = RandStream.getDefaultStream;
%         defaultStream.RandnAlg = 'inversion';
%
%   RandStream methods:
%       RandStream/RandStream - Create a random number stream.
%       create           - Create multiple independent random number streams.
%       list             - List available random number generator algorithms.
%       getDefaultStream - Get the default random number stream.
%       setDefaultStream - Set the default random number stream.
%       reset            - Reset a stream to its initial internal state.
%       rand             - Pseudorandom numbers from a uniform distribution.
%       randn            - Pseudorandom numbers from a standard normal distribution.
%       randi            - Pseudorandom integers from a uniform discrete distribution.
%       randperm         - Random permutation.
%
%   See also RANDFUN/RAND, RANDFUN/RANDN, RANDFUN/RANDI.

%   Copyright 2008-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.10 $  $Date: 2010/04/21 21:32:44 $

    properties(GetAccess='public', SetAccess='protected')
        %TYPE Random number stream generator algorithm.
        %   The Type property of a random number stream identifies the
        %   generator algorithm that the stream uses.  Type is a read-only
        %   property.
        %
        %   See also RANDSTREAM.
        Type = '';
        
        %SEED Random number stream seed.
        %   The Seed property of a random number stream contains the seed
        %   value used to create the stream.  Seed is a read-only property.
        %
        %   See also RANDSTREAM, RESET.
        Seed = uint32(0);
        
        %NUMSTREAMS Number of random number streams created at the same time.
        %   The NumStreams property of a random number stream contains the
        %   number of streams created at the same time as the stream.
        %   NumStreams is a read-only property.
        %
        %   See also RANDSTREAM.
        NumStreams = uint64([]);
        
        %STREAMINDEX Random number stream index.
        %   The StreamIndex property of a random number stream contains the
        %   stream's index among the group of streams in which it was created.
        %   StreamIndex is a read-only property.
        %
        %   See also RANDSTREAM.
        StreamIndex = uint64([]);
    end
    
    properties(GetAccess='protected', SetAccess='protected')
        Params = [];
        SpawnIncr = uint64([]);
        StreamID = uint64(0); % pointer to the C++ object
    end
    
    properties(Dependent=true, GetAccess='public', SetAccess='public')
        % These are stored in the object that StreamID points to
        
        %STATE Random number stream generator state.
        %   The State property of a random number stream contains the internal
        %   state of the generator.  You should not depend on the format of
        %   this property, or attempt to improvise a property value.  The value
        %   you assign to S.State must be a value read from S.State previously.
        %   Use RESET to return a stream to a predictable state without having
        %   previously read from the State property.
        %
        %   See also RANDSTREAM, RESET.
        State;
        
        %SUBSTREAM Random number stream substream index.
        %   The Substream property of a random number stream contains the
        %   index of the substream to which the stream is currently set.  The
        %   default is 1. Multiple substreams are not supported by all
        %   generator types.
        %
        %   See also RANDSTREAM.
        Substream;
        
        %RANDNALG Random number stream RANDN algorithm.
        %   The RandnAlg property of a random number stream contains the
        %   current algorithm used by its RANDN method to generate normal
        %   pseudorandom values, one of 'Ziggurat' (the default), 'Polar',
        %   or 'Inversion'.
        %
        %   See also RANDSTREAM, RANDN.
        RandnAlg;
        
        %ANTITHETIC Random number stream antithetic values flag.
        %   The Antithetic property of a random number stream is a logical
        %   value indicating whether the stream generates antithetic uniform
        %   pseudorandom values, that is, the usual values subtracted from 1.
        %   The default value is false.
        %
        %   See also RANDSTREAM.
        Antithetic;
        
        %FULLPRECISION Random number stream full precision flag.
        %   The FullPrecision property of a random number stream is a logical
        %   value indicating whether the stream generates values using its
        %   full precision.  Some generators are able to create pseudorandom
        %   values faster, but with fewer random bits, if FullPrecision is
        %   false.  The default value is true.
        %
        %   See also RANDSTREAM.
        FullPrecision;
    end
    methods % subsref is overloaded, but need these so that struct will work
        function b = get.State(a),         b = getset_mex('state',a.StreamID);         end
        function b = get.Substream(a),     b = getset_mex('substream',a.StreamID);     end
        function b = get.RandnAlg(a),      b = getset_mex('randnalg',a.StreamID);      end
        function b = get.Antithetic(a),    b = getset_mex('antithetic',a.StreamID);    end
        function b = get.FullPrecision(a), b = getset_mex('fullprecision',a.StreamID); end
    end

    properties(Constant=true, GetAccess='protected')
        % The local function localGetSetDefaultStream maintains a handle to
        % the current default and legacy streams in persistent variables that
        % are, in effect, static properties of the class, but modifiable.  The
        % streamIDs are also stored in C++ static variables in the built-in
        % code.
        
        % This is called by the register static method before registering
        % anything, so it is guaranteed to contain only the built-in types
        BuiltinTypes = getset_mex('generatorlist',true);
           % {'mt19937ar' 'mlfg6331_64' 'mrg32k3a' 'mcg16807' 'shr3cong' 'swb2712'};
        
        VisibleMethods = getMethodNames();
    end
    
    methods(Static=true, Access='public')
        function [varargout] = create(type, varargin)
%RANDSTREAM.CREATE Create multiple independent random number streams.
%   [S1,S2,...] = RandStream.CREATE('GENTYPE','NumStreams',N) creates N random
%   number streams that use the uniform pseudorandom number generator algorithm
%   specified by GENTYPE, and that are independent in a pseudorandom sense.
%   These streams are not necessarily independent from streams created at other
%   times.  Multiple streams are not supported by all generator types.  Type
%   RandStream.LIST for a list of possible values for GENTYPE, and DOC
%   RandStream for details on these generator algorithms.
%
%   S = RandStream.CREATE('GENTYPE') creates a single random stream.
%
%   [ ... ] = RandStream.CREATE(..., 'PARAM1',val1, 'PARAM2',val2, ...) allows
%   you to specify optional parameter name/value pairs to control creation of
%   the stream(s).  Parameters are:
%
%      NumStreams    - the total number of streams of this type that will be
%                      created, across sessions or labs.  Default is 1.
%      StreamIndices - the stream indices that should be created in this call.
%                      Default is 1:N, where N is the value given with the
%                      'NumStreams' parameter.
%      Seed          - a non-negative scalar integer seed with which to
%                      initialize all streams.  Default is 0.
%      RandnAlg      - the algorithm that will be used by RANDN(S, ...) to
%                      generate normal pseudorandom values, one of
%                      'Ziggurat' (the default), 'Polar', or 'Inversion'.
%      CellOutput    - a logical flag indicating whether or not to return the
%                      stream objects as elements of a cell array.  Default is
%                      false.
%
%   'NumStreams', 'StreamIndices', and 'Seed' can be used to ensure that
%   multiple streams created at different times are independent.  Streams of the
%   same type and created using the same value for 'NumStreams' and 'Seed', but
%   with different values of 'StreamIndices', are independent even if they were
%   created in separate calls to RandStream.CREATE. Instances of different
%   generator types may not be independent.
%
%   Examples:
%
%      Create three independent streams:
%         [s1,s2,s3] = RandStream.create('mrg32k3a','NumStreams',3);
%         r1 = rand(s1,100000,1); r2 = rand(s2,100000,1); r3 = rand(s3,100000,1);
%         corrcoef([r1,r2,r3])
%
%      Create only one stream from a set of three independent streams, and
%      designate it as the default stream:
%         s2 = RandStream.create('mrg32k3a','NumStreams',3,'StreamIndices',2);
%         RandStream.setDefaultStream(s2);
%
%   See also RANDSTREAM, RANDSTREAM/RANDSTREAM, RANDSTREAM.LIST,
%            RANDSTREAM.GETDEFAULTSTREAM, RANDSTREAM.SETDEFAULTSTREAM,
%            RANDSTREAM/RAND, RANDSTREAM/RANDI, RANDSTREAM/RANDN.

            if nargin < 1
                error('MATLAB:RandStream:TooFewInputs', ...
                      'Requires at least one input.');
            end
            
            pnames = {'numstreams' 'streamindices' 'seed' 'randnalg' 'celloutput' 'parameters'};
            dflts =  {          1              []      0         []        false           [] };
            [eid,emsg,nstreams,streamIdx,seed,randnalg,celloutput,params] = ...
                                                        getargs(pnames, dflts, varargin{:});         
            if ~isempty(eid)
                error(sprintf('MATLAB:RandStream:create:%s',eid),emsg);
            end
            
            if ~isnumeric(nstreams) || ~isreal(nstreams) || ~isscalar(nstreams) || ...
               ~(1<=nstreams && nstreams<2^64 && nstreams==round(nstreams))
                error('MATLAB:RandStream:create:BadNumStreams', ...
                      'NUMSTREAMS must be a positive integer value less than 2^64.');
            elseif ~isnumeric(seed) || ~isreal(seed) ||~isscalar(seed) || ~(0<=seed && seed<2^32)
                % Allow non-integer seed so that sum(100*clock) works.  Will truncate below.
                error('MATLAB:RandStream:create:BadSeed', ...
                      'SEED must be a nonnegative integer value less than 2^32.');
            elseif ~isnumeric(streamIdx) || ~isreal(streamIdx)
                error('MATLAB:RandStream:create:BadStreamIndex', ...
                      'STREAMINDICES must contain positive integer values less than or equal to NUMSTREAMS.');
            end
            if isempty(params)
                % none given, it will be defaulted to zero below
            elseif ~isnumeric(params) || ~isreal(params) || ~isvector(params) ...
                                      || ~all(params == round(params)) || ~all(params >= 0)
                error('MATLAB:RandStream:create:BadParams', ...
                      'PARAMETERS must be a vector of non-negative integer values.');
            elseif strmatch(lower(type),RandStream.BuiltinTypes,'exact')
                error('MATLAB:RandStream:create:ParamNotValid', ...
                      'PARAMETERS is not allowed for %s generators.',type);
            end
            if isempty(streamIdx)
                streamIdx = 1:nstreams;
            end
            
            if (celloutput && nargout > 1) || (nargout > numel(streamIdx))
                error('MATLAB:RandStream:create:TooManyOutputs', 'Too many output arguments.');
            end
            
            streams = cell(1,length(streamIdx));
            for i = 1:numel(streamIdx)
                index = streamIdx(i);
                if ~(1<=index && index<=nstreams && index==round(index))
                    error('MATLAB:RandStream:create:BadStreamIndex', ...
                          'STREAMINDICES must contain positive integer values less than or equal to NUMSTREAMS.');
                end
                
                % Fill in the stream properties by hand to avoid repeating the
                % overhead of repeated, identical argument processing by the constructor
                % s = RandStream('type', 'seed',seed, 'randnalg',randnalg, 'param',params);
                s = RandStream.newarray(1);
                s.Type = type;
                s.Seed = uint32(floor(seed)); % truncate if not integer
                s.Params = uint64(params); % possibly empty
                s.NumStreams = uint64(nstreams);
                s.StreamIndex = uint64(index); % stored one-based
                s.SpawnIncr = uint64(nstreams);
                s.StreamID = create_mex(s.Type,s.NumStreams,s.StreamIndex,s.Seed,s.Params);
                if ~isempty(randnalg), set(s,'RandnAlg',randnalg); end
                streams{i} = s;
            end
            
            if celloutput
                varargout{1} = streams;
            else
                varargout = streams;
            end
        end
                
        function list
%RANDSTREAM.LIST List available random number generator algorithms.
%   RandStream.LIST lists all the generator algorithms that may be used when
%   creating a random number stream with RandStream or RandStream.CREATE.  Type
%   DOC RandStream for details on these generator algorithms.
%
%   See also RANDSTREAM, RANDSTREAM.CREATE.
            genList = getset_mex('generatorlist',false);
            disp(' ');
            disp('The following random number generator algorithms are available:');
            disp(' ');
            for i = 1:length(genList)
                disp(genList{i});
            end
        end
        
        function old = setDefaultStream(stream)
%RANDSTREAM.SETDEFAULTSTREAM Set the default random number stream.
%   PREVSTREAM = RandStream.setDefaultStream(STREAM) returns the current default
%   random number stream, and designates the random number stream STREAM as the
%   new default to be used by the RAND, RANDI, and RANDN functions.
%
%   RAND, RANDI, and RANDN all rely on the same stream of uniform pseudorandom
%   numbers, known as the default stream.  RANDI uses one uniform value from the
%   default stream to generate each integer value; RANDN uses one or more
%   uniform values from the default stream to generate each normal value.  Note
%   that there are also RAND, RANDI, and RANDN methods for which you specify a
%   specific random stream from which to draw values.
%
%   See also RANDSTREAM, RANDSTREAM.GETDEFAULTSTREAM, RANDFUN/RAND,
%            RANDFUN/RANDN, RANDFUN/RANDI.
            if nargout > 0
                old = localGetSetDefaultStream();
            end
            localGetSetDefaultStream(stream);
        end
        
        function stream = getDefaultStream
%RANDSTREAM.GETDEFAULTSTREAM Get the default random number stream.
%   STREAM = RandStream.getDefaultStream returns the default random number
%   stream, i.e., the one currently used by the RAND, RANDI, and RANDN
%   functions.
%
%   RAND, RANDI, and RANDN all rely on the same stream of uniform pseudorandom
%   numbers, known as the default stream.  RANDI uses one uniform value from the
%   default stream to generate each integer value; RANDN uses one or more
%   uniform values from the default stream to generate each normal value.  Note
%   that there are also RAND, RANDI, and RANDN methods for which you specify a
%   specific random stream from which to draw values.
%
%   See also RANDSTREAM, RANDSTREAM.SETDEFAULTSTREAM, RANDFUN/RAND,
%            RANDFUN/RANDN, RANDFUN/RANDI.
            stream = localGetSetDefaultStream();
        end
    end
    
    methods(Access='public')
        function s = RandStream(type, varargin)
%RANDSTREAM Create a random number stream.
%   S = RandStream('GENTYPE') creates a random number stream that uses the
%   uniform pseudorandom number generator algorithm specified by GENTYPE.
%   Type RandStream.LIST for a list of possible values for GENTYPE, and
%   DOC RandStream for details on these generator algorithms.
%
%   [ ... ] = RandStream('GENTYPE', 'PARAM1',val1, 'PARAM2',val2, ...) allows
%   you to specify optional parameter name/value pairs to control creation of
%   the stream.  Parameters are:
%
%      Seed          - a non-negative scalar integer seed with which to
%                      initialize the stream.  Default is 0.
%      RandnAlg      - the algorithm that will be used by RANDN(S, ...) to
%                      generate normal pseudorandom values, one of
%                      'Ziggurat' (the default), 'Polar', or 'Inversion'.
%
%   Streams created using RandStream may not be independent from each other.
%   Use RandStream.CREATE to create multiple streams that are independent.
%
%   Examples:
%
%      Create a stream, make it the default, and save and restore its
%      state to reproduce the output of RANDN:
%         s = RandStream('mt19937ar');
%         RandStream.setDefaultStream(s);
%         savedState = s.State;
%         randn(1,5)
%         s.State = savedState;
%         randn(1,5)
%
%      Return RAND, RANDI, and RANDN to their default initial settings:
%         s = RandStream('mt19937ar','seed',5489);
%         RandStream.setDefaultStream(s);
%
%      Replace the default stream with a stream whose seed is based on CLOCK, so
%      RAND will return different values in different MATLAB sessions.  NOTE: It
%      is usually not desirable to do this more than once per MATLAB session.
%         s = RandStream('mt19937ar','seed',sum(100*clock));
%         RandStream.setDefaultStream(s);
%
%   See also RANDSTREAM, RANDSTREAM.CREATE, RANDSTREAM.LIST, RANDSTREAM/RAND,
%            RANDSTREAM/RANDI, RANDSTREAM/RANDN, RANDSTREAM.GETDEFAULTSTREAM,
%            RANDSTREAM.SETDEFAULTSTREAM.

            if nargin < 1
                error('MATLAB:RandStream:TooFewInputs', ...
                      'Requires at least one input.');
            end
            
            pnames = {'seed' 'randnalg' 'parameters'};
            dflts =  {    0         []           [] };
            [eid,emsg,seed,randnalg,params] = getargs(pnames, dflts, varargin{:});
            if ~isempty(eid)
                error(sprintf('MATLAB:RandStream:%s',eid),emsg);
            end
            
            if ~isnumeric(seed) || ~isreal(seed) ||~isscalar(seed) || ~(0<=seed && seed<2^32)
                % Allow non-integer seed so that sum(100*clock) works.  Will truncate below.
                error('MATLAB:RandStream:BadSeed', ...
                      'SEED must be a nonnegative integer value less than 2^32.');
            end
            
            if isempty(params)
                % none given, it will be defaulted to zero below
            elseif ~isnumeric(params) || ~isreal(params) || ~isvector(params) ...
                                      || ~all(params == round(params)) || ~all(params >= 0)
                error('MATLAB:RandStream:BadParams', ...
                      'PARAMETERS must be a vector of non-negative integer values.');
            elseif strmatch(lower(type),RandStream.BuiltinTypes,'exact')
                error('MATLAB:RandStream:ParamNotValid', ...
                      'PARAMETERS is not allowed for %s generators.',type);
            end    
            
            s.Type = type;
            s.Seed = uint32(floor(seed)); % truncate if not integer
            s.Params = uint64(params); % possibly empty
            s.NumStreams = uint64(1);
            s.StreamIndex = uint64(1); % stored one-based
            s.SpawnIncr = uint64(1);
            s.StreamID = create_mex(s.Type,s.NumStreams,s.StreamIndex,s.Seed,s.Params);
            if ~isempty(randnalg), set(s,'RandnAlg',randnalg); end
        end
        
        % Display methods
        function display(s)
            isLoose = strcmp(get(0,'FormatSpacing'),'loose');

            objectname = inputname(1);
            if isempty(objectname)
                objectname = 'ans';
            end

            if (isLoose)
                fprintf('\n');
            end
            fprintf('%s = \n', objectname);
            disp(s);
        end
        function disp(s)
            isLoose = strcmp(get(0,'FormatSpacing'),'loose');

            if (isLoose)
                fprintf('\n');
            end
            if s.StreamID>0
                if s == localGetSetDefaultStream()
                    disp([s.Type ' random stream (current default)']);
                else
                    disp([s.Type ' random stream']);
                end
                if isequal(lower(s.Type),'legacy')
                    state = getset_mex('state',s.StreamID);
                    randAlgs = {'V4 (Congruential)' 'V5 (Subtract-with-Borrow)' 'V7.4 (Mersenne Twister)'};
                    randnAlgs = {'V4 (Polar)' 'V5 (Ziggurat)'};
                    disp(['   RAND algorithm: ' randAlgs{state{1}(1)}]);
                    disp(['  RANDN algorithm: ' randnAlgs{state{1}(2)}]);
                else
                    if s.NumStreams > 1
                        disp(['      StreamIndex: ' num2str(s.StreamIndex)]);
                        disp(['       NumStreams: ' num2str(s.NumStreams)]);
                    end
                    disp(['             Seed: ' num2str(s.Seed)]);
                    disp(['         RandnAlg: ' get(s,'RandnAlg')]);
                    if isscalar(s.Params)
                        disp(['        Parameter: ' mat2str(s.Params)]);
                    elseif ~isempty(s.Params)
                        disp(['       Parameters: ' mat2str(s.Params)]);
                    end
                end
            else
                error('MATLAB:RandStream:disp:InvalidHandle', 'Invalid or deleted object.');
            end
        end
        
        % Subsref/Subsasgn
        function [varargout] = subsref(a,s)
            switch s(1).type
            case '()'
                error('MATLAB:RandStream:subsref:SubscriptReferenceNotAllowed', ...
                      'You cannot index into a RandStream using () indexing.')
            case '{}'
                error('MATLAB:RandStream:subsref:CellReferenceNotAllowed', ...
                      'You cannot index into a RandStream using {} indexing.')
            case '.'
                if a.StreamID==0
                    error('MATLAB:RandStream:subsref:InvalidHandle', 'Invalid or deleted object.');
                end
                switch s(1).subs
                case RandStream.VisibleMethods
                    if isscalar(s)
                        args = {};
                    else
                        if length(s) > 2 || ~isequal(s(2).type, '()')
                            error('MATLAB:RandStream:subsref:InvalidMethodSyntax', ...
                                  'Illegal method calling syntax.');
                        end
                        args = s(2).subs;
                    end
                    [varargout{1:nargout}] = feval(s(1).subs,a,args{:});
                otherwise
                    if (length(s) > 1)
                        error('MATLAB:RandStream:subsref:InvalidPropertySyntax', ...
                              'Illegal property reference.');
                    end
                    switch s(1).subs
                    case 'State'
                        varargout{1} = getset_mex('state',a.StreamID);
                    case 'Substream'
                        varargout{1} = getset_mex('substream',a.StreamID);
                    case 'RandnAlg'
                        varargout{1} = getset_mex('randnalg',a.StreamID);
                    case 'Antithetic'
                        varargout{1} = getset_mex('antithetic',a.StreamID);
                    case 'FullPrecision'
                        varargout{1} = getset_mex('fullprecision',a.StreamID);
                    case {'Type' 'Seed' 'NumStreams' 'StreamIndex'}
                        varargout{1} = a.(s(1).subs);
                    otherwise
                        error('MATLAB:RandStream:subsref:UnrecognizedProperty', ...
                              'Unrecognized property ''%s''.',s(1).subs);
                    end
                end
            end
        end
        function c = subsasgn(a,s,b)
            switch s(1).type
            case '()'
                error('MATLAB:RandStream:subsasgn:AssignmentNotAllowed', ...
                      'Assignment to a RandStream using () indexing is not allowed.');
            case '{}'
                error('MATLAB:RandStream:subsasgn:AssignmentNotAllowed', ...
                      'Assignment to a RandStream using {} indexing is not allowed.');
            case '.'
                if a.StreamID==0
                    error('MATLAB:RandStream:subsasgn:InvalidHandle', 'Invalid or deleted object.');
                elseif (length(s) > 1)
                    error('MATLAB:RandStream:subsasgn:InvalidPropertySyntax', ...
                          'Illegal property reference.');
                end
                switch s(1).subs
                case 'State'
                    getset_mex('state',a.StreamID,b);
                case 'Substream'
                    getset_mex('substream',a.StreamID,b);
                case 'RandnAlg'
                    getset_mex('randnalg',a.StreamID,b);
                case 'Antithetic'
                    getset_mex('antithetic',a.StreamID,b);
                case 'FullPrecision'
                    getset_mex('fullprecision',a.StreamID,b);
                case {'Type' 'Seed' 'NumStreams' 'StreamIndex'}
                    error('MATLAB:RandStream:subsasgn:IllegalPropertyAssignment', ...
                          'You cannot assign to the ''%s'' property.',s(1).subs);
                otherwise
                    error('MATLAB:RandStream:subsasgn:UnrecognizedProperty', ...
                          'Unrecognized property ''%s''.',s(1).subs);
                end
                c = a;
            end
        end
    end
    
    methods(Access='protected')
        advance(s,nsteps)
    end
    
    methods(Hidden=true, Static=true, Access='public')
        function a = loadobj(b)
            if isequal(b.Type,'')
                % no point in throwing an error here
                warning('MATLAB:RandStream:loadobj:InvalidHandle', 'Invalid or deleted object.');
                a = RandStream.newarray(1);
                return
            end
            
            try
                a = RandStream.newarray(1);
                a.Type = b.Type;
                a.Seed = b.Seed;
                a.Params = b.Params;
                a.NumStreams = b.NumStreams;
                a.StreamIndex = b.StreamIndex;
                a.SpawnIncr = b.SpawnIncr;
                a.StreamID = create_mex(a.Type,a.NumStreams,a.StreamIndex,a.Seed,a.Params);
                set(a,'Substream',b.Substream); % do this before state
                set(a,'State',b.State);
                set(a,'RandnAlg',b.RandnAlg);
                set(a,'Antithetic',b.Antithetic);
                set(a,'FullPrecision',b.FullPrecision);
            catch me
                warning('MATLAB:RandStream:loadobj:LoadError', ...
                        ['Unable to load RandStream object for the following reason:\n\n' ...
                         me.message]);
                a = RandStream.newarray(1);
            end
        end
    end
        
    methods(Static=true, Access='protected')
        function default = createDefaultStream()
            default = RandStream.newarray(1);
            default.Params = [];
            default.NumStreams = uint64(1);
            default.StreamIndex = uint64(1);
            default.SpawnIncr = uint64(0);
            [default.StreamID,default.Type,default.Seed] = getset_mex('defaultstream');
            % antithetic, randnAlg, substream, and state come from existing defaultstream C++ object
        end
        function legacy = createLegacyStream()
            legacy = RandStream.newarray(1);
            legacy.Type = 'legacy';
            legacy.Seed = uint32(0); % this will usually be a lie
            legacy.Params = [];
            legacy.NumStreams = uint64(1);
            legacy.StreamIndex = uint64(1);
            legacy.SpawnIncr = uint64(0);
            legacy.StreamID = getset_mex('legacystream');
            % antithetic, randnAlg, substream, and state come from existing legacystream C++ object
        end
    end
    
    methods(Hidden=true, Access='public')
        % Destructor
        delete(s)

        function b = saveobj(a)
            if isequal(a.Type,'legacy')
                % no point in throwing an error here
                warning('MATLAB:RandStream:saveobj:SavingLegacyStream', ...
                        'You cannot save the legacy stream to a file.');  
                b = struct('Type','', 'StreamID',0);
                return
            end
            
            try
                b = get(a);

                % These are not get-able properties
                b.Params = a.Params;
                b.SpawnIncr = a.SpawnIncr;
                
                % Do not save a.StreamID, it will be meaningless
            catch me
                warning('MATLAB:RandStream:saveobj:SaveError', ...
                        ['Unable to save RandStream object for the following reason:\n\n' ...
                        me.message]);  
                b = struct('Type','', 'StreamID',0);
            end
        end
            

        % Methods that we inherit from base handle class, but do not want
        function a = fields(varargin),          throwUndefinedError; end        
        function a = lt(varargin),              throwUndefinedError; end
        function a = le(varargin),              throwUndefinedError; end
        function a = ge(varargin),              throwUndefinedError; end
        function a = gt(varargin),              throwUndefinedError; end
        function a = permute(varargin),         throwUndefinedError; end
        function a = reshape(varargin),         throwUndefinedError; end
        function a = transpose(varargin),       throwUndefinedError; end
        function a = ctranspose(varargin),      throwUndefinedError; end
        function [a,b] = sort(varargin),        throwUndefinedError; end
        
        % Inherit default EQ, NE, ISVALID, FIELDNAMES, FINDPROP,
        % ADDLISTENER, NOTIFY from base handle class
        
        % All of these have to be taken away because they can create
        % non-scalar or empty arrays of objects.
        function a = findobj(varargin),         throwUndefinedError; end
        function a = cat(varargin),             throwNoCatError(); end
        function a = horzcat(varargin),         throwNoCatError(); end
        function a = vertcat(varargin),         throwNoCatError(); end
    end
    methods(Hidden = true, Static = true)
        function a = empty(varargin)
            error(['MATLAB:' mfilename ':NoEmptyAllowed'], ...
                  'Creation of empty %s objects is not allowed.',upper(mfilename));
        end
    end

end


function throwNoCatError()
me = MException(['MATLAB:' mfilename ':NoCatAllowed'], ...
    'Concatenation of %s objects is not allowed.  Use a cell array to contain multiple objects.',upper(mfilename));
throwAsCaller(me);
end

function throwUndefinedError()
st = dbstack;
name = regexp(st(2).name,'\.','split');
me = MException(['MATLAB:' mfilename ':UndefinedFunction'], ...
    'Undefined function or method ''%s'' for input arguments of type ''%s''.',name{2},mfilename);
throwAsCaller(me);
end


function names = getMethodNames
    names = methods('RandStream');
end


function stream = localGetSetDefaultStream(stream)
persistent default;
persistent legacy;
mlock

if inLegacyMode()
    if isempty(legacy) || ~isvalid(legacy)
        legacy = RandStream.createLegacyStream();
    end
    default = legacy;
elseif isempty(default) || ~isvalid(default)
    default = RandStream.createDefaultStream();
end

if nargin == 0
    stream = default;
elseif isa(stream,'RandStream')
    getset_mex('defaultstream', stream.StreamID);
    default = stream;
else
    error('MATLAB:RandStream:setdefaultstream:InvalidInput', ...
          'Input must be a RandStream object.');
end
end


function [eid,emsg,varargout] = getargs(pnames,dflts,varargin)

% Initialize some variables
emsg = '';
eid = '';
nparams = length(pnames);
varargout = dflts;
unrecog = {};
nargs = length(varargin);

% Must have name/value pairs
if mod(nargs,2)~=0
    eid = 'WrongNumberArgs';
    emsg = 'Wrong number of arguments.';
else
    % Process name/value pairs
    for j=1:2:nargs
        pname = varargin{j};
        if ~ischar(pname)
            eid = 'BadParamName';
            emsg = 'Parameter name must be text.';
            break;
        end
        i = strmatch(lower(pname),pnames);
        if isempty(i)
            eid = 'BadParamName';
            emsg = sprintf('Invalid parameter name:  %s.',pname);
            break;
        elseif length(i)>1
            eid = 'BadParamName';
            emsg = sprintf('Ambiguous parameter name:  %s.',pname);
            break;
        else
            varargout{i} = varargin{j+1};
        end
    end
end

varargout{nparams+1} = unrecog;

end

