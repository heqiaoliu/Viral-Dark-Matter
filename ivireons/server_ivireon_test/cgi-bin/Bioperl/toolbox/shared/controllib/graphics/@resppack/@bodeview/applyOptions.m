function applyOptions(this, Options)
% APPLYOPTIONS  Bodeview options

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2005 The MathWorks, Inc.
%  $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:20:25 $

cOpts = get(this(1), 'UnwrapPhase');

% Set new preferences
if isfield(Options, 'UnwrapPhase') && ~strcmp(Options.UnwrapPhase,cOpts)
  set(this, 'UnwrapPhase', Options.UnwrapPhase);
end

cOpts = get(this(1), 'ComparePhase');

% Set new preferences
if isfield(Options, 'ComparePhase') && ...
        (~strcmp(Options.ComparePhase.Enable,cOpts.Enable) || ...
        (Options.ComparePhase.Freq ~= cOpts.Freq) || ...
        (Options.ComparePhase.Phase ~= cOpts.Phase))
    set(this, 'ComparePhase', Options.ComparePhase);
end