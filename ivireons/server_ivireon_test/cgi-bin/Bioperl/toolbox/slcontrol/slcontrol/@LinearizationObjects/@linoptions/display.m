function display(this)
%DISPLAY  Defines properties for @linoptions class

%  Author(s): John Glass
%  Revised:
%   Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2008/10/31 07:35:10 $

disp(' ')
if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
    disp(sprintf('Options for <a href="matlab:help linearize">LINEARIZE</a>:'))
else
    disp(sprintf('Options for LINEARIZE:'))
end
disp(sprintf('    LinearizationAlgorithm        : %s', this.LinearizationAlgorithm));
if ischar(this.SampleTime)
    disp(sprintf('    SampleTime (-1 Auto Detect)   : %s', this.SampleTime));
else
    disp(sprintf('    SampleTime (-1 Auto Detect)   : %d', this.SampleTime));
end
disp(sprintf('    UseFullBlockNameLabels (on/off): %s', this.UseFullBlockNameLabels));
disp(sprintf('    UseBusSignalLabels (on/off): %s', this.UseBusSignalLabels));
disp(sprintf(' '));
disp(sprintf('  Options for ''blockbyblock'' algorithm'))
disp(sprintf('    BlockReduction (on/off)                   : %s', this.BlockReduction));       
disp(sprintf('    IgnoreDiscreteStates (on/off)             : %s', this.IgnoreDiscreteStates));
disp(sprintf('    RateConversionMethod (zoh/tustin/prewarp/ : %s', this.RateConversionMethod));
disp(sprintf('                          upsampling_zoh/           '));
disp(sprintf('                          upsampling_tustin/        '));
disp(sprintf('                          upsampling_prewarp        '));
if ischar(this.PreWarpFreq)
    disp(sprintf('    PreWarpFreq                               : %s', this.PreWarpFreq)); 
else
    disp(sprintf('    PreWarpFreq                               : %d', this.PreWarpFreq)); 
end
disp(sprintf('    UseExactDelayModel                        : %s', this.UseExactDelayModel)); 
disp(sprintf(' '));
disp(sprintf('  Options for ''numericalpert'' algorithm'))
disp(sprintf('    NumericalPertRel : %d', this.NumericalPertRel));  
if isempty(this.NumericalXPert)
    disp(sprintf('    NumericalXPert   : []'));
else
    disp(sprintf('    NumericalXPert   : [%dx%d double]', size(this.NumericalXPert)));
end
if isempty(this.NumericalUPert)
    disp(sprintf('    NumericalUPert   : []'));
else
    disp(sprintf('    NumericalUPert   : [%dx%d double]', size(this.NumericalUPert)));
end
disp(sprintf(' '));
if usejava('Swing') && desktop('-inuse') && feature('hotlinks')
    disp(sprintf('Options for <a href="matlab:help findop">FINDOP</a>:'))
else
    disp(sprintf('Options for FINDOP:'))
end
disp(sprintf('    OptimizationOptions        : [1x1 struct]'));       
disp(sprintf('    OptimizerType              : %s', this.OptimizerType));
disp(sprintf('    DisplayReport (on/iter/off): %s', this.DisplayReport));
disp(sprintf('\n'));
