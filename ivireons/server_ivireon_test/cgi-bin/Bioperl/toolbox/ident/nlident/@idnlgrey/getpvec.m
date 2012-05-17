function parvec = getpvec(nlsys)
%GETPVEC  Returns the parameters of nlsys as a Np-by-1 vector.
%
%   PARVEC = GETPVEC(NLSYS);
%
%   NLSYS is the IDNLGREY model.
%
%   PARVEC is a Np-by-1 (number of parameters) vector. Parameters that are
%   vectors/matrices will be stacked using the (:) operator.

%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $ $Date: 2008/06/13 15:23:34 $

% Check that the function is called with two arguments.
nin = nargin;
error(nargchk(1, 1, nin, 'struct'));

% Retrieve information about Parameters.
p = nlsys.Parameters;
npo = length(p);
parvec = [];
for k = 1:npo
    parvec = [parvec(:); p(k).Value(:)];
end