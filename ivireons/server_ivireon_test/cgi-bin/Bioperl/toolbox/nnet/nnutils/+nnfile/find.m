function out = find(str,files,options)

% Copyright 2010 The MathWorks, Inc.

% Files
if (nargin < 2) || ~iscell(files)
  files = [nnfile.nnet_mfiles; nnfile.nnet_test_files];
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
hits = [];
for i=1:length(files)
  file = files{i};
  text = nntext.load(file);
  hitloc = nntext.find(str,text,options);
  if ~isempty(hitloc)
    hit.type = 'file_hit';
    hit.file = file;
    hit.lines = hitloc;
    hits = [hits hit];
  end
end

% Results
if nargout == 0
  nntext.disp(hits)
else
  out = hits;
end
