%%
% This class is the wire-transmission form of a Remote. It expects to be
% broadcast, therefore it knows the full key vector for the valuestore. It
% also needs to transmit the client value, if that is known.
%

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2008/05/19 22:46:12 $

classdef SendableParcel
    properties ( Access = private, Hidden )
        % keyVec - cell array of either int64 or empty
        keyVec; 
        
        % userFcn - the user's function to call on the labs
        userFcn;

        % userData - for userFcn
        userData;

        % clientVal - any data
        clientVal;
        gotClientVal = false;
    end
    
    properties ( Access = private, Transient )
        % When choosing a resource set, Composites will already have been packed into
        % parcels, but we need to retain the resource set until transmission
        resSet;
    end
    
    methods
        
        
        function obj = SendableParcel( keyVec_, userFcn_, userData_, resSet_ )
            if ~iscell( keyVec_ ) || ~isa( userFcn_, 'function_handle' )
                error( 'distcomp:spmd:SendableParcelConstruction', ...
                       'Unexpected input arguments for SendableParcel construction' );
            end
            obj.keyVec   = keyVec_;
            obj.userFcn  = userFcn_;
            obj.userData = userData_;
            obj.resSet   = resSet_;
        end

        function obj = setClientValue( obj, cv )
            obj.clientVal = cv;
            obj.gotClientVal = true;
        end
        
        function rs = getResourceSet( obj )
            rs = obj.resSet;
        end

        % Called from AbstractSpmdExecutor.unpack() when this object has been
        % transferred to the labs. Looks in the value store (or client
        % value, if one exists)
        function unpacked = unpack( obj )
            if ~isempty( obj.keyVec{labindex} )
                try
                    unpacked = spmdlang.ValueStore.retrieve( obj.keyVec{labindex} );
                catch E
                    except = MException( 'distcomp:spmd:RemoteUnpack', ...
                                         'The Remote variable could not be found on the lab' );
                    except = addCause( except, E );
                    throw( except );
                end
            else
                if obj.gotClientVal
                    unpacked = obj.clientVal;
                else
                    % This is what happens if a Remote with no value on a particular lab
                    % gets passed in as an input value to an spmd block.
                    error( 'distcomp:spmd:NoInput', ...
                           'The remote object had no value on the given lab' );
                end
            end
            % Call the function as specified by the data.
            unpacked = obj.userFcn( unpacked, obj.userData );
        end
        
    end
end
