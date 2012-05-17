function s = slvnvhelp(option)
% SLVNVHELP Points Help browser to the HTML help file
%         corresponding to this simulink V&V block.

% Copyright 2005 The MathWorks, Inc.

blkname = get_param(gcb,'MaskType');
  
html_file=[docroot '/toolbox/slvnv/ug/' help_name(blkname)];

s=['file:///' html_file];

return

function y=help_name(x)
if isempty(x), x='default'; end
y = lower(x);
y(find(~isvalidchar(y))) = '';  %  Remove invalid characters
% if length(y)>35, y=y(1:35); end  %  Truncation of the block HTML page name is obsolete
y = [y '.html'];
return

function y = isvalidchar(x)
y = isletter(x) | isdigit(x) | isunder(x);
return

function y = isdigit(x)
y = (x>='0' & x<='9');
return

function y = isunder(x)
y = (x=='_');
return