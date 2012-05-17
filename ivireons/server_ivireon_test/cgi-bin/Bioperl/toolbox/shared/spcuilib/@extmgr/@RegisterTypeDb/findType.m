function hRegisterType = findType(hRegisterTypeDb,theType)
%FINDTYPE Find extension type in type database.
%  FINDTYPE(H,'theType') returns specified extension type in database.
%  If not found, empty is returned.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:47:27 $

% hRegisterType = iterator.findImmediateChild(hRegisterTypeDb, ...
%     @(hRegisterType)strcmpi(hRegisterType.Type,theType));

% This is faster, still case-independent since UDD offers that
% service via find implicitly:
hRegisterType = findChild(hRegisterTypeDb, 'Type', theType);

% [EOF]
