function display_measurements(hView, FLoss, RSAttenuation, MLWidth)
%DISPLAY_MEASUREMENTS Display the measurements

%   Author(s): V.Pellissier
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2009/07/14 04:03:39 $

if ~isrendered(hView),
    return
end

hndls = get(hView, 'Handles');

% Display the results
set(hndls.text(1), 'String', ...
    sprintf('Leakage Factor: %s %%', num2str(FLoss)));
set(hndls.text(2), 'String', ...
    sprintf('Relative sidelobe attenuation: %s dB', num2str(RSAttenuation)));
hPrm = getparameter(hView, 'freqmode');
if strcmpi(hPrm.Value, 'Hz') & ~isempty(MLWidth),
    [MLWidth,eu] = convert2engstrs(MLWidth);
    set(hndls.text(3), 'String', ...
        sprintf('Mainlobe width (-3dB): %s %sHz', MLWidth, eu));
else
    set(hndls.text(3), 'String', ...
        sprintf('Mainlobe width (-3dB): %s', num2str(MLWidth,'%0.5g')));
end
if (isunix),
    set(hndls.text,'FontSize',9);
end
    

% [EOF]
