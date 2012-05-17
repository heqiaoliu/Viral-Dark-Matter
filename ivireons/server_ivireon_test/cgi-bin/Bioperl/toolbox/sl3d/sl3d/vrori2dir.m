function d = vrori2dir(r, options)
%VRORI2DIR Convert viewpoint orientation to direction.
%   VRORI2DIR(R) converts the viewpoint orientation, specified by
%   a rotation vector R, to a direction the viewpoint points to.
%
%   VRORI2DIR(R, OPTIONS) converts the viewpoint orientation 
%   with the default algorithm parameters replaced by values defined 
%   in the structure OPTIONS.
%
%   The OPTIONS structure contains the following parameters:
%
%     'epsilon'
%        Minimum value to treat a number as zero. 
%        Default value of 'epsilon' is 1e-12.
%
%   See also VRDIR2ORI, VRROTVEC, VRROTVEC2MAT, VRROTMAT2VEC.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:37 $ $Author: batserve $

% test input arguments
error(nargchk(1, 2, nargin, 'struct'));

if any(~isreal(r) || ~isnumeric(r))
  error('VR:argnotreal','Input argument contains non-real elements.');
end

if (length(r) ~= 4)
  error('VR:argwrongdim','Wrong dimension of input argument.');
end

% compute the direction, let the vrrotvec2mat() check the optional 
% OPTIONS argument
if nargin == 1
  m = vrrotvec2mat(r);
else
  m = vrrotvec2mat(r, options);
end    
d = [0 0 -1]*m';
