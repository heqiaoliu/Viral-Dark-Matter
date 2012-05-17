function psdopts(this,varargin)
%PSDOPTS  Overloaded PSDOPTS method to produce a meaningful error message.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:14:38 $

error(generatemsgid('NotSupported'),['PSDOPTS method is not supported for the ',get(classhandle(this),'name'),' class.'])

% [EOF]
