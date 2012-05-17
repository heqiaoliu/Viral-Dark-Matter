function m = vrrotvec2mat(r, options)
%VRROTVEC2MAT Convert rotation from axis-angle to matrix representation.
%   M = VRROTVEC2MAT(R) returns a matrix representation of rotation 
%   defined by the axis-angle rotation vector R.
%
%   M = VRROTVEC2MAT(R, OPTIONS) returns a matrix representation of rotation 
%   defined by the axis-angle rotation vector R, with the default 
%   algorithm parameters replaced by values defined in the structure
%   OPTIONS.
%
%   The OPTIONS structure contains the following parameters:
%
%     'epsilon'
%        Minimum value to treat a number as zero. 
%        Default value of 'epsilon' is 1e-12.
%
%   The rotation vector R is a row vector of 4 elements,
%   where the first three elements specify the rotation axis
%   and the last element defines the angle.
%
%   To rotate a column vector of 3 elements, multiply the rotation
%   matrix by it. To rotate a row vector of 3 elements, multiply it
%   by the transposed rotation matrix.
%
%   See also VRROTMAT2VEC, VRROTVEC.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:09:46 $ $Author: batserve $

% test input arguments
error(nargchk(1, 2, nargin, 'struct'));

if any(~isreal(r) || ~isnumeric(r))
  error('VR:argnotreal','Input argument contains non-real elements.');
end

if (length(r) ~= 4)
  error('VR:argwrongdim','Wrong dimension of input argument.');
end

if nargin == 1
  % default options values
  epsilon = 1e-12;
else
  if ~isstruct(options)
     error('VR:optsnotstruct','OPTIONS is not a structure.');
  else
    % check / read the 'epsilon' option
    if ~isfield(options,'epsilon') 
      error('VR:optsfieldnameinvalid','Invalid OPTIONS field name(s).'); 
    elseif (~isreal(options.epsilon) || ~isnumeric(options.epsilon) || options.epsilon < 0)
      error('VR:optsfieldvalueinvalid','Invalid OPTIONS field(s).');   
    else
      epsilon = options.epsilon;
    end
  end
end

% build the rotation matrix
s = sin(r(4));
c = cos(r(4));
t = 1 - c;

n = sl3dnormalize(r(1:3), epsilon);

x = n(1);
y = n(2);
z = n(3);
m = [ ...
     t*x*x + c,    t*x*y - s*z,  t*x*z + s*y; ...
     t*x*y + s*z,  t*y*y + c,    t*y*z - s*x; ...
     t*x*z - s*y,  t*y*z + s*x,  t*z*z + c ...
    ];
