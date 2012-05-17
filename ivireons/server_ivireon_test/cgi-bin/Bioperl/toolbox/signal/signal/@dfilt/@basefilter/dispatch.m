function Hd = dispatch(Hb)
%DISPATCH Returns the contained DFILT objects.

%   Author: V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2007/12/14 15:07:24 $

error(generatemsgid('NotSupported'),'The method invoked is not supported by the %s object.', class(Hb))

% [EOF]
