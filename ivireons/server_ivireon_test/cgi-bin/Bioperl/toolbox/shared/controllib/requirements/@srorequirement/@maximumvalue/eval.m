function c = eval(this,Response)
% Evaluates maximum value for given signal. Note this
% requirement can be either an objective or constraint.
%
% Inputs:
%          this      - a srorequirement.maximumvalue object.
%          Response  - An nxm vector with the signal to evaluate, the first 
%                      column is the time vector.
% Outputs: 
%          c - a 1xm double giving the maximum value of the signal(s)
 
% Author(s): A. Stothert 21-March-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:01 $

c = []; 
if isempty(Response) 
   return 
end

%Measured response
y = Response(:,2:end);

c = max(y);
