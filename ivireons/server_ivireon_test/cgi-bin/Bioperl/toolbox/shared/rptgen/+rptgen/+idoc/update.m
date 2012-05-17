function update(varargin)
%   Update document
%

%    Copyright 2009 The Mathworks, Inc.

if isa(varargin{1},'rptgen.idoc.Document')
    workingDocument = varargin{1};
else
    workingDocument = rptgen.idoc.current();
end

workingDocument.generatePreview();
