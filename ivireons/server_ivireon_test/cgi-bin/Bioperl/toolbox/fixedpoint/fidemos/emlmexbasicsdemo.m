%% Fixed-Point Lowpass Filtering Using Embedded MATLAB(R) MEX
% This is a demonstration of some aspects of the Embedded MATLAB(R) C-MEX
% generation (emlmex). You will generate a C-MEX function from MATLAB(R) code, run
% the generated C-MEX function, and display the results.
%
% Copyright 1984-2010 The MathWorks, Inc.

%% Description of the Demonstration
% In this example, you take the weighted average of a signal.  By choosing
% the weights, or coefficients, in a certain way, you can average out
% only high frequencies and retain low frequencies.  Because you are
% allowing the low frequencies to pass through without modification, this
% is called a "lowpass filter".  A filter of this kind can be used to
% remove high-frequency hiss from a telephone, for example. A different
% choice of coefficients would allow you to filter out different frequency
% bands.  
%% Copy Required File
% There is a MATLAB-file that is needed to run this demonstration. Copy it to a 
% temporary directory. This step requires write-permission to the system's 
% temporary directory.
emlmexdir = [tempdir filesep 'emlmexdir'];
if ~exist(emlmexdir,'dir')
    mkdir(emlmexdir);
end
emlmexsrc = ...
    fullfile(matlabroot,'toolbox','fixedpoint','fidemos','emlmexfilter.m');
copyfile(emlmexsrc,emlmexdir,'f');
%% Inspect the MATLAB Weighted Average Filter Function Code
% The MATLAB function that performs the weighted average is in the file
% |emlmexfilter.m|. This code simply calls the |FILTER| function, which
% implements a Direct Form II Transposed FIR filter:
type(fullfile(emlmexdir,'emlmexfilter.m'))
%%
% The following variables are use in this function:
% 
% * |b| is the filter coefficients vector.
% * |x| is the input signal vector.
% * |y| is the output signal vector.
%
% So that you can see the effect of the filter, you use a chirp signal for
% the input |x|.  If played, this chirp sounds like a bird's chirp, going
% from low frequency to high frequency.  In the plot of the output, you can
% see the low frequencies passing through unchanged (but delayed a little 
% bit), and the higher frequencies are attenuated.

%% Create the Lowpass Coefficients
% Create FIR filter coefficients using Signal Processing Toolbox(TM).
%
%  % [L,fo,mo,w] = firpmord([1500 2000],[1 0], [0.01 01.], 8000 );
%  % b = firpm(L,fo,mo,w);
%
b = [  -0.0204578867332896
        0.0086603954613574
        0.1068667619076360
       -0.2187706460534480
        0.0730546552429822
        0.3153037876114750
        0.4649509557016000
        0.3153037876114750
        0.0730546552429822
       -0.2187706460534480
        0.1068667619076360
        0.0086603954613574
       -0.0204578867332896]';

stem(b)
title('Filter coefficients')
%% Create the Chirp Input Signal
Fs = 256;      % Sampling frequency
Ts = 1/Fs;     % Sample time
t = 0:Ts:1-Ts; % Time vector from 0 to 1 second
f1 = Fs/2;     % Target frequency of chirp set to Nyquist
gain = (1 - 2^-15);          % Scale the input to be in the range [-1, +1)
x0 = gain * sin(pi*f1*t.^2); % Linear chirp from 0 to Fs/2 Hz in 1 second.

%% Run the Filter with Floating-Point Data Types
emlcurdir = pwd;
cd(emlmexdir);
yfl = emlmexfilter(b, x0);

%% Define Fixed-Point Parameters
% Define signed, best precision fixed-point input arguments with 12-bit
% word length:
reset(fipref);
bfi = sfi(b,  12);
xfi = sfi(x0, 12);

%% Compile the MATLAB-File into a MEX File and Generate the Compilation Report
emlmex emlmexfilter -report -eg {bfi, xfi} -o emlmexfilterx

%% Run the Filter with Fixed-Point Data Types
yfi = emlmexfilterx(bfi, xfi);

%% Plot the Results
t = 1:length(x0);
subplot(3,1,[1 2]);
plot(t,x0,'c',t,yfl,'o-',t,yfi,'s-');
legend('Input','Floating point','Fixed Point');
subplot(3,1,3);
plot(double(yfi(:))-yfl(:),'r');
ylabel('Error');
figure(gcf);

%% Clean up Temporary Files
cd(emlcurdir);
clear emlmexfilterx;
status = rmdir(emlmexdir,'s');

displayEndOfDemoMessage(mfilename)
