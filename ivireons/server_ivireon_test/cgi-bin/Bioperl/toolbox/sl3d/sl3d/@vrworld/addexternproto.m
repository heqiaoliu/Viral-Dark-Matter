function addexternproto(world, protofile, protoname, protodef)
%ADDEXTERNPROTO Add an EXTERNPROTO declaration to the virtual world.
%   ADDEXTERNPROTO(W, PROTOFILE, PROTONAME) adds EXTERNPROTO declaration
%   from file PROTOFILE identified as PROTONAME to the virtual world referred
%   to by VRWORLD handle W. PROTONAME may be a cell array of identifiers, in
%   which case multiple EXTERNPROTOs from one file are added.
%
%   ADDEXTERNPROTO(W, PROTOFILE, PROTONAME, PROTODEF) does the same as above
%   but renames the new proto to PROTODEF.

%   Copyright 1998-2008 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2008/10/31 07:10:56 $ $Author: batserve $

% check arguments

% PROTOFILE
if ~ischar(protofile)
  throwAsCaller(MException('VR:invalidinarg', 'EXTERNPROTO file name must be a string.'));
end

% PROTONAME
if ischar(protoname)
  protoname = {protoname};
elseif ~iscellstr(protoname)
  throwAsCaller(MException('VR:invalidinarg', 'EXTERNPROTO name must be a string or a cell array of strings.'));
end

% PROTODEF
if nargin<4
  protodef = protoname;
else
  if ischar(protodef)
    protodef = {protodef};
  elseif ~iscellstr(protodef)
    throwAsCaller(MException('VR:invalidinarg', 'EXTERNPROTO new name must be a string or a cell array of strings.'));
  end
  if numel(protodef) ~= numel(protoname)
    throwAsCaller(MException('VR:invalidinarg', 'Number of new and existing EXTERNPROTO names must match.'));
  end
end

% read the prototype file
f = fopen(protofile, 'rt');
if f<0
  throwAsCaller(MException('VR:vrmlfileerror', 'Cannot open PROTO file "%s".', protofile));
end
  protos = fread(f, [1 inf], '*char');
  fclose(f);

% add the EXTERNPROTOs in a loop
for i = 1:numel(protoname)

  % extract the PROTO by its name
  [found, proto] = regexp(protos, sprintf('PROTO\\s+%s\\s+\\[([^\\]]*)\\]', protoname{i}), 'start', 'tokens', 'once');
  if isempty(found)
    throwAsCaller(MException('VR:vrmlfileerror', 'PROTO declaration "%s" not found in file "%s".', protoname{i}, protofile));
  end

  % extract PROTO field declarations and create the PROTO
  protofields = regexp(proto{1}, '(eventIn|eventOut|exposedField|field)\s+\S+\s+\S+', 'match');
  try
    vrsfunc('AddExternProto', get(world, 'Id'), sprintf('%s [%s\n]\n"%s#%s"', ...
                                                        protodef{i}, ...
                                                        sprintf('\n%s', protofields{:}), ...
                                                        protofile, ...
                                                        protoname{i} ));
  catch ME
    throwAsCaller(ME);
  end
end
