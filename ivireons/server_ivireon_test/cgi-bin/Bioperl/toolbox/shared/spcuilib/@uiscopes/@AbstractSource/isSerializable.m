function y = isSerializable(this) %#ok<INUSD>
%ISSERIALIZABLE Is data source serializable.
%  Returns false if this data source should not be serialized
%  into a data store, whether it is a file or a recent source list.
%  Generally, sources that do not have a text-string that can be
%  used to refer to the actual data repository are non-serializable,
%  otherwise the actual data itself must be recorded into the
%  repository leading to storage and efficiency issues.

% Copyright 2004-2005 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/03/30 23:59:10 $

% By default, data sources have text-string references
% (such as a file name, or an hierarchical path string, etc)
% and we return true:
%
y = true;

% [EOF]
