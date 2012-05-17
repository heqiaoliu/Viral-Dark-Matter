%% Fixed-Point Data Type Override, Min/Max Logging, and Scaling
%
% This is a demonstration of data type override, min/max logging, and scaling
% of fixed-point objects in MATLAB(R).  After determining the scaling of the
% fixed-point algorithm, we use that information in Embedded MATLAB(R) to
% automatically generate fixed-point C code from our MATLAB algorithm.

%% Development Process
%
% A common problem in fixed-point development is to determine the correct
% scaling and data types for a fixed-point algorithm.  This demo illustrates the
% method of running test signals through an algorithm, logging the minimum
% and maximum values of all variables, and setting their scaling based on the
% logged values.
%
% We will follow these steps.
%
% 1. Implement the textbook algorithm in MATLAB.
%
% 2. Verify with built-in floating-point data types in MATLAB.
%
% 3. Convert to fixed-point data types in MATLAB and run with default settings.
%
% 4. Set the |fipref| |DataTypeOverride| property to |ScaledDoubles| to
% log the full numerical range of values.
%
% 5. Use the logged minimum and maximum values to set the fixed-point scaling.
%
% 6. Validate the fixed-point solution.
%
% 7. Convert MATLAB to C using Embedded MATLAB.

%% The Textbook Algorithm
%
% The algorithm that we will use for our example is a second-order
% difference equation with input |x|, output |y|, and constant coefficients
%
% $$ y(k) = b_1 x(k) + b_2 x(k-1) + b_3 x(k-2) - a_2 y(k-1) - a_3 y(k-2).
% $$
%
% The transfer function of this equation is
%
% $$ H(z) \equiv {Y(z) \over X(z)} = 
% {b_1 + b_2 z^{-1} + b_3 z^{-2} \over 1 + a_2 z^{-1} + a_3
% z^{-2}}.$$
%
% Because the *b* coefficients appear in the numerator of the transfer
% function, they are commonly called *numerator* coefficients.  Similarly,
% the *a* coefficients are commonly called *denominator* coefficients.
%
% Difference equations are used in digital controllers and filters.

%% Implement Textbook Algorithm in MATLAB
% We have implemented this algorithm in the following MATLAB code.
type fi_2nd_order_filter

%% Notes on the MATLAB Code
% * The optimal fixed-point data type of the output and the accumulator
% cannot always be inferred from the inputs, so we input |numerictype|
% objects Ty and Tacc to specify the data type of the output |y| and the
% accumulator |acc|, respectively.
%
% * We check to see if the input is a |fi| object, and construct the output
% and accumulator accordingly, so that built-in data types can use the same
% code.
%
% * The filter has state variables |zx| and |zy| to process past inputs and
% outputs, initialized to zero.
%
% * The sum is accumulated in variable |acc| so we can log minimum and
% maximum values over the course of the sum.  As we will see in this
% example, an intermediate sum can overflow even when the output does
% not.

%% Verify with Built-in Floating-Point in MATLAB
% To validate the algorithm, we first run it with built-in double variables
% for coefficients and input.  For this example, we have chosen
% coefficients that define a low-pass filter and a linear chirp input to
% illustrate the attenuation of high frequencies.
num = [0.29290771484375   0.585784912109375  0.292907714843750];
den = [1.0                0.0                0.171600341796875];
Fs = 256;        % Sampling frequency
Ts = 1/Fs;       % Sample time
t = 0:Ts:1-Ts;   % Time vector from 0 to 1 second
f1 = Fs/2;       % Target frequency of chirp set to Nyquist
gain = (1-2^-15);           % Scale the input to be in the range [-1, +1)
u = gain * sin(pi*f1*t.^2); % Linear chirp from 0 to Fs/2 Hz in 1 second.
%%
% Run the filter with built-in double data types.
%
y0 = fi_2nd_order_filter(num, den, u);
%% Compute the Magnitude of the Frequency Response of the Filter
n = length(u);
H = abs(fft(num,2*n)./fft(den,2*n));  
H = H(1:n);
f = linspace(0,1,n);
%% Plot the Results
% The instantaneous frequency of the chirp signal goes from 0 to Fs/2 Hz,
% and the time goes from 0 to 1 second.  Hence, we can plot the frequency
% response against the normalized frequency (0 to 1) on the same axis as
% the time response (0 to 1 second).
clf
plot(f,u,'c-',f,y0,'bo-',f,H,'r--')
xlabel('Time (s) & Normalized Instantaneous Frequency (1 = Fs/2)')
ylabel('Amplitude')
legend('Input','Floating-point output','Frequency response')
title('Double-Precision Floating-Point Case')
%% Convert to Fixed-Point Data Types in MATLAB and Run with Default Settings
% Our initial try is to define the variables as fixed-point |fi| objects
% using default values.  We turn on overflow warnings, turn off
% underflow warnings, and turn on logging.
warning on  fi:overflow
warning off fi:underflow
warning off backtrace
fp = fipref;
currentLoggingMode = fp.LoggingMode; % store away current LoggingMode setting;
                                     % restore this at the end of the demo.
fipref('LoggingMode','on');

