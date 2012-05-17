function flag = is_text_file(file)

% Copyright 2010 The MathWorks, Inc.

name = nnpath.name(file);
flag = ~isempty(strmatch(name,...
  {'Makefile','TEST_LIST','chart','JAVA_LIST','MAKEFILE_LIST',...
  'DEPENDS.pcode'}));
