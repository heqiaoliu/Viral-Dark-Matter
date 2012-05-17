function sysOut = tf(varargin)
   %TF  Constructs transfer function or converts to transfer function.
   %
   %  Construction:
   %    SYS = TF(NUM,DEN) creates a continuous-time transfer function SYS with
   %    numerator NUM and denominator DEN. SYS is an object of class @tf.
   %
   %    SYS = TF(NUM,DEN,TS) creates a discrete-time transfer function with
   %    sampling time TS (set TS=-1 if the sampling time is undetermined).
   %
   %    S = TF('s') specifies the transfer function H(s) = s (Laplace variable).
   %    Z = TF('z',TS) specifies H(z) = z with sample time TS.
   %    You can then specify transfer functions directly as expressions in S
   %    or Z, for example,
   %       s = tf('s');  H = exp(-s)*(s+1)/(s^2+3*s+1)
   %
   %    SYS = TF creates an empty TF object.
   %    SYS = TF(M) specifies a static gain matrix M.
   %
   %    You can set additional model properties by using name/value pairs.
   %    For example,
   %       sys = tf(1,[1 2 5],0.1,'Variable','q','ioDelay',3)
   %    also sets the variable and transport delay. Type "properties(tf)" 
   %    for a complete list of model properties, and type 
   %       help tf.<PropertyName>
   %    for help on a particular property. For example, "help tf.Variable" 
   %    provides information about the "Variable" property.
   %
   %    By default, transfer functions are displayed as functions of 's' or 
   %    'z'. Alternatively, you can use the variable 'p' in continuous time 
   %    and the variables 'z^-1' or 'q' in discrete time by modifying the  
   %    "Variable" property.
   %
   %  Data format:
   %    For SISO models, NUM and DEN are row vectors listing the numerator 
   %    and denominator coefficients in descending powers of s,p,z,q or in
   %    ascending powers of z^-1 (DSP convention). For example, 
   %       sys = tf([1 2],[1 0 10])
   %    specifies the transfer function (s+2)/(s^2+10) while 
   %       sys = tf([1 2],[1 5 10],0.1,'Variable','z^-1')
   %    specifies (1 + 2 z^-1)/(1 + 5 z^-1 + 10 z^-2).
   %
   %    For MIMO models with NY outputs and NU inputs, NUM and DEN are 
   %    NY-by-NU cell arrays of row vectors where NUM{i,j} and DEN{i,j} 
   %    specify the transfer function from input j to output i. For example,
   %       H = tf( {-5 ; [1 -5 6]} , {[1 -1] ; [1 1 0]})
   %    specifies the two-output, one-input transfer function
   %       [     -5 /(s-1)      ]
   %       [ (s^2-5s+6)/(s^2+s) ]
   %
   %  Arrays of transfer functions:
   %    You can create arrays of transfer functions by using ND cell arrays 
   %    for NUM and DEN above. For example, if NUM and DEN are cell arrays 
   %    of size [NY NU 3 4], then
   %       SYS = TF(NUM,DEN)
   %    creates the 3-by-4 array of transfer functions
   %       SYS(:,:,k,m) = TF(NUM(:,:,k,m),DEN(:,:,k,m)),  k=1:3,  m=1:4.
   %    Each of these transfer functions has NY outputs and NU inputs.
   %
   %    To pre-allocate an array of zero transfer functions with NY outputs
   %    and NU inputs, use the syntax
   %       SYS = TF(ZEROS([NY NU k1 k2...])) .
   %
   %  Conversion:
   %    SYS = TF(SYS) converts any dynamic system SYS to the transfer
   %    function representation. The resulting SYS is of class @tf.
   %
   %  See also TF/EXP, FILT, TFDATA, ZPK, SS, FRD, DYNAMICSYSTEM.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:09 $
try
   ni = nargin;
   [ConstructFlag,InputList] = lti.parseConvertFcnInputs('tf',varargin);
   if ConstructFlag
      % TF(num,den,TFSYS): Try again with system replaced by struct
      sysOut = tf(InputList{:});
   elseif ni>2 || (ni==2 && ~ischar(varargin{2}))
      % Invalid syntax
      ctrlMsgUtils.error('Control:transformation:InvalidConversionSyntax','tf','tf')
   else
      sys = InputList{1};
      if isa(sys,'FRDModel')
         ctrlMsgUtils.error('Control:transformation:tf2',class(sys))
      end
      % Inherit metadata and Variable
      sysOut = copyMetaData(sys,tf_(sys));
      sysOut = copyVariable(sys,sysOut);
   end
catch E
   throw(E)
end
