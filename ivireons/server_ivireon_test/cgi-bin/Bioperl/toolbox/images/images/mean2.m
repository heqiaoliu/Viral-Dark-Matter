function y = mean2(x)
%MEAN2 Average or mean of matrix elements.
%   B = MEAN2(A) computes the mean of the values in A.
%
%   Class Support
%   -------------
%   A can be numeric or logical. B is a scalar of class double. 
%
%   Example
%   -------
%       I = imread('liftingbody.png');
%       val = mean2(I)
%  
%   See also MEAN, STD, STD2.

%   Copyright 1993-2005 The MathWorks, Inc.
%   $Revision: 5.19.4.6 $  $Date: 2006/06/15 20:09:12 $

y = sum(x(:), [], 'double') / numel(x);
