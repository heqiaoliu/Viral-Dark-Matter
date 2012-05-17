function sysOut = zpk(varargin)
   %ZPK  Constructs zero-pole-gain model or converts to zero-pole-gain format.
   %
   %  Construction:
   %    SYS = ZPK(Z,P,K) creates a continuous-time zero-pole-gain (ZPK) model 
   %    SYS with zeros Z, poles P, and gains K. SYS is an object of class @zpk.
   %
   %    SYS = ZPK(Z,P,K,Ts) creates a discrete-time ZPK model with sampling
   %    time Ts (set Ts=-1 if the sampling time is undetermined).
   %
   %    S = ZPK('s') specifies H(s) = s (Laplace variable).
   %    Z = ZPK('z',TS) specifies H(z) = z with sample time TS.
   %    You can then specify ZPK models directly as expressions in S or Z, 
   %    for example,
   %       z = zpk('z',0.1);  H = (z+.1)*(z+.2)/(z^2+.6*z+.09)
   %
   %    SYS = ZPK creates an empty zero-pole-gain model.
   %    SYS = ZPK(D) specifies a static gain matrix D.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = zpk(1,2,3,'Variable','p','DisplayFormat','freq')
   %    also sets the variable and display format. Type "properties(zpk)" 
   %    for a complete list of model properties, and type 
   %       help zpk.<PropertyName>
   %    for help on a particular property. For example, "help zpk.ioDelay" 
   %    provides information about the "ioDelay" property.
   %
   %  Data format:
   %    For SISO models, Z and P are the vectors of zeros and poles (set
   %    Z=[] when there are no zeros) and K is the scalar gain.
   %
   %    For MIMO systems with NY outputs and NU inputs,
   %      * Z and P are NY-by-NU cell arrays where Z{i,j} and P{i,j}
   %        specify the zeros and poles of the transfer function from
   %        input j to output i
   %      * K is the 2D matrix of gains for each I/O channel.
   %    For example,
   %       H = zpk( {[];[2 3]} , {1;[0 -1]} , [-5;1] )
   %    specifies the two-output, one-input ZPK model
   %       [    -5 /(s-1)      ]
   %       [ (s-2)(s-3)/s(s+1) ]
   %
   %  Arrays of zero-pole-gain models:
   %    You can create arrays of ZPK models by using ND cell arrays for Z,P
   %    and a ND double array for K. For example, if Z,P,K are 3D arrays
   %    of size [NY NU 5], then
   %       SYS = ZPK(Z,P,K)
   %    creates the 5-by-1 array of ZPK models
   %       SYS(:,:,m) = ZPK(Z(:,:,m),P(:,:,m),K(:,:,m)),   m=1:5.
   %    Each of these models has NY outputs and NU inputs.
   %
   %    To pre-allocate an array of zero ZPK models with NY outputs and NU
   %    inputs, use the syntax
   %       SYS = ZPK(ZEROS([NY NU k1 k2...])) .
   %
   %  Conversion:
   %    SYS = ZPK(SYS) converts any dynamic system SYS to the ZPK
   %    representation. The resulting SYS is of class @zpk.
   %
   %  See also ZPK/EXP, ZPKDATA, ZPK, SS, FRD, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:16 $
try
   ni = nargin;
   [ConstructFlag,InputList] = lti.parseConvertFcnInputs('zpk',varargin);
   if ConstructFlag
      % ZPK(z,p,k,ZPKSYS): Try again with system replaced by struct
      sysOut = zpk(InputList{:});
   elseif ni>2 || (ni==2 && ~ischar(varargin{2}))
      % Invalid syntax
      ctrlMsgUtils.error('Control:transformation:InvalidConversionSyntax','zpk','zpk')
   else
      sys = InputList{1};
      if isa(sys,'FRDModel')
         ctrlMsgUtils.error('Control:transformation:zpk2',class(sys))
      end
      % Inherit metadata and Variable
      sysOut = copyMetaData(sys,zpk_(sys));
      sysOut = copyVariable(sys,sysOut);
   end
catch E
   throw(E)
end

