%% Getting Started with Spectral Analysis Objects
% This demo describes an object-oriented paradigm for spectral analysis.

% Copyright 1988-2007 The MathWorks, Inc.
% $Revision: 1.1.6.12 $ $Date: 2008/08/01 12:25:23 $

%% Introduction
%
% The Signal Processing Toolbox(TM) provides several command line functions to
% perform spectral analysis, including classical (non-parametric)
% techniques, parametric techniques, and eigenvector (or subspace)
% techniques.  In addition, objects have been added which enhance the
% usability, and visualization capabilities to these functions.  There are
% nine classes representing the following spectral analysis algorithms.
%
%      Periodogram
%      Welch
%      MTM (Thomson multitaper method)
%      Burg
%      Covariance
%      Modified Covariance
%      Yule-Walker
%      MUSIC (Multiple Signal Classification)
%      Eigenvector
%

%% Default Spectrum Object
%
% You can instantiate a spectrum object without specifying any input
% arguments.  For example, the following creates a default periodogram
% spectrum object with default settings.

     h = spectrum.periodogram


%% Specifying Parameters at Object Instantiation
%
% Specifying parameter values at object construction time requires that you
% specify the parameters in the order listed in the help.  Type "help
% spectrum.welch" for an example.  When instantiating a Welch object you
% can't specify segment length without specifying window name.  However, as
% you will see later in this demo you can always set any parameter after
% the object is created.

%%
% Here's an example of specifying several of the object's parameter values
% at construction time.

    h = spectrum.welch('kaiser',66,50)


%% Changing Property Values after Object Instantiation
%
% You can set the value of any parameter, except for the EstimationMethod,
% using either dot-notation or the set method.  Here's how you set the
% window of the Welch object created above using dot-notation.

     h.WindowName = 'Chebyshev'   

%%
% Note that the Chebyshev window has a sidelobe attenuation parameter,
% which dynamically appears in the list of properties.

%%
% To specify a window parameter you must enclose the window name and the
% parameter value in a cell array.  Here's how you can specify the sidelobe
% attenuation value for the Chebyshev window:

    h = spectrum.welch({'Chebyshev',80})

    
%% Spectral Estimation Methods
%
% Some of the most important methods of the spectrum objects are psd,
% msspectrum, and pseudospectrum. The psd method returns the power spectral
% density (PSD).  The msspectrum method returns the mean-square (power)
% spectrum (MSS) calculated by the periodogram or Welch spectral estimation
% technique. The pseudospectrum method returns the pseudospectrum
% calculated by the MUSIC or eigenvector estimation technique.  All of
% these methods will plot the spectrum if no output argument is specified.
%
% The PSD is a measure of power per unit of frequency, hence it has units
% of power/frequency.  For example, for a sequence of voltage measurements
% the units of the PSD are volts^2/Hz.  The MSS, on the other hand, is a
% measure of power at specific frequency and has units of power.
% Continuing our example where the signal is voltage measurements the units
% would be volts^2.
%
% All three of these methods (psd, msspectrum, and pseudospectrum) have the
% same syntax.  They require a spectrum object as the first input and the
% signal to measure the power as the second input argument.  Then you can
% optionally specify property-value pairs for the sampling frequency, the
% spectrum range, and the number of FFT points, etc.
%
% Alternatively you can invoke the psdopts method on a spectrum object,
% which returns an options object with default values for these and other
% parameters. For example:

       h = spectrum.welch;
       hopts = psdopts(h)
	   
%%
% produces an options object hopts which contains the list of optional
% parameters that can be passed to the psd method.  This options object can
% now be used in multiple calls to the psd method.
	   
%% 
% You can then set the value of any of the properties of the options
% object hopts and pass hopts to the psd method. There are corresponding
% msspectrumopts and pseudospectrumopts methods that return options
% objects to be used with the msspectrum and pseudospectrum methods,
% respectively.

%% Spectral Analysis Example
%
% In this example you will compute and plot the power spectral density of a
% 200 Hz cosine signal with noise using a periodogram spectrum object.

       % Create signal.
       Fs = 1000;   t = 0:1/Fs:.3;
       randn('state',0);
       x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise

       % Instantiate spectrum object and call its PSD method.  
       h = spectrum.periodogram('rectangular');   
       hopts = psdopts(h,x);  % Default options based on the signal x
       set(hopts,'Fs',Fs,'SpectrumType','twosided','CenterDC',true);
       psd(h,x,hopts)

       
%%
% Because Fs was specified the PSD was plotted against the frequency with
% units of Hz.  If Fs was not specified a frequency with units of
% rad/sample would have been used (in that case the PSD units would be
% power/(rad/sample).)  Also, specifying the SpectrumType as 'twosided'
% indicates that you want the spectrum calculated over the whole Nyquist
% interval.
%
% If you specify an output argument then the psd method will return a PSD
% data object as shown in the example below.  See the section "Spectrum
% Data Objects" later in this document for more details on PSD data
% objects.

