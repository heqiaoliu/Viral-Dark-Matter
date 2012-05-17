function [fcnH, userData] = getRemoteFromSPMD( obj )
;%#ok undocumented

%getRemoteFromSPMD Internal functionality to support distributed

    
%   Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/03/25 21:59:04 $

fcnH = @iGetDistributed;
userData = {size( obj ), classUnderlying( obj ), issparse( obj ), iBytes( obj )};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Factory function which interprets the user data
function d = iGetDistributed(userData)
ud = userData{1}; % Should be replicated, so pick the user data from lab 1.
bb = 0;
for ii=1:length( userData )
    bb = bb + userData{ii}{end};
end
% Use the "undoc" flag to allow us to build the distributed with these arguments.
d = distributed( ud{1:end-1}, bb, 'undoc:distributedFromSPMD' );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper to extract the local size in bytes of this codistributed
function b = iBytes( obj )
lp = getLocalPart( obj ); %#ok<NASGU> used by "whos"
w  = whos( 'lp' );
b  = w.bytes;
end
