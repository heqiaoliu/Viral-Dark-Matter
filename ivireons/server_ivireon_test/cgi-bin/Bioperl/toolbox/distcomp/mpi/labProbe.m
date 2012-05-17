%labProbe - test to see if messages are ready to labReceive
%   labProbe on its own returns a logical value indicating whether or not
%   any data is available to labReceive.
%   
%   labProbe( source ) only tests for the specified source id
%
%   labProbe( 'any', tag ) only tests for the specified tag
%
%   labProbe( source, tag ) tests for the specified source and tag
%
%   In each case, two additional output arguments - the source and tag - are
%   available:
%   [data_available, source, tag] = labProbe
%
%   If no data is available, source and tag are returned as [].
%
%   See also labReceive.

%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.10.4 $  $Date: 2009/09/23 13:59:24 $
