%KeyHolder object - handle class to store a key into the value store. This
%lives in outer parallel context, and refers to the ValueStore inside
%parallel context.  - manages lifetime of remote data. When an instance of
%this object is destroyed, it implies that the value on the worker can be
%discarded.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/02/06 14:17:07 $
classdef (Hidden, Sealed) KeyHolder < handle
    
    properties ( SetAccess = private, GetAccess = public, Hidden, Transient )
        % The actual key into the value store
        Key = [];
    end

    properties ( Access = private, Hidden, Transient )
        % The index within the resource set of the lab to which this key applies
        LabIdx = -1;
        
        % The resource set holder - needed so we can notify when we're no longer
        % referenced
        ResSetHolder = -1;
    end
    
    methods ( Hidden, Access = private )
        function x = isValid( obj ) 
            x = ~isempty( obj.Key );
        end
    end
    
    methods ( Hidden )
        function obj = KeyHolder( k, resSetIdx, resSetHolder )
            obj.Key          = k;
            obj.LabIdx       = resSetIdx;
            obj.ResSetHolder = resSetHolder;
        end
        
        % Accessor for the key
        function key = getKey( obj )
            key = obj.Key;
        end
        
        function delete( obj )
            if obj.isValid()
                obj.ResSetHolder.getResourceSet().keyUnreferenced( obj.LabIdx, obj.Key );
            end
        end
        
        function val = getFromLab( obj )
            if ~obj.isValid()
                error( 'distcomp:spmd:InvalidRemote', ...
                       'Request to retrieve invalid Composite' );
            else
                val = obj.ResSetHolder.getResourceSet().getFromLab( obj.LabIdx, obj.Key );
            end
        end
    end
end
