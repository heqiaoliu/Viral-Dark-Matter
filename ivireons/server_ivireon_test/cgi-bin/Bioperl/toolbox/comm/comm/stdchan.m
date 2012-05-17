function [chan, channel_profile] = stdchan(ts, fd, chantype, varargin)
%STDCHAN Construct a channel object from a set of standardized channel models.
%   CHAN = STDCHAN(TS, FD, CHANTYPE) constructs a fading channel object
%   CHAN according to the specified CHANTYPE. The input string CHANTYPE is
%   chosen from the set of standardized channel profiles listed below. TS
%   is the sample time of the input signal, in seconds. FD is the maximum
%   Doppler shift, in Hertz.
%
%   CHAN = STDCHAN(TS, FD, CHANTYPE, TRMS) is used to create a channel
%   object CHAN when CHANTYPE is any one of '802.11a', '802.11b' or
%   '802.11g'. For these cases, the RMS delay spread of the channel model
%   needs to be specified as TRMS. As per 802.11 specifications, TS should
%   not be larger than TRMS/2.
%   
%   [CHAN, CHANPROFILE] = STDCHAN(...) also returns a structure CHANPROFILE
%   containing the parameters of the channel profile specified by CHANTYPE.
%
%   COST 207 channel models:
%   Note: The Rician K factors for the cases 'cost207RAx4' and
%   'cost207RAx6' are chosen as in 3GPP TS 45.005 V7.9.0 (2007-2)
%       'cost207RAx4'       : Rural Area (RAx), 4 taps
%       'cost207RAx6'       : Rural Area (RAx), 6 taps
%       'cost207TUx6'       : Typical Urban (TUx), 6 taps
%       'cost207TUx6alt'    : Typical Urban (TUx), 6 taps, alternative
%       'cost207TUx12'      : Typical Urban (TUx), 12 taps
%       'cost207TUx12alt'   : Typical Urban (TUx), 12 taps, alternative
%       'cost207BUx6'       : Bad Urban (BUx), 6 taps
%       'cost207BUx6alt'    : Bad Urban (BUx), 6 taps, alternative
%       'cost207BUx12'      : Bad Urban (BUx), 12 taps
%       'cost207BUx12alt'   : Bad Urban (BUx), 12 taps, alternative
%       'cost207HTx6'       : Hilly Terrain (HTx), 6 taps
%       'cost207HTx6alt'    : Hilly Terrain (HTx), 6 taps, alternative
%       'cost207HTx12'      : Hilly Terrain (HTx), 12 taps
%       'cost207HTx12alt'   : Hilly Terrain (HTx), 12 taps, alternative
% 
%   GSM/EDGE channel models:    3GPP TS 45.005 V7.9.0 (2007-2)
%                               3GPP TS 05.05 V8.20.0 (2005-11)          
%       'gsmRAx6c1'      : Typical case for rural area (RAx), 6 taps, case 1
%       'gsmRAx4c2'      : Typical case for rural area (RAx), 4 taps, case 2
%       'gsmHTx12c1'     : Typical case for hilly terrain (HTx), 12 taps, case 1
%       'gsmHTx12c2'     : Typical case for hilly terrain (HTx), 12 taps, case 2
%       'gsmHTx6c1'      : Typical case for hilly terrain (HTx), 6 taps, case 1
%       'gsmHTx6c2'      : Typical case for hilly terrain (HTx), 6 taps, case 2
%       'gsmTUx12c1'     : Typical case for urban area (TUx), 12 taps, case 1
%       'gsmTUx12c1'     : Typical case for urban area (TUx), 12 taps, case 2
%       'gsmTUx6c1'      : Typical case for urban area (TUx), 6 taps, case 1
%       'gsmTUx6c2'      : Typical case for urban area (TUx), 6 taps, case 2
%       'gsmEQx6'        : Profile for equalization test (EQx), 6 taps
%       'gsmTIx2'        : Typical case for very small cells (TIx), 2 taps
% 
%   3GPP channel models for deployment evaluation: 3GPP TR 25.943 V6.0.0
%   (2004-12)
%       '3gppTUx'       : Typical Urban channel model (TUx)
%       '3gppRAx'       : Rural Area channel model (RAx)
%       '3gppHTx'       : Hilly Terrain channel model (HTx)
% 
%   ITU-R 3G channel models: ITU-R M.1225 (1997-2)
%       'itur3GIAx'       : Indoor office, channel A
%       'itur3GIBx'       : Indoor office, channel B
%       'itur3GPAx'       : Outdoor to indoor and pedestrian, channel A
%       'itur3GPBx'       : Outdoor to indoor and pedestrian, channel B
%       'itur3GVAx'       : Vehicular - high antenna, channel A
%       'itur3GVBx'       : Vehicular - high antenna, channel B
%       'itur3GSAxLOS'    : Satellite, channel A, LOS
%       'itur3GSAxNLOS'   : Satellite, channel A, NLOS
%       'itur3GSBxLOS'    : Satellite, channel B, LOS
%       'itur3GSBxNLOS'   : Satellite, channel B, NLOS
%       'itur3GSCxLOS'    : Satellite, channel C, LOS
%       'itur3GSCxNLOS'   : Satellite, channel C, NLOS
% 
%   ITU-R HF channel models: ITU-R F.1487 (2000)
%   Note: FD must be 1 to obtain the correct frequency spreads for these models.
%       'iturHFLQ'      : Low latitudes, Quiet conditions
%       'iturHFLM'      : Low latitudes, Moderate conditions
%       'iturHFLD'      : Low latitudes, Disturbed conditions
%       'iturHFMQ'      : Medium latitudes, Quiet conditions
%       'iturHFMM'      : Medium latitudes, Moderate conditions
%       'iturHFMD'      : Medium latitudes, Disturbed conditions
%       'iturHFMDV'     : Medium latitudes, Disturbed conditions near
%                         vertical incidence
%       'iturHFHQ'      : High latitudes, Quiet conditions
%       'iturHFHM'      : High latitudes, Moderate conditions
%       'iturHFHD'      : High latitudes, Disturbed conditions
%
%   JTC channel models: 
%       'jtcInResA'        : Indoor residential A
%       'jtcInResB'        : Indoor residential B
%       'jtcInResC'        : Indoor residential C
%       'jtcInOffA'        : Indoor office A
%       'jtcInOffB'        : Indoor office B
%       'jtcInOffC'        : Indoor office C
%       'jtcInComA'        : Indoor commercial A
%       'jtcInComB'        : Indoor commercial B
%       'jtcInComC'        : Indoor commercial C
%       'jtcOutUrbHRLAA'   : Outdoor urban high-rise areas - Low antenna A
%       'jtcOutUrbHRLAB'   : Outdoor urban high-rise areas - Low antenna B
%       'jtcOutUrbHRLAC'   : Outdoor urban high-rise areas - Low antenna C
%       'jtcOutUrbLRLAA'   : Outdoor urban low-rise areas - Low antenna A
%       'jtcOutUrbLRLAB'   : Outdoor urban low-rise areas - Low antenna B
%       'jtcOutUrbLRLAC'   : Outdoor urban low-rise areas - Low antenna C
%       'jtcOutResLAA'     : Outdoor residential areas - Low antenna A
%       'jtcOutResLAB'     : Outdoor residential areas - Low antenna B
%       'jtcOutResLAC'     : Outdoor residential areas - Low antenna C
%       'jtcOutUrbHRHAA'   : Outdoor urban high-rise areas - High antenna A
%       'jtcOutUrbHRHAB'   : Outdoor urban high-rise areas - High antenna B
%       'jtcOutUrbHRHAC'   : Outdoor urban high-rise areas - High antenna C
%       'jtcOutUrbLRHAA'   : Outdoor urban low-rise areas - High antenna A
%       'jtcOutUrbLRHAB'   : Outdoor urban low-rise areas - High antenna B
%       'jtcOutUrbLRHAC'   : Outdoor urban low-rise areas - High antenna C
%       'jtcOutResHAA'     : Outdoor residential areas - High antenna A
%       'jtcOutResHAB'     : Outdoor residential areas - High antenna B
%       'jtcOutResHAC'     : Outdoor residential areas - High antenna C
%
%   HIPERLAN/2 channel models:
%       'hiperlan2A'    : Model A
%       'hiperlan2B'    : Model B
%       'hiperlan2C'    : Model C
%       'hiperlan2D'    : Model D
%       'hiperlan2E'    : Model E
%
%   802.11a/b/g channel models (share a common multipath delay profile):
%   Note: TS should not be larger than TRMS/2, as per 802.11 specifications. 
%       '802.11a'
%       '802.11b'
%       '802.11g'
%
%   Example:   
%       ts = 0.1e-4; fd = 200;
%       chan = stdchan(ts, fd, 'cost207TUx6');
%       chan.NormalizePathGains = 1;
%       chan.StoreHistory = 1;
%       y = filter(chan, ones(1,5e4));
%       plot(chan);
%
%   See also RAYLEIGHCHAN, RICIANCHAN, DOPPLER, DOPPLER/TYPES.

