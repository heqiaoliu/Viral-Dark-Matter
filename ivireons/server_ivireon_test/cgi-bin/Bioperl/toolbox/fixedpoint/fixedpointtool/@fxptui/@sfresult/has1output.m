function b = has1output(h)
%HAS1OUTPUT True if block for H is providing only one results. Not
%multiple inputs, outputs or values

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/20 07:54:09 $

b = true;
if (isa(h.daobject,'Stateflow.Chart') || isa(h.daobject,'Stateflow.TruthTableChart') || isa(h.daobject,'Stateflow.LinkChart'))   
  prts = get_param(h.daobject.Path,'Porthandles');
  out_prts = numel(prts.Outport);
  if out_prts > 1; b = false; end
end


% [EOF]
