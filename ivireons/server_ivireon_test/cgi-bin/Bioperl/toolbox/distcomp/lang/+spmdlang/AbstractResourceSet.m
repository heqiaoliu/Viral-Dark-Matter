% AbstractResourceSet - common interface for trivial and remote resource set
% objects. This abstract class manages the reference count mechanism, and
% defines the interface for subclasses.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:02 $
classdef AbstractResourceSet < handle

    % Reference-count behaviour is protected here
    properties ( Access = protected, Hidden )
        ReferenceCount = 0;
    end
    
    % Visible properties of a resource set
    properties ( SetAccess = private )
        numlabs = -1;
    end
    
    methods ( Hidden )
        
        function obj = AbstractResourceSet( nlabs )
            obj.numlabs = nlabs;
        end
        
        % Reference count management
        function tf = isReferenced( obj )
            tf = ( obj.ReferenceCount > 0 );
        end
        
        function incrementRefCount( obj )
            obj.ReferenceCount = obj.ReferenceCount + 1;
        end
        
        function decrementRefCount( obj )
            obj.ReferenceCount = obj.ReferenceCount - 1;
        end
        
        % Called to ensure this resource set is no longer used. (For example, when
        % the Session has gone away)
        function invalidate( obj, labsStillAvailable ) %#ok<INUSD>
            obj.ReferenceCount = -Inf;
        end
        
        function errorIfInvalid( obj )
            if ~obj.isValid()
                error( 'distcomp:spmd:InvalidResourceSet', ...
                       ['The labs you have attempted to access are no longer available.\n', ...
                        'This may occur if the matlabpool has been closed'] );
            end
        end
        
    end
    
    % Methods that subclasses must override.
    methods ( Abstract )
        % Does this resource set match the SPMD constraint arguments?
        tf      = satisfiesConstraints( obj, minN, maxN );
        
        % Is it OK to use this resource set?
        tf      = isValid( obj );

        % Are the labs free to be accessed?
        tf      = canAccessLabs( obj );

        % Retrieve a value from a lab
        val     = getFromLab( obj, labidx, key );
        
        % Set a value on a lab
        newKey  = setOnLab( obj, labidx, newValue );
        
        % Deal with a cleared value
        keyUnreferenced( obj, labidx, key );
        
        % Build an SpmdBlockExecutor
        blockEx = buildBlockExecutor( obj, bodyFcn, assignOutFcn, getOutFcn, ...
                                      unpackInFcn, initialOuts );
    end
    
end
