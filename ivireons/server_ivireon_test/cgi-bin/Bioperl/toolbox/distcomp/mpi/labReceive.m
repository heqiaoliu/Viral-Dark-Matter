%labReceive - receive data from another lab
%   data = labReceive - receive data from any lab with any tag
%
%   data = labReceive( source ) - receive data from the specified source
%   with any tag
%
%   data = labReceive( 'any', tag ) - receive data from any source with the
%   specified tag
%
%   data = labReceive( source, tag ) - receive data from the specified
%   source with the specified tag.
%
%   In each case, two additional output arguments - the source and tag - are
%   available:
%   [data, source, tag] = labReceive
%
%   This method will block until a corresponding call to labSend is made.
%
%   See also labBarrier, labSend, labSendReceive, labProbe, numlabs.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2009/09/23 13:59:25 $
