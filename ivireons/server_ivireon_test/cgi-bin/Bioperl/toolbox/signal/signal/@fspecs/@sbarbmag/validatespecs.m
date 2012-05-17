function [N,F,A,P,nfpts] = validatespecs(this)
%VALIDATESPECS   Validate the specs

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:35:28 $

% Get filter order, amplitudes and frequencies 
N = this.FilterOrder;
[F,A,P,nfpts] = super_validatespecs(this);

% [EOF]
