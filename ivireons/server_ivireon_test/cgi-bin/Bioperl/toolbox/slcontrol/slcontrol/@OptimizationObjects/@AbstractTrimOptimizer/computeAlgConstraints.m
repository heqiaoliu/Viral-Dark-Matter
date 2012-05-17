function computeAlgConstraints(this)
% COMPUTEALGCONSTRAINTS  Compute the algbraic constraints for a
% Simulink model.
%
 
% Author(s): John W. Glass 24-Aug-2007
% Copyright 2007 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2007/10/15 23:31:29 $

this.F_const = feval(this.model,[],[],[],'constraints');