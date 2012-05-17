function add(hText,str)
% Append text to last line of text

% Copyright 2006-2007 The MathWorks, Inc.

if iscellstr(str)
  error('MATLAB:codegen:stringbuffer:invalidInput','Cell string not supported')
end

t = get(hText,'Text');
t{end} = [t{end},str];
set(hText,'Text',t);