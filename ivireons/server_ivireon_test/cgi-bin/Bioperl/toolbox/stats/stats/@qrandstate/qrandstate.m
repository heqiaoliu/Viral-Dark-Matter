classdef (Hidden) qrandstate < handle
    %QRANDSTATE This undocumented class may be removed in a future release.
    
    %   QRANDSTATE is a class that encapsulates the a state of a stream.
    %   The default implementation contains an index into the point set:
    %   subclasses may add data that will speed up generation of the next
    %   point in the sequence.  An ISCOMPLETE method is provided that
    %   indicates whether a state contains all of the data expected for a
    %   state or whether it is partial, and only the index should be relied
    %   on.

    %   Copyright 2007-2008 The MathWorks, Inc.
    %   $Revision: 1.1.6.1 $    $Date: 2010/03/16 00:21:13 $
    
    
    % Index: User-visible index into point set.
    % SequenceIndex: Index into underlying sequence; may be point-set specific
    properties
        Index = 1;
        SequenceIndex = [];
    end
    
    
    methods
        function ok = isComplete(obj)
            %ISCOMPLETE Check whether state is complete or partial.
            %   ISCOMPLETE(SS) returns true if the state object contains a
            %   complete set of state information.  
            %
            %   This method should be overridden by subclasses to return
            %   false when a state has been reset using just an index.  In
            %   this case the next point generation must treat the state as
            %   though it has not been initialized and can only trust the
            %   Index property.  
            
            ok = ~isempty(obj.SequenceIndex);
        end
        
        
        function resetState(obj, Index)
            %RESETSTATE Change the state to a new point set index.
            %   RESETSTATE(OBJ,INDEX) changes the state to the specified
            %   point set index.  This method is used when the state of a
            %   stream is altered.
            %
            %   Subclasses that hold additional state data should
            %   override this method in order to clear or re-create that
            %   data.
            
            if ~isa(Index, 'double')
                error('stats:qrandstate:InvalidPropertyValue', ...
                    'Index must be a double.');
            end
            if ~isscalar(Index) || Index<1 || fix(Index)~=Index
                error('stats:qrandstate:InvalidPropertyValue', ...
                    'Index must be a scalar integer greater than 0');
            end
            obj.Index = Index; 
            obj.SequenceIndex = [];
        end
    end
end
