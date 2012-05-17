function var = obj2var(nlsys, varargin)
%OBJ2VAR  Serializes estimated parameter/state object data into estimation
%   variable data for optimizers.
%
%   VAR = OBJ2VAR(NLSYS);
%   VAR = OBJ2VAR(NLSYS, INFOSTRUCT);
%
%   NLSYS is the IDNLGREY model.
%
%   VAR is a structure containing a list of free entities along with their
%   lower and upper bounds.
%
%   See also IDNLGREY/VAR2OBJ.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.3 $ $Date: 2007/11/09 20:19:32 $

% Check that the function is called with one or two arguments.
nin = nargin;
error(nargchk(1, 2, nin, 'struct'));

% Create structure array with estimation entities (parameters and initial
% states) to work with.
p = [nlsys.Parameters(:); nlsys.InitialStates(:)];

% Retrieve estimation variable data for optimizers.
lb  = [];   % Lower parameter/state bound.
ub  = [];   % Upper parameter/state bound.
par = [];   % List of all parameters stored in a vector.
for ct = 1:length(p)
    pct = p(ct);
    e = find(~pct.Fixed);
    
    if ~isempty(e)
        % Values (serve as initial guesses).
        val = pct.Value(e);
        par = [par; val(:)];
        
        % Lower bounds.
        val = pct.Minimum(e);
        lb = [lb; val(:)];
        
        % Upper bounds.
        val = pct.Maximum(e);
        ub = [ub ; val(:)];
    end
end

% Return free parameter information structure.
var = struct('Value', par,  ...
             'Minimum', lb, ...
             'Maximum', ub  ...
            );