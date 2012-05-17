function y = intToCommaSepStr(x,noCell)
%Format integers as strings with comma separators.
%  intToCommaSepStr(X) converts a vector X of integer values to a cell-
%  vector of strings formatted with commas after every 3 digits.  After ~10
%  digits, scientific notation is utilized without comma-separated digits.
%
%  intToCommaSepStr(X,1) returns a string instead of a cell-vector when
%  converting scalar values.  If X is a vector, or if 0 is passed as the
%  second argument, a cell-vector is returned.
%
% % Example: convert numbers containing 1 to 12 digits
% s = embedded.ntxui.intToCommaSepStr([1 12 123 1234 12345 123456 1234567 ...
%        12345678 123456789 1234567890 12345678901 ...
%        123456789012])

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $     $Date: 2010/04/21 21:21:21 $

% Cache pre-formatted strings to accelerate subsequent calls
persistent sDstCache iDstCache
if isempty(sDstCache)
    [sDstCache,iDstCache] = cache(10);
end
if nargin>1 && noCell && isscalar(x)
    % Similar to the above, except we return a string not a cell
    sSrc = sprintf('%d',x);
    if any(sSrc=='e')
        y = sSrc;
    else
        nSrc = numel(sSrc);
        y = sDstCache{nSrc};
        y(iDstCache{nSrc}) = sSrc;
    end
else
    nX = numel(x);  % # integers in vector
    y = cell(nX,1); % cell-array of comma-delimited strings
    for i = 1:nX
        % Beyond 10 digits, '%d' returns scientific notation
        sSrc = sprintf('%d',x(i));  % source string (no commas)
        if any(sSrc=='e')           % did we get scientific notation?
            sDst = sSrc;            % don't add commas
        else
            nSrc = numel(sSrc);     % # digits in number
            sDst = sDstCache{nSrc}; % blanks with commas
            sDst(iDstCache{nSrc}) = sSrc; % copy src chars to dst
        end
        y{i} = sDst;
    end
end

function [sDstCache,iDstCache] = cache(N)
% Pre-calculate strings for comma-format conversion of integers
% with source number ranging from 1 to N.

sDstCache = cell(N,1);  % strings containing blanks and commas
iDstCache = cell(N,1);  % indices for copying chars into the strings
space = ' ';
for nSrc = 1:N  % loop over # of src digits
    % Cache "empty strings" with pre-written commas
    % iStart cycle: 1,2,3,4,5,6,... -> 2,3,4,2,3,4,...
    iStart = 2+rem(nSrc-1,3);
    nCommas = floor((nSrc-1)/3);
    sDst = space(ones(1,nSrc+nCommas));
    sDst(iStart:4:end) = ',';
    sDstCache{nSrc} = sDst;
    iDstCache{nSrc} = (nCommas+1:nCommas+nSrc)-floor((nSrc-1:-1:0)/3);
end
