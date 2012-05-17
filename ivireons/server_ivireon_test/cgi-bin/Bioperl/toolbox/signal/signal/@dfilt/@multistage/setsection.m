function setsection(Hd, section, pos)
%SETSECTION Set a section of the filter.

%   Inputs:
%     Hd: dfilt.cascade object
%     section: dfilt object
%     pos: position of the section to set

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/08/11 15:48:19 $

error(generatemsgid('ObsoleteMethod'), ...
    'The setsection method is obsolete.  Use the setstage method instead.');


