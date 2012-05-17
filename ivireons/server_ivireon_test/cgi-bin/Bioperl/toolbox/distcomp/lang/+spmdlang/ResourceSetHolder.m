% This class exists as an intermediary between any object and a resource
% set, and informs the resource set on destruction so that the resource set
% itself can maintain a reference count. Objects should not hold "raw"
% references to resource sets.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:09 $
classdef (Hidden, Sealed) ResourceSetHolder < handle
   
    properties ( Access = private, Hidden, Transient )
        % The actual resource set
        ResourceSetObj = [];
    end

    methods ( Access = private, Hidden )
        function tf = isValid( obj )
            tf = ~isempty( obj.ResourceSetObj );
        end
    end

    
    methods ( Access = public, Hidden )
        function obj = ResourceSetHolder( resSet )
            obj.ResourceSetObj = resSet;
            if ~isempty( resSet )
                resSet.incrementRefCount();
            end
        end
        
        function rs = getResourceSet( obj )
            if isValid( obj )
                rs = obj.ResourceSetObj;
            else
                error( 'distcomp:spmd:ResourceSet', ...
                       ['An unexpected attempt was made to use an invalid Resource Set object\n', ...
                        'This may occur if you attempt to save and load Composite objects'] );
            end
        end

        function delete( obj )
            if isValid( obj )
                obj.ResourceSetObj.decrementRefCount();
            end
        end
    end
    
end
