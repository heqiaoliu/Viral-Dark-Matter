%InvalidRemote - this class exists to support the return or other Remote
%types from SPMD blocks.

% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/06/24 17:03:05 $

classdef (Sealed) InvalidRemote < Composite
    methods (Hidden)
        function obj = InvalidRemote()
            obj = obj@Composite( 'empty' );
        end
        function disp( obj ) %#ok
            fprintf( 1, '    Invalid Composite\n\n' );
        end
    end
    
    methods ( Access = protected, Hidden )
        function obj = pPostKeySet( obj )
            % Override the key vector.
            obj.KeyVector = cell( 1, obj.ResSetHolder.getResourceSet().numlabs );
            % And null out the resource set, we don't need to keep that
            obj.ResSetHolder = [];
        end
    end
end
