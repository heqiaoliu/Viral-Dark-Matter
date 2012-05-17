function removesection(Hd, pos)
%REMOVESECTION Remove a section to the filter.

%   Inputs:
%     Hd: dfilt.cascade object
%     pos: position of the section to remove

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/08/11 15:48:17 $

error(generatemsgid('ObsoleteMethod'), ...
    'The removesection method is obsolete.  Use the removestage method instead.');


