function status = ismultiinput(nlobj)
%ISSINGLEREG return true for multi-input nonlinearity estimator
%
%  status = issingleinput(nlobj)
%
%This method, returning false, overloads the superclass idnlfun/ismultiinput.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/06/07 14:44:21 $

% Author(s): Qinghua Zhang

status = false;

% FILE END