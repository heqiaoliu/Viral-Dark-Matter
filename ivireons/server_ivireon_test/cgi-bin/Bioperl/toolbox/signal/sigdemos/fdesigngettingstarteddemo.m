%% Getting Started with Filter Design (FDESIGN) Objects
% The filter design (FDESIGN) objects are a collection of objects that
% allow you to design lowpass, highpass, and many other types of filters
% with a variety of constraints. The design process computes the filter
% coefficients using the various algorithms available in the 
% Signal Processing Toolbox(TM) and Filter Design Toolbox(TM) and
% associates a particular filter structure to those coefficients.

% Copyright 1999-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/11/13 05:03:09 $

%% Getting Help 
% Typing "help fdesign" in the command window will bring up the help for
% the filter design objects.  Various hyperlinks in the help allow you to
% navigate to all of the help for the filter design objects.  You can also
% type "help fdesign/responses" for information about the response types
% that can be specified with filter design objects.

%% Creating a Filter Design Object
% To create a filter design object, you need to select the response to be
% used.  For example, to create a lowpass filter you would type:

h = fdesign.lowpass

%% 
% Notice that each specification is listed as an abbreviation, for example
% Fp is the abbreviation for Fpass (the passband frequency edge) and Fst is
% the abbreviation for Fstop (the stopband frequency edge). The
% 'Description' property gives a full description of the properties that
% are added by the 'Specification'.

get(h, 'Description')

%% Changing Specification Types
% The 'Specification' property allows you to select different design
% parameters.  This is a string which lists the specifications that will be
% used for the design.  To see all valid specifications type:

set(h, 'Specification')

%%
% Changing the 'Specification' will change which properties the object has:

set(h, 'Specification', 'N,Fc');
h

%% Setting Design Parameters
% You can set design parameters after creating your specification object,
% or you can pass the specifications when you construct your object.  For
% example:

specs = 'N,Fp,Fst';
h = fdesign.lowpass(specs)

%%
% After specifying the specification that you want to use, you then specify
% the values for those specifications.

N     = 40;  % Filter Order
Fpass = .33; % Passband Frequency Edge
Fstop = .4;  % Stopband Frequency Edge
h     = fdesign.lowpass(specs, N, Fpass, Fstop)

%%
% You can also specify a sampling frequency after all of the specifications
% have been entered.

Fpass = 1.3;
Fstop = 1.6;
Fs    = 4.5; % Sampling Frequency
h     = fdesign.lowpass(specs, N, Fpass, Fstop, Fs)

%%
% Amplitude specifications can be given in linear or squared units by
% providing a flag to the constructor.  However, they will always be stored
% in dB.

Apass = .0575;
specs = 'N,Fp,Ap';
h     = fdesign.lowpass(specs, N, Fpass, Apass, Fs, 'linear')

%%
Apass = .95;
h     = fdesign.lowpass(specs, N, Fpass, Apass, Fs, 'squared')

%% 
% An alternative way of changing specifications is by using the SETSPECS
% method. The SETSPECS method works in the same way as the constructor.

specs = 'N,F3dB';
F3dB  = .9;
Fs    = 2.5;
setspecs(h, specs, N, F3dB, Fs);
h

%%
% If your object is already set to the correct 'Specification' you can omit
% that input from your call to SETSPECS.

F3dB  = 1.1;
Fs    = 3;
setspecs(h, N, F3dB, Fs);
h

%% Normalizing Frequency Specifications
% To normalize your frequency specifications you can use the NORMALIZEFREQ
% method.

normalizefreq(h);
h

%%
% The NORMALIZEFREQ method can also be used to unnormalize the frequency
% specifications.

newFs = 3.1;
normalizefreq(h, false, newFs);
h

%% Designing Filters
% To design filters you use the DESIGN method.

h  = fdesign.lowpass;
Hd = design(h)

%%
% With no extra inputs this will design the default filter.  To determine
% which method was used, use the DESIGNMETHODS method with the 'default'
% flag.

designmethods(h, 'default')

%%
% Specifying no outputs will launch FVTool.

design(h)
set(gcf,'Color','white')
%%
close(gcf)

%%
% For a complete list of design methods, use DESIGNMETHODS with no extra
% inputs.

designmethods(h)

%%
% To get a better description of each design method use the 'full' flag.

designmethods(h, 'full')

%%
% DESIGNMETHODS can also take the 'fir' or 'iir' flags to return only FIR
% algorithms or IIR algorithms.
%
% To design a filter with a specific algorithm, specify it at design time.

design(h, 'kaiserwin')
set(gcf,'Color','white')
%%
close(gcf);

%% Using Design Time Options
% Some methods have options that are specific to that method. For help on
% these design options use the HELP method and pass the desired algorithm
% name.

help(h, 'ellip')

%%
% These are specified at design time as a parameter/value pair. For example:

design(h, 'ellip', 'MatchExactly', 'passband')
set(gcf,'Color','white')
%%
close(gcf);

%%
% These parameters can also be specified in a structure.  The DESIGNOPTS
% method will return a valid structure for your object and specificed
% algorithm with the default values.

% Get the default design time options
do = designopts(h, 'ellip');

% Match the stopband exactly.
do.MatchExactly = 'stopband';

%%

design(h, 'ellip', do);
set(gcf,'Color','white')
%%
close(gcf)

%% Comparing Designs
% Design can also be used to investigate various designs simultaneously.

% Show all FIR designs
design(h, 'allfir');
set(gcf,'Color','white')
%%
close(gcf)

% Show all IIR designs
design(h, 'alliir');
set(gcf,'Color','white')
axis([0 1 -91 5])

%%
close(gcf)


displayEndOfDemoMessage(mfilename)

