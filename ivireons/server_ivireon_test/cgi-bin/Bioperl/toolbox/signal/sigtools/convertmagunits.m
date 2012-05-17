function val = convertmagunits(val, source, target, band)
%CONVERTMAGUNITS   Convert magnitude values to different units
%   CONVERTMAGUNITS(VAL, SRC, TRG, BAND) Convert VAL from SRC units to TRG
%   units in the filter band BAND.  SRC and TRG can be 'linear', 'squared'
%   or 'db'.  BAND can be 'pass' or 'stop'.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/12/14 15:15:35 $

error(nargchk(4,4,nargin,'struct'));

banderrmsg = sprintf('''%s'' is an unknown band, specify ''pass'' or ''stop''.', band);
banderrid  = generatemsgid('unknownBand');
targerrmsg = sprintf('''%s'' is an unknown target, specify ''linear'', ''squared'' or ''db''.', target);
targerrid  = generatemsgid('unknownTarget');

known = false;

switch source
    case 'linear'
        switch target
            case 'linear'
                switch band
                    case 'pass'
                         % NO OP, same target as source.
                    case 'stop'
                    case 'amplitude', val = abs(val);
                    otherwise,   error(banderrid,banderrmsg);  
                end
            case 'db'
                switch band
                    case 'pass', val = 20*log10((1+val)/(1-val));
                    case 'stop', val = -20*log10(val);
                    case 'amplitude', val = 20*log10(abs(val));
                    otherwise,   error(banderrid,banderrmsg);
                end
            case 'squared'
                switch band
                    case 'pass', val = ((1-val)/(1+val))^2;
                    case 'stop', val = val^2;
                    case 'amplitude', val = val.^2;
                    otherwise,   error(banderrid,banderrmsg);
                end
            case 'zerophase'  
                switch band
                    case 'amplitude'
                        % No Op.
                    otherwise
                        error(targerrid,targerrmsg);
                end
            otherwise
                error(targerrid,targerrmsg);
        end
    case 'squared'
        switch target
            case 'squared'
                % NO OP, same target as source
            case 'db'
                switch band
                    case {'pass', 'stop'}, val = 10*log10(1/val);
                    otherwise,             error(banderrid,banderrmsg);
                end
            case 'linear'
                switch band
                    case 'pass', val = (1-sqrt(val))/(1+sqrt(val));
                    case 'stop', val = sqrt(val);
                    otherwise,   error(banderrid,banderrmsg);
                end
            otherwise
                error(targerrid,targerrmsg);
        end
    case 'db'
        switch target
            case 'db'
                % NO OP, same target as source
            case 'squared'
                switch band
                    case {'pass', 'stop'}, val = 1/(10^(val/10));
                    otherwise,             error(banderrid,banderrmsg);
                end
            case 'linear'
                switch band
                    case 'pass', val = (10^(val/20) - 1)/(10^(val/20) + 1);
                    case 'stop', val = 10^(-val/20);
                    case 'amplitude', val = 10.^(val/20);
                    otherwise,   error(banderrid,banderrmsg);
                end
            otherwise
                error(targerrid,targerrmsg);
        end
    otherwise
        error(generatemsgid('unknownSource'), ...
            '''%s'' is an unknown source, specify ''linear'', ''squared'' or ''db''.', source);
end

% [EOF]