%   References:
%       [1] COST 207, "Digital land mobile radio communications", Office
%           for Official Publications of the European Communities, Final report,
%           Luxembourg, 1989.
%       [2] 3GPP TS 45.005 V7.9.0 (2007-2): 3rd Generation Partnership Project; 
%           Technical Specification Group GSM/EDGE Radio Access
%           Network; Radio transmission and reception (Release 7).
%       [3] 3GPP TS 05.05 V8.20.0 (2005-11): 3rd Generation Partnership Project;
%           Technical Specification Group GSM/EDGE Radio Access
%           Network; Radio transmission and reception (Release 1999).
%       [4] 3GPP TR 25.943 V6.0.0 (2004-12): 3rd Generation Partnership Project;
%           Technical Specification Group Radio Access Network;
%           Deployment aspects (Release 6).
%       [5] Recommendation ITU-R M.1225, "Guidelines for evaluation of radio 
%           transmission technologies for IMT-2000", 1997.
%       [6] Recommendation ITU-R F.1487, "Testing of HF modems with bandwidths
%           of up to about 12 kHz using ionospheric channel simulators", 2000.
%       [7] K. Pahlavan and A. Levesque, Wireless Information Networks,
%           Wiley-Interscience, New York, 1995.
%       [8] J. Medbo and P. Schramm, "Channel Models for HIPERLAN/2 in Different
%           Indoor Scenarios", ETSI/BRAN doc. no. 3ERI085B, 30 March 1998.
%       [9] N. Chayat, "Criteria for Comparison of 5 GHz High Speed PHY
%           Proposals", IEEE P802.11-97/96r2, Nov. 1997.
%       [10] J. Fakatselis, "Criteria for 2.4 GHz PHY Comparison of
%           Modulation Methods", IEEE P802.11-97/157r1, Nov. 1997.
%       [11] M. B. Shoemake, "TGg Comparison Criteria", IEEE 802.11-00/211r9, 
%            Sep. 2000.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:57:45 $ 

% Error checking

if nargin<3
    error('comm:stdchan:inputarguments', ...
        'STDCHAN requires three input arguments.');
end

if ( ~isnumeric(ts) || ~isscalar(ts) || ~isreal(ts) || ts<=0 ...
        || isinf(ts) || isnan(ts) )
    error('comm:stdchan:ts', ...
        'TS must be a strictly positive real finite scalar.');
end    

if ( ~isnumeric(fd) || ~isscalar(fd) || ~isreal(fd) || fd<0 ...
        || isinf(fd) || isnan(fd) )
    error('comm:stdchan:fd', ...
        'FD must be a non-negative real finite scalar.');
end 

if ( ~ischar(chantype) )
    error('comm:stdchan:chantype', ...
        'CHANTYPE must be a string chosen from the set of supported channel profiles.');
end  

c80211_channels = {'802.11a', '802.11b', '802.11g'};

if ismember(lower(chantype), c80211_channels)
    % Error checking for 802.11 channels
    if nargin~=4
        error('comm:stdchan:inputarguments80211', ...
        'STDCHAN requires four input arguments for the 802.11 channels.');
    end
    trms = varargin{1};
    if ( ~isnumeric(trms) || ~isscalar(trms) || ~isreal(trms) || trms<0 ...
        || isinf(trms) || isnan(trms) )
        error('comm:stdchan:trms', ...
            'TRMS must be a non-negative real finite scalar.');
    end
    if ts>trms/2
        warning('comm:stdchan:trms_ts', ...
            'TS should not be larger than TRMS/2, as per 802.11 specifications.');
    end    
else
    if nargin~=3
        error('comm:stdchan:inputarguments', ...
        'STDCHAN requires three input arguments.');
    end
    % Error checking for HF channels
    hf_channels = {'iturhflq', 'iturhflm', 'iturhfld', 'iturhfmq', 'iturhfmm', ...
               'iturhfmd', 'iturhfmdv', 'iturhfhq', 'iturhfhm', 'iturhfhd'};
    if ismember(lower(chantype), hf_channels) && (fd ~= 1)
    error('comm:stdchan:hffd', ...
        'For the HF channel models, FD must be 1 to obtain the correct frequency spreads.');
    end
end    

% CLASS (Jakes) Doppler object
dj = doppler.jakes;

% GAUS1 (bi-Gaussian) Doppler object
dg1 = doppler.bigaussian;
dg1.CenterFreqGaussian1 = -0.8;
dg1.CenterFreqGaussian2 = 0.4;
dg1.SigmaGaussian1 = 0.05;
dg1.SigmaGaussian2 = 0.1;
dg1.GainGaussian1 = sqrt(2*pi*(dg1.SigmaGaussian1)^2);
dg1.GainGaussian2 = 1/10 * sqrt(2*pi*(dg1.SigmaGaussian2)^2);

% GAUS2 (bi-Gaussian) Doppler object
dg2 = doppler.bigaussian;
dg2.CenterFreqGaussian1 = 0.7;
dg2.CenterFreqGaussian2 = -0.4;
dg2.SigmaGaussian1 = 0.1;
dg2.SigmaGaussian2 = 0.15;
dg2.GainGaussian1 = sqrt(2*pi*(dg1.SigmaGaussian1)^2);
dg2.GainGaussian2 = 1/10^1.5 * sqrt(2*pi*(dg1.SigmaGaussian2)^2);

% Flat Doppler object
df = doppler.flat;

