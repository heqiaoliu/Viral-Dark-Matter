function pcode(varargin)
%PCODE  Create content-obscured but executable files (pcoded files).
%   PCODE F1 F2... makes content-obscured versions of F1, F2...
%
%   The arguments F1, F2... must describe MATLAB functions or files 
%   containing MATLAB code.  
%
%   If the flag -INPLACE is used, the result is placed in the same
%   directory in which the corresponding file was found.
%   Otherwise, the result is placed in the current directory.  Any
%   existing results will be overwritten.  Needed private and class 
%   directories will be created in the current directory if they do
%   not already exist.
%
%   Once created, a pcoded file takes precedence over the corresponding 
%   .m file for execution, even if the .m file is subsequently changed.
%   Each created pcoded file has the suffix .p.
%
%   An argument that has no file extension and is not a directory must 
%   be a function found on the MATLAB path or in the current directory.  
%   The found file is used for input.
%
%   if ISDIR(F) is true for an argument F and neither '..' nor '*' 
%   appear in F, pcoded files are created for all MATLAB code files in F 
%   (but not in its subdirectories). 
%
%   The file part F of an argument of the form DIR/F or F can contain
%   wildcards '*'.  The wild cards are expanded.  Files with extensions 
%   other than  '.m', '.M' or '.p' are ignored.  The '.p' extension is a 
%   special case, indicating either '.m' or '.M'.
%

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.30.4.14 $  $Date: 2010/02/25 08:09:02 $


% FEATURES
%
%   It is no longer possible to make old-style P-files (R2008a and later).
%
%   Flags other than -inplace will get a generally worded error message.
%
%   In general an argument that cannot be processed will be warned and
%   skipped in contrast to causing an error.
%

