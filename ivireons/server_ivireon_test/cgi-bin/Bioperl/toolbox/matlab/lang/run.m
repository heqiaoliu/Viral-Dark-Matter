function run(script)
%RUN Run script.
%   Typically, you just type the name of a script at the prompt to
%   execute it.  This works when the script is on your path.  Use CD
%   or ADDPATH to make the script executable from the prompt.
%
%   RUN is a convenience function that runs scripts that are not
%   currently on the path. 
%
%   RUN SCRIPTNAME runs the specified script.  If SCRIPTNAME contains
%   the full pathname to the script, then RUN changes the current
%   directory to where the script lives, executes the script, and then
%   changes back to the original starting point.  The script is run
%   within the caller's workspace.
%
%   See also CD, ADDPATH.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.17.4.6 $  $Date: 2007/11/13 00:10:05 $

cur = cd;

if isempty(script), return, end
if ispc, script(script=='/')='\'; end
[p,s,ext] = fileparts(script);
if ~isempty(p),
  if exist(p,'dir'),
    cd(p)
    w = which(s);
    if ~isempty(w),
      % Check to make sure everything matches
      [wp,ws,wext] = fileparts(w);
      % Allow users to choose the .m file and run a .p
      if strcmp(wext,'.p') && strcmp(ext,'.m'),
         wext = '.m';
      end
      
      if ispc
        cont = ~strcmpi(wp,pwd) | ~strcmpi(ws,s) | ...
          (~isempty(ext) & ~strcmpi(wext,ext));
      else
        cont = ~isequal(wp,pwd) | ~isequal(ws,s) | ...
          (~isempty(ext) & ~isequal(wext,ext));
      end
      if cont
         if exist([s ext],'file')
           cd(cur)
           rehash;
           error('MATLAB:run:CannotExecute','Can''t run %s.',[s ext]);
         else
           cd(cur)
           rehash;
           error('MATLAB:run:FileNotFound','Can''t find %s.',[s ext]);
         end
      end
      try
          evalin('caller', [s ';']);
      catch e
          cd(cur);
          rethrow(e);
      end
    else
      cd(cur)
      rehash;
      error('MATLAB:run:FileNotFound','%s not found.',script)
    end
    cd(cur)
    rehash;
  else
    error('MATLAB:run:FileNotFound','%s not found.',script)
  end
else
  if exist(script,'file')
    evalin('caller',[script ';']);
  else
    error('MATLAB:run:FileNotFound','%s not found.',script)
  end
end

