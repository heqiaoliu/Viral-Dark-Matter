function [Nb,Na,F,A,P,nfpts] = validatespecs(this, specs)
%VALIDATESPECS   Validate the specs

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:28:09 $

% Get filter order, amplitudes and frequencies 
Nb = this.NumOrder;
Na = this.DenOrder;
[F,A,P,nfpts] = super_validatespecs(this);

% [EOF]
