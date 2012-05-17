function s = saveobj(h)
%SAVEOBJ Save data contained in dataset.
%   S = SAVEOBJ(H) is called by SAVE when an object is saved to a .MAT
%   file. The return value s is subsequently used by SAVE to populate the
%   .MAT file.
%
%   SAVEOBJ will be separately invoked for each object to be saved.
%
%   See also SAVE, LOADOBJ.

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/17 21:49:00 $

s = h.data2save;

% [EOF]