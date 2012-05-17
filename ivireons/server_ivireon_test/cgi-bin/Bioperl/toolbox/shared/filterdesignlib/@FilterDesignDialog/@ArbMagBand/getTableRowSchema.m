function tableRowSchema = getTableRowSchema(this, responseType, index)
%GETTABLEROWSCHEMA   Get the tableRowSchema.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:16:24 $

frequencies.Type           = 'edit';
frequencies.ObjectProperty = 'Frequencies';
frequencies.Source         = this;
frequencies.Tag            = sprintf('Frequencies%d', index);

tableRowSchema = {frequencies};

switch lower(responseType)
    case 'amplitudes'
        amplitudes.Type           = 'edit';
        amplitudes.ObjectProperty = 'Amplitudes';
        amplitudes.Source         = this;
        amplitudes.Mode           = true;
        amplitudes.Tag            = sprintf('Amplitudes%d', index);

        tableRowSchema{end+1} = amplitudes;
    case 'magnitudes and phases'
        magnitudes.Type           = 'edit';
        magnitudes.ObjectProperty = 'Magnitudes';
        magnitudes.Source         = this;
        magnitudes.Mode           = true;
        magnitudes.Tag            = sprintf('Magnitudes%d', index);

        tableRowSchema{end+1} = magnitudes;

        phases.Type           = 'edit';
        phases.ObjectProperty = 'Phases';
        phases.Source         = this;
        phases.Mode           = true;
        phases.Tag            = sprintf('Phases%d', index);

        tableRowSchema{end+1} = phases;
    case 'frequency response'
        fresp.Type           = 'edit';
        fresp.ObjectProperty = 'FreqResp';
        fresp.Source         = this;
        fresp.Mode           = true;
        fresp.Tag            = sprintf('FreqResp%d', index);

        tableRowSchema{end+1} = fresp;
end

% [EOF]
