function r = vrdir2ori(d, options)
%VRDIR2ORI Convert viewpoint direction to orientation.
%   VRDIR2ORI(D) converts the viewpoint direction, specified by a vector
%   of 3 elements, to an appropriate orientation (VRML rotation vector).
%
%   VRDIR2ORI(D, OPTIONS) converts the viewpoint direction with the default 
%   algorithm parameters replaced by values defined in the structure
%   OPTIONS.
%
%   The OPTIONS structure contains the following parameters:
%
%     'epsilon'
%        Minimum value to treat a number as zero. 
%        Default value of 'epsilon' is 1e-12.
%
%   See also VRORI2DIR, VRROTVEC, VRROTVEC2MAT, VRROTMAT2VEC.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:27 $ $Author: batserve $

% test input arguments
error(nargchk(1, 2, nargin, 'struct'));

if any(~isreal(d) || ~isnumeric(d))
  error('VR:argnotreal','Input argument contains non-real elements.');
end

if (length(d) ~= 3)
  error('VR:argwrongdim','Wrong dimension of input argument.');
end

% compute the orientation, let the vrrotvec() check the optional 
% OPTIONS argument
if nargin == 1
  r = vrrotvec([0 0 -1], d);
else
  r = vrrotvec([0 0 -1], d, options);
end
