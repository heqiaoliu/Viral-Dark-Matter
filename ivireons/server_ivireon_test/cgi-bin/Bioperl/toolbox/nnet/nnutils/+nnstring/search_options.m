function options = search_options(in1)

% Copyright 2010 The MathWorks, Inc.

if nargin < 1
  options.wholeword = false;
  options.nostring = false;
  options.nocomment = false;
  options.onlycomment = false;
  options.isfunction = false;
elseif iscell(in1)
  options.wholeword = ~isempty(strmatch('wholeword',in1,'exact'));
  options.nostring = ~isempty(strmatch('nostring',in1,'exact'));
  options.nocomment = ~isempty(strmatch('nocomment',in1,'exact'));
  options.onlycomment = ~isempty(strmatch('onlycomment',in1,'exact'));
  options.isfunction = ~isempty(strmatch('isfunction',in1,'exact'));
else
  options = in1;
end
