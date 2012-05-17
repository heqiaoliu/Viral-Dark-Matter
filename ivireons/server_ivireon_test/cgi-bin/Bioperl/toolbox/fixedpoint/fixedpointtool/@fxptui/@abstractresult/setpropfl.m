function val = setpropfl(h, val)
%SETPROPFL   Set the propfl.

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:52:43 $

if(isempty(val)); return; end
%call your dt function hereafs
SimulinkFixedPoint.Autoscaler.getProposedDTfromFL(h, val);

% [EOF]
