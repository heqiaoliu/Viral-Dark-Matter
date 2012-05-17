function strs = whichspecobjs(h)
%WHICHSPECOBJS Determine which specs objects are used by this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:09:21 $

strs = firceqrip_whichspecobjs(h);
strs = {strs{:},'filtdes.hpmagfir'};
