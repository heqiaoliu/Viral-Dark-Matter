classdef FRDModel < DynamicSystem
   % Frequency Response Data Model objects.
   %
   %   Frequency Response Data (FRD) models are frequency-domain models
   %   that describe the behavior of a dynamic system in terms of its 
   %   input/output frequency response. FRD models are useful to manipulate
   %   experimental data collected from a frequency analyzer and you can use
   %   them as surrogates for TF or SS models when designing control systems
   %   in the frequency domain.
   %
   %   All FRD model types derive from the @FRDModel superclass. This class 
   %   is not user-facing and cannot be instantiated. Use the @frd class to
   %   construct FRD models.
   %
   %   See also FRD.
   
%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:18 $
   
   % Abstract properties: Frequency and FrequencyUnit
   
   %%%%%%%%%%%%%%% PROTECTED INTERFACE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % TO BE IMPLEMENTED BY ALL SUBCLASSES
   methods (Abstract, Access = protected)
      sys = chgunits_(sys,newUnits)
      sys = frdfun_(sys,fhandle)
      sys = fselect_(sys,index)
      sys = fdel_(sys,ind2remove)
      sys = fcat_(sys,sys2)
   end
   
   % TO BE OPTIONALLY IMPLEMENTED BY SUBCLASSES
   methods (Access = protected)
      sysfn = fnorm_(sys,ntype)
   end
   
   %%%%%%%%%%%%%%%%% END PROTECTED INTERFACE %%%%%%%%%%%%%%%%%%%%%%

   
   % PUBLIC FRD METHODS
   methods
      
      function sys = chgunits(sys,newUnits)
         %CHGUNITS  Change frequency unit in FRD models.
         %
         %   SYS = CHGUNITS(SYS,UNIT) changes the unit of the frequency
         %   points stored in the FRD model SYS to UNIT, where UNIT
         %   is either 'Hz or 'rad/s'.  A 2*pi scaling factor is applied
         %   to the frequency values and the 'FrequencyUnit' property is 
         %   updated.
         %
         %   See also FRD.
         newUnits = ltipack.matchKey(newUnits,{'rad/s','Hz'});
         if isempty(newUnits)
            ctrlMsgUtils.error('Control:ltiobject:chgunits1')
         elseif ~strncmp(sys.FrequencyUnit,newUnits,1)
            % Apply unit change if necessary
            sys = chgunits_(sys,newUnits);
         end
      end
            
      
      function sys = fselect(sys,varargin)
         %FSELECT  Selects frequency points or range in FRD model.
         %
         %   SUBSYS = FSELECT(SYS,FMIN,FMAX) takes an FRD model SYS
         %   and selects the portion of the frequency response
         %   between the frequencies FMIN and FMAX.  The selected
         %   range [FMIN,FMAX] should be expressed in the FRD model
         %   units.
         %
         %   SUBSYS = FSELECT(SYS,INDEX) selects the frequency points
         %   specified by the vector of indices INDEX.  The resulting
         %   frequency grid is SYS.Frequency(INDEX).
         %
         %   See also FRD/INTERP, FCAT, FRD.
         ni = nargin;
         if ni<2
            ctrlMsgUtils.error('Control:general:TwoOrMoreInputsRequired','fselect','fselect')
         end
         
         % Check frequency range specification
         freqs = sys.Frequency;
         if ni>2
            index = find(freqs>=varargin{1} & freqs<=varargin{2});
         else
            index = varargin{1};
            if islogical(index)
               index = find(index);
            end
            if any(index<1 | index~=round(index))
               ctrlMsgUtils.error('Control:transformation:fselect2')
            elseif any(index>length(freqs))
               ctrlMsgUtils.error('Control:transformation:fselect1')
            elseif any(diff(index)<=0)
               ctrlMsgUtils.error('Control:transformation:fselect2')
            end
         end
         
         % Extract requested portion of the data
         sys = fselect_(sys,index);
      end
      
      
      function sys = fdel(sys,freq2remove)
         %FDEL  Removes specific frequencies from FRD model.
         %
         %   SYS = FDEL(SYS1,FREQ) removes the frequency points nearest to the
         %   values specified in the vector FREQ from the FRD model SYS1. The output
         %   SYS is the FRD model containing the remaining frequency points. The
         %   frequencies FREQ should be expressed in the FRD model units.
         %
         %   To select frequencies in a particular range, use FSELECT rather than FDEL.
         %
         %   See also FSELECT, FCAT, FRD.

         % Check number of input & output arguments
         error(nargchk(2,2,nargin));
         freqs = sys.Frequency;
         N = numel(freqs);
         
         % Get the set of closest frequencies
         ind2remove = round(utInterp1(freqs,1:N,freq2remove));
         ind2remove(freq2remove < freqs(1)) = 1;
         ind2remove(freq2remove > freqs(N)) = N;
         
         % Remove specified portion of the data
         sys = fdel_(sys,ind2remove);
      end     
      
      function sys = abs(sys)
         %ABS  Frequency response magnitude for FRD models.
         %
         %   ABSFRD = ABS(SYS) computes the magnitude of the frequency
         %   response contained in the FRD model SYS.  For MIMO models,
         %   the magnitude is computed for each entry.  The output ABSFRD
         %   is an FRD model containing the magnitude data across
         %   frequencies.
         %
         %   See also BODEMAG, SIGMA, FRDMODEL/REAL, FRDMODEL/IMAG, FNORM.
         try
            sys = frdfun_(sys,@abs);
         catch ME
            ltipack.throw(ME,'command','abs',class(sys))
         end
         sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
      end
      
      function sys = real(sys)
         %REAL  Real part of frequency response for FRD models.
         %
         %   REALFRD = REAL(SYS) computes the real part of the frequency
         %   response contained in the FRD model SYS, including the
         %   contribution of input, output, and I/O delays.  The output
         %   REALFRD is an FRD object containing the values of the real
         %   part across frequencies.
         %
         %   See also FRDMODEL/IMAG, FRDMODEL/ABS.
         try
            sys = frdfun_(sys,@real);
         catch ME
            ltipack.throw(ME,'command','abs',class(sys))
         end
         sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
      end
      
      function sys = imag(sys)
         %IMAG  Imaginary part of frequency response for FRD models.
         %
         %   IMAGFRD = IMAG(SYS) computes the imaginary part of the
         %   frequency response contained in the FRD model SYS, including
         %   the contribution of input, output, and I/O delays.  The output
         %   IMAGFRD is an FRD object containing the values of the imaginary
         %   part across frequencies.
         %
         %   See also FRDMODEL/REAL, FRDMODEL/ABS.
         try
            sys = frdfun_(sys,@imag);
         catch ME
            ltipack.throw(ME,'command','abs',class(sys))
         end
         sys.Name_ = [];  sys.Notes_ = [];  sys.UserData = [];
      end
      
      function sysfn = fnorm(sys, ntype)
         %FNORM  Pointwise peak gain of FRD model.
         %
         %   FNRM = FNORM(SYS) computes the pointwise 2-norm of the
         %   frequency response contained in the FRD model SYS, that
         %   is, the peak gain at each frequency point.  The output
         %   FNRM is an FRD object containing the peak gain across
         %   frequencies.
         %
         %   FNRM = FNORM(SYS,NTYPE) computes the frequency response 
         %   gains using the matrix norm specified by NTYPE. See NORM 
         %   for valid matrix norms and corresponding NTYPE values.
         %
         %   See also DYNAMICSYSTEM/NORM, FRDMODEL/ABS.
         if nargin < 2
            ntype = 2;
         elseif ~(isequal(ntype,1) || isequal(ntype,2) || isequal(ntype,Inf) || isequal(ntype,'fro'))
            ctrlMsgUtils.error('Control:analysis:fnorm1');
         end
         try
            sysfn = fnorm_(sys,ntype);
         catch ME
            ltipack.throw(ME,'command','fnorm',class(sys))
         end
      end
      
      function sys = diag(sys)
         %DIAG  Builds diagonal frequency response.
         %
         %   DSYS = DIAG(SYS) takes a vector-valued frequency response
         %   V1,...,Vn and constructs the matrix-valued response
         %   DIAG(V1),...,DIAG(Vn). SYS and DSYS are both FRD models.
         %
         %   See also APPEND, FRD.
         ios = iosize(sys);
         if all(ios~=1)
            ctrlMsgUtils.error('Control:combination:diag1');
         end
         % Data
         try
            sys = frdfun_(sys,@diag);
         catch ME
            ltipack.throw(ME,'command','diag',class(sys))
         end
         % Metadata
         if ios(1)~=1
            sys.IOSize_ = ios(:,[1 1]);
         else
            sys.IOSize_ = ios(:,[2 2]);
         end
         sys = resetMetaData(sys);
      end
      
   end
   
   methods (Access = protected)
      
      function [sys1,sys2] = matchFrequency(sys1,sys2)
         % Match frequency vectors and units (skipping empty system arrays
         % since sys.Frequency is always [])
         if nmodels(sys1)>0 && nmodels(sys2)>0
            Unit1 = sys1.FrequencyUnit;
            Unit2 = sys2.FrequencyUnit;
            [freqs,unit] = FRDModel.mrgfreq(sys1.Frequency,Unit1,sys2.Frequency,Unit2);
            if ~strcmp(Unit1,unit)
               sys1.Frequency = freqs;  sys1.FrequencyUnit = unit;
            end
            if ~strcmp(Unit2,unit)
               sys2.Frequency = freqs;  sys2.FrequencyUnit = unit;
            end
         end
      end

      function varargout = matchFrequencyN(varargin)
         % Match frequency vectors and units across N>2 systems (skipping empty
         % system arrays since sys.Frequency is always [])
         varargout = varargin;
         nsys = length(varargin);
         sysUnit = cell(nsys,1);
         unit = '';
         % Determine common frequency vector and units
         for j=1:nsys
            sysj = varargin{j};
            if nmodels(sysj)>0
               unitj = sysj.FrequencyUnit;
               if isempty(unit)
                  freqs = sysj.Frequency;   unit = unitj;
               else
                  [freqs,unit] = FRDModel.mrgfreq(freqs,unit,sysj.Frequency,unitj);
               end
               sysUnit{j} = unitj;
            end
         end
         % Harmonize frequency vectors and units
         for j=1:nsys
            sysj = varargin{j};
            if ~(isempty(sysUnit{j}) || strcmp(sysUnit{j},unit))
               sysj.Frequency = freqs;
               sysj.FrequencyUnit = unit;
               varargout{j} = sysj;
            end
         end
      end
      
   end
   
   
   methods (Static)
      
      [Model,w,unit] = parseFRDInputs(FRDfcn,InputList)
      
      function sys = cast(FRDType,X,refsys)
         % Conversion to FRD type.
         %   SYS = FRDModel.cast(FRDType,X,REFSYS) coerces the variable X to
         %   the specified FRD model type using attributes of the FRD model 
         %   REFSYS such as frequency, frequency units, and sampling time.
         %   This method is a wrapper around the *frd converters to handle
         %   numeric arrays and undefined sampling times.
         f = refsys.Frequency;
         Ts = refsys.Ts;
         if isnumeric(X)
            % Casting numeric array to FRD type
            s = size(X);
            X = repmat(reshape(X,[s(1:2) 1 s(3:end)]),[1 1 length(f)]);
            sys = feval(FRDType,frd(X,f,Ts));
            sys.FrequencyUnit = refsys.FrequencyUnit;
         else
            % Casting static or dynamic model to FRD
            if isa(X,'ltipack.SingleRateSystem') && X.Ts==-1 && (Ts>0 || isstatic(X))
               % Override Ts=-1 before computing frequency response
               X.Ts = Ts;
            end
            sys = feval(FRDType,X,f,refsys.FrequencyUnit);
         end
      end
      
      function [freqs,units] = mrgfreq(freqs1,units1,freqs2,units2)
         % Checks compatibility of frequency vectors, considering units.
         % If either system has units of rad/s, returns frequencies in
         % rad/s, otherwise, return frequencies in Hz.
         reltol = 1e3*eps;
         freqs1 = freqs1(:);
         freqs2 = freqs2(:);
         
         % Unit alignment
         if strcmpi(units1,units2)
            units = units1;
            freqs = freqs1;
         else
            units = 'rad/s';  % always wins
            % Note: Always return frequency vector originally expressed in
            % rad/s to avoid introducing small rounding errors
            if strcmpi(units1,'rad/s')
               freqs = freqs1;
               freqs2 = unitconv(freqs2,units2,units);
            else
               freqs = freqs2;
               freqs1 = unitconv(freqs1,units1,units);
            end
         end
         
         % The frequency points should now match up to round-off errors of level RELTOL
         if (length(freqs1)~=length(freqs2)) || any(abs(freqs1-freqs2)>reltol*(1+abs(freqs1)))
            ctrlMsgUtils.error('Control:ltiobject:mrgfreq1')
         end
      end

   end
   

end
