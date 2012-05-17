function nel = numel(varargin)
% number of elements in data

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $ $Date: 2008/10/02 18:46:58 $

if nargin>1
    % DAT{IDX} syntax disabled
    ctrlMsgUtils.error('Ident:iddata:obsoleteGetExpSyntax')
else
    nel = 1;
end
