function text = nn_loadtext(path)

% Copyright 2010 The MathWorks, Inc.

file = fopen(path,'r');
if (file == -1)
  nnerr.throw(['Cannot open file: ' path]);
end
text = {};
while true
  line = fgetl(file);
  if ~ischar(line), break; end
  text = [text; {line}];
end
fclose(file);
