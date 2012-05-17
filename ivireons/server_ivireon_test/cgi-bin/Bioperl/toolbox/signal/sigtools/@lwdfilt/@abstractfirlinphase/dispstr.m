function s = dispstr(this, varargin)
%DISPSTR Display string of coefficients.
%   DISPSTR(Hd) returns a string that can be used to display the coefficients
%   of discrete-time filter Hd.
%
%   See also DFILT.   
  
%   Author: Thomas A. Bryan
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/16 08:45:08 $

num = lcldispstr(this.Numerator(:), varargin{:});

s = char({'Numerator:'
          num
         });

%--------------------------------------------------------------------------
function varargout = lcldispstr(varargin)

% Ignore the format, can only work fixed.
if ischar(varargin{end})
    fmt = varargin{end};
    varargin(end) = [];
else
    fmt = 'dec';
end

switch lower(fmt(1:3))
    case 'dec'
        for indx = 1:length(varargin)
            varargout{indx} = signal_num2str(varargin{indx});
        end
    case 'hex'
        for indx = 1:length(varargin)
            [rows, cols] = size(varargin{indx});
            if cols > 1 && rows > 1
                str = [];
                for jndx = 1:cols
                    str = [str repmat('  ', rows, 1) num2hex(varargin{indx}(:,jndx))];
                end
                str(:, 1:2) = [];
            else
                str = num2hex(varargin{indx});
            end
            varargout{indx} = str;
        end
    case 'bin'
        if isfixptinstalled
            q = quantizer('double');
            for indx = 1:length(varargin)
                [rows, cols] = size(varargin{indx});
                if cols > 1 && rows > 1
                    str = [];
                    for jndx = 1:cols
                        str = [str repmat('  ', rows, 1) num2bin(q, varargin{indx}(:,jndx))];
                    end
                    str(:, 1:2) = [];
                else
                    str = num2bin(q, varargin{indx});
                end
                varargout{indx} = str;
            end
        else
            error(generatemsgid('invalidFormat'), ...
                '''bin'' is only available with the Fixed-Point Toolbox.');
        end
end

% [EOF]
