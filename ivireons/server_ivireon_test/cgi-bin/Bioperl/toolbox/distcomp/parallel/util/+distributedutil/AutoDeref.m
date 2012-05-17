%AUTODEREF - what a "AutoTransfer" becomes outside an SPMD block.

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 21:57:05 $

classdef AutoDeref < spmdlang.AbstractRemote
    
    properties ( GetAccess = public, Hidden )
        Value
    end
    
    methods ( Access = public )
        function obj = AutoDeref( value )
            obj.Value = value;
        end
        
        % This prevents an autoderef from making it back into SPMD.
        function [a,b] = getUserDataToSPMD( obj ) %#ok
            error( 'distcomp:spmd:AutoDerefTransferred', ...
                   'An unexpected object was sent into an SPMD block' );
        end
    end
end
