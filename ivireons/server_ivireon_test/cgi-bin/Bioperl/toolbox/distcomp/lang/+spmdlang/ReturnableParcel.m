%%
% ReturnableParcel - this is what gets returned from each lab at the end of
% an SPMD block. The client will receive a cell array of these, one from
% each lab, for each output value.
%

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/02/06 14:17:10 $

classdef ReturnableParcel
    properties ( Access = private )
        % The key into the ValueStore
        key;
        
        % The user's factory function
        fcnH;
        
        % The user data to go with the factory function
        userData;
    end
    
    methods 
        function obj = ReturnableParcel( k, f, d )
            if ~isa( k, 'int64' ) || ~isa( f, 'function_handle' )
                error( 'distcomp:spmd:ReturnableParcelConstruction', ...
                       'Unexpected input arguments for ReturnableParcel construction' );
            end
            obj.key      = k;
            obj.fcnH     = f;
            obj.userData = d;
        end

        function ff = getFactoryFcn( obj )
            ff = obj.fcnH;
        end
        
        function ud = getUserData( obj )
            ud = obj.userData;
        end
        
        function k = getKey( obj )
            k = obj.key;
        end
    end
end
