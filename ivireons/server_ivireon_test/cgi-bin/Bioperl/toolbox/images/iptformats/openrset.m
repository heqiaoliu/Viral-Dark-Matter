function openrset(filename)
%OPENRSET   Open R-Set file.
%   OPENRSET(FILENAME) opens the reduced resolution dataset (R-Set)
%   specified by FILENAME for viewing.
%
%   See also IMTOOL, RSETWRITE.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/06/16 04:12:26 $
    
    if isrset(filename)
        imtool(filename)
    else
          error('Images:openrset:invalidRSet',...
                'Unable to open R-Set file %s: not an R-Set file.',...
                filename);
    end

    
