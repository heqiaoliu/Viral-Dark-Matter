function [sfObject, varargout] = getSfObject(data)
%GETSFOBJECT Get the stateflow Object of the logged signal.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/14 16:54:04 $

sfObject = [];
varargout{1} = '';
varargout{2} = '';
% path = '';
% name = '';
if(~isfield(data, 'Signal') || isempty(data.Signal));return; end;
signal = data.Signal;
if(isempty(signal)); return; end
jblockpath = java.lang.String(signal.BlockPath);
dshIdx = jblockpath.lastIndexOf('/');
dotIdx = jblockpath.lastIndexOf('.');
if (dotIdx < 0 && dshIdx < 0); return; end;
if(dotIdx > 0)
  jpath = jblockpath.substring(0, dotIdx);
  jname = jblockpath.substring(dotIdx + 1);
else
  jpath = jblockpath.substring(0, dshIdx);
  jname = jblockpath.substring(dshIdx + 1);
end
path = char(jpath);
varargout{1} = strrep(path, '.', '/'); % path
varargout{2} = char(jname); %name
sfObject = getsfobject(varargout{1}, varargout{2});

%--------------------------------------------------------------------------
function blk = getsfobject(pth, nme)

%blk = [];
if(isempty(nme))
  % this is using the overloaded UDD find method and not the built-in
  % method
  blk = find(sfroot, '-isa', 'Stateflow.Object', 'Path', pth); %#ok<GTARG>
else
  % this is using the overloaded UDD find method and not the built-in
  % method
  blk = find(sfroot, '-isa', 'Stateflow.Object', 'Path', pth, 'Name', nme); %#ok<GTARG>
end


% [EOF]