b = fi(num)
a = fi(den)
x = fi(u);
[y,acc] = fi_2nd_order_filter(b,a,x);  % Fixed-point, default settings
%%
% Note the overflows in the |fi| assignment operation.  
% If you are interested in also seeing the line number in the code where
% the overflow occurred, do
%
%   warning on backtrace
%%
% You can see the effect of the overflows in the difference between the
% floating-point and fixed-point plots.
fi_datatype_override_demo_plot(b,a,x,y,y0,'Fixed-Point Case with Default Settings')

%% Override the fi Object with 'ScaledDouble' Data Type to Log Min and Max Values
% The saturation of the accumulator prevented the full range of possible values
% from being attained.  We change the data type of the |fi| object to be
% |ScaledDouble| to allow the full range of values to be displayed.  One of the
% differences between built-in MATLAB double-precision variables and |fi| objects
% set to |ScaledDouble| data type is that the |fi| object logs the minimum and
% maximum value that has been assigned to the variable.  Another benefit to
% using the |ScaledDouble| data type over the |double| data type is that it
% retains its fixed-point parameters so it can detect overflow and underflow.
currentDTOSetting = fp.DataTypeOverride; % store away current DataTypeOverride
                                         % setting; restore this at the end
                                         % of the demo.
fipref('DataTypeOverride','ScaledDoubles');
b = fi(num)
a = fi(den)
x = fi(u);
[y_sd_fi,acc_sd_fi] = fi_2nd_order_filter(b,a,x);  % fi ScaledDouble override
%% 
% Note that there were more overflows detected with the scaled double data type
% than with the fixed-point data type because intermediate values do not get
% quantized with the scaled double data type and so you can see the full range
% that a variable would have attained.
fi_datatype_override_demo_plot(b,a,x,y_sd_fi,...
                              'Data Type Override Case and Logging On')
%% Accessing Logged Values
% When the |LoggingMode| property of the |fipref| object is set to |'on'|, you
% can use the following functions to access the logged information on a |fi|
% object:
%
% * |maxlog(x)| returns the largest real-world value assigned to |fi| object |x|
% since logging was turned on
% * |minlog(x)| returns the smallest real-world value assigned to |fi| object
% |x| since logging was turned on
% * |noverflows(x)| returns the number of overflows of |fi| object |x| since
% logging was turned on
% * |nunderflows(x)| returns the number of underflows of |fi| object |x| since
% logging was turned on
% * |resetlog(x)| clears the log for |fi| object |x|
%
% In addition to the logging functions, you can use the following functions to
% get the range of the data type of a |fi|:
%
% * |range(x)| returns the numerical range of |fi| object |x|
% * |lowerbound(x)| returns the lower bound of the range of |fi| object |x|
% * |upperbound(x)| returns the upper bound of the range of |fi| object |x| 
%
% We have encapsulated the display of the logged data in the |logreport|
% function.  Note that the partial sums overflowed the accumulator |acc|,
% even though the output |y| did not overflow.
logreport(b,a,x,y_sd_fi,acc_sd_fi)
%% Use Logged Min and Max Values to Set the Fixed-Point Scaling
% Given the range of values from |minlog| and |maxlog| of our variables, we
% can now set optimal scaling to prevent overflow for the given input.
%
% Note that this scaling depends on the input that was used in the test.
% If the input changes, then the optimal scaling may change.  Great care
% should be taken to design inputs that will exercise the full range of
% values.  Common choices for input values are combinations of
%
% * Random noise scaled to the full numeric range of the fixed-point input data
% type
% * Step signals     [0 0 ... 0 1 1 ... 1]
% * Impulse signals  [1 0 0 ... 0]
% * Chirp signals from 0 to Fs/2 Hz
%
% We compute the best numeric type from the logs of a variable via the
% following function.
type fi_best_numeric_type_from_logs
%%
% We use 16-bit signed data, a 40-bit accumulator, and compute the
% best-precision scaling from logs generated by simulation with |ScaledDoubles|. 
% You can experiment by changing these values.  For example, also try 8-bit
% signed data and a 32-bit accumulator (|Wdata = 8; Wacc = 32;|)
Wdata = 16;  % Word length of the data
Wacc  = 40;  % Word length of the accumulator
is_signed = true;
Ty   = fi_best_numeric_type_from_logs(y_sd_fi,   is_signed, Wdata)
Tacc = fi_best_numeric_type_from_logs(acc_sd_fi, is_signed, Wacc)
%% Set up the fimath Object
% The |fimath| object encapsulates the settings for fixed-point math
% operations. We let the Fixed-Point Toolbox(TM) figure out the
% product types by setting |ProductMode| to |FullPrecision|, knowing that the 
% product will always be 32 bits long (both operands are 16 bit). 
F = fimath('RoundMode',             'floor', ...
           'OverflowMode',          'wrap', ...
           'ProductMode',           'FullPrecision', ...
           'SumMode',               'SpecifyPrecision', ...
           'SumWordLength',         Tacc.WordLength, ...
           'SumFractionLength',     Tacc.FractionLength)
