function addsection(Hd, section, pos)
%ADDSECTION Add a section to the filter.

%   Inputs:
%     Hd: dfilt.cascade object
%     section: dfilt object
%     pos: position of the section to add

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2009/08/11 15:48:14 $


error(generatemsgid('ObsoleteMethod'), ...
    'The addsection method is obsolete.  Use the addstage method instead.');


