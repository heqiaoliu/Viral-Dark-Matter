function open(w)
%OPEN Open a virtual world.
%   OPEN(W) opens the virtual world referred to by VRWORLD handle W.
%   When being opened for the first time, the virtual world internal
%   representation is created based on the associated VRML file.
%   If a world is opened more than once it must be also closed the
%   appropriate number of times.
%
%   If W is an array of handles all the virtual worlds are opened.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:11:08 $ $Author: batserve $

% do it
for i = 1:numel(w);
  vrsfunc('VRT3SceneOpen', w(i).id);
end
