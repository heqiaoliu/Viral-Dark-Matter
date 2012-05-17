function replace(fromStr,toStr,files,options)
%NNFILE.REPLACE

% Copyright 2010 The MathWorks, Inc.

% Files
if (nargin < 3) || ~iscell(files)
  files = nnfile.nnet_mfiles;
end

% Options
if nargin < 3
  options = nnstring.search_options;
elseif ischar(options)
  options = nnstring.search_options({options});
elseif iscell(options)
  options = nnstring.search_options(options);
end

% Search
for i=1:length(files)
  file = files{i};
  searchText = nntext.load(file);
  [searchText,change] = nntext.replace(fromStr,toStr,searchText,options);
  if change
    nntext.save(file,searchText);
    disp(['Updated: ' file])
  end
end
