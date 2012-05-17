function psd(this,varargin)
%PSD  Overloaded PSD method to produce a meaningful error message.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/01/10 21:13:19 $

error(generatemsgid('NotSupported'),'PSD method is not supported for the %s class.',get(classhandle(this),'name'));


