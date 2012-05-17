function sysOut = frd(varargin)
   %FRD  Constructs or converts to Frequency Response Data model.
   %
   %   Frequency Response Data (FRD) models store the frequency response of
   %   LTI systems, for example, experimental data collected with a frequency
   %   analyzer.
   %
   %  Construction:
   %    SYS = FRD(RESPONSE,FREQS) creates an FRD model SYS with response data
   %    RESPONSE specified at the frequency points in FREQS. The output SYS 
   %    is an object of class @frd.
   %
   %    SYS = FRD(RESPONSE,FREQS,TS) creates a discrete-time FRD model with
   %    sampling time TS (a positive value).
   %
   %    SYS = FRD creates an empty FRD model.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = frd(1:10,1:10,'FrequencyUnit','Hz')
   %    further specifies that the frequency vector is given in Hz. Type 
   %    "properties(frd)" for a complete list of model properties, and type 
   %       help frd.<PropertyName>
   %    for help on a particular property. For example, "help frd.ioDelay" 
   %    provides information about the "ioDelay" property.
   %
   %  Data format:
   %    For SISO models, FREQS is a vector of real frequencies, and RESPONSE 
   %    is a vector of frequency response values at these frequencies.
   %
   %    For MIMO FRD models with NY outputs, NU inputs, and NF frequency points,
   %    RESPONSE is a double array of size [NY NU NF] where RESPONSE(i,j,k) 
   %    specifies the frequency response from input j to output i at the 
   %    frequency point FREQS(k).
   %
   %    By default, FRD assumes that the frequencies FREQS are specified in 
   %    'rad/s'. To specify frequencies in Hz, set the "FrequencyUnit" property 
   %    to 'Hz'. To change the frequency unit from rad/s to Hz and convert
   %    the frequency values accordingly, use CHGUNITS.
   %
   %  Arrays of FRD models:
   %    You can create arrays of FRD models by using an ND array for RESPONSE.
   %    For example, if RESPONSE is an array of size [NY NU NF 3 4], then
   %       SYS = FRD(RESPONSE,FREQS)
   %    creates the 3-by-4 array of FRD models, where
   %       SYS(:,:,k,m) = FRD(RESPONSE(:,:,:,k,m),FREQS),  k=1:3,  m=1:4.
   %    Each of these FRD models has NY outputs, NU inputs, and data at
   %    the frequencies FREQS.
   %
   %  Conversion:
   %    SYS = FRD(SYS,FREQS,UNIT) converts any dynamic system SYS to the FRD
   %    representation by computing the system response at each frequency
   %    point in the vector FREQS.  The frequencies FREQS are expressed in
   %    the unit specified by the string UNIT ('rad/s' or 'Hz'). The default
   %    is 'rad/s' if UNIT is omitted. The resulting SYS is of class @frd.
   %
   %  See also FRDATA, CHGUNITS, TF, ZPK, SS, DYNAMICSYSTEM.

%   Author(s): S. Almy
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:39 $
try
   [ConstructFlag,InputList] = lti.parseConvertFcnInputs('frd',varargin);
   if ConstructFlag
      % FRD(R,W,LTISYS): Try again with LTI system replaced by struct
      sysOut = frd(InputList{:});
   else
      % Left with FRD(SYS,FREQ,UNIT)
      [sys,w,unit] = FRDModel.parseFRDInputs('frd',InputList);
      sysOut = copyMetaData(sys,frd_(sys,w,unit));
   end
catch E
   throw(E)
end
