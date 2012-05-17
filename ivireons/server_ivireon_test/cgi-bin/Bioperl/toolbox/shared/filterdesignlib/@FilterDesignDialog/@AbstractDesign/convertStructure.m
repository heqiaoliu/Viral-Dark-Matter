function longstruct = convertStructure(this, shortstruct)
%CONVERTSTRUCTURE   Convert from long struct to short struct names.

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/08/11 15:47:07 $

if nargin < 2
    shortstruct = get(this, 'Structure');
end

switch lower(shortstruct)
    case 'iirdecim'
        longstruct = 'IIR polyphase decimator';
    case 'iirinterp'
        longstruct = 'IIR polyphase interpolator';
    case 'firdecim'
        longstruct = 'Direct-form FIR polyphase decimator';
    case 'firinterp'
        longstruct = 'Direct-form FIR polyphase interpolator';
    case 'firtdecim'
        longstruct = 'Direct-form transposed FIR polyphase decimator';
    case 'fftfirinterp'
        longstruct = 'Overlap-add FIR polyphase interpolator';
    case 'dffir'
        longstruct = 'Direct-form FIR';
    case 'dffirt'
        longstruct = 'Direct-form FIR transposed';
    case 'dfsymfir'
        longstruct = 'Direct-form symmetric FIR';
    case 'dfasymfir'
        longstruct = 'Direct-form antisymmetric FIR';
    case 'df1'
        longstruct = 'Direct-form I';
    case 'df2'
        longstruct = 'Direct-form II';
    case 'df1t'
        longstruct = 'Direct-form I transposed';
    case 'df2t'
        longstruct = 'Direct-form II transposed';
    case 'df1sos'
        longstruct = 'Direct-form I SOS';
    case 'df2sos'
        longstruct = 'Direct-form II SOS';
    case 'df1tsos'
        longstruct = 'Direct-form I transposed SOS';
    case 'df2tsos'
        longstruct = 'Direct-form II transposed SOS';
    case 'fftfir'
        longstruct = 'Overlap-add FIR';
    case 'cascadeallpass'
        longstruct = 'Cascade minimum-multiplier allpass';
    case 'cascade minimum-multiplier allpass'
        longstruct = 'cascadeallpass';
    case 'cascadewdfallpass'
        longstruct = 'Cascade wave digital filter allpass';
    case 'cascade wave digital filter allpass'
        longstruct = 'cascadewdfallpass';
    case 'iirwdfdecim'
        longstruct = 'IIR wave digital filter polyphase decimator';
    case 'iir wave digital filter polyphase decimator'
        longstruct = 'iirwdfdecim';
    case 'iirwdfinterp'
        longstruct = 'IIR wave digital filter polyphase interpolator';
    case 'iir wave digital filter polyphase interpolator'
        longstruct = 'iirwdfinterp';
    case 'direct-form fir polyphase decimator'
        longstruct = 'firdecim';
    case 'direct-form fir polyphase interpolator'
        longstruct = 'firinterp';
    case 'direct-form transposed fir polyphase decimator'
        longstruct = 'firtdecim';
    case 'overlap-add fir polyphase interpolator'
        longstruct = 'fftfirinterp';
    case 'iir polyphase decimator'
        longstruct = 'iirdecim';
    case 'iir polyphase interpolator'
        longstruct = 'iirinterp';
    case 'direct-form fir'
        longstruct = 'dffir';
    case 'direct-form fir transposed'
        longstruct = 'dffirt';
    case 'direct-form symmetric fir'
        longstruct = 'dfsymfir';
    case 'direct-form antisymmetric fir'
        longstruct = 'dfasymfir';
    case 'direct-form i'
        longstruct = 'df1';
    case 'direct-form ii'
        longstruct = 'df2';
    case 'direct-form i transposed'
        longstruct = 'df1t';
    case 'direct-form ii transposed'
        longstruct = 'df2t';
    case 'direct-form i sos'
        longstruct = 'df1sos';
    case 'direct-form ii sos'
        longstruct = 'df2sos';
    case 'direct-form i transposed sos'
        longstruct = 'df1tsos';
    case 'direct-form ii transposed sos'
        longstruct = 'df2tsos';
    case 'overlap-add fir'
        longstruct = 'fftfir';
    case {'cicdecim', 'cicinterp'}
        longstruct = shortstruct;
    case 'fd'
        longstruct = 'Fractional delay';
    case 'fractional delay'
        longstruct = 'farrowfd';
    case 'farrowfd'
        longstruct = 'Farrow fractional delay';
    case 'farrow fractional delay'
        longstruct = 'farrowfd';
    case 'firsrc'
        longstruct = 'Direct-form FIR polyphase sample-rate converter';
    case 'direct-form fir polyphase sample-rate converter'
        longstruct = 'firsrc';
    otherwise
        error(generatemsgid('InternalError'), ...
            'Unknown structure: %s', shortstruct);
end

% [EOF]
