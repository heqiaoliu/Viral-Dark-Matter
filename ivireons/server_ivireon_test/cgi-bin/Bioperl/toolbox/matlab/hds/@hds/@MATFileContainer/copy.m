function A = copy(this,DataCopy)
%COPY  Copy method for @MATFileContainer.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/12/22 18:14:07 $

% RE: Never copy the file pointer (no obvious way to copy file-based data)
A = hds.MATFileContainer;