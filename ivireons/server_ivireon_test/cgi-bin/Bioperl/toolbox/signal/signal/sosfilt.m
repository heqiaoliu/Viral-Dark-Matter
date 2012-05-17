function X = sosfilt(SOS,X,dim)
%SOSFILT Second order (biquadratic) IIR filtering.
%   SOSFILT(SOS, X) filters the data in vector X with the second-order 
%   section (SOS) filter described by the matrix SOS.  The coefficients of
%   the SOS matrix must be expressed using an Lx6 second-order section
%   matrix where L is the number of second-order sections. If X is a
%   matrix, SOSFILT will filter along the columns of X.  If X is a
%   multidimensional array, filter operates on the first nonsingleton
%   dimension.
%
%   SOSFILT uses a direct form II implementation to perform the filtering.
%
%   The SOS matrix should have the following form:
%
%   SOS = [ b01 b11 b21 a01 a11 a21
%           b02 b12 b22 a02 a12 a22
%           ...
%           b0L b1L b2L a0L a1L a2L ]
%
%   SOSFILT(SOS, X, DIM) operates along the dimension DIM.
%
%   See also LATCFILT, FILTER, TF2SOS, SS2SOS, ZP2SOS, SOS2TF, SOS2SS, SOS2ZP.

%   Author(s): R. Firtion
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.12.4.7 $  $Date: 2008/08/01 12:25:29 $

error(nargchk(2,3,nargin),'struct')

if nargin<3 %#ok<UNRCH>
  dim = [];
end

if ~isa(X,'double'),
    error(generatemsgid('MustBeDouble'), 'Input argument "X" must be double.');
end

if ~isa(SOS,'double')
    error(generatemsgid('MustBeDouble'), 'SOS matrix "SOS" must be double.');
end

[m,n]=size(SOS);
if (m<1) || (n~=6),
	error(generatemsgid('InvalidDimensions'), ...
        'Size of SOS matrix must be Mx6. See "zp2sos" or "ss2sos" for details.');
end
      
h = SOS(:,[5 6 1:3]);
for i=1:size(h,1),
	h(i,:)=h(i,:)./SOS(i,4);  % Normalize by a0
    h(i,[1 2]) = -h(i,[1 2]); % [-a1 -a2 b0 b1 b2]
end
h=h.';

s = size(X);

[X,perm,nshifts] = shiftdata(X,dim);
s_shift = size(X); % New size
X = reshape(X,size(X,1),[]); % Force into 2-D

% Mex file will always filter along the columns
X = sosfiltmex(h,X);

% Convert back to the original shape
X = reshape(X,s_shift); % Back to N-D array
X = unshiftdata(X,perm,nshifts);
X = reshape(X,s);