% We will now make F the default |fimath| for all fixed-point operations. All
% FIs created henceforth will have this |fimath|.
currentGlobalFimath = fimath; % store away current global fimath;
                              % restore this at the end of the demo.
globalfimath(F);

%% Validate the Fixed-Point Solution
% Run the filter again with fixed-point data types and the settings that we have
% computed.
fipref('DataTypeOverride','ForceOff');
% Set up b, a, and x with best-precision fraction length
b = fi(num, is_signed, Wdata);
a = fi(den, is_signed, Wdata);
x = fi(u,   is_signed, Wdata);  
[y,acc] = fi_2nd_order_filter(b,a,x,Ty,Tacc);  % Optimal fixed-point settings
fi_datatype_override_demo_plot(b,a,x,y,y0,...
                              'Fixed-Point Case after Scaling')
%%
logreport(b,a,x,y,acc)
%%
% Note that there are no longer any overflows.
% 

%% Use Embedded MATLAB(TM) block in Simulink(R) to convert MATLAB to C
% If you have Simulink(R) Fixed Point(TM) and Real-Time Workshop(R), you 
% can put your fixed-point MATLAB-code into an Embedded MATLAB Function block,  
% to generate C-code from MATLAB-code.
%
% We added the fixed-point attributes that we computed above to the
% Embedded MATLAB block in this model, and re-used the identical algorithm
% in MATLAB.  Embedded MATLAB is a proper subset of MATLAB.
% 
% Note that as of R2008b, the Embedded MATLAB subset supports word-lengths
% of up to 128 bits. Thus an accumulator word-length of 40 bits is easily
% supported by the Embedded MATLAB Function block.
if license('test','Fixed-Point_Blocks')&&license('test','Real-Time_Workshop')
    bdclose all
    sim('eml_2nd_order_filter_vectorized')
end
%% Open the Embedded MATLAB Model
if license('test','Fixed-Point_Blocks')&&license('test','Real-Time_Workshop')
    eml_2nd_order_filter_vectorized
end
%% Open the Embedded MATLAB Function Block
% Double-click on the Embedded MATLAB block to see the MATLAB
% code.

%% Sample-Based Model
% Using the identical Embedded MATLAB code we can also run in sample-based
% mode, in which the function processes one input sample and produces one
% output sample at each time step.  Here is an example of the block
% in sample-based mode.
if license('test','Fixed-Point_Blocks')&&license('test','Real-Time_Workshop')
    bdclose all
    eml_2nd_order_filter
end

%% Use Embedded MATLAB features emlmex and emlc
%% Copy Required File
% There is a MATLAB-file that is needed to run this demonstration. Copy it to a
% temporary directory. This step requires write-permission to the system's 
% temporary directory. 
% Switch off |LoggingMode| for now as emlmex does not 
% support it.

emlmexdir = [tempdir filesep 'emlmexdir'];
emlcdir = [tempdir filesep 'emlcdir'];

if ~exist(emlmexdir,'dir')
    mkdir(emlmexdir);
end
if ~exist(emlcdir,'dir')
    mkdir(emlcdir);
end

emlmexsrc = ...
    fullfile(matlabroot,'toolbox','fixedpoint','fidemos','fieml_2nd_order_filter.m');
copyfile(emlmexsrc,emlmexdir,'f');
copyfile(emlmexsrc,emlcdir,'f');

emlcurdir = pwd;
cd(emlmexdir);
fipref('LoggingMode','off');
%% Compile the MATLAB-File into a MEX File
% Use the variables |b|, |a| and |x| as set-up in 'Validate the Fixed-Point
% Solution' section of this demo as inputs to emlmex. 
emlmex -o xemlmex_filter fieml_2nd_order_filter -eg {b,a,x}

%% Compare the Speed of the Filter Using the MEX File and the Original MATLAB-File 
% First call the MATLAB-file filter.
% Next call the MEX File generated in the previous step. Note that the
% inputs you specify to the MEX File must have the same |numerictype| as
% the original inputs used during its creation.
% Observe that the execution of the filter-algorithm is much faster when
% you use the MEX File

tic; ym = fieml_2nd_order_filter(b,a,x); toc;
tic; yeml = xemlmex_filter(b,a,x); toc;

%% Generate C-Code Using Real-Time Workshop(TM)
if license('test','Real-Time_Workshop')
    cd(emlcdir);    
    emlc -o xemlc_filter fieml_2nd_order_filter -eg {b,a,x}
end

%% Inspect the Generated Code
if license('test','Real-Time_Workshop')
    type(fullfile(emlcdir,'emcprj','mexfcn','fieml_2nd_order_filter',...
        'fieml_2nd_order_filter.c'))
end

%% Clean up Temporary Files and Folders
cd(emlcurdir);
clear xemlmex_filter;
clear xemlc_filter;
status1 = rmdir(emlmexdir,'s');
status2 = rmdir(emlcdir,'s');

% Copyright 2005-2010 The MathWorks, Inc.

%%
% $Revision: 1.1.6.7 $
globalfimath(currentGlobalFimath);
fipref('LoggingMode',currentLoggingMode,'DataTypeOverride',currentDTOSetting);
bdclose all; close all;
displayEndOfDemoMessage(mfilename)
