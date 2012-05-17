function [x0, par] = var2obj(nlsys, x)
%VAR2OBJ  Extracts initial states (X0) and parameters (PAR) from X. Takes a
%   common vector of free parameters and states and returns all the model
%   parameters and initial states as separate outputs.
%
%   [X0, PAR] = VAR2OBJ(NLSYS, X);
%
%   NLSYS is the IDNLGREY model.
%
%   X is a vector containing the free entities (parameters and initial
%   states) of NLSYS.
%
%   X0 is a Nx-by-Ne (number of states-by-number of experiments) initial
%   states matrix.
%
%   PAR is a Npo-by-1 (number of parameter objects; such an object can be a
%   scalar, a column vector or a 2-dimensional matrix) cell array with
%   model parameter values.
%
%   See also IDNLGREY/OBJ2VAR.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.10.2 $ $Date: 2006/12/27 21:00:09 $

% Check that the function is called with two arguments.
nin = nargin;
error(nargchk(2, 2, nin, 'struct'));

% Retrieve information about Parameters.
p = nlsys.Parameters;
npo = length(p);
par = cell(npo, 1);
offset = 0;
for k = 1:npo
    valk = p(k).Value;
    idx = ~p(k).Fixed;
    len = sum(idx(:));
    if (len > 0)
        valk(idx) = x(offset+1:offset+len);
        offset = offset+len;
    end
    par{k} = valk;
end

% Retrieve information about InitialStates.
x0 = cat(1, nlsys.InitialStates.Value);
idx = ~cat(1, nlsys.InitialStates.Fixed);
x0(idx) = x(offset+1:end);