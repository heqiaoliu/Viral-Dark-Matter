function [filtstruct,mfiltstruct] = determineiirhalfbandfiltstruct(this,desmode,filtstruct)
%DETERMINEIIRHALFBANDFILTSTRUCT Determine appropriate structure for
%   singlerate and multirate iirhalfband designs  

%   Author(s): R. Losada
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/18 14:27:07 $

mfiltstruct = [];
errid = 'invalidStructure';
errmsg = 'Invalid structure specified for this type of design.';
switch lower(desmode),
    case 'singlerate',
        switch lower(filtstruct),
            case {'iirdecim','iirinterp'},
                mfiltstruct = filtstruct;
                filtstruct = 'cascadeallpass';
            case {'iirwdfdecim','iirwdfinterp'},
                mfiltstruct = filtstruct;
                filtstruct = 'cascadewdfallpass';
            otherwise
                % Do nothing
        end
    case 'decimator',
        switch  lower(filtstruct),
            case 'cascadeallpass',
                mfiltstruct = 'iirdecim';
            case 'cascadewdfallpass',
                mfiltstruct = 'iirwdfdecim';
            case 'iirdecim',
                mfiltstruct = filtstruct;
                filtstruct = 'cascadeallpass';
            case 'iirwdfdecim',
                mfiltstruct = filtstruct;
                filtstruct = 'cascadewdfallpass';
            otherwise
                error(generatemsgid(errid),errmsg);
        end
    case 'interpolator',
        switch  lower(filtstruct),
            case 'cascadeallpass',
                mfiltstruct = 'iirinterp';
            case 'cascadewdfallpass',
                mfiltstruct = 'iirwdfinterp';
            case 'iirinterp',
                mfiltstruct = filtstruct;
                filtstruct = 'cascadeallpass';
            case 'iirwdfinterp',
                mfiltstruct = filtstruct;
                filtstruct = 'cascadewdfallpass';
            otherwise
                error(generatemsgid(errid),errmsg);
        end
end


% [EOF]
