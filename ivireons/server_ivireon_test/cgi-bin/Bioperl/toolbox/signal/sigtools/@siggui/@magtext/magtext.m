function this = magtext
%MAGTEXT   A magnitude frame with nothing but text in it.
%   MAGTEXT(DEFAULTSTRING)  creates a magtext object and sets the string.

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:24:27 $

% first call builtin constructor
this = siggui.magtext;

% Set the tag of the object
settag(this);

% [EOF]
