function s = getsize(this,dim)
%GETSIZE  Inquires about lti source size.
%
%   S = GETSIZE(SRC) returns the 3-entry vector [Ny Nu Nsys] where
%     * Ny is the number of outputs
%     * Nu is the number of inputs
%     * Nsys is the total number of models.
%
%   S = GETSIZE(SRC,DIM) returns the size if the requested dimension
%   (DIM must be 1, 2, or 3).

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:21:24 $

Size = size(this.Model);
if isa(this.Model,'lti')
   s = [Size(1:2) prod(Size(3:end))];
elseif isa(this.Model,'idmodel')
   s = [Size(1:2) 1];
end

if nargin>1
   s = s(dim);
end