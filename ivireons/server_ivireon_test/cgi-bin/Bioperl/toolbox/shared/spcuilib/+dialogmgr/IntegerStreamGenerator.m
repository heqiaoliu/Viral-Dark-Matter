classdef IntegerStreamGenerator < handle
    % Integer sequence stream generator.

        
%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $   $Date: 2010/03/31 18:39:09 $

    properties (SetAccess=private)
        InitialValue = 1
    end
    properties (Dependent)
        NextValue
    end
    properties (SetAccess=private)
        Stream = 'Default'
    end
    properties (Access=private)
        StreamFullName = ''
    end
        
    methods
        function h = IntegerStreamGenerator(stream,initialValue)
            % Construct an integer-sequence stream generator object.
            %
            % obj = IntegerStreamGenerator(Stream,Value) creates
            % an IntegerStreamGenerator object connecting to the stream
            % generator identified by string Stream.
            %
            % If this stream has not been created previously in this MATLAB
            % session, a new stream is initialized with the integer value
            % InitialValue. If omitted, InitialValue is 1 and Stream is
            % 'Default'.
            %
            % Once created, successive integers may be generated from the
            % stream by calling i=generate(obj).  The first integer
            % returned is InitialValue, and successive calls to
            % generate(obj) return InitialValue+1, InitialValue+2, etc.
            %
            % The next integer in the stream may be obtained without
            % updating the internal state of the stream generator using
            % the property obj.NextValue.  A subsequent call to
            % generate(obj) will return the value previously observed in
            % obj.NextValue. Once generated, obj.NextValue is automatically
            % updated.
            %
            % A stream may be reset to its initial state by calling
            % reset(obj), after which the next call to generate(obj) will
            % return InitialValue.
            %
            % The value returned is a double-precision integer, with an
            % upper bound of 2^52.  Beyond that, the stream resets its
            % internal counter and will return InitialValue as the next
            % integer value in the sequence.
            %
            % All integer streams created in a MATLAB session are
            % maintained throughout the session, and may be accessed
            % multiple times and from multiple MATLAB programs.  However,
            % the state of a stream will be lost when MATLAB is exited and 
            % will be reinitialized in a subsequent MATLAB session.
            
            % Initialize stream name
            if nargin>0
                h.Stream = stream;
            end
            h.StreamFullName = ['IntegerStreamGenerator_' h.Stream];
            
            % Initialize first integer
            if nargin>1
                h.InitialValue = initialValue;
            end
            
            connect(h);
        end
        
        function i = get.NextValue(h)
            % Returns the next value from the integer stream, leaving
            % the previous state of the stream generator unaltered.  The
            % next call to generate() will return this integer value.
            i = getappdata(0,h.StreamFullName);
        end
        
        function iCurr = generate(h)
            % Returns the next value from the integer stream, incrementing
            % the internal state of the stream generator.  The next call to
            % generate() will return the next integer from the stream.
            
            % Get current integer to return to caller
            iCurr = getappdata(0,h.StreamFullName);
            
            % Increment the double-precision floating point counter
            % See if we've past the limit of integer resolution
            % Limit is 2^52.  If i=2^53 and j=i+1, then i==j and we fail.
            % Note: this is NOT "inf" - we hit the limit of precision for
            % representing the 1's place in the 52 bit mantissa of doubles.
            %
            % The spec is to go back to InitialValue and recycle sequence
            % values.  The NEXT value returned by the generator will be
            % InitialValue.
            
            iNext = iCurr+1;
            if iNext == iCurr
                iNext = h.InitialValue; % return back to zero
            end
            setappdata(0,h.StreamFullName,iNext);
        end
        
        function reset(h)
            % Reset a stream back to its initial state, after which the
            % next call to generate(obj) will return firstInt.
            setappdata(0,h.StreamFullName,h.InitialValue);
        end
    end
    
    methods (Access=private)
        function connect(h)
            % Connect to named stream
            % If non-existent, initialize it
            if ~isappdata(0,h.StreamFullName)
                setappdata(0,h.StreamFullName,h.InitialValue);
            end
        end
    end
end
