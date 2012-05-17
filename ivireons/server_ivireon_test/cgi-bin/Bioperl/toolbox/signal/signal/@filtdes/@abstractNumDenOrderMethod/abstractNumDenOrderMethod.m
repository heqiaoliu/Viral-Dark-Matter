function varargout = abstractNumDenOrderMethod
%ABSTRACTNUMDENORDERMETHOD  Constructor for this object.


%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.4 $  $Date: 2009/05/23 08:15:15 $

error(nargchk(0,0,nargin,'struct'));

% This class is abstract, for now error in the constructor
error(generatemsgid('AbstractClass'),'This is an abstract class.');







