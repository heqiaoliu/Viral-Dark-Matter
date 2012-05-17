function val = pSetClusterSize(obj, val)
; %#ok Undocumented

%  Copyright 2007 The MathWorks, Inc.

if val ~= round( val )
    error( 'distcomp:scheduler:InvalidProperty', 'ClusterSize must be an integer' );
end
if  val < 0
    % ClusterSize cannot be < 0
    error( 'distcomp:scheduler:InvalidProperty', 'ClusterSize cannot be negative' );
end
