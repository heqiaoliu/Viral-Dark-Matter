function setFocus(h)
% SETFOCUS

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 2000-2005 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:26:33 $

awtinvoke( h.STable, 'requestFocus()' );
