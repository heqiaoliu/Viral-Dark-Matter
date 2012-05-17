function flag =setresetbeforefiltering(Hd, flag)
%SETRESETBEFOREFILTERING Set function of the ResetBeforeFiltering property.

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/12/26 22:03:58 $

Hd.PersistentMemory = ~strcmpi(flag,'on');

