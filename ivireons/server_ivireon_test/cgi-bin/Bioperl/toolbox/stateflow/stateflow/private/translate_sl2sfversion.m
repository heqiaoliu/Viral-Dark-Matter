function output = translate_sl2sfversion(slversion)

%   Copyright 2009 The MathWorks, Inc.

    switch (slversion)
        case {'SAVEAS_R2011A', ...
            'SAVEAS_R2011B', ...
            'SAVEAS_R2012A', ...
            'SAVEAS_R2012B', ...
            'SAVEAS_R2013A', ...
            'SAVEAS_R2013B', ...
            'SAVEAS_R2014A', ...
            'SAVEAS_R2014B', ...
            'SAVEAS_R2015A', ...
            'SAVEAS_R2015B', ...
            }
            output = '75014000.000003';
        case 'SAVEAS_R2010B'
            output = '75014000.000003';
        case 'SAVEAS_R2010A'
            output = '75014000.000002';
        case 'SAVEAS_R2009B'
            output = '71014000.000011';
        case {'SAVEAS_R2009A'}
            output = '71014000.000008';
        case {'SAVEAS_R2008B'}
            output = '71014000.000007';
        case {'SAVEAS_R2008A'}
            output = '71014000.000003';
        case {'SAVEAS_R2007B'}
            output = '67014000.000001';
        case {'SAVEAS_R2007A'}
            output = '66014000.000000';
        case {'SAVEAS_R2006B'}
            output = '65014000.000000';
        case {'SAVEAS_R2006A'}
            output = '64014000.000000';
        case {'SAVEAS_R14SP3'}
            output = '62014000.000000';
        case {'SAVEAS_R14SP2'}
            output = '62014000.000000';
        case {'SAVEAS_R14SP1'}
            output = '61014000.000000';
        otherwise
            output = '60014000.000006'; % Use R14 student temporarily
    end
end
