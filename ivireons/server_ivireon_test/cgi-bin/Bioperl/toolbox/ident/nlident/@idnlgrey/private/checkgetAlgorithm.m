function [errmsg, Algorithm] = checkgetAlgorithm(Algorithm, ny)
%CHECKGETALGORITHM  Checks that the Algorithm information is valid.
%   PRIVATE FUNCTION.
%
%   [ERRMSG, ALGORITHM] = CHECKGETALGORITHM(ALGORITHM);
%
%   ALGORITHM is a structure with contents according to
%   idnlgreydef('Algorithm').
%
%   ERRMSG is a struct specifying the first error encountered during
%   algorithm checking (empty if no errors found).

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.6 $ $Date: 2008/12/04 22:34:47 $
%   Written by Peter Lindskog.

% Check that the function is called with one argument.
error(nargchk(2, 2, nargin, 'struct'));

% A.1. Check that Algorithm is a structure.
if ~isstruct(Algorithm)
    ID = 'Ident:general:structPropVal'; msg = ctrlMsgUtils.message(ID,'Algorithm');
    errmsg = struct('identifier',ID,'message',msg);
    return
end

% A.2. Check that Algorithm contains the correct fields.
Names1 = fieldnames(Algorithm);
Names2 = fieldnames(idnlgreydef('Algorithm'));

ID = 'Ident:utility:invalidAlgoStruct';
msg0 = ctrlMsgUtils.message(ID);

if (length(Names1) ~= length(Names2))
    errmsg = struct('identifier',ID,'message',msg0);
    return;
elseif ~all(ismember(Names1, Names2))
    errmsg = struct('identifier',ID,'message',msg0);
    return;
end

% B. Check that Algorithm.SimulationOptions is proper.
[errmsg, Algorithm.SimulationOptions] = checkgetAlgorithmProperty('SimulationOptions', Algorithm.SimulationOptions);
if ~isempty(errmsg)
    return;
end

% C. Check that Algorithm.GradientOptions is proper.
[errmsg, Algorithm.GradientOptions] = checkgetAlgorithmProperty('GradientOptions', Algorithm.GradientOptions);
if ~isempty(errmsg)
    return;
end

% D. Check that Algorithm.SearchMethod is proper.
[errmsg, Algorithm.SearchMethod] = checkgetAlgorithmProperty('SearchMethod', Algorithm.SearchMethod);
if ~isempty(errmsg)
    return;
end

% E. Check that Algorithm.Criterion is proper.
[errmsg, Algorithm.Criterion] = checkgetAlgorithmProperty('Criterion', Algorithm.Criterion);
if ~isempty(errmsg)
    return;
end

% F. Check that Algorithm.Weighting is proper.
[errmsg, Algorithm.Weighting] = checkgetAlgorithmProperty('Weighting', Algorithm.Weighting, ny);
if ~isempty(errmsg)
    return;
end

% G. Check that Algorithm.MaxIter is proper.
[errmsg, Algorithm.MaxIter] = checkgetAlgorithmProperty('MaxIter', Algorithm.MaxIter);
if ~isempty(errmsg)
    return;
end

% H. Check that Algorithm.Tolerance is a finite scalar positive real.
[errmsg, Algorithm.Tolerance] = checkgetAlgorithmProperty('Tolerance', Algorithm.Tolerance);
if ~isempty(errmsg)
    return;
end

% I. Check that Algorithm.LimitError is a finite scalar positive real.
[errmsg, Algorithm.LimitError] = checkgetAlgorithmProperty('LimitError', Algorithm.LimitError);
if ~isempty(errmsg)
    return;
end

% J. Check that Algorithm.Display is 'Off', 'On', or 'Full'.
[errmsg, Algorithm.Display] = checkgetAlgorithmProperty('Display', Algorithm.Display);
if ~isempty(errmsg)
    return;
end

% K. Check that Algorithm.Advanced is a proper structure.
[errmsg, Algorithm.Advanced] = checkgetAlgorithmProperty('Advanced', Algorithm.Advanced);
if ~isempty(errmsg)
    return;
end
