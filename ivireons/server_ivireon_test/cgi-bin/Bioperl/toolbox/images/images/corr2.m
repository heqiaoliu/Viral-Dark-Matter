function r = corr2(varargin)
%CORR2 2-D correlation coefficient.
%   R = CORR2(A,B) computes the correlation coefficient between A
%   and B, where A and B are matrices or vectors of the same size.
%
%   Class Support
%   -------------
%   A and B can be numeric or logical. 
%   R is a scalar double.
%
%   Example
%   -------
%   I = imread('pout.tif');
%   J = medfilt2(I);
%   R = corr2(I,J)
%
%   See also CORRCOEF, STD2.

%   Copyright 1992-2005 The MathWorks, Inc.
%   $Revision: 5.18.4.5 $  $Date: 2006/06/15 20:08:33 $

[a,b] = ParseInputs(varargin{:});

a = a - mean2(a);
b = b - mean2(b);
r = sum(sum(a.*b))/sqrt(sum(sum(a.*a))*sum(sum(b.*b)));

%--------------------------------------------------------
function [A,B] = ParseInputs(varargin)

iptchecknargin(2,2,nargin, mfilename);

A = varargin{1};
B = varargin{2};

iptcheckinput(A, {'logical' 'numeric'}, {'real'}, mfilename, 'A', 1);
iptcheckinput(B, {'logical' 'numeric'}, {'real'}, mfilename, 'B', 2);

if any(size(A)~=size(B))
    messageId = 'Images:corr2:notSameSize';
    message1 = 'A and B must be the same size.';
    error(messageId, '%s', message1);
end

if (~isa(A,'double'))
    A = double(A);
end

if (~isa(B,'double'))
    B = double(B);
end










