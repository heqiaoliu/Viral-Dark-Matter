function success = action(h)
%ACTION Export a filter to SPTool.

%   Author(s): P. Costa
%   Copyright 1988-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.7 $  $Date: 2007/12/14 15:20:31 $

% Set up the sptool structure for importing
s = setupstruct(h);

shh = get(0, 'ShowHiddenHandles');
set(0, 'ShowHiddenHandles', 'On');

% Import the structure into SPTool
sptool('import',s);

set(0, 'ShowHiddenHandles', shh);

success = true;

% ---------------------------------------------------------
function s = setupstruct(h)
% Build the structure which sptool requires from an existing structure

% Need to revisit when exporting multiple filters to SPTool.
G = elementat(h.data,1);
if length(G) > 1,
    error(generatemsgid('NotSupported'),'Exporting multiple filter objects to SPTool is not yet supported.');
end

name = h.variablename{1};
if ~isvarname(name)
    error(generatemsgid('invalidVarName'), '''%s'' is not a valid variable name.', name);
end

% Make sure that SPTool is open
sptool;

% Get the filter information from sptool
s = sptool('Filters');

names = {s.label};
old_name = name;
name  = genvarname(name, names);

if ~strcmp(old_name, name)
    warning(generatemsgid('FilterNameChanged'), ...
        'The exported filter has been renamed to ''%s'', because ''%s'' already exists.', name, old_name);
end

s = s(end);

[s.tf.num, s.tf.den] = tf(G);

% Clear out the unused fields
s.ss = [];
s.zpk = [];
s.imp = [];
s.step = [];
s.t = [];
s.H = [];
s.G = [];
s.f = [];
s.specs = [];

% The sampling frequency for SPTool must be in Hz.  We are forcing Fs to 2
% so that the frequency response will be shown from 0-1.  It was low !/$ for
% carrying over the Fs from FDATool (see g256594)
s.Fs = 2;

s.type = 'imported';

% need to revisit when exporting multiple filters to SPTool.
s.label = name;

if isfield(s, 'FDAspecs')
% For now, FDAspecs is not used in exporting filter to sptool, so remove
% it.
    s = rmfield(s, 'FDAspecs');
end

% [EOF]
