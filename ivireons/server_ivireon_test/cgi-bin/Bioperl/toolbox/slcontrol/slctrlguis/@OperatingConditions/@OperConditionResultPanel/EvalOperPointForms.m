function op = EvalOperPointForms(this)
% EVALOPERPOINTFORMS  Evaluate the operating point forms
 
% Author(s): John W. Glass 24-Jun-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/10/31 07:36:17 $

% Create a copy of the operating point and check for a consistent set of
%  operating point
op = copy(this.OpPoint);
update(op,true);