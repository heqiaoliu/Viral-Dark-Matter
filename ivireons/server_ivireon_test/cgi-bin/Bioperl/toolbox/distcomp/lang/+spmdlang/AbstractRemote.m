%AbstractRemote - base class for all Remote types.  The main purpose of this
%class is to maintain the cell array of keys to remote data, and manage
%merging of newly supplied keys.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.4 $   $Date: 2009/03/25 21:54:40 $
classdef AbstractRemote

    properties ( Access = protected, Transient, Hidden )
        % A cell-array of KeyHolder objects, some may be empty
        KeyVector = [];
        
        % Handle to resource set
        ResSetHolder = [];
        
        % Our factory function
        FactoryFcn = [];
    end

    methods ( Access = public, Static, Hidden )
        function c = saveLoadCount( action )
        % saveLoadCount - used for tracking transferral of remote objects across
        % SPMD boundaries.
            persistent count
            if isempty( count )
                count = 0;
            end
            switch action
              case 'increment'
                count = count + 1;
              case 'get'
                c = count;
              case 'clear'
                count = 0;
            end
        end
    end

    
    % NB - no constructor, as all the properties are default constructible.
    
    methods ( Access = protected, Hidden )
        function obj = pPostKeySet( obj )
        % Do nothing. This method is called after new keys have been supplied.
        end
        
        function obj = mergeUserData( obj, newUserDataCell ) %#ok<INUSD>
        % Do nothing. Subclasses may choose to override this if necessary.
        end
        
        % Return a cell array containing either raw int64, or empty based on KeyVector.
        function rawKeyCell = getRawKeyCell( obj )
        % rawKeys to become a cell array with empty entries where no key exists
            empties                = cellfun( @isempty, obj.KeyVector );
            rawKeyCell             = cell( 1, length( obj.KeyVector ) );
            rawKeyCell( ~empties ) = cellfun( @getKey, obj.KeyVector( ~empties ), ...
                                              'UniformOutput', false );
        end
        
        % Return true iff the matlabpool corresponding to this Remote is still open
        function tf = isResourceSetOpen( obj )
            if isempty( obj.ResSetHolder )
                % Get here for a save/loaded Remote, but don't warn - the user will already
                % have been warned.
                tf = false;
            else
                tf = obj.ResSetHolder.getResourceSet().isValid();
            end
        end
    end

    methods ( Access = public, Hidden )
        % Return the wire-transmission form of this Remote. This method is not
        % sealed to allow Composite to override it.
        function packed = packForTransmission( obj )
            [userFcn, userData] = getUserDataToSPMD( obj );
            packed = spmdlang.SendableParcel( getRawKeyCell( obj ), ...
                                              userFcn, userData, ...
                                              obj.ResSetHolder.getResourceSet() );
        end
    end
    
    methods ( Access = public, Sealed, Hidden )

        % Called post-construction by the spmd executor to supply keys, resource
        % set, and factory function.
        function obj = init( obj, keyVec, resSetHolder, ffcn )
            obj.KeyVector = cell( 1, length( keyVec ) );
            for ii=1:length( keyVec )
                if ~isempty( keyVec{ii} )
                    obj.KeyVector{ii} = spmdlang.KeyHolder( keyVec{ii}, ii, resSetHolder );
                end
            end
            obj.ResSetHolder = resSetHolder;
            obj.FactoryFcn = ffcn;
            % Allow subclasses the opportunity to change things
            obj = obj.pPostKeySet();
        end

        function [fcnH, userData] = getRemoteFromSPMD( obj ) %#ok
            % Composites to Remote is disallowed, return function to build invalid Remote
            fcnH = @spmdlang.invalidRemoteBuilder;
            userData = [];
        end
        
        
        function tf = isMergable( obj, ffcn, resSet )
        % We will call this prior to attempting to merge a Remote to ensure that
        % the factory function is compatible.
            tf = isequal( obj.FactoryFcn, ffcn ) && ...
                 isequal( resSet, obj.ResSetHolder.getResourceSet() );
        end
        
        % default behaviour is simply to overwrite the pre-existing lab-side value
        function obj = mergeNewReturns( obj, newKeyVec )
            for ii=1:length( newKeyVec )
                if ~isempty( newKeyVec{ii} )
                    obj.KeyVector{ii} = spmdlang.KeyHolder( newKeyVec{ii}, ii, obj.ResSetHolder );
                end
            end
            % Give the object a chance to do stuff with the new keys
            obj = obj.pPostKeySet();
        end
    end
end