switch lower(chantype)
    
    % COST 207
    case 'cost207rax4'
        % Rural Area, 4 taps
        cost207RAx4.ChannelType = 'Rician';
        cost207RAx4.PathDelays = [0.0 0.2 0.4 0.6] * 1e-6;
        cost207RAx4.AvgPathGaindB = [0 -2 -10 -20];
        cost207RAx4.DopplerSpectrum = [dj dj dj dj];
        cost207RAx4.KFactor = 0.87/0.13;
        cost207RAx4.DirectPathDopplerShift = 0.7 * fd;
        channel_profile = cost207RAx4;
    case 'cost207rax6'
        % Rural Area, 6 taps
        cost207RAx6.ChannelType = 'Rician';
        cost207RAx6.PathDelays = [0.0 0.1 0.2 0.3 0.4 0.5] * 1e-6;
        cost207RAx6.AvgPathGaindB = [0 -4 -8 -12 -16 -20];
        cost207RAx6.DopplerSpectrum = [dj dj dj dj dj dj];
        cost207RAx6.KFactor = 0.83/0.17;
        cost207RAx6.DirectPathDopplerShift = 0.7 * fd;
        channel_profile = cost207RAx6;
    case 'cost207tux6'
        % Typical Urban, 6 taps
        cost207TUx6.ChannelType = 'Rayleigh';
        cost207TUx6.PathDelays = [0.0 0.2 0.6 1.6 2.4 5.0] * 1e-6;
        cost207TUx6.AvgPathGaindB = [-3 0 -2 -6 -8 -10];
        cost207TUx6.DopplerSpectrum = [dj dj dg1 dg1 dg2 dg2];
        channel_profile = cost207TUx6;
    case 'cost207tux6alt'
        % Typical Urban, 6 taps, alternative
        cost207TUx6alt.ChannelType = 'Rayleigh';
        cost207TUx6alt.PathDelays = [0.0 0.2 0.5 1.6 2.3 5.0] * 1e-6;
        cost207TUx6alt.AvgPathGaindB = [-3 0 -2 -6 -8 -10];
        cost207TUx6alt.DopplerSpectrum = [dj dj dj dg1 dg2 dg2];
        channel_profile = cost207TUx6alt;
    case 'cost207tux12'
        % Typical Urban, 12 taps
        cost207TUx12.ChannelType = 'Rayleigh';
        cost207TUx12.PathDelays = [0.0 0.2 0.4 0.6 0.8 1.2 1.4 1.8 2.4 3.0 3.2 5.0] * 1e-6;
        cost207TUx12.AvgPathGaindB = [-4 -3 0 -2 -3 -5 -7 -5 -6 -9 -11 -10];
        cost207TUx12.DopplerSpectrum = [dj dj dj dg1 dg1 dg1 dg1 dg1 dg2 dg2 dg2 dg2];
        channel_profile = cost207TUx12;
    case 'cost207tux12alt'
        % Typical Urban, 12 taps, alternative
        cost207TUx12alt.ChannelType = 'Rayleigh';
        cost207TUx12alt.PathDelays = [0.0 0.1 0.3 0.5 0.8 1.1 1.3 1.7 2.3 3.1 3.2 5.0] * 1e-6;
        cost207TUx12alt.AvgPathGaindB = [-4 -3 0 -2.6 -3 -5 -7 -5 -6.5 -8.6 -11 -10];
        cost207TUx12alt.DopplerSpectrum = [dj dj dj dj dg1 dg1 dg1 dg1 dg2 dg2 dg2 dg2];
        channel_profile = cost207TUx12alt;
    case 'cost207bux6'
        % Bad Urban, 6 taps
        cost207BUx6.ChannelType = 'Rayleigh';
        cost207BUx6.PathDelays = [0.0 0.4 1.0 1.6 5.0 6.6] * 1e-6;
        cost207BUx6.AvgPathGaindB = [-3 0 -3 -5 -2 -4];
        cost207BUx6.DopplerSpectrum = [dj dj dg1 dg1 dg2 dg2];
        channel_profile = cost207BUx6;
    case 'cost207bux6alt'
        % Bad Urban, 6 taps, alternative
        cost207BUx6alt.ChannelType = 'Rayleigh';
        cost207BUx6alt.PathDelays = [0.0 0.3 1.0 1.6 5.0 6.6] * 1e-6;
        cost207BUx6alt.AvgPathGaindB = [-2.5 0 -3 -5 -2 -4];
        cost207BUx6alt.DopplerSpectrum = [dj dj dg1 dg1 dg2 dg2];
        channel_profile = cost207BUx6alt;            
    case 'cost207bux12'
        % Bad Urban, 12 taps
        cost207BUx12.ChannelType = 'Rayleigh';
        cost207BUx12.PathDelays = [0.0 0.2 0.4 0.8 1.6 2.2 3.2 5.0 6.0 7.2 8.2 10.0] * 1e-6;
        cost207BUx12.AvgPathGaindB = [-7 -3 -1 0 -2 -6 -7 -1 -2 -7 -10 -15];
        cost207BUx12.DopplerSpectrum = [dj dj dj dg1 dg1 dg2 dg2 dg2 dg2 dg2 dg2 dg2];
        channel_profile = cost207BUx12;
    case 'cost207bux12alt'
        % Bad Urban, 12 taps, alternative
        cost207BUx12alt.ChannelType = 'Rayleigh';
        cost207BUx12alt.PathDelays = [0.0 0.1 0.3 0.7 1.6 2.2 3.1 5.0 6.0 7.2 8.1 10.0] * 1e-6;
        cost207BUx12alt.AvgPathGaindB = [-7.7 -3.4 -1.3 0 -2.3 -5.6 -7.4 -1.4 -1.6 -6.7 -9.8 -15.1];
        cost207BUx12alt.DopplerSpectrum = [dj dj dj dg1 dg1 dg2 dg2 dg2 dg2 dg2 dg2 dg2];
        channel_profile = cost207BUx12alt;
    case 'cost207htx6'
        % Hilly Terrain, 6 taps
        cost207HTx6.ChannelType = 'Rayleigh';
        cost207HTx6.PathDelays = [0.0 0.2 0.4 0.6 15.0 17.2] * 1e-6;
        cost207HTx6.AvgPathGaindB = [0 -2 -4 -7 -6 -12];
        cost207HTx6.DopplerSpectrum = [dj dj dj dj dg2 dg2];
        channel_profile = cost207HTx6;
    case 'cost207htx6alt'
        % Hilly Terrain, 6 taps, alternative
        cost207HTx6alt.ChannelType = 'Rayleigh';
        cost207HTx6alt.PathDelays = [0.0 0.1 0.3 0.5 15.0 17.2] * 1e-6;
        cost207HTx6alt.AvgPathGaindB = [0 -1.5 -4.5 -7.5 -8.0 -17.7];
        cost207HTx6alt.DopplerSpectrum = [dj dj dj dj dg2 dg2];
        channel_profile = cost207HTx6alt;
    case 'cost207htx12'
        % Hilly Terrain, 12 taps
        cost207HTx12.ChannelType = 'Rayleigh';
        cost207HTx12.PathDelays = [0.0 0.2 0.4 0.6 0.8 2.0 2.4 15.0 15.2 15.8 17.2 20.0] * 1e-6;
        cost207HTx12.AvgPathGaindB = [-10 -8 -6 -4 0 0 -4 -8 -9 -10 -12 -14];
        cost207HTx12.DopplerSpectrum = [dj dj dj dg1 dg1 dg1 dg2 dg2 dg2 dg2 dg2 dg2];
        channel_profile = cost207HTx12;
    case 'cost207htx12alt'
        % Hilly Terrain, 12 taps, alternative
        cost207HTx12alt.ChannelType = 'Rayleigh';
        cost207HTx12alt.PathDelays = [0.0 0.1 0.3 0.5 0.7 1.0 1.3 15.0 15.2 15.7 17.2 20.0] * 1e-6;
        cost207HTx12alt.AvgPathGaindB = [-10 -8 -6 -4 0 0 -4 -8 -9 -10 -12 -14];
        cost207HTx12alt.DopplerSpectrum = [dj dj dj dj dg1 dg1 dg1 dg2 dg2 dg2 dg2 dg2];
        channel_profile = cost207HTx12alt;

    % GSM/EDGE    
    case 'gsmrax6c1'
        % Typical case for rural area (RAx), 6 taps, case 1
        gsmRAx6c1.ChannelType = 'Rician';
        gsmRAx6c1.PathDelays = [0.0 0.1 0.2 0.3 0.4 0.5] * 1e-6;
        gsmRAx6c1.AvgPathGaindB = [0 -4 -8 -12 -16 -20];
        gsmRAx6c1.DopplerSpectrum = dj;
        gsmRAx6c1.KFactor = 0.83/0.17;
        gsmRAx6c1.DirectPathDopplerShift = 0.7 * fd;
        channel_profile = gsmRAx6c1;
    case 'gsmrax4c2'
        % Typical case for rural area (RAx), 4 taps, case 2
        gsmRAx4c2.ChannelType = 'Rician';
        gsmRAx4c2.PathDelays = [0.0 0.2 0.4 0.6] * 1e-6;
        gsmRAx4c2.AvgPathGaindB = [0 -2 -10 -20];
        gsmRAx4c2.DopplerSpectrum = dj;
        gsmRAx4c2.KFactor = 0.87/0.13;
        gsmRAx4c2.DirectPathDopplerShift = 0.7 * fd;
        channel_profile = gsmRAx4c2;
    case 'gsmhtx12c1'
        % Typical case for hilly terrain (HTx), 12 taps, case 1
        gsmHTx12c1.ChannelType = 'Rayleigh';
        gsmHTx12c1.PathDelays = [0.0 0.1 0.3 0.5 0.7 1.0 1.3 15.0 15.2 15.7 17.2 20.0] * 1e-6;
        gsmHTx12c1.AvgPathGaindB = [-10 -8 -6 -4 0 0 -4 -8 -9 -10 -12 -14];
        gsmHTx12c1.DopplerSpectrum = dj;
        channel_profile = gsmHTx12c1;
    case 'gsmhtx12c2'
        % Typical case for hilly terrain (HTx), 12 taps, case 
        gsmHTx12c2.ChannelType = 'Rayleigh';
        gsmHTx12c2.PathDelays = [0.0 0.2 0.4 0.6 0.8 2.0 2.4 15.0 15.2 15.8 17.2 20.0] * 1e-6;
        gsmHTx12c2.AvgPathGaindB = [-10 -8 -6 -4 0 0 -4 -8 -9 -10 -12 -14];
        gsmHTx12c2.DopplerSpectrum = dj;
        channel_profile = gsmHTx12c2;
    case 'gsmhtx6c1'
        % Typical case for hilly terrain (HTx), 6 taps, case 1
        gsmHTx6c1.ChannelType = 'Rayleigh';
        gsmHTx6c1.PathDelays = [0.0 0.1 0.3 0.5 15.0 17.2] * 1e-6;
        gsmHTx6c1.AvgPathGaindB = [0 -1.5 -4.5 -7.5 -8.0 -17.7];
        gsmHTx6c1.DopplerSpectrum = dj;
        channel_profile = gsmHTx6c1;
    case 'gsmhtx6c2'
        % Typical case for hilly terrain (HTx), 6 taps, case 2
        gsmHTx6c2.ChannelType = 'Rayleigh';
        gsmHTx6c2.PathDelays = [0.0 0.2 0.4 0.6 15.0 17.2] * 1e-6;
        gsmHTx6c2.AvgPathGaindB = [0 -2 -4 -7 -6 -12];
        gsmHTx6c2.DopplerSpectrum = dj;
        channel_profile = gsmHTx6c2;
    case 'gsmtux12c1'
        % Typical case for urban area (TUx), 12 taps, case 1
        gsmTUx12c1.ChannelType = 'Rayleigh';
        gsmTUx12c1.PathDelays = [0.0 0.1 0.3 0.5 0.8 1.1 1.3 1.7 2.3 3.1 3.2 5.0] * 1e-6;
        gsmTUx12c1.AvgPathGaindB = [-4 -3 0 -2.6 -3 -5 -7 -5 -6.5 -8.6 -11 -10];
        gsmTUx12c1.DopplerSpectrum = dj;
        channel_profile = gsmTUx12c1;
    case 'gsmtux12c2'
        % Typical case for urban area (TUx), 12 taps, case 2
        gsmTUx12c2.ChannelType = 'Rayleigh';
        gsmTUx12c2.PathDelays = [0.0 0.2 0.4 0.6 0.8 1.2 1.4 1.8 2.4 3.0 3.2 5.0] * 1e-6;
        gsmTUx12c2.AvgPathGaindB = [-4 -3 0 -2 -3 -5 -7 -5 -6 -9 -11 -10];
        gsmTUx12c2.DopplerSpectrum = dj;
        channel_profile = gsmTUx12c2;
    case 'gsmtux6c1'
        % Typical case for urban area (TUx), 6 taps, case 1
        gsmTUx6c1.ChannelType = 'Rayleigh';
        gsmTUx6c1.PathDelays = [0.0 0.2 0.5 1.6 2.3 5.0] * 1e-6;
        gsmTUx6c1.AvgPathGaindB = [-3 0 -2 -6 -8 -10];
        gsmTUx6c1.DopplerSpectrum = dj;
        channel_profile = gsmTUx6c1;
    case 'gsmtux6c2'
        % Typical case for urban area (TUx), 6 taps, case 2
        gsmTUx6c2.ChannelType = 'Rayleigh';
        gsmTUx6c2.PathDelays = [0.0 0.2 0.6 1.6 2.4 5.0] * 1e-6;
        gsmTUx6c2.AvgPathGaindB = [-3 0 -2 -6 -8 -10];
        gsmTUx6c2.DopplerSpectrum = dj;
        channel_profile = gsmTUx6c2;
    case 'gsmeqx6'
        % Profile for equalization test (EQx), 6 taps
        gsmEQx6.ChannelType = 'Rayleigh';
        gsmEQx6.PathDelays = [0.0 3.2 6.4 9.6 12.8 16.0] * 1e-6;
        gsmEQx6.AvgPathGaindB = [0 0 0 0 0 0];
        gsmEQx6.DopplerSpectrum = dj;
        channel_profile = gsmEQx6;
    case 'gsmtix2'
        % Typical case for very small cells (TIx), 2 taps
        gsmTIx2.ChannelType = 'Rayleigh';
        gsmTIx2.PathDelays = [0.0 0.4] * 1e-6;
        gsmTIx2.AvgPathGaindB = [0 0];
        gsmTIx2.DopplerSpectrum = dj;
        channel_profile = gsmTIx2;

    % 3GPP - Deployment    
    case '3gpptux'
        % Typical Urban channel model (TUx)
        c3gppTUx.ChannelType = 'Rayleigh';
        c3gppTUx.PathDelays = [0.0 0.217 0.512 0.514 0.517 0.674 0.882 1.230 1.287 1.311 1.349 1.533 1.535 1.622 1.818 1.836 1.884 1.943 2.048 2.140] * 1e-6;
        c3gppTUx.AvgPathGaindB = [-5.7 -7.6 -10.1 -10.2 -10.2 -11.5 -13.4 -16.3 -16.9 -17.1 -17.4 -19.0 -19.0 -19.8 -21.5 -21.6 -22.1 -22.6 -23.5 -24.3];
        c3gppTUx.DopplerSpectrum = dj;
        channel_profile = c3gppTUx;
    case '3gpprax'
        % Rural Area channel model (RAx)
        c3gppRAx.ChannelType = 'Rician';
        c3gppRAx.PathDelays = [0.0 0.042 0.101 0.129 0.149 0.245 0.312 0.410 0.469 0.528] * 1e-6;
        c3gppRAx.AvgPathGaindB = [-5.2 -6.4 -8.4 -9.3 -10.0 -13.1 -15.3 -18.5 -20.4 -22.4];
        c3gppRAx.DopplerSpectrum = dj;
        c3gppRAx.KFactor = 1e6;
        c3gppRAx.DirectPathDopplerShift = 0.7 * fd;
        channel_profile = c3gppRAx;
    case '3gpphtx'
        % Hilly Terrain channel model (HTx)
        c3gppHTx.ChannelType = 'Rayleigh';
        c3gppHTx.PathDelays = [0.0 0.356 0.441 0.528 0.546 0.609 0.625 0.842 0.916 0.941 15.000 16.172 16.492 16.876 16.882 16.978 17.615 17.827 17.849 18.016] * 1e-6;
        c3gppHTx.AvgPathGaindB = [-3.6 -8.9 -10.2 -11.5 -11.8 -12.7 -13.0 -16.2 -17.3 -17.7 -17.6 -22.7 -24.1 -25.8 -25.8 -26.2 -29.0 -29.9 -30.0 -30.7];
        c3gppHTx.DopplerSpectrum = dj;
        channel_profile = c3gppHTx;
        
    % ITU-R 3G    
    case 'itur3giax'
        % Indoor office, channel A
        itur3GIAx.ChannelType = 'Rayleigh';
        itur3GIAx.PathDelays = [0 50 110 170 290 310] * 1e-9;
        itur3GIAx.AvgPathGaindB = [0 -3.0 -10.0 -18.0 -26.0 -32.0];
        itur3GIAx.DopplerSpectrum = df;
        channel_profile = itur3GIAx;
    case 'itur3gibx'
        % Indoor office, channel B
        itur3GIBx.ChannelType = 'Rayleigh';
        itur3GIBx.PathDelays = [0 100 200 300 500 700] * 1e-9;
        itur3GIBx.AvgPathGaindB = [0 -3.6 -7.2 -10.8 -18.0 -25.2];
        itur3GIBx.DopplerSpectrum = df;
        channel_profile = itur3GIBx;
    case 'itur3gpax'
        % Outdoor to indoor and pedestrian, channel A
        itur3GPAx.ChannelType = 'Rayleigh';
        itur3GPAx.PathDelays = [0 110 190 410] * 1e-9;
        itur3GPAx.AvgPathGaindB = [0 -9.7 -19.2 -22.8];
        itur3GPAx.DopplerSpectrum = dj;
        channel_profile = itur3GPAx;
    case 'itur3gpbx'
        % Outdoor to indoor and pedestrian, channel B
        itur3GPBx.ChannelType = 'Rayleigh';
        itur3GPBx.PathDelays = [0 200 800 1200 2300 3700] * 1e-9;
        itur3GPBx.AvgPathGaindB = [0 -0.9 -4.9 -8.0 -7.8 -23.9];
        itur3GPBx.DopplerSpectrum = dj;
        channel_profile = itur3GPBx;
    case 'itur3gvax'
        % Vehicular - high antenna, channel A
        itur3GVAx.ChannelType = 'Rayleigh';
        itur3GVAx.PathDelays = [0 310 710 1090 1730 2510] * 1e-9;
        itur3GVAx.AvgPathGaindB = [0 -1.0 -9.0 -10.0 -15.0 -20.0];
        itur3GVAx.DopplerSpectrum = dj;
        channel_profile = itur3GVAx;
    case 'itur3gvbx'
        % Vehicular - high antenna, channel B
        itur3GVBx.ChannelType = 'Rayleigh';
        itur3GVBx.PathDelays = [0 300 8900 12900 17100 20000] * 1e-9;
        itur3GVBx.AvgPathGaindB = [-2.5 0 -12.8 -10.0 -25.2 -16.0];
        itur3GVBx.DopplerSpectrum = dj;
        channel_profile = itur3GVBx;
    case 'itur3gsaxlos'
        % Satellite, channel A, LOS
        itur3GSAxLOS.ChannelType = 'Rician';
        itur3GSAxLOS.PathDelays = [0 100 180] * 1e-9;
        itur3GSAxLOS.AvgPathGaindB = [0 -23.6 -28.1];
        itur3GSAxLOS.DopplerSpectrum = dj;
        itur3GSAxLOS.KFactor = 10;
        itur3GSAxLOS.DirectPathDopplerShift = 0.0 * fd;
        channel_profile = itur3GSAxLOS;
    case 'itur3gsaxnlos'
        % Satellite, channel A, NLOS
        itur3GSAxNLOS.ChannelType = 'Rayleigh';
        itur3GSAxNLOS.PathDelays = [0 100 180] * 1e-9;
        itur3GSAxNLOS.AvgPathGaindB = [-7.3 -23.6 -28.1];
        itur3GSAxNLOS.DopplerSpectrum = dj;
        channel_profile = itur3GSAxNLOS;
    case 'itur3gsbxlos'
        % Satellite, channel B, LOS
        itur3GSBxLOS.ChannelType = 'Rician';
        itur3GSBxLOS.PathDelays = [0 100 250] * 1e-9;
        itur3GSBxLOS.AvgPathGaindB = [0 -24.1 -25.1];
        itur3GSBxLOS.DopplerSpectrum = dj;
        itur3GSBxLOS.KFactor = 5;
        itur3GSBxLOS.DirectPathDopplerShift = 0.0 * fd;
        channel_profile = itur3GSBxLOS;
    case 'itur3gsbxnlos'
        % Satellite, channel B, NLOS
        itur3GSBxNLOS.ChannelType = 'Rayleigh';
        itur3GSBxNLOS.PathDelays = [0 100 250] * 1e-9;
        itur3GSBxNLOS.AvgPathGaindB = [-9.5 -24.1 -25.1];
        itur3GSBxNLOS.DopplerSpectrum = dj;
        channel_profile = itur3GSBxNLOS;
    case 'itur3gscxlos'
        % Satellite, channel C, LOS
        itur3GSCxLOS.ChannelType = 'Rician';
        itur3GSCxLOS.PathDelays = [0 60 100 130 250] * 1e-9;
        itur3GSCxLOS.AvgPathGaindB = [0 -17.0 -18.3 -19.1 -22.1];
        itur3GSCxLOS.DopplerSpectrum = dj;
        itur3GSCxLOS.KFactor = 2;
        itur3GSCxLOS.DirectPathDopplerShift = 0.0 * fd;
        channel_profile = itur3GSCxLOS;
    case 'itur3gscxnlos'
        % Satellite, channel C, NLOS
        itur3GSCxNLOS.ChannelType = 'Rayleigh';
        itur3GSCxNLOS.PathDelays = [0 60 100 130 250] * 1e-9;
        itur3GSCxNLOS.AvgPathGaindB = [-12.1 -17.0 -18.3 -19.1 -22.1];
        itur3GSCxNLOS.DopplerSpectrum = dj;
        channel_profile = itur3GSCxNLOS;
        
    % ITU-R HF    
    case 'iturhflq'
        % Low latitudes, Quiet conditions
        iturHFLQ.ChannelType = 'Rayleigh';
        iturHFLQ.PathDelays = [0 0.5] * 1e-3;
        iturHFLQ.AvgPathGaindB = [0 0];
        iturHFLQ.DopplerSpectrum = doppler.gaussian(0.5/2);
        channel_profile = iturHFLQ;
    case 'iturhflm'
        % Low latitudes, Moderate conditions
        iturHFLM.ChannelType = 'Rayleigh';
        iturHFLM.PathDelays = [0 2] * 1e-3;
        iturHFLM.AvgPathGaindB = [0 0];
        iturHFLM.DopplerSpectrum = doppler.gaussian(1.5/2);
        channel_profile = iturHFLM;
    case 'iturhfld'
        % Low latitudes, Disturbed conditions
        iturHFLD.ChannelType = 'Rayleigh';
        iturHFLD.PathDelays = [0 6] * 1e-3;
        iturHFLD.AvgPathGaindB = [0 0];
        iturHFLD.DopplerSpectrum = doppler.gaussian(10/2);
        channel_profile = iturHFLD;
    case 'iturhfmq'
        % Mid-latitudes, Quiet conditions
        iturHFMQ.ChannelType = 'Rayleigh';
        iturHFMQ.PathDelays = [0 0.5] * 1e-3;
        iturHFMQ.AvgPathGaindB = [0 0];
        iturHFMQ.DopplerSpectrum = doppler.gaussian(0.1/2);
        channel_profile = iturHFMQ;
    case 'iturhfmm'
        % Mid-latitudes, Moderate conditions
        iturHFMM.ChannelType = 'Rayleigh';
        iturHFMM.PathDelays = [0 1] * 1e-3;
        iturHFMM.AvgPathGaindB = [0 0];
        iturHFMM.DopplerSpectrum = doppler.gaussian(0.5/2);
        channel_profile = iturHFMM;
    case 'iturhfmd'
        % Mid-latitudes, Disturbed conditions
        iturHFMD.ChannelType = 'Rayleigh';
        iturHFMD.PathDelays = [0 2] * 1e-3;
        iturHFMD.AvgPathGaindB = [0 0];
        iturHFMD.DopplerSpectrum = doppler.gaussian(1/2);
        channel_profile = iturHFMD;
    case 'iturhfmdv'
        % Mid-latitudes, Disturbed conditions near vertical incidence
        iturHFMDV.ChannelType = 'Rayleigh';
        iturHFMDV.PathDelays = [0 7] * 1e-3;
        iturHFMDV.AvgPathGaindB = [0 0];
        iturHFMDV.DopplerSpectrum = doppler.gaussian(1/2);
        channel_profile = iturHFMDV;
    case 'iturhfhq'
        % High latitudes, Quiet conditions
        iturHFHQ.ChannelType = 'Rayleigh';
        iturHFHQ.PathDelays = [0 1] * 1e-3;
        iturHFHQ.AvgPathGaindB = [0 0];
        iturHFHQ.DopplerSpectrum = doppler.gaussian(0.5/2);
        channel_profile = iturHFHQ;
    case 'iturhfhm'
        % High latitudes, Moderate conditions
        iturHFHM.ChannelType = 'Rayleigh';
        iturHFHM.PathDelays = [0 3] * 1e-3;
        iturHFHM.AvgPathGaindB = [0 0];
        iturHFHM.DopplerSpectrum = doppler.gaussian(10/2);
        channel_profile = iturHFHM;
    case 'iturhfhd'
        % High latitudes, Disturbed conditions
        iturHFHD.ChannelType = 'Rayleigh';
        iturHFHD.PathDelays = [0 7] * 1e-3;
        iturHFHD.AvgPathGaindB = [0 0];
        iturHFHD.DopplerSpectrum = doppler.gaussian(30/2);
        channel_profile = iturHFHD;
       
    % JTC
    case 'jtcinresa'   
        % Indoor residential A
        jtcInResA.ChannelType = 'Rayleigh';
        jtcInResA.PathDelays = [0 50 100] * 1e-9;
        jtcInResA.AvgPathGaindB = [0 -9.4 -18.9];
        jtcInResA.DopplerSpectrum = df;
        channel_profile = jtcInResA;
    case 'jtcinresb'   
        % Indoor residential B
        jtcInResB.ChannelType = 'Rayleigh';
        jtcInResB.PathDelays = [0 50 100 150 200 250 300 350] * 1e-9;
        jtcInResB.AvgPathGaindB = [0 -2.9 -5.8 -8.7 -11.6 -14.5 -17.4 -20.3];
        jtcInResB.DopplerSpectrum = df;
        channel_profile = jtcInResB;
    case 'jtcinresc'   
        % Indoor residential C
        jtcInResC.ChannelType = 'Rayleigh';
        jtcInResC.PathDelays = [0 50 150 225 400 525 750] * 1e-9;
        jtcInResC.AvgPathGaindB = [-4.6 0 -4.3 -6.5 -3.0 -15.2 -21.7];
        jtcInResC.DopplerSpectrum = df;
        channel_profile = jtcInResC;
        
    case 'jtcinoffa'   
        % Indoor office A
        jtcInOffA.ChannelType = 'Rayleigh';
        jtcInOffA.PathDelays = [0 50 100] * 1e-9;
        jtcInOffA.AvgPathGaindB = [0 -3.6 -7.2];
        jtcInOffA.DopplerSpectrum = df;
        channel_profile = jtcInOffA;        
    case 'jtcinoffb'   
        % Indoor office B
        jtcInOffB.ChannelType = 'Rayleigh';
        jtcInOffB.PathDelays = [0 50 150 325 550 700] * 1e-9;
        jtcInOffB.AvgPathGaindB = [0 -1.6 -4.7 -10.1 -17.1 -21.7];
        jtcInOffB.DopplerSpectrum = df;
        channel_profile = jtcInOffB;               
    case 'jtcinoffc'   
        % Indoor office C
        jtcInOffC.ChannelType = 'Rayleigh';
        jtcInOffC.PathDelays = [0 100 150 500 550 1125 1650 2375] * 1e-9;
        jtcInOffC.AvgPathGaindB = [0 -0.9 -1.4 -2.6 -5.0 -1.2 -10.0 -21.7];
        jtcInOffC.DopplerSpectrum = df;
        channel_profile = jtcInOffC;     
        
     case 'jtcincoma'   
        % Indoor commercial A
        jtcInComA.ChannelType = 'Rayleigh';
        jtcInComA.PathDelays = [0 50 100 150 200] * 1e-9;
        jtcInComA.AvgPathGaindB = [0 -2.9 -5.8 -8.7 -11.6];
        jtcInComA.DopplerSpectrum = df;
        channel_profile = jtcInComA;     
    case 'jtcincomb'   
        % Indoor commercial B
        jtcInComB.ChannelType = 'Rayleigh';
        jtcInComB.PathDelays = [0 50 150 225 400 525 750] * 1e-9;
        jtcInComB.AvgPathGaindB = [-4.6 0 -4.3 -6.5 -3.0 -15.2 -21.7];
        jtcInComB.DopplerSpectrum = df;
        channel_profile = jtcInComB;     
    case 'jtcincomc'   
        % Indoor commercial C
        jtcInComC.ChannelType = 'Rayleigh';
        jtcInComC.PathDelays = [0 50 250 300 550 800 2050 2675] * 1e-9;
        jtcInComC.AvgPathGaindB = [0 -0.4 -6.0 -2.5 -4.5 -1.2 -17.0 -10.0];
        jtcInComC.DopplerSpectrum = df;
        channel_profile = jtcInComC;     

    case 'jtcouturbhrlaa'   
        % Outdoor urban high-rise areas - Low antenna A
        jtcOutUrbHRLAA.ChannelType = 'Rayleigh';
        jtcOutUrbHRLAA.PathDelays = [0 50 150 325 550 700] * 1e-9;
        jtcOutUrbHRLAA.AvgPathGaindB = [0 -1.6 -4.7 -10.1 -17.1 -21.7];
        jtcOutUrbHRLAA.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbHRLAA;     
    case 'jtcouturbhrlab'   
        % Outdoor urban high-rise areas - Low antenna B
        jtcOutUrbHRLAB.ChannelType = 'Rayleigh';
        jtcOutUrbHRLAB.PathDelays = [0 200 250 800 1250 2100 3050 3750] * 1e-9;
        jtcOutUrbHRLAB.AvgPathGaindB = [0 -1.2 -13.0 -4.6 -7.2 -6.0 -13.0 -21.7];
        jtcOutUrbHRLAB.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbHRLAB;     
    case 'jtcouturbhrlac'   
        % Outdoor urban high-rise areas - Low antenna C
        jtcOutUrbHRLAC.ChannelType = 'Rayleigh';
        jtcOutUrbHRLAC.PathDelays = [0 50 500 800 2250 4200 6300 7500 8550 10000] * 1e-9;
        jtcOutUrbHRLAC.AvgPathGaindB = [-9.0 0 -1.1 -11.2 -4.9 -9.1 -9.6 -16.3 -18.6 -21.7];
        jtcOutUrbHRLAC.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbHRLAC;          

    case 'jtcouturblrlaa'   
        % Outdoor urban low-rise areas - Low antenna A
        jtcOutUrbLRLAA.ChannelType = 'Rayleigh';
        jtcOutUrbLRLAA.PathDelays = [0 50 150 325 550 700] * 1e-9;
        jtcOutUrbLRLAA.AvgPathGaindB = [0 -1.6 -4.7 -10.1 -17.1 -21.7];
        jtcOutUrbLRLAA.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbLRLAA; 
    case 'jtcouturblrlab'   
        % Outdoor urban low-rise areas - Low antenna B
        jtcOutUrbLRLAB.ChannelType = 'Rayleigh';
        jtcOutUrbLRLAB.PathDelays = [0 50 200 475 1000 1650 2350 2800 3500 5100] * 1e-9;
        jtcOutUrbLRLAB.AvgPathGaindB = [0 -3.0 -2.6 -1.4 -1.2 -4.8 -5.2 -8.1 -10.1 -14.8];
        jtcOutUrbLRLAB.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbLRLAB; 
    case 'jtcouturblrlac'   
        % Outdoor urban low-rise areas - Low antenna C
        jtcOutUrbLRLAC.ChannelType = 'Rayleigh';
        jtcOutUrbLRLAC.PathDelays = [0 50 500 800 2250 4200 6300 7500 8550 10000] * 1e-9;
        jtcOutUrbLRLAC.AvgPathGaindB = [0 -0.1 -6.0 -1.7 -4.9 -9.1 -13.7 -7.0 -18.6 -21.7];
        jtcOutUrbLRLAC.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbLRLAC; 
        
    case 'jtcoutreslaa'   
        % Outdoor residential areas - Low antenna A
        jtcOutResLAA.ChannelType = 'Rayleigh';
        jtcOutResLAA.PathDelays = [0 50 100 150 200 250 300 350] * 1e-9;
        jtcOutResLAA.AvgPathGaindB = [0 -2.9 -5.8 -8.7 -11.6 -14.5 -17.4 -20.3];
        jtcOutResLAA.DopplerSpectrum = dj;
        channel_profile = jtcOutResLAA; 
    case 'jtcoutreslab'   
        % Outdoor residential areas - Low antenna B
        jtcOutResLAB.ChannelType = 'Rayleigh';
        jtcOutResLAB.PathDelays = [0 50 250 300 550 800 2050 2675] * 1e-9;
        jtcOutResLAB.AvgPathGaindB = [0 -0.4 -6.0 -2.5 -4.5 -1.2 -17.0 -10.0];
        jtcOutResLAB.DopplerSpectrum = dj;
        channel_profile = jtcOutResLAB; 
    case 'jtcoutreslac'   
        % Outdoor residential areas - Low antenna C
        jtcOutResLAC.ChannelType = 'Rayleigh';
        jtcOutResLAC.PathDelays = [0 50 200 475 1000 1650 2350 2800 3500 5100] * 1e-9;
        jtcOutResLAC.AvgPathGaindB = [0 -3.0 -2.6 -1.4 -1.2 -4.8 -5.2 -8.1 -10.1 -14.8];
        jtcOutResLAC.DopplerSpectrum = dj;
        channel_profile = jtcOutResLAC; 


    case 'jtcouturbhrhaa'   
        % Outdoor urban high-rise areas - High antenna A
        jtcOutUrbHRHAA.ChannelType = 'Rayleigh';
        jtcOutUrbHRHAA.PathDelays = [0 50 250 300 550 800 2050 2675] * 1e-9;
        jtcOutUrbHRHAA.AvgPathGaindB = [0 -0.4 -6.0 -2.5 -4.5 -1.2 -17.0 -10.0];
        jtcOutUrbHRHAA.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbHRHAA; 
    case 'jtcouturbhrhab'   
        % Outdoor urban high-rise areas - High antenna B
        jtcOutUrbHRHAB.ChannelType = 'Rayleigh';
        jtcOutUrbHRHAB.PathDelays = [0 50 300 750 1250 5000 8900 13000 17000 20000] * 1e-9;
        jtcOutUrbHRHAB.AvgPathGaindB = [-5.2 -3.0 0 -0.8 -1.4 -4.6 -9.6 -6.0 -18.5 -13.0];
        jtcOutUrbHRHAB.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbHRHAB;
    case 'jtcouturbhrhac'   
        % Outdoor urban high-rise areas - High antenna C
        jtcOutUrbHRHAC.ChannelType = 'Rayleigh';
        jtcOutUrbHRHAC.PathDelays = [0 300 350 750 1250 4000 10000 22000 29000 50000] * 1e-9;
        jtcOutUrbHRHAC.AvgPathGaindB = [-4.6 -0.1 0 -0.3 -0.5 -7.0 -4.3 -4.0 -8.2 -16.0];
        jtcOutUrbHRHAC.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbHRHAC;        
        
    case 'jtcouturblrhaa'   
        % Outdoor urban low-rise areas - High antenna A
        jtcOutUrbLRHAA.ChannelType = 'Rayleigh';
        jtcOutUrbLRHAA.PathDelays = [0 50 200 500 1200 1525 1750] * 1e-9;
        jtcOutUrbLRHAA.AvgPathGaindB = [-3.0 -7.0 0 -6.2 -5.2 -18.9 -21.7];
        jtcOutUrbLRHAA.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbLRHAA; 
     case 'jtcouturblrhab'   
        % Outdoor urban low-rise areas - High antenna B
        jtcOutUrbLRHAB.ChannelType = 'Rayleigh';
        jtcOutUrbLRHAB.PathDelays = [0 300 700 750 1250 5000 8900 15000 21000 25000] * 1e-9;
        jtcOutUrbLRHAB.AvgPathGaindB = [-1.2 -6.0 0 -0.7 -1.1 -5.2 -7.7 -3.0 -18.2 -16.0];
        jtcOutUrbLRHAB.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbLRHAB; 
     case 'jtcouturblrhac'   
        % Outdoor urban low-rise areas - High antenna C
        jtcOutUrbLRHAC.ChannelType = 'Rayleigh';
        jtcOutUrbLRHAC.PathDelays = [0 300 350 750 2250 8000 20000 32000 39000 55000] * 1e-9;
        jtcOutUrbLRHAC.AvgPathGaindB = [-4.6 -0.1 -0.1 -7.0 -0.7 0 -5.8 -7.0 -7.0 -10.0];
        jtcOutUrbLRHAC.DopplerSpectrum = dj;
        channel_profile = jtcOutUrbLRHAC;         

    case 'jtcoutreshaa'   
        % Outdoor residential areas - High antenna A
        jtcOutResHAA.ChannelType = 'Rayleigh';
        jtcOutResHAA.PathDelays = [0 50 150 500 850 1325 1750] * 1e-9;
        jtcOutResHAA.AvgPathGaindB = [-6.0 -3.0 0 -6.7 -1.2 -17.7 -23.4];
        jtcOutResHAA.DopplerSpectrum = dj;
        channel_profile = jtcOutResHAA; 
    case 'jtcoutreshab'   
        % Outdoor residential areas - High antenna B
        jtcOutResHAB.ChannelType = 'Rayleigh';
        jtcOutResHAB.PathDelays = [0 450 500 1050 3250 6000 8300 10000 12050 15000] * 1e-9;
        jtcOutResHAB.AvgPathGaindB = [-6.0 -3.0 0 -1.5 -4.7 -3.0 -12.0 -14.5 -17.4 -21.7];
        jtcOutResHAB.DopplerSpectrum = dj;
        channel_profile = jtcOutResHAB; 
    case 'jtcoutreshac'   
        % Outdoor residential areas - High antenna C
        jtcOutResHAC.ChannelType = 'Rayleigh';
        jtcOutResHAC.PathDelays = [0 300 350 750 1250 4000 10000 22000 29000 50000] * 1e-9;
        jtcOutResHAC.AvgPathGaindB = [-4.6 -0.1 0 -0.3 -0.5 -7.0 -4.3 -4.0 -8.2 -16.0];
        jtcOutResHAC.DopplerSpectrum = dj;
        channel_profile = jtcOutResHAC;         

    % HIPERLAN/2    
    case 'hiperlan2a'
        % Model A
        hiperlan2A.ChannelType = 'Rayleigh';
        hiperlan2A.PathDelays = [0 10 20 30 40 50 60 70 80 90 110 140 170 200 240 290 340 390] * 1e-9;
        hiperlan2A.AvgPathGaindB = [0 -0.9 -1.7 -2.6 -3.5 -4.3 -5.2 -6.1 -6.9 -7.8 -4.7 -7.3 -9.9 -12.5 -13.7 -18.0 -22.4 -26.7];
        hiperlan2A.DopplerSpectrum = dj;
        channel_profile = hiperlan2A;
    case 'hiperlan2b'
        % Model B
        hiperlan2B.ChannelType = 'Rayleigh';
        hiperlan2B.PathDelays = [0 10 20 30 50 80 110 140 180 230 280 330 380 430 490 560 640 730] * 1e-9;
        hiperlan2B.AvgPathGaindB = [-2.6 -3.0 -3.5 -3.9 0.0 -1.3 -2.6 -3.9 -3.4 -5.6 -7.7 -9.9 -12.1 -14.3 -15.4 -18.4 -20.7 -24.6];
        hiperlan2B.DopplerSpectrum = dj;
        channel_profile = hiperlan2B;
    case 'hiperlan2c'
        % Model C
        hiperlan2C.ChannelType = 'Rayleigh';
        hiperlan2C.PathDelays = [0 10 20 30 50 80 110 140 180 230 280 330 400 490 600 730 880 1050] * 1e-9;
        hiperlan2C.AvgPathGaindB = [-3.3 -3.6 -3.9 -4.2 0.0 -0.9 -1.7 -2.6 -1.5 -3.0 -4.4 -5.9 -5.3 -7.9 -9.4 -13.2 -16.3 -21.2];
        hiperlan2C.DopplerSpectrum = dj;
        channel_profile = hiperlan2C;
    case 'hiperlan2d'
        % Model D
        hiperlan2D.ChannelType = 'Rician';
        hiperlan2D.PathDelays = [0 10 20 30 50 80 110 140 180 230 280 330 400 490 600 730 880 1050] * 1e-9;
        hiperlan2D.AvgPathGaindB = [0 -10.0 -10.3 -10.6 -6.4 -7.2 -8.1 -9.0 -7.9 -9.4 -10.8 -12.3 -11.7 -14.3 -15.8 -19.6 -22.7 -27.6];
        hiperlan2D.DopplerSpectrum = dj;
        hiperlan2D.KFactor = 10;
        hiperlan2D.DirectPathDopplerShift = 0.0 * fd;
        channel_profile = hiperlan2D;
    case 'hiperlan2e'
        % Model E
        hiperlan2E.ChannelType = 'Rayleigh';
        hiperlan2E.PathDelays = [0 10 20 40 70 100 140 190 240 320 430 560 710 880 1070 1280 1510 1760] * 1e-9;
        hiperlan2E.AvgPathGaindB = [-4.9 -5.1 -5.2 -0.8 -1.3 -1.9 -0.3 -1.2 -2.1 0.0 -1.9 -2.8 -5.4 -7.3 -10.6 -13.4 -17.4 -20.9];
        hiperlan2E.DopplerSpectrum = dj;
        channel_profile = hiperlan2E;
        
    % 802.11a / 802.11b / 802.11g   
    case {'802.11a', '802.11b', '802.11g'}
        kmax = ceil(10*trms/ts);
        omega0 = ( 1-exp(-ts/trms) )/( 1-exp(-(kmax+1)*ts/trms) );
        c80211.ChannelType = 'Rayleigh';
        c80211.PathDelays = (0:1:kmax)*ts;
        c80211.AvgPathGaindB = 10*log10( omega0*exp(-(0:1:kmax)*ts/trms) );
        c80211.DopplerSpectrum = dj;
        channel_profile = c80211;
        
    otherwise
        error('comm:stdchan:chantype', ...
            'CHANTYPE must be chosen from the set of supported channel profiles.');    
end


channelType = channel_profile.ChannelType;
tau = channel_profile.PathDelays;
pdb = channel_profile.AvgPathGaindB;

if strcmp(channelType, 'Rayleigh')
    % Creation of Rayleigh channel object
    chan = rayleighchan(ts, fd, tau, pdb);
elseif strcmp(channelType, 'Rician')
    % Creation of Rician channel object
    k = channel_profile.KFactor;
    fdLOS = channel_profile.DirectPathDopplerShift;
    chan = ricianchan(ts, fd, k, tau, pdb, fdLOS);
end

chan.DopplerSpectrum = channel_profile.DopplerSpectrum;