%%
       % Use a long FFT for integral approximation accuracy
       set(hopts,'NFFT',2^14);
       hpsd = psd(h,x,hopts)

%%
% The PSD data object returned contains among other parameters the spectrum
% data, the frequencies at which the spectrum was calculated, and the
% sampling frequency.  The methods of the PSD data object include plot, and
% avgpower.  The plot method plots the spectrum data stored in the object.
% The avgpower method uses a rectangle approximation to the integral to
% calculate the signal's average power using the PSD data stored in the
% object.  
 
%%
% The avgpower method returns the average power of the signal which is the
% area under the PSD curve.
       avgpower(hpsd)
   

%% One-sided PSD
%
% In the example above you specified 'twosided' in the call to the psd
% method via the options object hopts.  However, for real signals by
% default the 'onesided' PSD is returned.  Likewise, if no output argument
% is specified the plot displays only half the Nyquist interval (the other
% half is duplicate information).  

       set(hopts,'SpectrumType','onesided');
       psd(h,x,hopts)

%%
% It is important to note that although you are only seeing half the
% Nyquist interval it contains the total power, i.e., if you integrate
% under the PSD curve you get the total average power - this is called the
% one-sided PSD.  Continuing the last example let's measure the average
% power which should be the same as when we used the 'twosided' PSD above.

       hpsd = psd(h,x,hopts);
       avgpower(hpsd)
       
%% Spectrum Using a Vector of Frequencies
%
% You can configure a dspopts.spectrum object so as to supply a vector of
% frequencies where the power spectrum of the signal is to be evaluated.
%
% In this example you will use the msspectrum object to resolve the 1.24
% kHz and 1.26 kHz components in a cosine which also has a 10 kHz
% component.

       % Generate signal.
       randn('state',0);
       Fs = 32e3;   t = 0:1/Fs:2.96;
       x  = cos(2*pi*t*10e3)+cos(2*pi*t*1.24e3)+cos(2*pi*t*1.26e3)...
            + randn(size(t));

       nfft = (length(x)+1)/2;
       f = (Fs/2)/nfft*(0:nfft-1);          % Generate frequency vector
       
       % Instantiate spectrum object and call its PSD method.  
       h = spectrum.periodogram('rectangular');   
       hopts = psdopts(h,x);  % Default options based on the signal x
       set(hopts,'Fs',Fs,'SpectrumType','twosided');
       hopts.FreqPoints = 'User Defined';
       hopts.FrequencyVector = f(f>1.2e3 & f<1.3e3);
       msspectrum(h,x,hopts)
       
       
%% Spectrum Estimates with Confidence Intervals
%
% You can obtain the confidence interval for the spectrum estimate by
% specifying the confidence level. This feature is available for psd and 
% msspectrum methods. 
%
% In this example you will calculate the confidence interval for a
% confidence level of 95%.

       % Create signal.
       Fs = 1000;   t = 0:1/Fs:.296;
       x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
        
       % Confidence Level
       p = 0.95;
       
       % PSD with confidence level
       h = spectrum.welch;
       hpsd = psd(h,x,'Fs',Fs,'ConfLevel',p)
       plot(hpsd)        
      
       
%% Spectrum Data Objects
%
% You can also instantiate psd, msspectrum, and pseudospectrum data objects
% directly. These objects can be used to hold existing spectrum data and
% enable you to use the plotting features.  These objects also accept the
% data in a matrix format where each column is different spectral estimate.
%
% In this example you will estimate the power spectral density of a real
% signal using three different windows.  Then you will create a PSD data
% object with these three spectrums stored as a matrix, and call its plot
% method to view the results graphically.

       % Create signal.
       Fs = 1000;   t = 0:1/Fs:.296;
       x = cos(2*pi*t*200)+randn(size(t));  % A cosine of 200Hz plus noise
  
       % Construct a Welch spectrum object.
       h = spectrum.welch('hamming',64);

       % Create three power spectral density estimates.
       hpsd1 = psd(h,x,'Fs',Fs);
       Pxx1 = hpsd1.Data;
       W = hpsd1.Frequencies;
       
       h.WindowName = 'Kaiser';
       hpsd2 = psd(h,x,'Fs',Fs);
       Pxx2 = hpsd2.Data;
       
       h.WindowName = 'Chebyshev';
       hpsd3 = psd(h,x,'Fs',Fs);
       Pxx3 = hpsd3.Data;
       
       % Instantiate a PSD data object and store the three different
       % estimates since they all share the same frequency information.
       hpsd = dspdata.psd([Pxx1, Pxx2, Pxx3],W,'Fs',Fs)
%%     
       plot(hpsd);
       legend('Hamming','kaiser','Chebyshev');
       
       
displayEndOfDemoMessage(mfilename)
