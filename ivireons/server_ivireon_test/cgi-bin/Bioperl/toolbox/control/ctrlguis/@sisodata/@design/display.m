function display(this)
% Display method for @design class

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2005/12/22 17:40:03 $
disp(rmfield(get(this),{'Fixed','Tuned','Loops'}))