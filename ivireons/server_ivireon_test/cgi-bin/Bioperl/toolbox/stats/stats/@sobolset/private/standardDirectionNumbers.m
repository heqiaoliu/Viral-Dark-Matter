function V = standardDirectionNumbers(sStart, sEnd)
%STANDARDDIRECTIONNUMBERS Get direction numbers for a Sobol net.
%   STANDARDDIRECTIONNUMBERS(S) returns a matrix of direction numbers for
%   the dimensions up to the value of S.  The n'th row of the output
%   will contain the direction numbers for the n'th dimension.
%
%   STANDARDDIRECTIONNUMBERS(S1,S2) returns the matrix of direction numbers
%   for dimensions between S1 and S2.

%   References:
%      [1] Paul Bratley and Bennet L. Fox (1988) ALGORITHM 659 Implementing
%          Sobol's Quasirandom Sequence Generator, ACM Transactions on
%          Mathematical Software, Vol. 14, No. 1.
%      [2] Stephen Joe and France Y. Kuo (2003) Remark on Algorithm 659:
%          Implementing Sobol’s Quasirandom Sequence Generator,  ACM
%          Transactions on Mathematical Software, Vol. 29, No. 1.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:37 $

% The direction numbers, v, are traditionally taken as fractional values,
% but here we keep them shifted up into the first 53 bits of a uint64,
% ready for both fast xoring and easy conversion of the result back down
% into a fraction by simply dividing by 2^NBits.


if nargin==1
    sEnd = sStart;
    sStart = 1;
end

MaxBits = 53;
persistent D DimsDone
if isempty(D)
    % Initialise the direction number matrix.
    D = zeros(1111, MaxBits, 'uint64');

    % Do first dimension here.  This corresponds to having all the m values
    % equal to 1.
    D(1,:) = 2.^((MaxBits-1):-1:0)';

    DimsDone = 1;
end

if sEnd>DimsDone
    % Load the polynomials and initial m values
    pth = fileparts(mfilename('fullpath'));
    InitData = load(fullfile(pth, 'DirectionInit.mat'));

    % Call a mex routine to do the bit operations quickly
    D((DimsDone+1):sEnd, :) = ...
        computeDN(InitData.m(DimsDone:(sEnd-1)), InitData.Poly(DimsDone:(sEnd-1))).';

    DimsDone = sEnd;
end
V = D(sStart:sEnd, :);
