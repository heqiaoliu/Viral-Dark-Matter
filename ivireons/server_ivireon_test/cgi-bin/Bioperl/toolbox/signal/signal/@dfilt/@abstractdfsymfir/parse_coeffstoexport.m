function [hTar,domapcoeffstoports] = parse_coeffstoexport(Hd,hTar)
%PARSE_COEFFSTOEXPORT Store coefficient names and values into hTar for
%export.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/05/23 08:13:50 $

state = hTar.MapCoeffsToPorts;

if strcmpi(state,'on')
    [mapstate coeffnames var] = mapcoeffstoports(Hd,'MapCoeffsToPorts','on',...
                                        'CoeffNames',hTar.CoeffNames);
    % Coefficient names
    hTar.CoeffNames = coeffnames;
    
    % Coefficient values for export
    num = Hd.privNum.';
    max_order = ceil(length(num)/2);
    coeffvar{1} = num(1:max_order);
    setprivcoefficients(hTar,coeffvar);
end

domapcoeffstoports = strcmpi(state,'on');

% [EOF]
