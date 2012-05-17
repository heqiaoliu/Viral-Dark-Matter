function setP(this,P)
% Sets value of augmented plant P.

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2009/04/21 03:07:01 $

this.P = P; % set private value

% Update plant representation for fast frequency response evaluation
try
    this.Pfr = zpk(P);
catch ME %#ok<NASGU>
    % FRD or Model with Internal Delays
    this.Pfr = P;
end

