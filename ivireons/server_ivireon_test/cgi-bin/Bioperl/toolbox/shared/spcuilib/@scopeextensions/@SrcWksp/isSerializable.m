function y = isSerializable(hSrc)
%ISSERIALIZABLE Is data source serializable.
%  Returns false if this data source should not be serialized
%  into a data store, whether it is a file or a recent source list.
%  Generally, sources that do not have a text-string that can be
%  used to refer to the actual data repository are non-serializable,
%  otherwise the actual data itself must be recorded into the
%  repository leading to storage and efficiency issues.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/09 19:33:22 $

% For workspace data sources, we must be careful to see if we
% have an explicit text-string representation of the expression
% itself.  Without this, we would need to explicitly retain the 
% source data and this is inefficient and undesirable.

% Get string from import dialog edit-box
%
% If it is empty, we were unable to determine this
% and there is no way to reproduce the data without
% explicit storage of it.
importStr = hSrc.LoadExpr.mlvar;

y = ~strcmp(importStr, '(MATLAB Expression)') && ~isempty(importStr);

% [EOF]