% HOW PCODE.M works
%
%   The general approach is to reduce each complex general argument to a
%   standard form, check the validity of the input and then pass the
%   now-standardized args to the undocumented builtin _pwrite that does 
%   the heavy lifting.
%
% PROGRAM PCODE.M STRUCTURE
%
% The entry is pcode(...).
%   1. arguments are processed and flags are checked
%   2. arguments are standardized, ending with .m or .M
%   3. each argument is an entry to the local function pcodefile(...)
%   4. insure code file(s) exist
%   5. if there is no flag -inplace, insure private, + and @ directories 
%      are created to hold the new pcoded files.
%   6. call undocumented builtin _mcheck(fullpath2m) to insure input 
%      can compile.
%   7. call undocumented builtin _pwrite(fullpath2m, fullpath2p)
%
%   The debugging PTRACE facilty exists but is turned off.
% -------------------------------------------------------------------

  PTRACE('PTRACE 0: enter pcode, nargin=%d  pwd=%s\n', nargin, pwd);

  % ---Make a pass over the input arguments, record and remove flags.---
  inplace = false;                                % default: put F.p in pwd

  for i = nargin:-1:1                             % backwards so delete works

    if ~ischar(varargin{i})       ...
    ||  numel(varargin{i})  == 0  ...
    ||  size(varargin{i},1) ~= 1  ...
    ||  ndims(varargin{i})  ~= 2
      error('MATLAB:pcode:ArgMustBeString', ...
          'Input argument must be a nonempty string.');
    end
    % the argument is now known to be a string

    % check, record, and remove flags from arg list
    if strncmp(varargin{i},'-',1)             % it's a flag
      if strcmpi(varargin{i},'-inplace'),
        inplace = true;                           % put F.P where F.M is
      else
        error('MATLAB:pcode:UnknownFlag', 'Unknown flag ''%s''.', varargin{i});
      end
      varargin(i) = [];                           % Remove flag from input list
    end
  end
  % remaining arguments must be function, file or dir descriptions

  PTRACE('PTRACE 1: numel(varargin)=%d  inplace=%d\n', ...
         numel(varargin), inplace);

  % --------------- process one argument at a time --------------------
  for i=1:numel(varargin)
  
    arg = varargin{i};                            % a raw non-flag input
    
    % ------------ check and transform argument ---------------
    baddots = strfind(arg, '..');                 % leads to trouble
    badqmark = strfind(arg, '?');                 % needed for marker
    if ~isempty(baddots) || ~isempty(badqmark)
      warning('MATLAB:pcode:BadPath', ...
        'Skipping ''%s'', neither ''?'' nor ''..'' allowed in arg.', arg);
      continue;
    end
    PTRACE('PTRACE 2: i=%d  arg=%s\n', i, arg);

    % using ? as a marker; whole directory DIR becomes DIR/*.?
    if exist(arg, 'dir')                          % convert dir to files
      if exist([arg, '.m'], 'file') ...          
      || exist([arg, '.M'], 'file')
        warning('MATLAB:pcode:Ambiguous', ...
                '''%s'' names both a MATLAB code file and directory.', arg);
      end      
      arg = fullfile(arg, '*.?');                 % ready to expand
    end
    PTRACE('PTRACE 3: i=%d  arg=%s\n', i, arg);
    
    % a function name: which looks for it on path
    [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
    if ~isempty(fn)                               % there is a file name
      if isempty(en) || strcmpi(en, '.p')         % no M extension
        origName = which(fullfile(pn, [fn '.m']));
        if ~isempty(origName)
            arg = origName;
        else
            origName = which(fullfile(pn, [fn '.M']));
            if ~isempty(origName)
                arg = origName;
            else
              arg = fullfile(pn, [fn '.?']);          % use dir later                
            end
        end
      else                                        % try input extension
        fullarg = which(arg);                     % look on path
        if ~isempty(fullarg) 
          arg = fullarg;                          % abs path to file
        end
      end
    end      
    PTRACE('PTRACE 4: i=%d  arg=%s\n', i, arg);
    
    %  no path, make one
    pn = fileparts(arg);                          % get path
    if isempty(pn)
      arg = fullfile('.', arg);                   % pn becomes '.'
    end
    PTRACE('PTRACE 5: i=%d  arg=%s\n', i, arg);
    
    % warn and skip if path is invalid
    [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
    if ~exist(pn, 'dir')
      warning('MATLAB:pcode:NotPath', ...
              'Skipping argument ''%s'' (invalid pathname).', varargin{i});
      continue
    end
    PTRACE('PTRACE 6: i=%d pn=%s  fn=%s  en=%s\n', i, pn, fn, en);

    % make absolute path from relative path if necessary
    [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
    ap = fullfile(pwd, pn, '');                   % see if pwd is valid prefix
    if exist(ap, 'dir')                           % pn was relative
      arg = fullfile(ap, [fn en]);                % arg now absolute
    end    
    PTRACE('PTRACE 7: i=%d arg=%s\n', i, arg);

    % insure there is a file name (it may have wildcards)
    [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
    if isempty(fn)
      warning('MATLAB:pcode:NotFileName', ...
              'Skipping argument ''%s'' because ''%s'' is not a file name.', ...
              varargin{i}, [fn en]);
      continue;                                   % skip this entry
    end
    
    % discard .p extension -- let wildcards find .m and .M
    if strcmpi(en, '.p') || strcmp(en, '.*')      % often from DEPENDS.pcode
      en = '.?';                                  % pick up .m and .M
    elseif ~strcmpi(en, '.m') && ~strcmp(en, '.?')
      warning('MATLAB:pcode:FileUnsupported', ...
              'Skipping argument ''%s'', not a MATLAB code file.', varargin{i});
      continue;
    end  
    arg = fullfile(pn, [fn en]);                  % reconstitute arg
    PTRACE('PTRACE 8: i=%d arg=%s\n', i, arg);
    
    %----------------- prepare individual files-----------------
    
    % wild card expansion
    [pn, fn, en] = fileparts(arg);                % arg = pn/fn.en
    if strcmp(en, '.?')
      fm = dir(fullfile(pn, [fn '.m']));
      fM = dir(fullfile(pn, [fn '.M']));
      files = [fm; fM];
    else
      files = dir(arg);
    end
    PTRACE('PTRACE 9: i=%d numel(files)=%d\n', i, numel(files));
    
    if isempty(files)
      warning('MATLAB:pcode:FileNotFound', ...
              'Skipping argument ''%s'', no MATLAB code found.', varargin{i});
      continue;
    end
    
    for j = 1:numel(files)
      fname = files(j).name;                      % local file name
      [~, ~, en] = fileparts(fname);             % en is found extension
      if strcmpi(en, '.m')                        % check for .m or .M
        pcodefile(pn, fname, inplace);            % do one at a time
      end                                         % discard other files
    end
    
  end  % end loop on varargin{}

  rehash % Force MATLAB to see any newly generated or regenerated pcoded files.
end    % end pcode


% ---- the workhorse ----
function pcodefile(pth, fn, inplace)
  PTRACE('PTRACE 10: pth=%s  fn=%s  inplace=%d\n', pth, fn, inplace);
  origName = fullfile(pth, fn);
  pname = [origName(1:end-2) '.p'];                  % .p ext
  if inplace                               
    builtin('_mcheck', origName);                    % detect compile errors
    builtin('_pwrite', origName, pname);
  else                                            % in pwd
    npth = pcodedirs(pth);                        % set up dirs in pwd
    pf = fullfile(npth, [fn(1:end-2) '.p']);      % dot-p target
    PTRACE('PTRACE 11: codefile=%s  pf=%s\n', origName, pf);
    builtin('_mcheck', origName);                    % detect compile errors
    builtin('_pwrite', origName, pf);                % dot-p into pwd
  end
end   % end pcodefile

%-------- mirror +,@ and private dirs in pwd -----------------
%{

private, + and @ directories are implicitly on the path.  Ensure that the 
implicit directories from the source path are appended to the parent of 
the implicit directories in the destination path.

%}

function destinationDir = pcodedirs(sourceDir)
    destinationDir = pwd;
    PTRACE('PTRACE 12: dirs sourceDir=%s destinationDir=%s\n', sourceDir, destinationDir);

    % strip off all implicit dirs from the target dir
    destinationDir = helpUtils.separateImplicitDirs(destinationDir);
    
    % get the implicit dirs from the source dir
    [~, sourceImplicitDirs] = helpUtils.separateImplicitDirs(sourceDir);

    if ~isempty(sourceImplicitDirs)
        % append the implicit directories from the source dir to the 
        % parent dir of the implicit directories from the destination
        destinationDir = fullfile(destinationDir, sourceImplicitDirs);
        cmkdir(destinationDir);
    end
end

% make directory if it does not already exist
function cmkdir(pth)
  if ~exist(pth, 'dir')
    mkdir(pth);
  end
end   % end cmkdir

function PTRACE(f, varargin)
%  fprintf(f, varargin{:});              % comment this line for normal use
end

