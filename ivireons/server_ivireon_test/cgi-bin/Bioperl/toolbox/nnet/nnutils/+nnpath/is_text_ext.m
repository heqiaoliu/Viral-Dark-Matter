function flag = is_text_ext(ext)

% Copyright 2010 The MathWorks, Inc.

flag = ~isempty(strmatch(ext,...
  {'csv','ixf','java','m','mdl','m_template','mtf','phl','txt','xml'},'exact'));
