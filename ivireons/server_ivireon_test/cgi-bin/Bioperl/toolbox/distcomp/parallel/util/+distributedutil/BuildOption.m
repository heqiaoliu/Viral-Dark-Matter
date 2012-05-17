%BuildOption Enum for AbstractCodistributor.buildFromLocalPart

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/12 17:28:19 $

classdef BuildOption
    properties (Constant = true)
        CommunicationAllowed = 0;
        NoCommunication = 1;
        CalculateSize = 2;
        MatchLocalParts = 3;
  end
end
