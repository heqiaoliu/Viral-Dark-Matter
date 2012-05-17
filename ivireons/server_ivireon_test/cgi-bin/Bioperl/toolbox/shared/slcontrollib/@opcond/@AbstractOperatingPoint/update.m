function this = update(this,varargin)
%

%UPDATE Updates operating point object with structural changes in a Simulink
%       model.
%
%   UPDATE(OP) updates an operating point object OP with changes in a
%   Simulink model such as states being added or removed.

% Use update(this,Check), Check - 1 or 0 as a flag to error out if a
% Simulink model has changed notifying the user to call this method
% directly to update their model.

%  Author(s): John Glass
%  Revised:
%   Copyright 1986-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/30 00:40:08 $

% Initialize the check flag
if (nargin == 2) && varargin{1};
    Check = true;
else
    Check = false;
end

% Determine if the model has been precompiled
feval(this.Model,[],[],[],'compile')
try
    sync(this,Check);
catch Ex
   feval(this.Model,[],[],[],'term')  
   rethrow(Ex);
end
feval(this.Model,[],[],[],'term')  
end