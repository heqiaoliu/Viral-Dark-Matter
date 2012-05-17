function out = setanalysis(hObj, out)
%SETANALYSIS Set the analysis in FVTool
%   SETANALYSIS(H, ANALYSIS) Set the analysis of FVTool to ANALYSIS.  If
%   only one input argument is given this function will return all the
%   available analyses.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/13 00:24:02 $

% This will be the overloaded set on the CurrentAnalysis property

info  = get(hObj, 'AnalysesInfo');
names = fieldnames(info);

if ~isempty(out),
    
    % Look for the input analysis among those available.
    indx = strmatch(lower(out), lower(names)); % Make sure it is case insensitive
    
    if isempty(indx),
        
        % If no analyses are found, error
        error(generatemsgid('invalidAnalysis'), '''%s'' is not a valid analysis.', out);
    end
    
    % If there are more than 1 found, use the first
    indx = indx(1);
    
    out = names{indx};
end

% [EOF]
