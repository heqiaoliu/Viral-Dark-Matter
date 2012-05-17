function status = ismultiinput(nlobj)
%ISSINGLEREG return true for multi-input nonlinearity estimator
%
%  status = issingleinput(nlobj)
%
%This method, returning false, overloads the superclass idnlfun/ismultiinput.


% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:58:09 $

% Author(s): Qinghua Zhang

status = false;

% FILE END