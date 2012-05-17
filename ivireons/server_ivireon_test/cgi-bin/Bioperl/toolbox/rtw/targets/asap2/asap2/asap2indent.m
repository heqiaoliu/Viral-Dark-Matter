function result = asap2indent(ASAP2FileName)
% ASAP2INDENT Reformat indenting of ASAP2 file.
%
%   Called by asap2main.tlc (as part of ASAP2 file generation process).

%   Copyright 1994-2005 The MathWorks, Inc.
%   $Revision: 1.5.2.3 $

PerlFile = 'asap2indent.pl';

if isempty(ASAP2FileName)
  result = sprintf('Undefined ASAP2FileName.\n');
  return;
end

% Change to build directory
% (ASAP2FileName is defined relative to build directory)
oldDir = cd;
buildArgs = evalin('caller', 'varargin');
buildDir  = buildArgs{strncmp('-O', buildArgs, 2)};
buildDir  = strrep(buildDir, '-O', '');
cd(buildDir);

try
  % Change to directory in which ASAP2 file is located
  [a2lDir, a2lName, a2lExt] = fileparts(ASAP2FileName);
  if ~isempty(a2lDir)
    cd(a2lDir);
  end
  
  % Call PerlFile from operating system
  result = perl(PerlFile, [a2lName, a2lExt]);
  
catch ME
  warning(ME.identifier, ME.message);
end

% Change back to original directory
cd(oldDir);

% Error handling
if exist('result') && strcmp(result, '0')
  % Successful completion of ASAP2 file indenting.
  result = sprintf('### Indenting ASAP2 file.\n');
end