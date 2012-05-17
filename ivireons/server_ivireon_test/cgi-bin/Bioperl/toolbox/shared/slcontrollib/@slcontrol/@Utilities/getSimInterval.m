function [Tstart, Tstop, Fail] = getSimInterval(this, model)
% GETSIMTIME Get simulation interval from the MODEL

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.4 $ $Date: 2004/12/10 19:33:42 $

[Tstart, FailStart] = evalExpression( this, get_param( model, 'StartTime' ) );

[Tstop, FailStop]   = evalExpression( this, get_param( model, 'StopTime'  ) );

FailRange = (Tstart > Tstop) | isinf(Tstart);
Fail = FailStop || FailStart || FailRange;
