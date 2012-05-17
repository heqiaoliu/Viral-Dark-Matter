function indexhelper(demosroot,source,callback,product,label,file,overrideDefaultLang)
% INDEXHELPER A helper function for the demos index page.

% Matthew J. Simoneau, January 2004
% Copyright 1984-2010 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2010/05/03 16:09:26 $

% Remove escaping.
if (nargin > 0)
    demosroot = decode(demosroot);
end
if (nargin > 1)
    source = decode(source);
end
if (nargin > 2)
    callback = decode(callback);
end
if (nargin > 3)
    product = decode(product);
end
if (nargin > 4)
    label = decode(label);
end
if (nargin > 5)
    file = decode(file);
end

if isempty(callback)
    callback = source;
end
if isempty(file)
   body = '';
   base = '';
else
   fullpath = fullfile(demosroot,file);
   f = fopen(fullpath);
   if (f == -1)
      error('MATLAB:indexhelper:OpenFailed','Could not open "%s".',fullpath);
   end
   body = fread(f,'char=>char')';
   fclose(f);
   base = ['file:///' fullpath];
end
   
if isempty(callback)
   web(fullpath,'-helpbrowser')
else
   demowin(callback,product,label,body,base,'',overrideDefaultLang)
end

%===============================================================================
function label=decode(label)

% For some reason, the browser doesn't encode "+", so we must do it here.
label = strrep(label,'+','%2B');
% Decode any Unicode characters that the browser encoded.
label = char(java.net.URLDecoder.decode(label,'UTF-8'));
