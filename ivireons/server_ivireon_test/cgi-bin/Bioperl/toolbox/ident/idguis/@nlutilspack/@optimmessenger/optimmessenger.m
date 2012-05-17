function h = optimmessenger
% create optimmemssenger object that will send iterinfo to GUI during
% optimization. An instance of this object is stored in the OptimMessenger
% property of idnlmodel by the GUI. The GUI creates this object, puts it in
% the idnlmodel object and adds a listener to it.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2008/10/02 18:50:53 $

h = nlutilspack.optimmessenger;
