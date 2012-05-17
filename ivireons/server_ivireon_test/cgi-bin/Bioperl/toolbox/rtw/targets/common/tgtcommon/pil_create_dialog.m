function obj = pil_create_dialog(h,className)
% PIL_CREATE_DIALOG Instantiates a dynamic dialog object.
%
%    OBJ = PIL_CREATE_DIALOG returns OBJ, a dynamic 
%    dialog object.

%    Copyright 2005-2006 The MathWorks, Inc.
%    $Revision: 1.1.6.1 $  $Date: 2006/06/16 20:14:00 $

obj = pilverification.(className{1})(h);
