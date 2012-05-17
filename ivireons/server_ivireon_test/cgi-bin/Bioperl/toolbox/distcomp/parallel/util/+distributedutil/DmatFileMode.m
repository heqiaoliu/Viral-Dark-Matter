% DmatFileMode Enum for DmatFile

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $   $Date: 2009/10/12 17:28:22 $

classdef DmatFileMode < int32
    properties ( Constant = true )
        PartialReadMode = distributedutil.DmatFileMode( 0 ); % Normal read mode, supports partial reading
        ReadCompatMode  = distributedutil.DmatFileMode( 1 ); % Read "compatibility" mode
        WriteMode       = distributedutil.DmatFileMode( 2 ); % Normal write mode
    end 
    
    methods ( Access = private )
        function obj = DmatFileMode( val )
            obj@int32( val );
        end
    end

    methods
        function tf = canRead( dfm )
            tf = ( dfm == distributedutil.DmatFileMode.PartialReadMode || ...
                   dfm == distributedutil.DmatFileMode.ReadCompatMode );
        end
        function tf = canWrite( dfm )
            tf = ( dfm == distributedutil.DmatFileMode.WriteMode );
        end
    end
end
