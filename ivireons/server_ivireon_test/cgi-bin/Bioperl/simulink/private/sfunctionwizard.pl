#  Name:
#     sfunctionwizard.pl-- generats an S-function for Simulink
#  Usage:
#    to be called by $MATLAB/toolbox/simulink/simulink/sfunctionwizard.m
#
# Copyright 1990-2009 The MathWorks, Inc.
# $Revision: 1.18.4.26 $
# Ricardo Monteiro 01/26/2001

($sfunName, $sfunNameWrapper, $mdlOutputTempFile, $mdlUpdateTempFile, $headersTempFile, $legacy_c, $pathFcnCall,
 $FileParams,$businfoFile,$bus_header, $mdlDerivativeTempFile, $sfbVersion) = @ARGV;
#####################
# Global variables  #
#####################
 @InDataType  = ();
 @InRow  = ();
 @InCol = ();
 @InComplexity = ();
 @InFrameBased =  ();
 @InBusBased =  ();
 @InBusname = ();
 @Inframe = ();
 @inDataTypeMacro = ();

 @OutRow  = ();
 @OutCol = ();
 @OutDataType = ();
 @OutComplexity = ();
 @OutFrameBased =  ();
 @OutBusBased =  ();
 @OutBusname = ();
 @outDataTypeMacro =();
 $flag_Busused = 0;
 @ParameterName       = ();
 @ParameterDataType   = ();
 @ParameterComplexity = ();
 $EMPTY_SPACE = "                         ";
 $EMPTY_SPACE1= "                     ";
 $EMPTY_SPACE2= "                  ";

#####################
# Read Params File  #
#####################
open(INFileParams, "<$FileParams") || die "Unable to open  $FileParams";
while (<INFileParams>) {  
    my($line) = $_;
    chomp($line);


 if($line =~ /NumberOfInputPorts/){
   $NumberOfInputPorts  = substr($line, index($line,"=") + 1);
 }

 if($line =~ /NumberOfOutputPorts/){
   $NumberOfOutputPorts  = substr($line, index($line,"=") + 1);
 }

 for($i=0;$i<$NumberOfInputPorts; $i++){
   $n = $i+1;
   $p = "InPort" . $n;
   if(/$p\{/.../\}\s*$/) {
     $InPortNameStr = "inPortName" . $n;
     $InRowStr = "inRow" . $n;
     $InColStr = "inCol" . $n;
     $InDataTypeStr = "inDataType" . $n;
     $InComplexityStr = "inComplexity" . $n;
     $InFrameBasedStr = "inFrameBased" . $n;
     $InBusBasedStr = "inBusBased" . $n;
     $InBusnameStr = "inBusname" . $n;
     $InDimsStr = "inDims" . $n;
     $InIsSignedStr = "inIsSigned" . $n;
     $InWordLengthStr = "inWordLength" . $n;
     $InFractionLengthStr = "inFractionLength" . $n;
     $InFixPointScalingTypeStr = "inFixPointScalingType" . $n;
     $InBiasStr = "inBias" . $n;
     $InSlopeStr = "inSlope" . $n;

     if($line =~ /\b$InPortNameStr\b/) {
       @InPortName[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InRowStr\b/) {
       @InRow[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InColStr\b/) {
       @InCol[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InDataTypeStr\b/) {
       @InDataType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InComplexityStr\b/) {
       @InComplexity[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InFrameBasedStr\b/) {
       @InFrameBased[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InBusBasedStr\b/) {
         @InBusBased[$i]  = substr($line, index($line,"=") + 1);
         if($InBusBased[$i] eq "on"){
             $IsInBusBased[$i] = 1;
             $flag_Busused = 1;
         }
         else{
             $IsInBusBased[$i] = 0;
         }
     }
     
     if($line =~ /\b$InBusnameStr\b/) {
         @InBusname[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InDimsStr\b/) {
       @InDims[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InIsSignedStr\b/) {
       @InIsSigned[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InWordLengthStr\b/) {
       @InWordLength[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$InFractionLengthStr\b/) {
       @InFractionLength[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$InFixPointScalingTypeStr\b/) {
       @InFixPointScalingType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$InBiasStr\b/) {
       @InBias[$i]  = substr($line, index($line,"=") + 1);
     }
     if($line  =~ /\b$InSlopeStr\b/) {
       @InSlope[$i]  = substr($line, index($line,"=") + 1);
     }


   }
 } #end for

 for($i=0;$i<$NumberOfOutputPorts; $i++){
   $n = $i+1;
   $p = "OutPort" . $n;
   if(/$p\{/.../\}\s*$/) {
     $OutPortNameStr = "outPortName" . $n;
     $OutRowStr = "outRow" . $n;
     $OutColStr = "outCol" . $n;
     $OutDataTypeStr = "outDataType" . $n;
     $OutComplexityStr = "outComplexity" . $n;
     $OutFrameBasedStr = "outFrameBased" . $n;
     $OutBusBasedStr = "outBusBased" . $n;
     $OutBusnameStr = "outBusname" . $n;
     $OutDimsStr = "outDims" . $n;
     $OutIsSignedStr = "outIsSigned" . $n;
     $OutWordLengthStr = "outWordLength" . $n;
     $OutFractionLengthStr = "outFractionLength" . $n;
     $OutFixPointScalingTypeStr = "outFixPointScalingType" . $n;
     $BiasStr = "outBias" . $n;
     $SlopeStr = "outSlope" . $n;

     if($line =~ /\b$OutPortNameStr\b/) {
       @OutPortName[$i]  = substr($line, index($line,"=") + 1);
     }
    
     if($line =~ /\b$OutRowStr\b/) {
       @OutRow[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutColStr\b/) {
       @OutCol[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutDataTypeStr\b/) {
       @OutDataType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutComplexityStr\b/) {
       @OutComplexity[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutFrameBasedStr\b/) {
       @OutFrameBased[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutBusBasedStr\b/) {
         @OutBusBased[$i]  = substr($line, index($line,"=") + 1);
         if($OutBusBased[$i] eq "on"){
             $IsOutBusBased[$i] = 1;
             $flag_Busused = 1;
         }
         else{
             $IsOutBusBased[$i] = 0;
         }
     }

     if($line =~ /\b$OutBusnameStr\b/) {
         @OutBusname[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutDimsStr\b/) {
       @OutDims[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutIsSignedStr\b/) {
       @OutIsSigned[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line =~ /\b$OutWordLengthStr\b/) {
       @OutWordLength[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$OutFractionLengthStr\b/) {
       @OutFractionLength[$i]  = substr($line, index($line,"=") + 1);
     }
     
     if($line  =~ /\b$OutFixPointScalingTypeStr\b/) {
       @OutFixPointScalingType[$i]  = substr($line, index($line,"=") + 1);
     }

     if($line  =~ /\b$BiasStr\b/) {
       @OutBias[$i]  = substr($line, index($line,"=") + 1);
     }
     if($line  =~ /\b$SlopeStr\b/) {
       @OutSlope[$i]  = substr($line, index($line,"=") + 1);
     }

   }
 } #end for


    if($line =~ /NumberOfInputs/){
      $InRow[0]  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /NumberOfOutputs/){
      $OutRow[0]  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /directFeed/){
      $directFeed  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /NumOfDStates/){
      $NumDiscStates  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /DStatesIC/){
      $DStatesIC = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /NumOfCStates/){
      $NumContStates = substr($line, index($line,"=") + 1);
    }
    if($line =~ /CStatesIC/){
      $CStatesIC = substr($line, index($line,"=") + 1);
    }
    if($line =~ /SampleTime/){
      $sampleTime = substr($line, index($line,"=") + 1);
    }
    if($line =~ /NumberOfParameters/){
      $NumParams = substr($line, index($line,"=") + 1);
    }    
    if($line =~ /CreateWrapperTLC/){
      $CreateWrapperTLC = substr($line, index($line,"=") + 1);
    }
    if($line =~ /UseSimStruct/){
      $UseSimStruct = substr($line, index($line,"=") + 1);
    }
    if($line =~ /CreateDebugMex/){
      $CreateDebugMex = substr($line, index($line,"=") + 1);
    }
    if($line =~ /ShowCompileSteps/){
      $ShowCompileSteps = substr($line, index($line,"=") + 1);
    }
    if($line =~ /SaveCodeOnly/){
      $SaveCodeOnly = substr($line, index($line,"=") + 1);
    }
    if($line =~ /LibList/){
      $LibrarySourceFiles  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /PanelIndex/){
      $PanelIndex  = substr($line, index($line,"=") + 1);
    }  
    if($line =~ /TemplateType/){
      $TemplateType  = substr($line, index($line,"=") + 1);
    } else { 
      $TemplateType = '1';
    }
    if($line =~ /InputDims_0_col/){
      $InputDim_0_Col  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /OutputDims_0_col/){
      $OutputDim_0_Col  = substr($line, index($line,"=") + 1);
    }
    if($line =~ /Gen_HeaderFile/){
      $Gen_HeaderFile  = substr($line, index($line,"=") + 1);
    }

    for($i=0;$i<$NumParams; $i++){
      $n = $i+1;
      $p = "Parameter" . $n;
      if(/$p\{/.../\}\s*$/) {
	$ParameterNameStr = "parameterName" . $n;
	$ParameterDataTypeStr = "parameterDataType" . $n;
	$ParameterComplexityStr = "parameterComplexity" . $n;
	
	if($line =~ /\b$ParameterNameStr\b/) {
	  @ParameterName[$i]  = substr($line, index($line,"=") + 1);
	}
	
	if($line =~ /\b$ParameterDataTypeStr\b/) {
	  @ParameterDataType[$i]  = substr($line, index($line,"=") + 1);
	}
	
	if($line =~ /\b$ParameterComplexityStr\b/) {
	  @ParameterComplexity[$i]  = substr($line, index($line,"=") + 1);
	}
	
      }
    } #end for

    if($line =~ /GenerateStartFunction/){
      $GenerateStartFunction  = substr($line, index($line,"=") + 1);
    }
    
    if($line =~ /GenerateTerminateFunction/){
      $GenerateTerminateFunction  = substr($line, index($line,"=") + 1);
    }
  }

close(INFileParams);
for($i=0;$i<$NumberOfInputPorts; $i++) {
 # Create the data type macro
 # for exmaple SS_BOOLEAN
 $inDataTypeMacro[$i] = getDataTypeMacros($InDataType[$i]);

 if($InFrameBased[$i] =~ "FRAME_YES" || $InFrameBased[$i] =~ "FRAME_INHERITED")
 {
   $Inframe[$i] = '1';
 } else {
   $Inframe[$i] = '0';
 }
}

for($i=0;$i<$NumberOfOutputPorts; $i++) {
 $outDataTypeMacro[$i] = getDataTypeMacros($OutDataType[$i]);
}

for($i=0;$i<$NumParams; $i++) {
 $ParameterDataTypeMacro[$i] = getDataTypeMacros($ParameterDataType[$i]);
}
# Remove .c from the S-function name #
@n = split(/\./,$sfunName);
$sFName = @n[0];

# Set the path to the sfunwiz_template.c according to the platform
if($pathFcnCall =~ /\//) {
    $sfun_template = "$pathFcnCall/sfunwiz_template.c.tmpl";
    $sfun_template_wrapper = "$pathFcnCall/sfunwiz_template_wrapper.c.tmpl";
    $sfun_template_wrapperTLC = "$pathFcnCall/sfunwiz_template.tlc";
}
else {
    $sfun_template = "$pathFcnCall\\sfunwiz_template.c.tmpl";
    $sfun_template_wrapper = "$pathFcnCall\\sfunwiz_template_wrapper.c.tmpl";
    $sfun_template_wrapperTLC = "$pathFcnCall\\sfunwiz_template.tlc";
}

$sfunNameWrapperTLC = $sFName . ".tlc";
$sfunBusHeaderFile = $sFName. "_bus.h";

$SfunDir =`pwd`; 
open(OUT,">$sfunName") || die "Unable to create $sfunName. Please check the directory permission:\n $SfunDir \n";
open(OUTWrapper,">$sfunNameWrapper") || die "Unable to create $sfunNameWrapper Please check the directory permission\n";
open(IN, "<$sfun_template") || die "Unable to open $sfun_template ";
open(INWrapper, "<$sfun_template_wrapper") || die "Unable to open $sfun_template_wrapper ";
open(HTEMP,"<$mdlOutputTempFile") || die "Unable to open $mdlOutputTempFile";

if($flag_Busused == 1){
    if($Gen_HeaderFile == 1){
        $bus_Header_List = genBusHeaderFile($sfunBusHeaderFile,$bus_header,1);
    }
    else{
        $bus_Header_List = genBusHeaderFile($sfunBusHeaderFile,$bus_header,0);
    }
}


$strDStates = "NO_USER_DEFINED_DISCRETE_STATES";
if( $mdlUpdateTempFile =~ /$strDStates/){
      $flagdStates = 0;
    }
else {
  open(dStatesHandle,"<$mdlUpdateTempFile") || die "Unable to open $mdlUpdateTempFile";
  @discStatesArray  = <dStatesHandle>;
  $flagdStates = 1;
}

$strCStates = "NO_USER_DEFINED_CONTINUOS_STATES";
if( $mdlDerivativeTempFile =~ /$strCStates/){
      $flagCStates = 0;
    }
else {
  open(CStatesHandle,"<$mdlDerivativeTempFile") || die "Unable to open $mdlDerivativeTempFile";
  @contStatesArray  = <CStatesHandle>;
  $flagCStates = 1;
}



$strH = "NO_USER_DEFINED_HEADER_CODE";
if($headersTempFile =~ /$strH/){
      $flagH = 0;
    }
else {
  open(HeaderF,"<$headersTempFile") || die "Unable to open $headersTempFile";
  @headerArray  = <HeaderF>;
  $flagH = 1;
}

$strC = "NO_USER_DEFINED_C_CODE";
if($legacy_c =~ $strC) {
  $flagL = 0;
}
else {
  open(HC,"<$legacy_c") || die "Unable to open $legacy_c";
  @externDeclarationsArray  = <HC>;
  $flagL = 1;
}


# declare 'width' in case output port width is -1
$strDynSize =  'DYNAMICALLY_SIZED';
$flagDynSize = 0;
if(($OutRow[0] =~ $strDynSize) || ($InRow[0] =~ $strDynSize)) {
  $flagDynSize = 1;
} else { 
  # Use to #define the u_width and y_width 
  $flagDynSize = 2;

} 

$strDynSize =  'DYNAMICALLY_SIZED';
if($InRow[0] == -1 && $NumberOfInputPorts == 1) {
  $InRow[0] = $strDynSize;
}
if($OutRow[0] == -1 && $NumberOfOutputPorts == 1) {
  $OutRow[0] = $strDynSize;
}

# Time Stamp
$timeString = localtime;

# Read mdlOutputTempFile into an array #
@mdlOutputArray = <HTEMP>;

$UpdatefcnStr = "Update";
$stateDStr = "xD";
$fcnProtoTypeUpdate =  genStatesWrapper($NumParams,$NumDiscStates,$UpdatefcnStr,
					$stateDStr, $sFName,$InDataType[0],$OutDataType[0], 0, 0);
$fcnCallUpdate = genFunctionCall($NumParams,$NumDiscStates,$UpdatefcnStr,$stateDStr, $sFName);
$wrapperExternDeclarationUpdate =  "extern $fcnProtoTypeUpdate;\n";

$fcnProtoTypeUpdateTLC =  genStatesWrapper($NumParams,$NumDiscStates,$UpdatefcnStr,
					$stateDStr, $sFName,$InDataType[0],$OutDataType[0], 1, 0);
$wrapperExternDeclarationUpdateTLC =  "extern $fcnProtoTypeUpdateTLC;\n";

if($flag_Busused){
   # $fcnProtoTypeUpdateTLC1 generates:
   #    extern void sfbuilder_bus_Outputs_wrapper_accel(const void *u0, void *__u0BUS,
   #                       const int32_T *u1,
   #                       void *y0, void *__y0BUS,
   #                       int32_T *y1);
  
    $fcnProtoTypeUpdateTLC1 = genStatesWrapper($NumParams,$NumDiscStates,$UpdatefcnStr,
                                               $stateDStr, $sFName,$InDataType[0],$OutDataType[0], 1, 1);

    # $fcnProtoTypeUpdateTLC2 generates:
    # 	sfbuilder_bus_Outputs_wrapper((SFB_COUNTERBUS *) __u0BUS,
    #                          u1,
    #                          (SFB_COUNTERBUS *) __y0BUS,
    #                          y1);
 
    $fcnProtoTypeUpdateTLC2 = genStatesWrapper($NumParams,$NumDiscStates,$UpdatefcnStr,
                                               $stateDStr, $sFName,$InDataType[0],$OutDataType[0], 1, 2);					
}

$DerivativesfcnStr = "Derivatives";
$stateCStr = "xC";
$fcnProtoTypeDerivatives =  genStatesWrapper($NumParams,$NumContStates,$DerivativesfcnStr,
					     $stateCStr, $sFName,$InDataType[0],$OutDataType[0], 0, 0);
$fcnCallDerivatives = genFunctionCall($NumParams,$NumContStates,$DerivativesfcnStr,$stateCStr ,$sFName);
$wrapperExternDeclarationDerivatives =  "extern $fcnProtoTypeDerivatives;\n";

$fcnProtoTypeDerivativesTLC =  genStatesWrapper($NumParams,$NumContStates,$DerivativesfcnStr,
					     $stateCStr, $sFName,$InDataType[0],$OutDataType[0], 1, 0);
$wrapperExternDeclarationDerivativesTLC =  "extern $fcnProtoTypeDerivativesTLC;\n";

if($flag_Busused){
    $fcnProtoTypeDerivativesTLC1 = genStatesWrapper($NumParams,$NumContStates,$DerivativesfcnStr,
                                                    $stateCStr, $sFName,$InDataType[0],$OutDataType[0], 1, 1);
    $fcnProtoTypeDerivativesTLC2 = genStatesWrapper($NumParams,$NumContStates,$DerivativesfcnStr,
                                                    $stateCStr, $sFName,$InDataType[0],$OutDataType[0], 1, 2);					    
}

$OutputfcnStr = "Outputs";

$fcnProtoTypeOutput =  genOutputWrapper($NumParams, $NumDiscStates, $NumContStates, 
					$OutputfcnStr, $sFName, $flagDynSize,$InDataType[0],$OutDataType[0], 0, 0);
$fcnCallOutput =  genFunctionCallOutput($NumParams, $NumDiscStates,$NumContStates, $OutputfcnStr, $sFName, $flagDynSize);
$wrapperExternDeclarationOutput =  "extern $fcnProtoTypeOutput;\n";
$fcnProtoTypeOutputTLC = genOutputWrapper($NumParams, $NumDiscStates, $NumContStates, 
					$OutputfcnStr, $sFName, $flagDynSize,$InDataType[0],$OutDataType[0], 1, 0);

if($flag_Busused){
   # Same as $fcnProtoTypeUpdateTLC1
    $fcnProtoTypeOutputTLC1 = genOutputWrapper($NumParams, $NumDiscStates, $NumContStates, 
                                               $OutputfcnStr, $sFName, $flagDynSize,$InDataType[0],$OutDataType[0], 1, 1);
    # Same as $fcnProtoTypeUpdateTLC2
    $fcnProtoTypeOutputTLC2 = genOutputWrapper($NumParams, $NumDiscStates, $NumContStates, 
                                               $OutputfcnStr, $sFName, $flagDynSize,$InDataType[0],$OutDataType[0], 1, 2);
    
    $wrapperExternDeclarationOutputTLCForBus =  genExternDeclarationTLCForBus($fcnProtoTypeOutputTLC1,$fcnProtoTypeOutputTLC2,
                                                                               $fcnProtoTypeUpdateTLC1,$fcnProtoTypeUpdateTLC2,
                                                                               $fcnProtoTypeDerivativesTLC1,$fcnProtoTypeDerivativesTLC2);
}

$wrapperExternDeclarationOutputTLC =  "extern $fcnProtoTypeOutputTLC;\n";

#Trim the list of source/lib files to be printend in the generated S-function
@vectorLib = split(',', $LibrarySourceFiles);
foreach $Lib (@vectorLib){
  $Lib =~ s/\'//;
  $Lib =~ s/\'//;
  $LibLists = "$LibLists $Lib";
}
$LibLists =~ s/\s//;

##########################
# Create the S-function  #
##########################
while (<IN>) {  
  my($line) = $_;
  
  # comments
  if($. == 2) {
    print OUT " * File: $sfunName\n";
  }

  if($. == 3) {
    $strIntro = genIntro();
    print OUT $strIntro; 
  }

  if($. == 4) {
    print OUT " * Created: $timeString\n";
  }
  #Don't print Copyright
  if($. == 6 ) { next; }
  if($. == 7 ) { next; }
  
  ################### 
  # S-function name #
  ###################
    if (/--SfunctionName--/){   
    print OUT "#define S_FUNCTION_NAME $sFName\n";
    next;
  }

  if (/--Builder Defines--/){   
print  OUT "/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
/* %%%-SFUNWIZ_defines_Changes_BEGIN --- EDIT HERE TO _END */\n";
print OUT "#define NUM_INPUTS          $NumberOfInputPorts\n";               

for($i=0;$i<$NumberOfInputPorts; $i++){
  print OUT "/* Input Port  $i */\n";
  print OUT "#define IN_PORT_$i\_NAME      $InPortName[$i]\n";
  print OUT "#define INPUT_$i\_WIDTH       $InRow[$i]\n";
  print OUT "#define INPUT_DIMS_$i\_COL    $InCol[$i]\n";
  print OUT "#define INPUT_$i\_DTYPE       $InDataType[$i]\n";
  print OUT "#define INPUT_$i\_COMPLEX     $InComplexity[$i]\n";
  print OUT "#define IN_$i\_FRAME_BASED    $InFrameBased[$i]\n";
  print OUT "#define IN_$i\_BUS_BASED      $IsInBusBased[$i]\n";
  print OUT "#define IN_$i\_BUS_NAME       $InBusname[$i]\n";
  print OUT "#define IN_$i\_DIMS           $InDims[$i]\n";
  print OUT "#define INPUT_$i\_FEEDTHROUGH $directFeed\n";
  print OUT "#define IN_$i\_ISSIGNED        $InIsSigned[$i]\n";
  print OUT "#define IN_$i\_WORDLENGTH      $InWordLength[$i]\n";
  print OUT "#define IN_$i\_FIXPOINTSCALING $InFixPointScalingType[$i]\n";
  print OUT "#define IN_$i\_FRACTIONLENGTH  $InFractionLength[$i]\n";
  print OUT "#define IN_$i\_BIAS            $InBias[$i]\n";
  print OUT "#define IN_$i\_SLOPE           $InSlope[$i]\n";
}

print OUT "\n#define NUM_OUTPUTS          $NumberOfOutputPorts\n";
for($i=0;$i<$NumberOfOutputPorts; $i++){
  print OUT "/* Output Port  $i */\n";
  print OUT "#define OUT_PORT_$i\_NAME      $OutPortName[$i]\n";
  print OUT "#define OUTPUT_$i\_WIDTH       $OutRow[$i]\n";
  print OUT "#define OUTPUT_DIMS_$i\_COL    $OutCol[$i]\n";
  print OUT "#define OUTPUT_$i\_DTYPE       $OutDataType[$i]\n";
  print OUT "#define OUTPUT_$i\_COMPLEX     $OutComplexity[$i]\n";
  print OUT "#define OUT_$i\_FRAME_BASED    $OutFrameBased[$i]\n";
  print OUT "#define OUT_$i\_BUS_BASED      $IsOutBusBased[$i]\n";
  print OUT "#define OUT_$i\_BUS_NAME       $OutBusname[$i]\n";
  print OUT "#define OUT_$i\_DIMS           $OutDims[$i]\n";
  print OUT "#define OUT_$i\_ISSIGNED        $OutIsSigned[$i]\n";
  print OUT "#define OUT_$i\_WORDLENGTH      $OutWordLength[$i]\n";
  print OUT "#define OUT_$i\_FIXPOINTSCALING $OutFixPointScalingType[$i]\n";
  print OUT "#define OUT_$i\_FRACTIONLENGTH  $OutFractionLength[$i]\n";
  print OUT "#define OUT_$i\_BIAS            $OutBias[$i]\n";
  print OUT "#define OUT_$i\_SLOPE           $OutSlope[$i]\n";

}

print OUT "\n#define NPARAMS              $NumParams\n";
for($i=0;$i<$NumParams; $i++){
  $n = $i+1;
  print OUT "/* Parameter  $n */\n";
  print OUT "#define PARAMETER_$i\_NAME      $ParameterName[$i]\n";
  print OUT "#define PARAMETER_$i\_DTYPE     $ParameterDataType[$i]\n";
  print OUT "#define PARAMETER_$i\_COMPLEX   $ParameterComplexity[$i]\n";
}

#print OUT "#define NPARAMS              $NumParams
print OUT "\n#define SAMPLE_TIME_0        $sampleTime
#define NUM_DISC_STATES      $NumDiscStates
#define DISC_STATES_IC       [$DStatesIC]
#define NUM_CONT_STATES      $NumContStates
#define CONT_STATES_IC       [$CStatesIC]

#define SFUNWIZ_GENERATE_TLC $CreateWrapperTLC
#define SOURCEFILES \"$LibLists\"
#define PANELINDEX           $PanelIndex
#define USE_SIMSTRUCT        $UseSimStruct
#define SHOW_COMPILE_STEPS   $ShowCompileSteps                   
#define CREATE_DEBUG_MEXFILE $CreateDebugMex
#define SAVE_CODE_ONLY       $SaveCodeOnly
#define SFUNWIZ_REVISION     3.0\n";
     print OUT  "/* %%%-SFUNWIZ_defines_Changes_END --- EDIT HERE TO _BEGIN */
/*<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/\n";

    next;
  }  

  if(/--IncludeBusHeader--/) {
      if($flag_Busused == 1){
          if($Gen_HeaderFile == 1){
              print OUT "#include \"$sfunBusHeaderFile\"\n";
          }else{
              print OUT "$bus_Header_List";
          }
          print OUT "/*
* RTW Environment flag (simulation or standalone target).
 */
static int_T isSimulationTarget;
";
          print OUT "/*  Utility function prototypes. */
static int_T GetRTWEnvironmentMode(SimStruct *S);
/* Macro used to check if Simulation mode is set to accelerator */
#define isDWorkPresent !(ssRTWGenIsCodeGen(S) && isSimulationTarget)
";

      }
      next;
  }
#end of if(/--IncludeBusHeader--/)

  $IsFixedBeingPropagated = 0;
  for($i=0;$i<$NumberOfInputPorts; $i++){
    if($InDataType[$i] =~ /\bfixpt\b/) {
      $IsFixedBeingPropagated = 1;
      last;
    }
  }

  if($IsFixedBeingPropagated == 0) {
    for($i=0;$i<$NumberOfOutputPorts; $i++){
      if($OutDataType[$i] =~ /\bfixpt\b/) {
	$IsFixedBeingPropagated = 1;
	last;
      }
    }
  }
  if(/--IncludeFixedPointDotH--/) {
    if($IsFixedBeingPropagated == 1) {
      print OUT "#include \"fixedpoint.h\"\n"; 
    }
    next;
  } 
 ###########
 # Defines #
 ###########
 %defines_repeat_hash = ();
 if (/--Parameters Defines--/){  
   for($i=0; $i < $NumParams ; $i++){
       print OUT "#define PARAM_DEF$i(S) ssGetSFcnParam(S, $i)\n";
     }
   writeSFcnBCache();
# (xxx) make this into a table
  for($i=0; $i < $NumParams ; $i++){
    if($ParameterComplexity[$i]  =~ /COMPLEX_NO/) {
      if($ParameterDataType[$i] =~ /\breal_T\b/) {
        next if ($defines_repeat_hash{real_T}++ > 0);
	print OUT "\n#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))\n";
      }

      if($ParameterDataType[$i] =~ /\breal32_T\b/) {
        next if ($defines_repeat_hash{real32_T}++ > 0);
	print OUT "\n#define IS_PARAM_SINGLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsSingle(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bint8_T\b/) {
        next if ($defines_repeat_hash{int8_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT8(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsInt8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bint16_T\b/) {
        next if ($defines_repeat_hash{int16_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT16(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsInt16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bint32_T\b/) {
        next if ($defines_repeat_hash{int32_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT32(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsInt32(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\buint8_T\b/) {
        next if ($defines_repeat_hash{uint8_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT8(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsUint8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\buint16_T\b/) {
        next if ($defines_repeat_hash{uint16_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT16(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsUint16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\buint32_T\b/) {
        next if ($defines_repeat_hash{uint32_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT32(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsUint32(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bboolean_T\b/) {    
        next if ($defines_repeat_hash{boolean_T}++ > 0);
	print OUT "\n#define IS_PARAM_BOOLEAN(pVal) (mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal))\n";
      }
    }

    if($ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
      if($ParameterDataType[$i] =~ /\bcreal_T\b/) {
        next if ($defines_repeat_hash{creal_T}++ > 0);
	print OUT "\n#define IS_PARAM_DOUBLE_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsDouble(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcreal32_T\b/) {
        next if ($defines_repeat_hash{creal32_T}++ > 0);
	print OUT "\n#define IS_PARAM_SINGLE_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsSingle(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcint8_T\b/) {
        next if ($defines_repeat_hash{cint8_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT8_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsInt8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcint16_T\b/) {
        next if ($defines_repeat_hash{cint16_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT16_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsInt16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcint32_T\b/) {
        next if ($defines_repeat_hash{cint32_T}++ > 0);
	print OUT "\n#define IS_PARAM_INT32_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsInt32(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcuint8_T\b/) {
        next if ($defines_repeat_hash{cuint8_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT8_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsUint8(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcuint16_T\b/) {
        next if ($defines_repeat_hash{cuint16_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT16_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsUint16(pVal))\n";
      }
      if($ParameterDataType[$i] =~ /\bcuint32_T\b/) {
        next if ($defines_repeat_hash{cuint32_T}++ > 0);
	print OUT "\n#define IS_PARAM_UINT32_CPLX(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && mxIsComplex(pVal) && mxIsUint32(pVal))\n";
      }
    }
  }
   next;
 }

 ######################
 # Extern declaration #
 ######################
  if(/--ExternDeclarationOutputs--/){
   print OUT $wrapperExternDeclarationOutput;
    next;
  }

  if(/--ExternDeclarationUpdates--/) {
    if($NumDiscStates){
     print OUT $wrapperExternDeclarationUpdate;
    }
    next;
  }
  if(/--ExternDeclarationDerivatives--/){
    if($NumContStates){
     print OUT $wrapperExternDeclarationDerivatives;
    }
    next;
  }
  #####################
  #mdlCheckParameters # 
  #####################
  if(/--MDL_CHECK_PARAMETERS--/){
    if ($NumParams){
      $method = get_mdlCheckParameters_method(); 
      print  OUT $method;
    }
    next;
  }
  ######################
  # mdlInitializeSizes #
  ######################
  if(/--ParametersDeclaration--/) {

      if($NumberOfInputPorts > 0) {
          print OUT  "    DECL_AND_INIT_DIMSINFO(inputDimsInfo);\n";
      }
      print OUT  "    DECL_AND_INIT_DIMSINFO(outputDimsInfo);\n";
      $parameterDeclaration = get_parameters_declaration($NumParams);
      print OUT $parameterDeclaration;
      next;
  } 
  
  if(/--ssSetNumContStates--/){
    print OUT  "    ssSetNumContStates(S, NUM_CONT_STATES);\n";
    next;
  } 
  if(/--ssSetNumDiscStates--/){
    print OUT  "    ssSetNumDiscStates(S, NUM_DISC_STATES);\n";
    next;
  } 

  if(/--ssSetNumInputPortsInfo--/) {
    print OUT "    if (!ssSetNumInputPorts(S, NUM_INPUTS)) return;\n";
    next;
  }
if(/--ssSetInputPortInformation--/) {
 if ($NumberOfInputPorts == 1 && $InDims[0] == "1-D") {
     if($IsInBusBased[0] == 1){
         $busStr = genBusString(0,1);
         print OUT $busStr;
     }
     else{
         if( ($InRow[0] == $OutRow[0] || $OutRow[0] == 1)  && 
             ($InRow[0] > 1 || ($InRow[0] =~ $strDynSize)) ) {
             print OUT "    inputDimsInfo.width = INPUT_0_WIDTH;";
             print OUT "\n    ssSetInputPortDimensionInfo(S, 0, &inputDimsInfo);";
             if($Inframe[0] == 1) {
                 print OUT "\n    ssSetInputPortMatrixDimensions(  S ,0, INPUT_0_WIDTH, INPUT_DIMS_0_COL);";
             }
             print OUT "\n    ssSetInputPortFrameData(S, 0, IN_0_FRAME_BASED);";
             if($InDataType[0] =~ /\bfixpt\b/) {
                 if($InFixPointScalingType[0] == 1) {
                     print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_SLOPE,
            IN_0_BIAS,
            1 );";
                 } else {
                     print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_FRACTIONLENGTH,
            1 );";
	}
                 print OUT "\n    ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]" . "_0);\n }";
             } else {
                 print OUT "\n    ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]);";
             }
             print OUT "\n    ssSetInputPortComplexSignal(S, 0, INPUT_0_COMPLEX);";  
         } else {
             if($Inframe[0] == 1) {
                 print OUT "    inputDimsInfo.width = INPUT_0_WIDTH;";
                 print OUT "\n    ssSetInputPortDimensionInfo(S, 0, &inputDimsInfo);";
                 print OUT "\n    ssSetInputPortMatrixDimensions(  S ,0, INPUT_0_WIDTH, INPUT_DIMS_0_COL);";
                 print OUT "\n    ssSetInputPortFrameData(S, 0, IN_0_FRAME_BASED);\n";
             }
             if($Inframe[0] == 0) {
                 print OUT "    ssSetInputPortWidth(S, 0, INPUT_0_WIDTH);";
             } 
             
             if($InDataType[0] =~ /\bfixpt\b/) {
                 if($InFixPointScalingType[0] == 1) {
                     print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_SLOPE,
            IN_0_BIAS,
            1 );";
                 } else {
                     print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_0_ISSIGNED,
            IN_0_WORDLENGTH,
            IN_0_FRACTIONLENGTH,
            1 );";
	  }
	  print OUT "\n     ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]" . "_0);\n    }";
	} else {
	  print OUT "\n    ssSetInputPortDataType(S, 0, $inDataTypeMacro[0]);";
       }
	print OUT "\n    ssSetInputPortComplexSignal(S, 0, INPUT_0_COMPLEX);";  
      }
  print OUT "\n    ssSetInputPortDirectFeedThrough(S, 0, INPUT_0_FEEDTHROUGH);";
  print OUT "\n    ssSetInputPortRequiredContiguous(S, 0, 1); /*direct input signal access*/\n";
     }
} else {
  for($i=0;$i<$NumberOfInputPorts; $i++) {
     print OUT "    /*Input Port $i */\n";
     if($IsInBusBased[$i] == 1) {
         $busStr = genBusString($i,1);
         print OUT $busStr;
     }
     else{
         if ($InRow[$i] > 1 || ($InRow[$i] =~ $strDynSize)) {
             if ($InCol[$i] > 1 || $Inframe[$i] == 1) {
                 print OUT "    inputDimsInfo.width = INPUT_$i\_WIDTH;";
                 print OUT "\n    ssSetInputPortDimensionInfo(S, $i, &inputDimsInfo);";
                 print OUT "\n    ssSetInputPortMatrixDimensions(  S ,$i, INPUT_$i\_WIDTH, INPUT_DIMS_$i\_COL);";
                 print OUT "\n    ssSetInputPortFrameData(S, $i, IN_$i\_FRAME_BASED);";
             } else  {
                 print OUT "    ssSetInputPortWidth(S,  $i, INPUT_$i\_WIDTH);";
      }

             if($InDataType[$i] =~ /\bfixpt\b/) {
                 if($InFixPointScalingType[$i] == 1) {
                     print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_SLOPE,
            IN_$i\_BIAS,
            1 );";
                 } else {
                     print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_FRACTIONLENGTH,
            1 );";
	  }
                 print OUT "\n    ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]" . "\_$i);\n }";
             } else {
           print OUT "\n    ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]);";
       }
             print OUT "\n    ssSetInputPortComplexSignal(S, $i, INPUT_$i\_COMPLEX);";  
         } else {
             if($InCol[$i] > 1 || $Inframe[$i] == 1) {
                 print OUT "    inputDimsInfo.width = INPUT_$i\_WIDTH;";
                 print OUT "\n    ssSetInputPortDimensionInfo(S,  $i, &inputDimsInfo);";
                 print OUT "\n    ssSetInputPortMatrixDimensions(  S , $i, INPUT_$i\_WIDTH, INPUT_DIMS_$i\_COL);";
                 print OUT "\n    ssSetInputPortFrameData(S,  $i, IN_$i\_FRAME_BASED);\n";
             } else {
                 print OUT "    ssSetInputPortWidth(S,  $i, INPUT_$i\_WIDTH); /* */";
             }
             if($InDataType[$i] =~ /\bfixpt\b/) {
                 if($InFixPointScalingType[$i] == 1) {
                     print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpSlopeBias(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_SLOPE,
            IN_$i\_BIAS,
            1 );";
                 } else {
                     print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpBinaryPoint(
            S,
            IN_$i\_ISSIGNED,
            IN_$i\_WORDLENGTH,
            IN_$i\_FRACTIONLENGTH,
            1 );";
                 }
                 print OUT "\n      ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]" . "\_$i);\n    }";
             } else {
                 print OUT "\n    ssSetInputPortDataType(S, $i, $inDataTypeMacro[$i]);";
             }
             print OUT "\n    ssSetInputPortComplexSignal(S,  $i, INPUT_$i\_COMPLEX);";  
         }
         print OUT "\n    ssSetInputPortDirectFeedThrough(S, $i, INPUT_$i\_FEEDTHROUGH);";
         print OUT "\n    ssSetInputPortRequiredContiguous(S, $i, 1); /*direct input signal access*/\n";
         print OUT "\n";
     }
 } #end of for loop
}
  next;
}
  if(/--ssSetInputPortDirectFeedThroughInfo--/) {
    next;
  } 

  if(/--ssSetNumOutputPortsInfo--/) {
    print OUT "    if (!ssSetNumOutputPorts(S, NUM_OUTPUTS)) return;\n";
    next;
  }
  if(/--ssSetOutputPortInformation--/) {
      if ($NumberOfOutputPorts == 1 &&  $OutDims[0] == "1-D") {
          if($IsOutBusBased[0] == 1) {
              $busStr = genBusString(0,2);
              print OUT $busStr;
          }
          else{
              if(($InRow[0] == $OutRow[0] || $OutRow[0] == 1) && ($InRow[0] > 1 || ($InRow[0] =~ $strDynSize)))  {
                  if ($OutCol[0] == 1 && ($OutFrameBased[0] eq 'FRAME_NO') && ($OutDims[0] eq '1-D') && !($OutRow[0] =~ $strDynSize) &&
                      isAnyInputSignalAMatrixSignal() == 1) {
                      print OUT "    ssSetOutputPortWidth(S, 0, OUTPUT_0_WIDTH);";
                  } else {
                      print OUT "    outputDimsInfo.width = OUTPUT_0_WIDTH;";
                      print OUT "\n    ssSetOutputPortDimensionInfo(S, 0, &outputDimsInfo);";
                      if($Inframe[0] == 1) {
                          print OUT "\n    ssSetOutputPortMatrixDimensions( S ,0, OUTPUT_0_WIDTH, OUTPUT_DIMS_0_COL);";
                      }
                      print OUT "\n    ssSetOutputPortFrameData(S, 0, OUT_0_FRAME_BASED);";
                  }
                  
                  if($OutDataType[0] =~ /\bfixpt\b/) {
                      if($OutFixPointScalingType[0] == 1) {
                          print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_SLOPE,
            OUT_0_BIAS,
            1 );";
                      } else {
                          print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_FRACTIONLENGTH,
            1 );";
                      }
                      print OUT "\n    ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]" . "_0);\n }";
                  } else {
                      print OUT "\n    ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]);";
                  }
                  print OUT "\n    ssSetOutputPortComplexSignal(S, 0, OUTPUT_0_COMPLEX);";  
              } else {
                  # generate calls for Detailed template
                  if($Inframe[0] == 1) {
                      print OUT "    outputDimsInfo.width = OUTPUT_0_WIDTH;";
                      print OUT "\n    ssSetOutputPortDimensionInfo(S, 0, &outputDimsInfo);";
                      print OUT "\n    ssSetOutputPortMatrixDimensions( S ,0, OUTPUT_0_WIDTH, OUTPUT_DIMS_0_COL);";
                      print OUT "\n    ssSetOutputPortFrameData(S, 0, OUT_0_FRAME_BASED);\n";
                  }
                  if($Inframe[0] == 0) {
                      print OUT "    ssSetOutputPortWidth(S, 0, OUTPUT_0_WIDTH);";
                  }
                  if($OutDataType[0] =~ /\bfixpt\b/) {
                      if($OutFixPointScalingType[0] == 1) {
                          print OUT "\n    { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpSlopeBias(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_SLOPE,
            OUT_0_BIAS,
            1 );";
                      } else {
                          print OUT "\n { DTypeId DataTypeId_0 = ssRegisterDataTypeFxpBinaryPoint(
            S,
            OUT_0_ISSIGNED,
            OUT_0_WORDLENGTH,
            OUT_0_FRACTIONLENGTH,
            1 );";
                      }
                      print OUT "\n      ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]" . "_0);\n    }";
                  } else {
                      print OUT "\n    ssSetOutputPortDataType(S, 0, $outDataTypeMacro[0]);";
                  }
              }
                  print OUT "\n    ssSetOutputPortComplexSignal(S, 0, OUTPUT_0_COMPLEX);";  
              }
          } else {
              for($i=0;$i<$NumberOfOutputPorts; $i++) {
                  print OUT "    /* Output Port $i */\n";
                  if($IsOutBusBased[$i] == 1) {
                      $busStr = genBusString($i,2);
                      print OUT $busStr;
                  }
                  else{
                  if ($OutCol[$i] > 1 || ($OutFrameBased[$i] eq 'FRAME_YES') || ($OutDims[$i] eq '2-D')) {
                      print OUT "    outputDimsInfo.width = OUTPUT_$i\_WIDTH;";
                      print OUT "\n    ssSetOutputPortDimensionInfo(S, $i, &outputDimsInfo);";
                      print OUT "\n    ssSetOutputPortMatrixDimensions( S ,$i, OUTPUT_$i\_WIDTH, OUTPUT_DIMS_$i\_COL);";
                      print OUT "\n    ssSetOutputPortFrameData(S, $i, OUT_$i\_FRAME_BASED);";
                  } else {
                      print OUT "    ssSetOutputPortWidth(S, $i, OUTPUT_$i\_WIDTH);";
                  }
                  if($OutDataType[$i] =~ /\bfixpt\b/) {
                      if($OutFixPointScalingType[$i] == 1) {
                          print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpSlopeBias(
            S,
            OUT_$i\_ISSIGNED,
            OUT_$i\_WORDLENGTH,
            OUT_$i\_SLOPE,
            OUT_$i\_BIAS,
            1 );";
                      } else {
                          print OUT "\n    { DTypeId DataTypeId_$i = ssRegisterDataTypeFxpBinaryPoint(
            S,
            OUT_$i\_ISSIGNED,
            OUT_$i\_WORDLENGTH,
            OUT_$i\_FRACTIONLENGTH,
            1 );";
                  }
                  print OUT "\n      ssSetOutputPortDataType(S, $i, $outDataTypeMacro[$i]" . "\_$i);\n    }";
              } else {
                  print OUT "\n    ssSetOutputPortDataType(S, $i, $outDataTypeMacro[$i]);";
              }
              print OUT "\n    ssSetOutputPortComplexSignal(S, $i, OUTPUT_$i\_COMPLEX);\n";  
              }
          } #end for loop
      }
      next;
  } #end if(/--ssSetOutputPortInformation--/)

  if(/--ssSetDworkInformation--/) {
     if($flag_Busused == 1){
         $NumberofBuses = 0;
         for($i=0;$i<$NumberOfInputPorts; $i++) {
             if($IsInBusBased[$i] == 1) {
                 $NumberOfBuses = $NumberOfBuses + 1;
             }
         }
         for($i=0;$i<$NumberOfOutputPorts; $i++) {
             if($IsOutBusBased[$i] == 1) {
                 $NumberOfBuses = $NumberOfBuses + 1;
             }
         }
      
         $DworkInit1 = "
    if (ssRTWGenIsCodeGen(S)) {
       isSimulationTarget = GetRTWEnvironmentMode(S);
    if (isSimulationTarget==-1) {
       ssSetErrorStatus(S, \" Unable to determine a valid RTW environment mode\");
       return;
     }
       isSimulationTarget |= ssRTWGenIsModelReferenceSimTarget(S);
    }
  
    /* Set the number of dworks */
    if (!isDWorkPresent) {
      if (!ssSetNumDWork(S, 0)) return;
    } else {
      if (!ssSetNumDWork(S, $NumberOfBuses)) return;
    }

";

         $DworkInit2 =  "
   if (isDWorkPresent) {
   ";
         
         $DworkInit3 = "";
  $dworkCount = 0;
         for($i=0;$i<$NumberOfInputPorts; $i++) {
             if($IsInBusBased[$i] == 1) {
                 $DworkInit3 = $DworkInit3."
    /*
     * Configure the dwork $dworkCount (u$i.\"BUS\")
     */
#if defined(MATLAB_MEX_FILE)

    if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {
      DTypeId dataTypeIdReg;
      ssRegisterTypeFromNamedObject(S, \"@InBusname[$i]\", &dataTypeIdReg);
      if (dataTypeIdReg == INVALID_DTYPE_ID) return;
      ssSetDWorkDataType(S, $dworkCount, dataTypeIdReg);
    }

#endif

    ssSetDWorkUsageType(S, $dworkCount, SS_DWORK_USED_AS_DWORK);
    ssSetDWorkName(S, $dworkCount, \"u$i". "BUS\");
    ssSetDWorkWidth(S, $dworkCount, DYNAMICALLY_SIZED);
    ssSetDWorkComplexSignal(S, $dworkCount, COMPLEX_NO);
"; 
                 $dworkCount =  $dworkCount +1;
             }
    }
         
         for($i=0;$i<$NumberOfOutputPorts; $i++) {
             if($IsOutBusBased[$i] == 1) {
                 $DworkInit3 = $DworkInit3."
    /*
     * Configure the dwork $dworkCount (y$i"."BUS)
     */
#if defined(MATLAB_MEX_FILE)

    if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY) {
      DTypeId dataTypeIdReg;
      ssRegisterTypeFromNamedObject(S, \"@OutBusname[$i]\", &dataTypeIdReg);
      if (dataTypeIdReg == INVALID_DTYPE_ID) return;
      ssSetDWorkDataType(S, $dworkCount, dataTypeIdReg);
    }

#endif

    ssSetDWorkUsageType(S, $dworkCount, SS_DWORK_USED_AS_DWORK);
    ssSetDWorkName(S, $dworkCount, \"y$i". "BUS\");
    ssSetDWorkWidth(S, $dworkCount, DYNAMICALLY_SIZED);
    ssSetDWorkComplexSignal(S, $dworkCount, COMPLEX_NO);
"; 
                 $dworkCount =  $dworkCount +1;
             }
         }
         
         print OUT $DworkInit1.$DworkInit2.$DworkInit3.'}';
     }
     next;
 }
  
  
  if(/--SS_OPTION_USE_TLC_WITH_ACCELERATOR--/){
      if ($CreateWrapperTLC == 1) {
        print OUT "                     SS_OPTION_USE_TLC_WITH_ACCELERATOR | \n";  
      }
      next;
  }
  
  if(/--MDL_SET_PORTS_DIMENSION_INFO--/){
    if(($InRow[0] =~ $strDynSize && $OutRow[0] == 1) || 
       ($InRow[0] > 1  && $OutRow[0] == 1) ||
       ($InRow[0] > 1  && $InCol[0] == 1) ||
       ($Inframe[0] == 1)) {
      $DimsInfoMOne_One = getBodyDimsInfoWidthMdlPortWidth($InRow[0],
							    $OutRow[0],
							    $strDynSize,
							    $Inframe[0]);
      print  OUT $DimsInfoMOne_One;
     }

    $mdlSetInputPortFrameData = "# define MDL_SET_INPUT_PORT_FRAME_DATA
static void mdlSetInputPortFrameData(SimStruct  *S, 
                                     int_T      port,
                                     Frame_T    frameData)
{
    ssSetInputPortFrameData(S, port, frameData);
}\n";
  if($NumberOfInputPorts > 0) { 
    print  OUT $mdlSetInputPortFrameData;
  }
    $DimsInfoMinus_By_N = getBodyMdlPortWidthMinusByN();
   if($InRow[0] =~ $strDynSize && $OutRow[0] > 1 &&   $Inframe[0] == '0') {
      print  OUT $DimsInfoMinus_By_N;
    }
    next;
  }


  if(/--MDL_SET_DWORK_WIDTHS--/){
      if($flag_Busused == 1){
          $mdlDworkWidth1 = "
#define MDL_SET_WORK_WIDTHS
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)

static void mdlSetWorkWidths(SimStruct *S)
{
  /* Set the width of DWork(s) used for marshalling the IOs */
  if (isDWorkPresent) {
";

   $mdlDworkWidth2 = "";
   $dworkCount = 0;
   for($i=0;$i<$NumberOfInputPorts; $i++) {
      if($IsInBusBased[$i] == 1) {
         $mdlDworkWidth2 = $mdlDworkWidth2."
     /* Update dwork $dworkCount */
     ssSetDWorkWidth(S, $dworkCount, ssGetInputPortWidth(S, $i));
       ";
         $dworkCount = $dworkCount +1;
        }
   }
   for($i=0;$i<$NumberOfOutputPorts; $i++) {
      if($IsOutBusBased[$i] == 1) {
         $mdlDworkWidth2 = $mdlDworkWidth2."
     /* Update dwork $dworkCount */
     ssSetDWorkWidth(S, $dworkCount, ssGetOutputPortWidth(S, $i));
       ";         
         $dworkCount = $dworkCount +1;
        }
   }

$mdlDworkWidth3 = " 
    }
}

#endif
";

       print OUT $mdlDworkWidth1.$mdlDworkWidth2.$mdlDworkWidth3;
   }
   next;
  }



   

  ###################################################
  # mdlInitializeSampleTime ports Data type methods #
  ###################################################
  if(/--ssSetSampleTimeInfo--/){
   $IsSampleTimeNotUsedAsParamter = 1;
   if ($NumParams){
     for($i=0;$i<$NumParams; $i++){
       if($ParameterName[$i] =~  /\b$sampleTime\b/){
        print OUT "    ssSetSampleTime(S, 0, *mxGetPr(ssGetSFcnParam(S, $i)));\n";
        $IsSampleTimeNotUsedAsParamter = 0;
        last;
       }
     }
     if($IsSampleTimeNotUsedAsParamter) {
        print OUT "    ssSetSampleTime(S, 0, SAMPLE_TIME_0);\n";
     }
   } else {
     print OUT "    ssSetSampleTime(S, 0, SAMPLE_TIME_0);\n";
   }
    next;
  } 

  if(/--MDL_INITIALIZE_CONDITIONS--/){
    if ($NumDiscStates || $NumContStates ){
      $methodInit=get_mdlInitializeConditions_method($NumDiscStates ,$DStatesIC ,$NumContStates, $CStatesIC);
      print  OUT $methodInit;
    }
    next;
  }

  if(/--MDL_START_FUNCTION--/){
    if($flag_Busused == 1){
      $startFcn = genStartFcnMethodsforBus($businfoFile);
      print OUT $startFcn;
    }
    elsif($GenerateStartFunction > 0) {
      $startFcn = genStartFcnMethods();
      print OUT $startFcn;
    }
    next;
   }

  if(/--MDL_SET_PORTS_DATA_TYPE--/) {
    $portMethods = genPortDataTypeMethods();
    print  OUT  $portMethods;
    next;
  }
  ##############
  # mdlOutputs #
  ##############
  
  if(/--InputDataTypeDeclaration--/) {
    if($directFeed > 0 ) {
       for($i=0;$i<$NumberOfInputPorts; $i++){
        if($IsInBusBased[$i] == 1){
            print OUT "    const char *$InPortName[$i] = (char *) ssGetInputPortSignal(S,$i);\n";
        }
        else{
         if($InDataType[$i] =~ /\bfixpt\b/) {
             $isSigned = "u";
             if($InIsSigned[$i]) {
               $isSigned = "";
             }
            if ($InWordLength[$i] <= 8) {
              print OUT "    const " . $isSigned . "int8_T  *$InPortName[$i]   = (const " . $isSigned . "int8_T*) ssGetInputPortSignal(S,$i);\n";
            } elsif ($InWordLength[$i] <= 16) {
              print OUT "    const " . $isSigned . "int16_T  *$InPortName[$i]  = (const " . $isSigned . "int16_T*) ssGetInputPortSignal(S,$i);\n";
            } elsif ($InWordLength[$i] <= 32) {             
              print OUT "    const " . $isSigned . "int32_T  *$InPortName[$i]  = (const " . $isSigned . "int32_T*) ssGetInputPortSignal(S,$i);\n";
            } else {
              print OUT "    const " . $isSigned . "int64_T  *$InPortName[$i]  = (const  " . $isSigned . "int64_T*) ssGetInputPortSignal(S,$i);\n";
           }
         } else {
          print OUT "    const $InDataType[$i]   *$InPortName[$i]  = (const $InDataType[$i]*) ssGetInputPortSignal(S,$i);\n";
         }
       }
     }
   }
    next;
  }
  if(/--OutputDataTypeDeclaration--/){

    for($i=0;$i<$NumberOfOutputPorts; $i++){
        if($IsOutBusBased[$i] == 1){
            print OUT "    char *$OutPortName[$i] = (char *) ssGetOutputPortSignal(S,$i);\n";
        }
        else{
      if($OutDataType[$i] =~ /\bfixpt\b/) {
            $isSigned = "u";
            if($OutIsSigned[$i]) {
               $isSigned = "";
            }
            if ($OutWordLength[$i] <= 8) {
              print OUT "    "  . $isSigned . "int8_T     *$OutPortName[$i]   = (const " . $isSigned . "int8_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } elsif ($OutWordLength[$i] <= 16) {
              print OUT "    "  .  $isSigned . "int16_T   *$OutPortName[$i]  = (const " . $isSigned . "int16_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } elsif ($OutWordLength[$i] <= 32) {             
              print OUT "    "  . $isSigned . "int32_T    *$OutPortName[$i]  = (const " . $isSigned . "int32_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } else {
              print OUT "    "  . $isSigned . "int64_T    *$OutPortName[$i]  = (const  " . $isSigned . "int64_T*) ssGetOutputPortRealSignal(S,$i);\n";
           }
      } else {
        print OUT "    $OutDataType[$i]        *$OutPortName[$i]  = ($OutDataType[$i] *)ssGetOutputPortRealSignal(S,$i);\n";
      }
     }
    }
    next; 
  }

  if(/--mdlOutputsNumDiscStates--/) {
    if($NumDiscStates){
      print OUT "    const real_T   *xD = ssGetDiscStates(S);\n";
    }
    next;
  }
  if(/--mdlOutputsNumContStates--/) {
    if($NumContStates){
      print OUT "    const real_T   *xC = ssGetContStates(S);\n";
    }
    next;
  }

  if(/--mdlOutputsNumParams--/){
    print OUT writeParamsDeclaration();
    $complex_parameter_str = writeParamsDeclaration_cmplx();
    next;
  }
  
  
  if(/--mdlOutputsPortWidthDeclaration--/) {
    if($flagDynSize == 1 && $directFeed > 0 ){
      print OUT "    const int_T        y_width = ssGetOutputPortWidth(S,0);\n";
      print OUT "    const int_T        u_width = ssGetInputPortWidth(S,0);\n";
    }
    next;
  }


  if(/--mdlOutputFunctionCall--/){
      if($flag_Busused == 1){
          $OutputBusFcn = genFunctionforBus($businfoFile,$fcnCallOutput,$complex_parameter_str);
          print OUT $OutputBusFcn;
      }else{
          print OUT    $complex_parameter_str;
           print OUT "    $fcnCallOutput\n";
      }
    next;
  }

  ##############
  # mdlUpdate #
  ##############

  if(/--Define_MDL_UPDATE--/){
    if($NumDiscStates){
   print OUT "#define MDL_UPDATE  /* Change to #undef to remove function */\n"; 
   print OUT "/* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
  static void mdlUpdate(SimStruct *S, int_T tid)
  {\n";
      }
    next;
  }
  if(/--mdlUpdateInputDataTypeDeclaration--/){
   if ($NumDiscStates) {
      print OUT "    real_T         *xD  = ssGetDiscStates(S);\n";
      for($i=0;$i<$NumberOfInputPorts; $i++){
       if($InDataType[$i] =~ /\bfixpt\b/) {
            $isSigned = "";
            if($InIsSigned[$i]) {
               $isSigned = "u";
             }
            if ($InWordLength[$i] <= 8) {
              print OUT "    const " . $isSigned . "int8_T  *$InPortName[$i]   = (const " . $isSigned . "int8_T*) ssGetInputPortSignal(S,$i);\n";
            } elsif ($InWordLength[$i] <= 16) {
              print OUT "    const " . $isSigned . "int16_T  *$InPortName[$i]  = (const " . $isSigned . "int16_T*) ssGetInputPortSignal(S,$i);\n";
            } elsif ($InWordLength[$i] <= 32) {             
              print OUT "    const " . $isSigned . "int32_T  *$InPortName[$i]  = (const " . $isSigned . "int32_T*) ssGetInputPortSignal(S,$i);\n";
            } else {
              print OUT "    const " . $isSigned . "int64_T  *$InPortName[$i]  = (const  " . $isSigned . "int64_T*) ssGetInputPortSignal(S,$i);\n";
           }
        } else {
            if($IsInBusBased[$i] == 1){
                print OUT "    const char *$InPortName[$i] = (char *) ssGetInputPortSignal(S,$i);\n";
            }
            else{
                print OUT "    const $InDataType[$i]   *$InPortName[$i]  = (const $InDataType[$i]*) ssGetInputPortSignal(S,$i);\n";
            }
        }
   }
  } 
   next;
  }

  if(/--mdlUpdateOutputDataTypeDeclaration--/) {
    if ($NumDiscStates) {
      for($i=0;$i<$NumberOfOutputPorts; $i++){
       if($OutDataType[$i] =~ /\bfixpt\b/) {
           $isSigned = "u";
            if($OutIsSigned[$i]) {
               $isSigned = "";
            }
            if ($OutWordLength[$i] <= 8) {
              print OUT "    "  . $isSigned . "int8_T     *$OutPortName[$i]   = (const " . $isSigned . "int8_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } elsif ($OutWordLength[$i] <= 16) {
              print OUT "    "  .  $isSigned . "int16_T   *$OutPortName[$i]  = (const " . $isSigned . "int16_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } elsif ($OutWordLength[$i] <= 32) {             
              print OUT "    "  . $isSigned . "int32_T    *$OutPortName[$i]  = (const " . $isSigned . "int32_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } else {
              print OUT "    "  . $isSigned . "int64_T    *$OutPortName[$i]  = (const  " . $isSigned . "int64_T*) ssGetOutputPortRealSignal(S,$i);\n";
           }
       } else {
           if($IsOutBusBased[$i] == 1){
                print OUT "    char *$OutPortName[$i] = (char *) ssGetOutputPortSignal(S,$i);\n";
            }
            else{
                print OUT "    $OutDataType[$i]        *$OutPortName[$i]  = ($OutDataType[$i] *)ssGetOutputPortRealSignal(S,$i);\n";
            } 
       }
   }
  }
    next; 
  }
  if(/--mdlUpdateNumParams--/) {
   if ($NumDiscStates) {
      print OUT writeParamsDeclaration();
      $complex_parameter_str = writeParamsDeclaration_cmplx();

      if($flagDynSize == 1){
          print OUT "    const int_T     y_width = ssGetOutputPortWidth(S,0);\n";
          print OUT "    const int_T     u_width = ssGetInputPortWidth(S,0);\n";
      }
   }
    next;
}

  if(/--mdlUpdateFunctionCall--/){
    if ($NumDiscStates) {
        if($flag_Busused == 1){
            $UpdateBusFcn = genFunctionforBus($businfoFile,$fcnCallUpdate,$complex_parameter_str);
            print OUT $UpdateBusFcn;
        }
        else{
            print OUT "    $fcnCallUpdate";
            print OUT    $complex_parameter_str;
        }        
        print OUT "\n}\n";
    }
    next;
  } 

  ##################
  # mdlDerivatives #
  ##################

  if(/--Define_MDL_DERIVATIVES--/){
    if($NumContStates){
      print OUT "#define MDL_DERIVATIVES  /* Change to #undef to remove function */\n"; 
      print OUT "/* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
  static void mdlDerivatives(SimStruct *S)
  {\n";
    }
  next;
  }
  if(/--mdlDerivativesInputDataTypeDeclaration--/){
   if($NumContStates){
    for($i=0;$i<$NumberOfInputPorts; $i++){
      if($InDataType[$i] =~ /\bfixpt\b/) {
            $isSigned = "u";
            if($InIsSigned[$i]) {
               $isSigned = "";
             }
            if ($InWordLength[$i] <= 8) {
              print OUT "    const " . $isSigned . "int8_T  *$InPortName[$i]   = (const " . $isSigned . "int8_T*) ssGetInputPortSignal(S,$i);\n";
            } elsif ($InWordLength[$i] <= 16) {
              print OUT "    const " . $isSigned . "int16_T  *$InPortName[$i]  = (const " . $isSigned . "int16_T*) ssGetInputPortSignal(S,$i);\n";
            } elsif ($InWordLength[$i] <= 32) {             
              print OUT "    const " . $isSigned . "int32_T  *$InPortName[$i]  = (const " . $isSigned . "int32_T*) ssGetInputPortSignal(S,$i);\n";
            } else {
              print OUT "    const " . $isSigned . "int64_T  *$InPortName[$i]  = (const  " . $isSigned . "int64_T*) ssGetInputPortSignal(S,$i);\n";
           }
      } else {
          if($IsInBusBased[$i] == 1){
              print OUT "    const char *$InPortName[$i] = (char *) ssGetInputPortSignal(S,$i);\n";
          }
          else{
              print OUT "    const $InDataType[$i]   *$InPortName[$i]  = (const $InDataType[$i]*) ssGetInputPortSignal(S,$i);\n";
          }
      }
  }
     print OUT "    real_T         *dx  = ssGetdX(S);\n";
     print OUT "    real_T         *xC  = ssGetContStates(S);\n";
   }
   next;
  }

  if(/--mdlDerivativesOutputDataTypeDeclaration--/) {
    if($NumContStates){
      for($i=0;$i<$NumberOfOutputPorts; $i++){
	if($OutDataType[$i] =~ /\bfixpt\b/) {
            $isSigned = "u";
            if($OutIsSigned[$i]) {
               $isSigned = "";
            }
            if ($OutWordLength[$i] <= 8) {
              print OUT "    "  . $isSigned . "int8_T     *$OutPortName[$i]   = (const " . $isSigned . "int8_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } elsif ($OutWordLength[$i] <= 16) {
              print OUT "    "  .  $isSigned . "int16_T   *$OutPortName[$i]  = (const " . $isSigned . "int16_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } elsif ($OutWordLength[$i] <= 32) {             
              print OUT "    "  . $isSigned . "int32_T    *$OutPortName[$i]  = (const " . $isSigned . "int32_T*) ssGetOutputPortRealSignal(S,$i);\n";
            } else {
              print OUT "    "  . $isSigned . "int64_T    *$OutPortName[$i]  = (const  " . $isSigned . "int64_T*) ssGetOutputPortRealSignal(S,$i);\n";
           }
	} else {
            if($IsOutBusBased[$i] == 1){
                print OUT "    char *$OutPortName[$i] = (char *) ssGetOutputPortSignal(S,$i);\n";
            }
            else{
                print OUT "    $OutDataType[$i]        *$OutPortName[$i]  = ($OutDataType[$i] *) ssGetOutputPortRealSignal(S,$i);\n";
            }
        }
    }
  }
    next;
  }
  if(/--mdlDerivativesNumParams--/) {
   if($NumContStates){
      print OUT writeParamsDeclaration();
      $complex_parameter_str = writeParamsDeclaration_cmplx();
       if($flagDynSize == 1){
           print OUT "    const int_T    y_width = ssGetOutputPortWidth(S,0);\n";
           print OUT "    const int_T    u_width = ssGetInputPortWidth(S,0);\n";
       } 
   }
   next;
  }
  if(/--mdlDerivativesFunctionCall--/) {
      if($NumContStates){
          if($flag_Busused == 1){
              $DerivativeBusFcn = genFunctionforBus($businfoFile,$fcnCallDerivatives,$complex_parameter_str);
              print OUT $DerivativeBusFcn."\n}\n";
          }
          else{
              print OUT    $complex_parameter_str;
              print OUT "    $fcnCallDerivatives\n}\n";
          }
      }
    next;
  } 

   if(/--mdlTerminateDeclaration--/) {
       $writeCacheValue = 1;
       for($i=0; $i < $NumParams ; $i++) {
         if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
             if ($writeCacheValue == 1) {
                 print OUT  "    SFcnBCache *c = (SFcnBCache *)ssGetUserData(S);";
                 print OUT "\n    if (c!=NULL) { ";
                 $writeCacheValue = 2;
                 print OUT "\n    /*Free complex parameter information*/";
             }
             print OUT "\n      free(c->". "$ParameterName[$i]" . ");";           
         }
       }
      
       if ($writeCacheValue == 2) {
           if($flag_Busused == 1){
               print OUT "\n    /*Free bus information*/";
               print OUT "\n      free(c->busInfo);";
           }
           print OUT "\n      free(c);";
           print OUT "\n    }";
           print OUT  "\n      ssSetUserData(S,NULL);\n";
       }
       else{
           if($flag_Busused == 1){
               print OUT  "    /*Free stored bus information*/
    int_T *busInfo = (int_T *) ssGetUserData(S);
    if(busInfo!=NULL) {
      free(busInfo);
    }\n"
    }
       }
     next;
    } 

  if(/--GetRTWEnvironmentMode--/){
      if($flag_Busused == 1){
          $GetRTWStaticFunctionStr = "

static int_T GetRTWEnvironmentMode(SimStruct *S)
{
    int_T status;
    mxArray *plhs[1];
    mxArray *prhs[1];
    int_T err;
    
    /*
      * Get the name of the Simulink block diagram
    */
    prhs[0] = mxCreateString(ssGetModelName(ssGetRootSS(S)));
    plhs[0] = NULL;
    
    /*
      * Call \"isSimulationTarget = rtwenvironmentmode(modelName)\" in MATLAB
    */
    mexSetTrapFlag(1);
    err = mexCallMATLAB(1, plhs, 1, prhs, \"rtwenvironmentmode\");
    mexSetTrapFlag(0);
    mxDestroyArray(prhs[0]);
    
    /*
     * Set the error status if an error occurred
    */
    if (err) {
        if (plhs[0]) {
            mxDestroyArray(plhs[0]);
            plhs[0] = NULL;
        }
        ssSetErrorStatus(S, \"Unknow error during call to 'rtwenvironmentmode'.\");
        return -1;
    }
    
    /*
      * Get the value returned by rtwenvironmentmode(modelName)
    */
   if (plhs[0]) {
       status = (int_T) (mxGetScalar(plhs[0]) != 0);
       mxDestroyArray(plhs[0]);
       plhs[0] = NULL;
   }
    
    return (status);
}

";
          print OUT $GetRTWStaticFunctionStr;
      }
      next;      
  }


   if(/--IncludeFixedPointDotC--/) {
     if($IsFixedBeingPropagated == 1) {
       print OUT "#include \"fixedpoint.c\"\n"; 
     }
     next;
    } 
    print OUT $_;
 
}    

close(IN);
close(OUT);
close(HC);
close(HTEMP);
close(HeaderF);
close(dStatesHandle);
close(CStatesHandle);


#################################
# Create the S-function Wrapper #
#################################

while (<INWrapper>) { 
 my($linewrapper) = $_;
 #Don't print Copyright
 if($. == 1 ) { next; }
 if($. == 2 ) { next; }

 if(/--WrapperIntroduction--/) {
    $strIntro = genWrapperIntro($timeString);
    print OUTWrapper "$strIntro\n"; 
    next;
  }

 if(/--IncludeSimStuctOrRTWTypes--/) {
   print OUTWrapper getIncludeTypes(); 
   next;
  }

 if(/--IncludeBusHeader--/) {
    if($Gen_HeaderFile == 1){
        print OUTWrapper "\n";
        print OUTWrapper "#include \"$sfunBusHeaderFile\"\n";
    }
    else{
        print OUTWrapper "\n$bus_Header_List";
    }
   next;
  }
 
 if(/--IncludeHeaders--/) {
    print OUTWrapper @headerArray;
    next;
  }

 if(/--DefinesWidths--/){ 
   if($flagDynSize == 2) {
     print OUTWrapper "#define u_width $InRow[0]\n";
     print OUTWrapper "#define y_width $OutCol[0]\n";
   }
    next;
 }
 ######################
 # Extern declaration #
 ######################
 if(/--WrapperExternalDecalrations--/) {
   if($flagL){
     print OUTWrapper @externDeclarationsArray;
   }
    next;
 }
 
 if(/--mdlOutputsFcnPrototype--/) {
   print OUTWrapper "$fcnProtoTypeOutput\n";
   next; 
 }
 if(/--mdlOutputsFcnCode--/) {
     print OUTWrapper @mdlOutputArray;
     print OUTWrapper "\n";
     next;  
 }

if(/--mdlUpdateFcnPrototype--/) {
 if ($NumDiscStates) {
  print OUTWrapper "\n/*
  * Updates function
  *
  */\n";
  print OUTWrapper "$fcnProtoTypeUpdate\n";
  print OUTWrapper "{
  /* %%%-SFUNWIZ_wrapper_Update_Changes_BEGIN --- EDIT HERE TO _END */\n";
 }
  next;
}

if(/--mdlUpdateFcnCode--/) {
 if ($NumDiscStates) {
   print OUTWrapper @discStatesArray;
   print OUTWrapper "\n";
   print OUTWrapper "/* %%%-SFUNWIZ_wrapper_Update_Changes_END --- EDIT HERE TO _BEGIN */\n}\n";
 }
  next;
 }

if(/--mdlDerivativesFcnPrototype--/) {
 if($NumContStates){
  print OUTWrapper "\n/*
  *  Derivatives function
  *
  */\n";
  print OUTWrapper "$fcnProtoTypeDerivatives\n";
  print OUTWrapper "{\n/* %%%-SFUNWIZ_wrapper_Derivatives_Changes_BEGIN --- EDIT HERE TO _END */\n";
 }
 next;
}

 if(/--mdlDerivativesFcnCode--/) {
  if($NumContStates){
   print OUTWrapper @contStatesArray;
   print OUTWrapper "\n";
   print OUTWrapper "/* %%%-SFUNWIZ_wrapper_Derivatives_Changes_END --- EDIT HERE TO _BEGIN */\n}"; 
  }
  next;
}

  print  OUTWrapper $_;
}
close(INWrapper);
close(OUTWrapper);

#################################
# Create the Wrapper TLC        #
#################################

if($CreateWrapperTLC) {

  $sfunNameWrapperTLC = $sFName . ".tlc";
  $sfNameWrapperTLC = $sFName . "_wrapper";
  
  $fcnCallOutputTLC =  genFunctionCallOutputTLC($NumParams, $NumDiscStates,$NumContStates, 
                                                $OutputfcnStr,$sFName ,  $flagDynSize,0);

  $fcnCallOutputTLC1 =  genFunctionCallOutputTLC($NumParams, $NumDiscStates,$NumContStates, 
                                                $OutputfcnStr,$sFName ,  $flagDynSize,1);

  if ($fcnCallOutputTLC1){
      $fcnCallOutputTLC = $fcnCallOutputTLC1."  %else\n"."\t".$fcnCallOutputTLC."  %endif\n";
  }
  
  $stateDStrTLC = "%<pxd>";
  $fcnCallUpdateTLC = genFunctionCallTLC($NumParams,$NumDiscStates,$UpdatefcnStr,$stateDStrTLC, $sFName, 0);
  $fcnCallUpdateTLC1 = genFunctionCallTLC($NumParams,$NumDiscStates,$UpdatefcnStr,$stateDStrTLC, $sFName, 1);

  if ($fcnCallUpdateTLC1){
      $fcnCallUpdateTLC = $fcnCallUpdateTLC1."\n  %else\n"."\t".$fcnCallUpdateTLC."\n  %endif\n";
  }
  
  $stateCStrTLC = "pxc";
  $fcnCallDerivativesTLC = genFunctionCallTLC($NumParams,$NumContStates,$DerivativesfcnStr,$stateCStrTLC ,$sFName, 0);
  $fcnCallDerivativesTLC1 = genFunctionCallTLC($NumParams,$NumContStates,$DerivativesfcnStr,$stateCStrTLC ,$sFName, 1);

  if ($fcnCallDerivativesTLC1){
      $fcnCallDerivativesTLC = $fcnCallDerivativesTLC1."\n  %else\n"."\t".$fcnCallDerivativesTLC."\n  %endif\n";
  }
  
  open(OUTWrapperTLC,">$sfunNameWrapperTLC") || die "Unable to create $sfunNameWrapperTLC Please check the directory permission\n";
  open(INWrapperTLC, "<$sfun_template_wrapperTLC") || die "Unable to open $sfun_template_wrapperTLC";
  
  while (<INWrapperTLC>) { 
    
    if($. == 1) {
      print OUTWrapperTLC  "%% File : $sFName.tlc" ;
    }
    
    if($. == 2) {
      print OUTWrapperTLC "%% Created: $timeString";
    }
    if($. == 6) {
      print OUTWrapperTLC  "%%   S-function \"$sfunName\"\.";
    }
    #Don't print Copyright
    if($. == 17 ) { next; }
    if($. == 18 ) { next; }

    if(/--ImplementsBlkDef--/) {
      print OUTWrapperTLC "%implements  $sFName \"C\"\n";
      next;
    }

    if(/--ExternDeclarationBusTLC--/) {
        if($flag_Busused == 1){
            $inputSignalFixPtDataInfo ="";
            for($i = 0; $i < $NumberOfInputPorts ; $i++){
                if($InDataType[$i] =~ /\bfixpt\b/) {
                    $inputSignalFixPtDataInfo = $inputSignalFixPtDataInfo . "\n  %assign u$i" . "DT = FixPt_GetInputDataType($i)";
                }
            }
            $outputSignalFixPtDataInfo ="";
            for($i = 0; $i < $NumberOfOutputPorts ; $i++){
                if($OutDataType[$i] =~ /\bfixpt\b/) {
                    $outputSignalFixPtDataInfo = $outputSignalFixPtDataInfo . "\n  %assign y$i" . "DT = FixPt_GetOutputDataType($i)";
                }
            }            
            print OUTWrapperTLC "  $inputSignalFixPtDataInfo";
            print OUTWrapperTLC "  $outputSignalFixPtDataInfo";
            print OUTWrapperTLC "\n  $wrapperExternDeclarationOutputTLCForBus";         
        }
        next;  
    }

    if(/--ExternDeclarationOutputTLC--/) {
       $inputSignalFixPtDataInfo ="";
       for($i = 0; $i < $NumberOfInputPorts ; $i++){
	 if($InDataType[$i] =~ /\bfixpt\b/) {
	   $inputSignalFixPtDataInfo = $inputSignalFixPtDataInfo . "\n  %assign u$i" . "DT = FixPt_GetInputDataType($i)";
	 }
       }
       $outputSignalFixPtDataInfo ="";
       for($i = 0; $i < $NumberOfOutputPorts ; $i++){
	 if($OutDataType[$i] =~ /\bfixpt\b/) {
	   $outputSignalFixPtDataInfo = $outputSignalFixPtDataInfo . "\n  %assign y$i" . "DT = FixPt_GetOutputDataType($i)";
	 }
       }

       print OUTWrapperTLC "  $inputSignalFixPtDataInfo";
       print OUTWrapperTLC "  $outputSignalFixPtDataInfo";
       print OUTWrapperTLC "\n  $wrapperExternDeclarationOutputTLC";
       next;  
     }

     if(/--ExternDeclarationUpdateTLC--/) {
       if($NumDiscStates> 0) {
	 print OUTWrapperTLC "  $wrapperExternDeclarationUpdateTLC";
       }
       next;
     }
     if(/--ExternDeclarationDerivativesTLC--/) {
       if($NumContStates> 0) {
	 print OUTWrapperTLC  "  $wrapperExternDeclarationDerivativesTLC";
       }
       next;
     }

     if(/--ExternDeclarationEndBusTLC--/){
       if($flag_Busused == 1){
	 print OUTWrapperTLC  "\n %endif\n";
       }
       next;
     }

     if(/--mdlInitializeConditionsTLC--/) {
       if ($NumDiscStates || $NumContStates ){
	 $methodInitTLC=get_mdlInitializeConditionsTLC_method($NumDiscStates ,$DStatesIC ,$NumContStates, $CStatesIC);
	 print  OUTWrapperTLC $methodInitTLC;
       }
       next;
     }

      if(/--mdlStartFunctionTLC--/) {
         if($GenerateStartFunction > 0) {
	  print  OUTWrapperTLC genStartFcnMethodsTLC();
	}
       next;
      }
     ###########
     # Outputs #
     ###########
     if(/--OutputsComment--/) {
       print OUTWrapperTLC  "  %%";
       next;
     }
    if(/--OutputsPortsAddrTLC--/) {
      if($directFeed > 0 ) {
          for($i=0; $i < $NumberOfInputPorts ; $i++){
              print OUTWrapperTLC "  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)\n";
          }   
      }
      for($i=0; $i < $NumberOfOutputPorts ; $i++){
	print OUTWrapperTLC "  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)\n";
       }   
     next;
     }

     # DStates
     if(/--OutputsNumDiscStatesTLC--/) {
       if ($NumDiscStates > 0) {
	 print OUTWrapperTLC   "  %assign pxd = LibBlockDWorkAddr(DSTATE, \"\", \"\", 0)\n";
       }
       next;
     }
     if(/--OutputsNumParamsTLC--/) {
       $n = 1;
       for($i=0; $i < $NumParams ; $i++){
	 print OUTWrapperTLC "  %assign nelements$n = LibBlockParameterSize(P$n)\n";
	 print OUTWrapperTLC "  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]\n";
 $paramDeclarationTLC = "%if (param_width$n) > 1
     %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n)
   %else
     %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
   %endif";
	 print OUTWrapperTLC "  $paramDeclarationTLC\n";
	 $n++; 
       }
       next;
     }
     # Port Widths
     if(/--OutputsPortWidthsTLC--/) {
       if($NumberOfOutputPorts > 0 && $directFeed > 0 ) {
	 print  OUTWrapperTLC  "  %assign py_width = LibBlockOutputSignalWidth(0)\n";

       }
      if($NumberOfInputPorts > 0 && $directFeed > 0) {
	 print  OUTWrapperTLC  "  %assign pu_width = LibBlockInputSignalWidth(0)\n";
      }
       next;  
     }
     # CStates
     if(/--OutputsCodeAndNumContStatesTLC--/) {
       if($NumContStates > 0) {
	 if($UseSimStruct) {
	   print OUTWrapperTLC getSimStructAccessTLC_Code();
	   $simStructDec = "\n    " . getSimStructDec();
	 } else {
	   $simStructDec = "";
	 }
         print  OUTWrapperTLC " { $simStructDec\n    real_T *pxc = &%<LibBlockContinuousState(\"\", \"\", 0)>;\n    $fcnCallOutputTLC  }";
       } else {
	 if($UseSimStruct) {
	   print OUTWrapperTLC getSimStructAccessTLC_Code() . "  {\n    " .  getSimStructDec(). "\n";
	   print OUTWrapperTLC   "    $fcnCallOutputTLC  }";
	 } else {
	   print OUTWrapperTLC   "  $fcnCallOutputTLC";
	}
       }
       next;
     }

     ###########
     # Update  #
     ###########
     if(/--UpdateFunctionTLC--/) {
       if($NumDiscStates> 0){
	 $bFcn = getBodyFunctionUpdateTLC($NumParams, $sfNameWrapperTLC, $fcnCallUpdateTLC);
	 print  OUTWrapperTLC  $bFcn;
       }
       next;
     }
     ###############
     # Derivatives #
     ###############
     if(/--DerivativesFunctionTLC--/) {
       if($NumContStates> 0){
	 $bFcn =  getBodyFunctionDerivativesTLC($NumParams, $sfNameWrapperTLC, $fcnCallDerivativesTLC);
	 print  OUTWrapperTLC  $bFcn;
       }
       next;
     }
     ###############
     # Terminate   #
     ###############
     if(/--TerminateFunctionTLC--/) {
       if($GenerateTerminateFunction > 0) {
	 print  OUTWrapperTLC genTerminateFcnMethodsTLC();
       }
      next;
     }
     if(/--EOF--/) {
       print OUTWrapperTLC  "\n%% [EOF] $sfunNameWrapperTLC";
       next;
     }

     print  OUTWrapperTLC $_;
   }

   close(INWrapperTLC);
   close(OUTWrapperTLC);

###########################################################################
# Create the RTWMAKECFG.M file for use with RTW_C.M.
# This file looks in the current folder for <sfunction>__SFB__.mat files
# that contain configuration information for any additional library paths,
# source paths, include paths to be added to the build process.
###########################################################################
$ErrMsgCouldNotOpenRTWMAKECFGFileForRead = 
"Could not open rtwmakecfg.m to read ".
"even though it exists in the current folder.".
"Please check to see that the file is a readable ".
"text file. Please also check the read permissions on ".
"the file. Simply removing the file from the current ".
"folder should solve the problem.";

$ErrMsgCouldNotOpenRTWMAKECFGFileForWrite = 
    "Could not open rtwmakecfg.m to write.".
    "Please check to see that the folder has write permissions.";

$titleForRTWMAKECFG = "function makeInfo=rtwmakecfg()
%RTWMAKECFG adds include and source directories to rtw make files.
%  makeInfo=RTWMAKECFG returns a structured array containing
%  following field:
%     makeInfo.includePath - cell array containing additional include
%                            directories. Those directories will be
%                            expanded into include instructions of rtw
%                            generated make files.
%
%     makeInfo.sourcePath  - cell array containing additional source
%                            directories. Those directories will be
%                            expanded into rules of rtw generated make
%                            files.
makeInfo.includePath = {};
makeInfo.sourcePath  = {};
makeInfo.linkLibsObjs = {};
";

$sfBuilderInsertTag = "\n%<Generated by S-Function Builder ".$sfbVersion.". DO NOT REMOVE>\n";
$customBodyForRTWMAKECFG = 
$sfBuilderInsertTag."
sfBuilderBlocksByMaskType = find_system(bdroot,'FollowLinks','on','MaskType','S-Function Builder');
sfBuilderBlocksByCallback = find_system(bdroot,'OpenFcn','sfunctionwizard(gcbh)');
sfBuilderBlocksDeployed   = find_system(bdroot,'BlockType','S-Function','SFunctionDeploymentMode','on');
sfBuilderBlocks = {sfBuilderBlocksByMaskType{:} sfBuilderBlocksByCallback{:} sfBuilderBlocksDeployed{:}};
sfBuilderBlocks = unique(sfBuilderBlocks);
if isempty(sfBuilderBlocks)
   return;
end
for idx = 1:length(sfBuilderBlocks)
   sfBuilderBlockNameMATFile{idx} = get_param(sfBuilderBlocks{idx},'FunctionName');
   sfBuilderBlockNameMATFile{idx} = ['.' filesep 'SFB__' char(sfBuilderBlockNameMATFile{idx}) '__SFB.mat'];
end
sfBuilderBlockNameMATFile = unique(sfBuilderBlockNameMATFile);
for idx = 1:length(sfBuilderBlockNameMATFile)
   if exist(sfBuilderBlockNameMATFile{idx})
      loadedData = load(sfBuilderBlockNameMATFile{idx});
      if isfield(loadedData,'SFBInfoStruct')
         makeInfo = UpdateMakeInfo(makeInfo,loadedData.SFBInfoStruct);
         clear loadedData;
      end
   end
end
";
$sfBuilderUpdateMakeInfoFcn = "
function updatedMakeInfo = UpdateMakeInfo(makeInfo,SFBInfoStruct)
updatedMakeInfo = {};
if isfield(makeInfo,'includePath')
   if isfield(SFBInfoStruct,'includePath')
      updatedMakeInfo.includePath = {makeInfo.includePath{:} SFBInfoStruct.includePath{:}};
   else
      updatedMakeInfo.includePath = {makeInfo.includePath{:}};
   end
end
if isfield(makeInfo,'sourcePath')
   if isfield(SFBInfoStruct,'sourcePath')
      updatedMakeInfo.sourcePath = {makeInfo.sourcePath{:} SFBInfoStruct.sourcePath{:}};
   else
      updatedMakeInfo.sourcePath = {makeInfo.sourcePath{:}};
   end
end
if isfield(makeInfo,'linkLibsObjs')
   if isfield(SFBInfoStruct,'additionalLibraries')
      updatedMakeInfo.linkLibsObjs = {makeInfo.linkLibsObjs{:} SFBInfoStruct.additionalLibraries{:}};
   else
      updatedMakeInfo.linkLibsObjs = {makeInfo.linkLibsObjs{:}};
   end
end
";

$fileName = "rtwmakecfg.m";

if ( -f $fileName ) {
    open readHandle,"<$fileName" or die $ErrMsgCouldNotOpenRTWMAKECFGFileForRead;
    $fileData = join("",(<readHandle>));
    close(readHandle);
    die "Unable to create an RTWMAKECFG.M file needed ".
    "by the S-Function Builder as it already exists in this folder. Please rename the existing RTWMAKECFG.M file, ".
    "re-build the S-Function Builder target and then consolidate your RTWMAKECFG.M with the ".
    "RTWMAKECFG.M that is generated by the S-Function Builder.\n" unless ( $fileData =~ /$sfBuilderInsertTag/ );
} else {
    open writeHandle,">$fileName" or die $ErrMsgCouldNotOpenRTWMAKECFGFileForWrite;
    print writeHandle $titleForRTWMAKECFG.$customBodyForRTWMAKECFG.$sfBuilderUpdateMakeInfoFcn;
    close(writeHandle);
}
}

 ###################
 #Local functions  #
 ###################
sub getIncludeTypes {
if($UseSimStruct) {
   $includeTypes = "#include \"simstruc.h\"\n";
 } else {
   $includeTypes = "#if defined(MATLAB_MEX_FILE)
#include \"tmwtypes.h\"
#include \"simstruc_types.h\"
#else
#include \"rtwtypes.h\"
#endif";
   }
return $includeTypes;
}

sub isAnyInputSignalAMatrixSignal {
    $isMatrix = 0;
    for($i=0;$i<$NumberOfInputPorts; $i++) {
        if($InCol[$i] > 1 && $InRow[$i] > 1) {
            $isMatrix = 1;
            last;
        }
    }
    return $isMatrix;
}
sub getSimStructString {

  $simStructString = "";
  if($UseSimStruct) {
    $simStructString = ", S";
  }
  return $simStructString;
}

sub getSimStructParamStr {

  $simStructParmString = "";
  if($UseSimStruct) {
    $simStructParmString = ", SimStruct *S";
  }
  return $simStructParmString;
}
sub getTLCSimStructStr {

  $TLCSimStructString = "";
  if($UseSimStruct) {
    $TLCSimStructString  = ", %<s>";
  }
  return $TLCSimStructString;
}

 sub get_parameters_declaration {
 ($NumParams) =  @_;

 if ($NumParams){
 $declareNumParams = 
 "    ssSetNumSFcnParams(S, NPARAMS);  /* Number of expected parameters */
      #if defined(MATLAB_MEX_FILE)
	if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
	  mdlCheckParameters(S);
	  if (ssGetErrorStatus(S) != NULL) {
	    return;
	  }
	 } else {
	   return; /* Parameter mismatch will be reported by Simulink */
	 }
      #endif\n";
 }
 else{

 $declareNumParams= "    ssSetNumSFcnParams(S, NPARAMS);
     if (ssGetNumSFcnParams(S) != ssGetSFcnParamsCount(S)) {
	 return; /* Parameter mismatch will be reported by Simulink */
     }\n";
 }
 return $declareNumParams;
 }

sub getSimStructAccessTLC_Code {
$SimStructAccessTLCcode  = "  %if EXISTS(\"block.SFunctionIdx\") == 0
     %% Register S-function in the Model S-function list
     %assign SFunctionIdx = NumChildSFunctions
     %assign block = block + SFunctionIdx
     %assign ::CompiledModel.ChildSFunctionList = ...
       ::CompiledModel.ChildSFunctionList + block
      
  %endif
  %assign s = tChildSimStruct\n";

return $SimStructAccessTLCcode;
}
sub getSimStructDec {

  return "SimStruct *%<s> = %<RTMGetIdxed(\"SFunction\", block.SFunctionIdx)>;";
}
 sub get_mdlCheckParameters_method 
 {
   #(xxx) make this code into data driven table
   $checkparams = "";
   local $i;
   for($i=0; $i < $NumParams ; $i++){
     # parameter is the sample time
     if($ParameterName[$i] =~  /\b$sampleTime\b/){
       $ErrorStringParam = "Sample time parameter $ParameterName[$i]" .  " must be of type double";
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!mxIsDouble(pVal$i)) {
	    ssSetErrorStatus(S,\"$ErrorStringParam\");
	    return; 
	  }
	 }";
     }
     # Double parameters
     if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\breal_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_DOUBLE(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
     # Double Complex parameters
    if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcreal_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_DOUBLE_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
    #Single parameters
    if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\breal32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_SINGLE(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
    #Single Complex parameters
    if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcreal32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_SINGLE_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }
    #Int8 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT8(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Int8 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT8_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }


    #Int16 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT16(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Int16 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT16_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Int32 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT32(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Int32 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_INT32_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Uint8 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\buint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT8(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Uint8 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcuint8_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT8_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Uint16 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\buint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT16(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Uint16 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcuint16_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT16_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Uint32 parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\buint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT32(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

   #Uint32 Complex parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_YES/ && $ParameterDataType[$i] =~ /\bcuint32_T\b/) {
       $checkparams =   $checkparams . "\n
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_UINT32_CPLX(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }

    #Boolean parameters
   if($ParameterComplexity[$i]  =~ /COMPLEX_NO/ && $ParameterDataType[$i] =~ /\bboolean_T\b/) {
       $checkparams =   $checkparams . "
	 {
	  const mxArray *pVal$i = ssGetSFcnParam(S,$i);
	  if (!IS_PARAM_BOOLEAN(pVal$i)) {
	    validParam = true;
	    paramIndex = $i;
	    goto EXIT_POINT;
	  }
	 }";
      }


   }
   $paramVector = "char paramVector[] ={'1'";
   local $n = 2;
   for($i=1; $i < $NumParams ; $i++){
     $paramVector = $paramVector . ",'$n'";
     $n++;
   }
   $paramVector = $paramVector ."};";
   $initSfcnCache;
   $writeCache = 0;
   for($i=0; $i < $NumParams ; $i++) {
        if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
            $writeCache = 1;
        }
    }
   if($writeCache == 1) {
       $initSfcnCache = "{\n";
       for($i=0; $i < $NumParams ; $i++) {
        if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
             $initSfcnCache = $initSfcnCache . 
                 "      $ParameterDataType[$i]*  $ParameterName[$i] = ($ParameterDataType[$i] *)malloc(mxGetNumberOfElements(PARAM_DEF$i(S))*sizeof($ParameterDataType[$i]));\n";     
        }
      }
       $initSfcnCache = $initSfcnCache . "      SFcnBCache *c = (SFcnBCache *)ssGetUserData(S);";
       $initSfcnCache = $initSfcnCache . 
           "\n      if (c != NULL) {";
       for($i=0; $i < $NumParams ; $i++) {
           if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
               $initSfcnCache = $initSfcnCache . "\n        free(c->". "$ParameterName[$i]" . ");";
           }
       }

       if($flag_Busused == 1){
           $initSfcnCache = $initSfcnCache .
           "\n        free(c->busInfo);"
       }
       $initSfcnCache = $initSfcnCache .
            " \n        free(c);
        ssSetUserData(S,NULL);
      }";
       $initSfcnCache = $initSfcnCache . "\n      c = (SFcnBCache *) calloc(1, sizeof(SFcnBCache));
       if (c == NULL) {
        ssSetErrorStatus(S, \"Memory allocation failed\");
        goto EXIT_POINT;
       }";
       for($i=0; $i < $NumParams ; $i++) {
           if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
               $initSfcnCache = $initSfcnCache . "\n      c->" . "$ParameterName[$i] = $ParameterName[$i];";
         }
       }
       $initSfcnCache = $initSfcnCache . "\n      ssSetUserData(S,c);";
       $initSfcnCache = $initSfcnCache . "\n     }"
   }
 $Body = "#define MDL_CHECK_PARAMETERS
 #if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)
   /* Function: mdlCheckParameters =============================================
     * Abstract:
     *    Validate our parameters to verify they are okay.
     */
    static void mdlCheckParameters(SimStruct *S)
    {
     int paramIndex  = 0;
     bool validParam = false;
     /* All parameters must match the S-function Builder Dialog */
     $checkparams
     $initSfcnCache 
     EXIT_POINT:
      if (validParam) {
          char parameterErrorMsg[1024];
          sprintf(parameterErrorMsg, \"The data type and or complexity of parameter  %d does not match the \"
                  \"information specified in the S-function Builder dialog. \"
                  \"For non-double parameters you will need to cast them using int8, int16, \"
                  \"int32, uint8, uint16, uint32 or boolean.\", paramIndex + 1);
	  ssSetErrorStatus(S,parameterErrorMsg);
      }
	return;
    }
 #endif /* MDL_CHECK_PARAMETERS */\n";

 return $Body;
 }


sub genBusString
{
my($busString);

if($_[1] == 1)
{
    $busString = "
  /* Register $InBusname[$_[0]] datatype for Input port $_[0] */

    #if defined(MATLAB_MEX_FILE)
    if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY)
    {
      DTypeId dataTypeIdReg;
      ssRegisterTypeFromNamedObject(S, \"$InBusname[$_[0]]\", &dataTypeIdReg);
      if(dataTypeIdReg == INVALID_DTYPE_ID) return;
      ssSetInputPortDataType(S,$_[0], dataTypeIdReg);
    }
    #endif
    ssSetInputPortWidth(S, $_[0], INPUT_$_[0]_WIDTH);
    ssSetInputPortComplexSignal(S, $_[0], INPUT_$_[0]_COMPLEX);
    ssSetInputPortDirectFeedThrough(S, $_[0], INPUT_$_[0]_FEEDTHROUGH);
    ssSetInputPortRequiredContiguous(S, $_[0], 1); /*direct input signal access*/
    ssSetBusInputAsStruct(S, $_[0],IN_$_[0]_BUS_BASED);
    ssSetInputPortBusMode(S, $_[0], SL_BUS_MODE);";
}

else
{
    $busString = "
  /* Register $OutBusname[$_[0]] datatype for Output port $_[0] */

  #if defined(MATLAB_MEX_FILE)
    if (ssGetSimMode(S) != SS_SIMMODE_SIZES_CALL_ONLY)
    {
      DTypeId dataTypeIdReg;
      ssRegisterTypeFromNamedObject(S, \"$OutBusname[$_[0]]\", &dataTypeIdReg);
      if(dataTypeIdReg == INVALID_DTYPE_ID) return;
        ssSetOutputPortDataType(S,$_[0], dataTypeIdReg);
    }
    #endif

    ssSetBusOutputObjectName(S, $_[0], (void *) \"$OutBusname[$_[0]]\");
    ssSetOutputPortWidth(S, $_[0], OUTPUT_$_[0]_WIDTH);
    ssSetOutputPortComplexSignal(S, $_[0], OUTPUT_$_[0]_COMPLEX);
    ssSetBusOutputAsStruct(S, $_[0],OUT_$_[0]_BUS_BASED);
    ssSetOutputPortBusMode(S, $_[0], SL_BUS_MODE);";

}
return $busString;
}


 sub get_mdlInitializeConditions_method 
 {

 ($NumDStates, $dIC, $NumCStates, $cIC ) =  @_;

 $dIC =~ s/\s+/,/;
 $cIC =~ s/\s+/,/;
 $dIC =~ s/,{1,}/,/;
 $cIC =~ s/,{1,}/,/;

 @vectordIC = split(',', $dIC);
 @vectorcIC = split(',', $cIC);

 $IsInitialConditionNotUsedAsParamter = 1;
 if($NumDStates){
   $declareDInitC = "real_T *xD   = ssGetRealDiscStates(S);";
  
   for($i=0; $i < $NumDStates; $i++){
     for($k=0;$k<$NumParams; $k++){
       if ($vectordIC[$i] =~ /\b$ParameterName[$k]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
             if( $ParameterName[$k] =~  /\^$vectordIC[$i]\$/){  
                 $initD =  "$initD\n    xD[$i] =  *mxGetPr(ssGetSFcnParam(S, $k));/* adfasd */";  
             } else {
                 $exp = $vectordIC[$i];
                 $exp =~ s/$ParameterName[$k]/(*mxGetPr(ssGetSFcnParam(S, $k)))/;
                 $initD =  "$initD\n    xD[$i] = $exp;";  
             }
	 } else { 
	   $initD =  "$initD\n    xD[$i] = 0.0; /* State must be of type double */";  
	 }
	 $IsInitialConditionNotUsedAsParamter = 0;
	 last;
	} else {
	  $IsInitialConditionNotUsedAsParamter = 1;
	}
     }
     if( $IsInitialConditionNotUsedAsParamter) {
       $initD =  "$initD\n    xD[$i] =  $vectordIC[$i];";  
     }
   }
 }

 $IsInitialConditionNotUsedAsParamterForContStates = 1;

 if($NumCStates){
  $declareCInitC = "real_T *xC   = ssGetContStates(S);";

   for($i=0; $i < $NumCStates; $i++){
     for($k=0;$k<$NumParams; $k++){
       if ($vectorcIC[$i] =~ /\b$ParameterName[$k]\b/){
	 if ($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
               if($ParameterName[$k] =~  /\^$vectorcIC[$i]\$/){ 
                   $initC =  "$initC\n    xC[$i] = *mxGetPr(ssGetSFcnParam(S, $k));";
               } else {
                   $exp = $vectorcIC[$i];
                   $exp =~ s/$ParameterName[$k]/(*mxGetPr(ssGetSFcnParam(S, $k)))/;
                   $initC =  "$initC\n    xC[$i] = $exp;";  
               }
	 } else {
	   $initC =  "$initC\n    xC[$i] = 0.0; /* State must be of type double */";  
	 }
	 $IsInitialConditionNotUsedAsParamterForContStates = 0;
	 last;
       } else {
	 $IsInitialConditionNotUsedAsParamterForContStates = 1;
       }
     }
     if($IsInitialConditionNotUsedAsParamterForContStates) {
       $initC =  "$initC\n    xC[$i] =  $vectorcIC[$i];";  
     }
   }
}

 $modymdlInitCond ="#define MDL_INITIALIZE_CONDITIONS
 /* Function: mdlInitializeConditions ========================================
  * Abstract:
  *    Initialize the states
  */
 static void mdlInitializeConditions(SimStruct *S)
 {
   $declareDInitC
   $declareCInitC
    $initD
    $initC
 }";

 return $modymdlInitCond;
 }

 sub get_mdlInitializeConditionsTLC_method {

 ($NumDStates, $dIC, $NumCStates, $cIC ) =  @_;
 @vectordIC = split(',',$dIC);
 @vectorcIC = split(',',$cIC);

 if($NumDStates){  

   for($i=0; $i < $NumDStates; $i++){
     $n = 1;
     for($k=0;$k<$NumParams; $k++){
       if($ParameterName[$k] =~  /\b$vectordIC[$i]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
	   $pinit = "%<pp" . $n . ">";
	   $_ = $dIC;
	   $dIC =~ s/$ParameterName[$k]/$pinit/e;
   $paramNeeded = " $paramNeeded\n   %assign nelements$n = LibBlockParameterSize(P$n)
   %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]
   %if (param_width$n) > 1
     %assign pp$n = LibBlockMatrixParameter(P$n)
   %else
     %assign pp$n = LibBlockParameter(P$n, \"\", \"\", 0)
   %endif\n";
	 }
       }
       $n++;
     }
   }

  $discreteInitCondDec = "real_T initVector[$NumDStates] = {$dIC};\n";

  $discStatesCode = "{\n"."$paramNeeded
   $discreteInitCondDec"."   %assign rollVars = [\"<dwork>/DSTATE\"]
   %assign rollRegions = [0:%<LibBlockDWorkWidth(DSTATE)-1>]
   %roll sigIdx = rollRegions, lcv = 1, block, \"Roller\", rollVars
     %if %<LibBlockDWorkWidth(DSTATE)> == 1
       %<LibBlockDWork(DSTATE, \"\", lcv, sigIdx)> = initVector[0];
      %else
       %<LibBlockDWork(DSTATE, \"\", lcv, sigIdx)> = initVector[%<lcv>];
      %endif
   %endroll"."\n  }";
 }

 @vectorcIC = split(',|\s+',$cIC);
 $contStatesCode = "real_T *xC   = &%<LibBlockContinuousState(\"\", \"\", 0)>;";
 if($NumCStates){  

   for($i=0; $i < $NumCStates; $i++){
     $n = 1;
     for($k=0;$k<$NumParams; $k++){
       if($ParameterName[$k] =~  /\b$vectorcIC[$i]\b/){
	 if($ParameterComplexity[$k]  =~ /COMPLEX_NO/ && $ParameterDataType[$k] =~ /\breal_T\b/) {
             if( $ParameterName[$k] =~  /\^$vectorcIC[$i]\$/){  
                 $paramInit = "%<p_c" . $n . ">";
             } else {
                 $exp = $vectorcIC[$i];
                 $paramInit = "%<p_c" . $n . ">";
                 $exp =~ s/$ParameterName[$k]/$paramInit/;
                 $paramInit = $exp;
             }
	   $vectorcIC[$i] = $paramInit;
   $contParamNeeded = " $contParamNeeded\n   %assign pnelements$n = LibBlockParameterSize(P$n)
   %assign cparam_width$n = pnelements$n\[0\] * pnelements$n\[1\]
   %if (cparam_width$n) > 1
     %assign p_c$n = LibBlockMatrixParameter(P$n)
   %else
     %assign p_c$n = LibBlockParameter(P$n, \"\", \"\", 0)
   %endif\n";
	 }
       }
       $n++;
     }
   }

   for($i=0; $i < $NumCStates; $i++) {
     $initCondDec =  "$initCondDec\n    xC[$i] =  $vectorcIC[$i];";  
   }

   $contStatesBody = "{ 
   $contStatesCode
   $contParamNeeded
   $initCondDec
  }";
 }
 $mdlInitCondTLC = "%% InitializeConditions =========================================================
 %%
 %function InitializeConditions(block, system) Output
  /* %<Type> Block: %<Name> */
  $discStatesCode
  $contStatesBody
 %endfunction";

 return  $mdlInitCondTLC;
 }

 sub genIntro {

 my($intro);

 $intro = " *
  *
  *   \--- THIS FILE GENERATED BY S-FUNCTION BUILDER: 3.0 \---
  *
  *   This file is an S-function produced by the S-Function
  *   Builder which only recognizes certain fields.  Changes made
  *   outside these fields will be lost the next time the block is
  *   used to load, edit, and resave this file. This file will be overwritten
  *   by the S-function Builder block. If you want to edit this file by hand, 
  *   you must change it only in the area defined as:  
  *
  *        %%%-SFUNWIZ_defines_Changes_BEGIN
  *        #define NAME 'replacement text' 
  *        %%% SFUNWIZ_defines_Changes_END
  *
  *   DO NOT change NAME--Change the 'replacement text' only.
  *
  *   For better compatibility with the Real-Time Workshop, the
  *   \"wrapper\" S-function technique is used.  This is discussed
  *   in the Real-Time Workshop User\'s Manual in the Chapter titled,
  *   \"Wrapper S-functions\".
  *
  *  -------------------------------------------------------------------------
  * | See matlabroot/simulink/src/sfuntmpl_doc.c for a more detailed template |
  *  ------------------------------------------------------------------------- ";

 return $intro;
 }

 sub genWrapperIntro {

 my($wrapperintro);

 $wrapperintro = "/*
  *
  *   \--- THIS FILE GENERATED BY S-FUNCTION BUILDER: 3.0 \---
  *
  *   This file is a wrapper S-function produced by the S-Function
  *   Builder which only recognizes certain fields.  Changes made
  *   outside these fields will be lost the next time the block is
  *   used to load, edit, and resave this file. This file will be overwritten
  *   by the S-function Builder block. If you want to edit this file by hand, 
  *   you must change it only in the area defined as:  
  *
  *        %%%-SFUNWIZ_wrapper_XXXXX_Changes_BEGIN 
  *            Your Changes go here
  *        %%%-SFUNWIZ_wrapper_XXXXXX_Changes_END
  *
  *   For better compatibility with the Real-Time Workshop, the
  *   \"wrapper\" S-function technique is used.  This is discussed
  *   in the Real-Time Workshop User\'s Manual in the Chapter titled,
  *   \"Wrapper S-functions\".
  *
  *   Created: $timeString
  */";

 return $wrapperintro;
 }

 ############################################################################
 # Outputs Function call i.e:                                               # 
 #  extern void sys_Outputs_wrapper(const real_T *$InPortName[0],           #
 #                             const real_T *$OutPortName[0],               #
 #                             real_T  *param0,  const real_T  *param1);    #
 ############################################################################
 sub genOutputWrapper {

 ($NumParams, $NumDStates, $NumCStates,$fcnType, $sfName, $flagDynSize, $inDType, $outDType, $isTLC, $isAccel) =  @_;
 local $i, $n,$fcnType, $useComma;
 my( $declareU);
 my( $declareY);
 my( $declareUTLC);
 my( $declareYTLC);
 my( $declareUForAccel);
 my( $declareYForAccel);
 my($tempString);
 my($commaStr);
 
  # port widths
 if($flagDynSize == 1 && $directFeed > 0){
     if($isAccel == 2){
         $portwidths = ",\n\t\t\t     y_width, u_width";
     }else{
         $portwidths = ",\n\t\t\t     const int_T y_width, const int_T u_width";
     }
 } else {
     $portwidths = "";
 }
 $fcnPrototypeRequired ="void ". $sfName . "_". $fcnType . "_wrapper(";
 if($isAccel == 1){
     $fcnPrototypeRequired = "void ". $sfName . "_". $fcnType . "_wrapper_accel(";
 }
 elsif($isAccel == 2){
     $fcnPrototypeRequired = $sfName . "_". $fcnType . "_wrapper(";     
 }
  $commaStr = "";
  if( ($NumberOfInputPorts > 0 && $directFeed > 0) || ($NumberOfOutputPorts > 0)) {
    $commaStr = ",";
  }
 ##########
 # inputs #
 ##########
 if( $NumberOfInputPorts > 0 &&  $directFeed > 0 ) {
   if($InDataType[0] =~ /\bfixpt\b/) {
     if($isTLC) {
       $declareU ="const  %<u0DT.NativeType> *$InPortName[0]";
     } else {
        $isSigned = "u";
        if($InIsSigned[0]) {
            $isSigned = "";
        }
       if ($InWordLength[0] <= 8) {
           $declareU ="const "  . $isSigned . "int8_T  *$InPortName[0]";
       } elsif ($InWordLength[0] <= 16) {
           $declareU ="const "  . $isSigned . "int16_T  *$InPortName[0]";
       } elsif ($InWordLength[0] <= 32) {             
           $declareU ="const "  . $isSigned . "int32_T  *$InPortName[0]";
       } else {
           $declareU ="const "  . $isSigned . "int64_T  *$InPortName[0]";
       } 
     }
   } else {
       if($IsInBusBased[0] =~ 1){
           if($isAccel == 1){
               $declareU ="const void *$InPortName[0], void *__$InPortName[0]"."BUS";
           }
           else{
               $declareU ="const $InBusname[0] *$InPortName[0]";
           }
       }
       else{
           $declareU ="const $InDataType[0] *$InPortName[0]";
       }
   }
 }

if($isAccel == 2){
    if($IsInBusBased[0] =~ 1){
        $declareUForAccelTLC = "("."$InBusname[0]"." *) __". $InPortName[0] ."BUS";
    }
    else{
        $declareUForAccelTLC =  $InPortName[0];
    }
}

 if( $directFeed > 0 ) {
     for($i=1;$i<$NumberOfInputPorts; $i++){
         if($InDataType[$i] =~ /\bfixpt\b/) {
             if($isTLC) {
                 $declareU =  $declareU . ",\n$EMPTY_SPACE const  %<u$i" . "DT.NativeType> *$InPortName[$i]";
             } else {
                 $isSigned = "u";
                 if($InIsSigned[$i]) {
                     $isSigned = "";
                 }
                 if ($InWordLength[$i] <= 8) {
                     $declareU =  $declareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int8_T  *$InPortName[$i]";
                 } elsif ($InWordLength[$i] <= 16) {
                     $declareU =  $declareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int16_T  *$InPortName[$i]";
                 } elsif ($InWordLength[$i] <= 32) {             
                     $declareU =  $declareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int32_T  *$InPortName[$i]";
                 } else {
                     $declareU =  $declareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int64_T  *$InPortName[$i]";
                 } 
             }
         } else {
             if($IsInBusBased[$i] =~ 1){
                 if($isAccel ==1){
                     $declareU =$declareU. ",$EMPTY_SPACE const void *$InPortName[$i], void *__$InPortName[$i]"."BUS";
                 }
                 else{
                     $declareU =$declareU. ",\n$EMPTY_SPACE const $InBusname[$i] *$InPortName[$i]";
                 }         
             }
             else{
                 $declareU =  $declareU . ",\n$EMPTY_SPACE const $InDataType[$i] *$InPortName[$i]";
             }
         }
     }
     if($isAccel == 2){
         for($i=1;$i<$NumberOfInputPorts; $i++){
             if($IsInBusBased[$i] =~ 1){
                 $declareUForAccelTLC = $declareUForAccelTLC. ", ("."$InBusname[$i]"." *) __". $InPortName[$i] ."BUS";
             }
             else{
                 $declareUForAccelTLC =  $declareUForAccelTLC . ",\n$EMPTY_SPACE $InPortName[$i]";
             }
         }
     }     
 }
 # pad the $declareU with extra space so we can get nice format
if($NumberOfInputPorts > 0 && $directFeed > 0 ) {
 if( $NumberOfOutputPorts > 0 ||
     (($NumParams > 0  ||  $NumDStates > 0 && $NumCStates > 0 )) ) {
     $declareU = $declareU . ",\n$EMPTY_SPACE ";
     $declareUForAccelTLC = $declareUForAccelTLC . ",\n$EMPTY_SPACE ";
 }
}
 ###########
 # outputs #
 ###########
 if( $NumberOfOutputPorts > 0) {
  if($OutDataType[0] =~ /\bfixpt\b/) {
     if($isTLC) {
       $declareY = "%<y0DT.NativeType>" . " *$OutPortName[0]";
     } else {
       $isSigned = "u";
        if($OutIsSigned[0]) {
            $isSigned = "";
        }
       if ($OutWordLength[0] <= 8) {
           $declareY = $isSigned . "int8_T  *$OutPortName[0]";
       } elsif ($OutWordLength[0] <= 16) {
           $declareY = $isSigned . "int16_T  *$OutPortName[0]";
       } elsif ($OutWordLength[0] <= 32) {             
           $declareY = $isSigned . "int32_T  *$OutPortName[0]";
       } else {
           $declareY = $isSigned . "int64_T  *$OutPortName[0]";
       } 
     }
   } else {
       if($IsOutBusBased[0] =~ 1){
           if($isAccel == 1){
               $declareY =  "void *$OutPortName[0], void *__$OutPortName[0]"."BUS";
           }
           else{
               $declareY =  "$OutBusname[0] *$OutPortName[0]";
           }
       }
       else{
           $declareY = $OutDataType[0] . " *$OutPortName[0]";
       }
  }
 }

if($isAccel == 2){
    if($IsOutBusBased[0] =~ 1){
        $declareYForAccelTLC = "("."$OutBusname[0]"." *) __". $OutPortName[0] ."BUS";
    }
    else{
        $declareYForAccelTLC = $OutPortName[0];
    }
    for($i=1;$i<$NumberOfOutputPorts; $i++){
        if($IsOutBusBased[$i] =~ 1){
            $declareYForAccelTLC =  $declareYForAccelTLC . ", ("."$OutBusname[$i]"." *) __".  $OutPortName[$i] ."BUS";
        }
        else{
            $declareYForAccelTLC = $declareYForAccelTLC . ",\n" . "$EMPTY_SPACE $OutPortName[$i]";
        }
    }
}


 for($i=1;$i<$NumberOfOutputPorts; $i++){
  if($OutDataType[$i] =~ /\bfixpt\b/) {
     if($isTLC) {
       $declareY =  $declareY . ",\n" . "$EMPTY_SPACE %<y$i" . "DT.NativeType> *$OutPortName[$i]";
     } else {
        $isSigned = "u";
        if($OutIsSigned[$i]) {
            $isSigned = "";
        }
       if ($OutWordLength[$i] <= 8) {
           $declareY =  $declareY . ",\n$EMPTY_SPACE " . $isSigned . "int8_T  *$OutPortName[$i]";
       } elsif ($OutWordLength[$i] <= 16) {
           $declareY =  $declareY . ",\n$EMPTY_SPACE " . $isSigned . "int16_T  *$OutPortName[$i]";
       } elsif ($OutWordLength[$i] <= 32) {             
           $declareY =  $declareY . ",\n$EMPTY_SPACE " . $isSigned . "int32_T  *$OutPortName[$i]";
       } else {
           $declareY =  $declareY . ",\n$EMPTY_SPACE "  . $isSigned . "int64_T  *$OutPortName[$i]";
       } 
     }
  } else {
      if($IsOutBusBased[$i] =~ 1){
           if($isAccel == 1){
               $declareY = $declareY . ",\n$EMPTY_SPACE void *$OutPortName[$i], void *__$OutPortName[$i]"."BUS";
           }
           else{
               $declareY = $declareY . ",\n$EMPTY_SPACE $OutBusname[$i] *$OutPortName[$i]";
           }
       }
      else{
          $declareY =  $declareY . ",\n" . "$EMPTY_SPACE $OutDataType[$i] *$OutPortName[$i]";
      }
  }
}

 if($isAccel == 2){
     $fcnPrototypeRequired = $fcnPrototypeRequired . 
	         	     $declareUForAccelTLC .
			     $declareYForAccelTLC;
 }
 else{
     $fcnPrototypeRequired = $fcnPrototypeRequired . 
			     $declareU .
                             $declareY;
 }

 $n = 0;
 if($NumParams == 0 &&  $NumDStates == 0 && $NumCStates ==0 ) {
    $fcnPrototype = $fcnPrototypeRequired . $portwidths .  getSimStructParamStr() . ")";

 } else {
     if($isAccel == 2){
         $varDStates =     "xD";
         $varCStates =     "xC";
     }else{
         $varDStates =     "const real_T  *xD";
         $varCStates =     "const real_T *xC";
     }
     $varParams = "";
     if($NumParams){
       $emptySpace = "                              ";
       ##(xxx) Fixed for zero outputs
       if($NumberOfOutputPorts > 0) { $useComma = ",";}
       for($i=0; $i < $NumParams - 1 ; $i++){
           if($isAccel ==2){
               $varParams = $varParams . "$EMPTY_SPACE $ParameterName[$i], p_width$i, \n";  
           }else{
               $varParams = $varParams . "$EMPTY_SPACE const $ParameterDataType[$i]  *$ParameterName[$i], const int_T  p_width$i, \n";  
           }
	 $n = $i+ 1;     
       }
       if(($NumDStates > 0) && ($NumCStates == 0)){
	 ##(xxx) Fixed for zero outputs
           if($isAccel ==2){
               $fcnPrototype = "$fcnPrototypeRequired $useComma
			      $varDStates,\n$varParams $EMPTY_SPACE1   $ParameterName[$n], p_width$n";
           }else{
               $fcnPrototype = "$fcnPrototypeRequired $useComma
			      $varDStates,\n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n";
     }
	 
       } elsif(($NumDStates == 0) && ($NumCStates > 0)) { 
	 ##(xxx) Fixed for zero outputs
           if($isAccel ==2){
               $fcnPrototype = "$fcnPrototypeRequired $useComma
			   $varCStates,\n$varParams $EMPTY_SPACE1 $ParameterName[$n], p_width$n"; 
           }else{
               $fcnPrototype = "$fcnPrototypeRequired $useComma
			   $varCStates,\n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n"; 
           }	 
       } elsif(($NumDStates > 0) && ($NumCStates > 0)) { 
           if($isAccel ==2){
               $fcnPrototype = "$fcnPrototypeRequired  $useComma
			              $varDStates $useComma
                          $varCStates,\n$varParams $EMPTY_SPACE1    $ParameterName[$n], p_width$n";
           }else{
               $fcnPrototype = "$fcnPrototypeRequired  $useComma
			              $varDStates $useComma
                          $varCStates,\n$varParams $EMPTY_SPACE1   const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n";
           }
	 
       }
	elsif(($NumDStates == 0) && ($NumCStates == 0)){ 
            if ($NumParams == 1) {
            # $commaStr
                if($isAccel ==2){
                    $fcnPrototype = "$fcnPrototypeRequired" . "$useComma 
                           $ParameterName[$n], p_width$n";                            
                }else{
                    $fcnPrototype = "$fcnPrototypeRequired" . "$useComma 
                           const $ParameterDataType[$n]  *$ParameterName[$n], const int_T p_width$n";                            
                }                
            } else {
                if($isAccel ==2){
                    $fcnPrototype = "$fcnPrototypeRequired  $useComma \n$varParams $EMPTY_SPACE1    $ParameterName[$n],  p_width$n";         
                }else{
                    $fcnPrototype = "$fcnPrototypeRequired  $useComma \n$varParams $EMPTY_SPACE1    const $ParameterDataType[$n]  *$ParameterName[$n],  const int_T p_width$n";         
                }
            }
        }
       
   } else {
       if(($NumDStates > 0) && ($NumCStates == 0)){
	    $fcnPrototype = "$fcnPrototypeRequired,
                          $varDStates";
	} elsif(($NumDStates == 0) && ($NumCStates > 0)) { 
	    $fcnPrototype = "$fcnPrototypeRequired,
                          $varCStates";
	} elsif(($NumDStates > 0) && ($NumCStates > 0)) { 
	    $fcnPrototype = "$fcnPrototypeRequired,
                          $varDStates,
                          $varCStates";
	}
      }
    $fcnPrototype = $fcnPrototype . $portwidths .  getSimStructParamStr() . ")";
}
return $fcnPrototype;

}

############################################################################
 # Outputs Function call i.e:                                               # 
 #  extern void sys_Outputs_wrapper(const real_T *$InPortName[0],           #
 #                             const real_T *$OutPortName[0],               #
 #                             real_T  *param0,  const real_T  *param1);    #
 ############################################################################
 sub  genExternDeclarationTLCForBus{

 ($fcnProtoTypeOutputTLC1,$fcnProtoTypeOutputTLC2,$fcnProtoTypeUpdateTLC1,$fcnProtoTypeUpdateTLC2,$fcnProtoTypeDerivativesTLC1,$fcnProtoTypeDerivativesTLC2) = @_;

 local $i;
 my($wrapperNameAccel);

 $wrapperNameAccel = $sfName."_accel_wrapper";
 if($Gen_HeaderFile == 1){
     $busHeaderTLCList =  "#include \"$sfunBusHeaderFile\"\n";
 }else{
     $busHeaderTLCList = "$bus_Header_List";
 }

 $busFunctionDeclarations = $fcnProtoTypeOutputTLC1.";";

 if($NumDiscStates> 0) {
     $busFunctionDeclarations = $busFunctionDeclarations."\n\t extern ".$fcnProtoTypeUpdateTLC1.";";
 }
 if($NumContStates> 0) {
     $busFunctionDeclarations = $busFunctionDeclarations."\n\t extern ".$fcnProtoTypeDerivativesTLC1.";";
 }

 
 $busAccelCheckStr = "%if IsModelReferenceSimTarget() || CodeFormat==\"S-Function\"
    %assign hFileName = \"$wrapperNameAccel\"
    %assign hFileNameMacro = FEVAL(\"upper\", hFileName)
    %openfile hFile = \"%<hFileName>.h\"
    %selectfile hFile
    #ifndef _%<hFileNameMacro>_H_
    #define _%<hFileNameMacro>_H_

    #include \"tmwtypes.h\"
    extern ". $busFunctionDeclarations. "
    #endif
    %closefile hFile

    %assign cFileName = \"$wrapperNameAccel\"
    %openfile cFile = \"%<cFileName>.c\"
    %selectfile cFile
    #include <string.h>
    #include \"tmwtypes.h\"
    $busHeaderTLCList";
    
 $fcnOutputBody = "\t".$fcnProtoTypeOutputTLC1."{";
 for($i=0;$i<$NumberOfInputPorts; $i++){
     if($IsInBusBased[$i] =~ 1){
         $fcnOutputBody = $fcnOutputBody."\n\t%assign dTypeId = LibBlockInputSignalDataTypeId($i)
    %<SLibAssignSLStructToUserStruct(dTypeId, \"(*(".@InBusname[$i]. "*) __". $InPortName[$i] ."BUS)\", \"(char *)".$InPortName[$i]."\", $i)>\n";        
     }
}
      $fcnOutputBody = $fcnOutputBody."\t".$fcnProtoTypeOutputTLC2.";\n";

 for($i=0;$i<$NumberOfOutputPorts; $i++){
     if($IsOutBusBased[$i] =~ 1){
         $fcnOutputBody = $fcnOutputBody."\n\t%assign dTypeId = LibBlockOutputSignalDataTypeId($i)
    %<SLibAssignUserStructToSLStruct(dTypeId, \"(char *)".$OutPortName[$i]."\", \"(*(".@OutBusname[$i]. "*) __". $OutPortName[$i]."BUS)\", $i)>\n";        
     }
 }

 $fcnOutputBody = $fcnOutputBody."}\n";

 if($NumDiscStates> 0) {
     $fcnUpdateBody = "\n\t".$fcnProtoTypeUpdateTLC1."{";
     for($i=0;$i<$NumberOfInputPorts; $i++){
         if($IsInBusBased[$i] =~ 1){
             $fcnUpdateBody = $fcnUpdateBody."\n\t%assign dTypeId = LibBlockInputSignalDataTypeId($i)
    %<SLibAssignSLStructToUserStruct(dTypeId, \"(*(".@InBusname[$i]. "*) __". $InPortName[$i] ."BUS)\", \"(char *)".$InPortName[$i]."\", $i)>\n";        
         }
}
     $fcnUpdateBody = $fcnUpdateBody."\t".$fcnProtoTypeUpdateTLC2.";\n";
     
 for($i=0;$i<$NumberOfOutputPorts; $i++){
     if($IsOutBusBased[$i] =~ 1){
         $fcnUpdateBody = $fcnUpdateBody."\n\t%assign dTypeId = LibBlockOutputSignalDataTypeId($i)
    %<SLibAssignUserStructToSLStruct(dTypeId, \"(char *)".$OutPortName[$i]."\", \"(*(".@OutBusname[$i]. "*) __". $OutPortName[$i]."BUS)\", $i)>\n";        
     }
 }
     
     $fcnUpdateBody = $fcnUpdateBody."}\n";
 }


 if($NumContStates> 0) {
     $fcnDerivativesBody = "\n\t".$fcnProtoTypeDerivativesTLC1."{";
     for($i=0;$i<$NumberOfInputPorts; $i++){
         if($IsInBusBased[$i] =~ 1){
             $fcnDerivativesBody = $fcnDerivativesBody."\n\t%assign dTypeId = LibBlockInputSignalDataTypeId($i)
    %<SLibAssignSLStructToUserStruct(dTypeId, \"(*(".@InBusname[$i]. "*) __". $InPortName[$i] ."BUS)\", \"(char *)".$InPortName[$i]."\", $i)>\n";        
         }
     }
     $fcnDerivativesBody = $fcnDerivativesBody."\t".$fcnProtoTypeDerivativesTLC2.";\n";
     
     for($i=0;$i<$NumberOfOutputPorts; $i++){
         if($IsOutBusBased[$i] =~ 1){
             $fcnDerivativesBody = $fcnDerivativesBody."\n\t%assign dTypeId = LibBlockOutputSignalDataTypeId($i)
    %<SLibAssignUserStructToSLStruct(dTypeId, \"(char *)".$OutPortName[$i]."\", \"(*(".@OutBusname[$i]. "*) __". $OutPortName[$i]."BUS)\", $i)>\n";        
         }
     }     
     $fcnDerivativesBody = $fcnDerivativesBody."}\n\n";
 }
 
 $busAccelCheckStr = $busAccelCheckStr.$fcnOutputBody.$fcnUpdateBody.$fcnDerivativesBody."
   %closefile cFile

    %<LibAddToCommonIncludes(\"%<hFileName>.h\")>
    %<LibAddToModelSources(\"%<cFileName>\")>

  %else
";

}

############################################################################
# States Function call i.e:                                                # 
#  extern void sys_Derivatives_wrapper(const real_T *$InPortName[0],       #
#                             const real_T *$OutPortName[0],               #
#                             real_T      *xD,                             #  
#                             real_T  *param0,  const real_T  *param1);    #
############################################################################
sub genStatesWrapper {

($UpNumParams, $UpNumDStates, $UpfcnType, $state,  $sfName, $inDType, $outDType, $isTLC, $isAccel) =  @_;
local $Upi, $Upn, $useComma;
my($commaStr);
 # port widths
 if($flagDynSize == 1){
     if($isAccel == 2){
         # Bus is being used because  $isAccel == 2 or  $isAccel == 1
         $portwidths = ",\n\t\t\t     y_width, u_width";
     }else{
         $portwidths = ",\n\t\t\t     const int_T y_width, const int_T u_width";
     }
 } else {
   $portwidths = "";
}

$UpfcnPrototypeRequired ="void ". $sfName . "_". $UpfcnType . "_wrapper(";
if($isAccel == 1){
    # Bus is being used because  $isAccel == 2 or  $isAccel == 1
     $UpfcnPrototypeRequired = "void ". $sfName . "_". $fcnType . "_wrapper_accel(";
 }
 elsif($isAccel == 2){
     # Bus is being used because  $isAccel == 2 or  $isAccel == 1
     $UpfcnPrototypeRequired = $sfName . "_". $fcnType . "_wrapper(";     
 }
if( ($NumberOfInputPorts > 0) ||  ($NumberOfOutputPorts > 0)) {
   $commaStr = ",";
 }
##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
    if($InDataType[0] =~ /\bfixpt\b/) {
        if($isTLC) {
            $UpdeclareU ="const  %<u0DT.NativeType> *$InPortName[0]"; 
        } else {
            $isSigned = "u";
            if($InIsSigned[0]) {
                $isSigned = "";
        }
            if ($InWordLength[0] <= 8) {
                $UpdeclareU ="const "  . $isSigned . "int8_T  *$InPortName[0]";
            } elsif ($InWordLength[0] <= 16) {
                $UpdeclareU ="const "  . $isSigned . "int16_T  *$InPortName[0]";
            } elsif ($InWordLength[0] <= 32) {             
                $UpdeclareU ="const "  . $isSigned . "int32_T  *$InPortName[0]";
            } else {
                $UpdeclareU ="const "  . $isSigned . "int64_T  *$InPortName[0]";
            } 
        }
    } else {
      if($IsInBusBased[0] =~ 1){
          if($isAccel == 1){
              $UpdeclareU ="const void *$InPortName[0], void *__$InPortName[0]"."BUS";
          }
          else{
              $UpdeclareU ="const $InBusname[0] *$InPortName[0]";
          }
      }
      else{
          $UpdeclareU ="const $InDataType[0] *$InPortName[0]"; 
      }
  }   
}

if($isAccel == 2){
    if($IsInBusBased[0] =~ 1){
        $UpdeclareUForAccelTLC = "("."$InBusname[0]"." *) __". $InPortName[0] ."BUS";
    }
    else{
        $UpdeclareUForAccelTLC = $InPortName[0];
    }
}

for($i=1;$i<$NumberOfInputPorts; $i++){
    if($IsInBusBased[$i] =~ 1){
        if($isAccel ==1){
            $declareU =$declareU. ",$EMPTY_SPACE const void *$InPortName[$i], void *__$InPortName[$i]"."BUS";
        }
        else{
            $UpdeclareU = $UpdeclareU . ",\n$EMPTY_SPACE const $InBusname[$i] *$InPortName[$i]";
        }
    }
    else{
        if($InDataType[$i] =~ /\bfixpt\b/) {
            if($isTLC) {
                $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE const  %<u$i" . "DT.NativeType> *$InPortName[$i]";
            } else {
                $isSigned = "u";
                if($InIsSigned[$i]) {
                    $isSigned = "";
                }
                if ($InWordLength[$i] <= 8) {
                    $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int8_T  *$InPortName[$i]";
                } elsif ($InWordLength[$i] <= 16) {
                    $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int16_T  *$InPortName[$i]";
                } elsif ($InWordLength[$i] <= 32) {             
                    $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int32_T  *$InPortName[$i]";
                } else {
                    $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE " . "const "  . $isSigned . "int64_T  *$InPortName[$i]";
                } 
            }
        } else {
            $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE const $InDataType[$i] *$InPortName[$i]";
        }
    }   
}

if($isAccel == 2){
    for($i=1;$i<$NumberOfInputPorts; $i++){
        if($IsInBusBased[$i] =~ 1){
            $UpdeclareUForAccelTLC = $UpdeclareUForAccelTLC. ", ("."$InBusname[$i]"." *) __". $InPortName[$i] ."BUS";
        }
        else{
            $UpdeclareUForAccelTLC =  $UpdeclareUForAccelTLC . ",\n$EMPTY_SPACE $InPortName[$i]";
        }
    }
}

# pad the $declareU with extra space so we can get nice format
if( $NumberOfInputPorts > 0) {
    if ( $NumberOfOutputPorts > 0 || $NumParams > 0  ||  $UpNumDStates > 0 || $NumCStates > 0  ) {        
        $UpdeclareU =  $UpdeclareU . ",\n$EMPTY_SPACE ";
        $UpdeclareUForAccelTLC = $UpdeclareUForAccelTLC . ",\n$EMPTY_SPACE ";
    }
}
###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
    if($IsOutBusBased[0] =~ 1){
        if($isAccel == 1){
            $UpdeclareY =  "void *$OutPortName[0], void *__$OutPortName[0]"."BUS";
        }
        else{
            $UpdeclareY ="const $OutBusname[0] *$OutPortName[0]";
        }
    }
    else{
        if($OutDataType[0] =~ /\bfixpt\b/) {
            if($isTLC) {
                $UpdeclareY ="const %<y0DT.NativeType>" . " *$OutPortName[0]";
            } else {
                $isSigned = "u";
                if($OutIsSigned[0]) {
                    $isSigned = "";
                }
                if ($OutWordLength[0] <= 8) {
                    $UpdeclareY = $isSigned . "int8_T  *$OutPortName[0]";
                } elsif ($OutWordLength[0] <= 16) {
                    $UpdeclareY = $isSigned . "int16_T  *$OutPortName[0]";
                } elsif ($OutWordLength[0] <= 32) {             
                    $UpdeclareY = $isSigned . "int32_T  *$OutPortName[0]";
                } else {
                    $UpdeclareY = $isSigned . "int64_T  *$OutPortName[0]";
                } 
            }
        } else {
            $UpdeclareY ="const $OutDataType[0]" . " *$OutPortName[0]";
        }
    }
} 

if($isAccel == 2){
    if($IsOutBusBased[0] =~ 1){
        $UpdeclareYForAccelTLC = "("."$OutBusname[0]"." *) __". $OutPortName[0] ."BUS";
    }
    else{
        $UpdeclareYForAccelTLC = $OutPortName[0];
    }
    for($i=1;$i<$NumberOfOutputPorts; $i++){
        if($IsOutBusBased[$i] =~ 1){
            $UpdeclareYForAccelTLC = $UpdeclareYForAccelTLC . ", ("."$OutBusname[$i]"." *) __".  $OutPortName[$i] ."BUS";
        }
        else{
            $UpdeclareYForAccelTLC = $UpdeclareYForAccelTLC . ",\n" . "$EMPTY_SPACE $OutPortName[$i]";
        }
    }
}

for($i=1;$i<$NumberOfOutputPorts; $i++){
    if($IsOutBusBased[$i] =~ 1){
        if($isAccel == 1){
            $UpdeclareY = $UpdeclareY . ",\n$EMPTY_SPACE void *$OutPortName[$i], void *__$OutPortName[$i]"."BUS";
        }
        else{
            $UpdeclareY = $UpdeclareY . ",\n$EMPTY_SPACE $OutBusname[$i] *$OutPortName[$i]";
        }            
    }
    else{
        if($OutDataType[$i] =~ /\bfixpt\b/) {
            if($isTLC) {
                $UpdeclareY =  $UpdeclareY . ",\n" . "$EMPTY_SPACE const %<y$i" . "DT.NativeType> *$OutPortName[$i]";
            } else {
                $isSigned = "u";
                if($OutIsSigned[$i]) {
                    $isSigned = "";
                }
                if ($OutWordLength[$i] <= 8) {
                    $UpdeclareY =  $UpdeclareY . ",\n$EMPTY_SPACE " . $isSigned . "int8_T  *$OutPortName[$i]";
                } elsif ($OutWordLength[$i] <= 16) {
                    $UpdeclareY =  $UpdeclareY . ",\n$EMPTY_SPACE " . $isSigned . "int16_T  *$OutPortName[$i]";
                } elsif ($OutWordLength[$i] <= 32) {             
                    $UpdeclareY =  $UpdeclareY . ",\n$EMPTY_SPACE " . $isSigned . "int32_T  *$OutPortName[$i]";
                } else {
                    $UpdeclareY =  $UpdeclareY . ",\n$EMPTY_SPACE "  . $isSigned . "int64_T  *$OutPortName[$i]";
                } 
            }
        } else {
            $UpdeclareY =  $UpdeclareY . ",\n" . "$EMPTY_SPACE const $OutDataType[$i] *$OutPortName[$i]";
        }
    }
}

if($state =~ /xC/) {
  if ($NumberOfOutputPorts > 0 ) {
      $UpdeclareY = "$UpdeclareY" . ",\n $EMPTY_SPACE";
      $UpdeclareYForAccelTLC = "$UpdeclareYForAccelTLC". ",\n $EMPTY_SPACE";
   }
  if($isAccel == 2){
      $UpfcnPrototypeRequired = $UpfcnPrototypeRequired . 
                            $UpdeclareUForAccelTLC .
                            $UpdeclareYForAccelTLC .
                            "dx"; 
  }else{
      $UpfcnPrototypeRequired = $UpfcnPrototypeRequired . 
                              $UpdeclareU .
                              $UpdeclareY .
                            "real_T *dx"; 
  }

} else {
    if($isAccel == 2){
        $UpfcnPrototypeRequired = $UpfcnPrototypeRequired . 
                            $UpdeclareUForAccelTLC .
                            $UpdeclareYForAccelTLC;                             
    }else{
        $UpfcnPrototypeRequired = $UpfcnPrototypeRequired . 
                            $UpdeclareU .
			    $UpdeclareY;
    }
}


$Upn = 0;
if($UpNumParams == 0 &&  $UpNumDStates == 0) {
  $UpfcnPrototype = "$UpfcnPrototypeRequired" . " $portwidths" . getSimStructParamStr() .")"; 
  
} else {
    
    if($isAccel ==2){
        $UpvarDStates = "$state";
    }else{
        $UpvarDStates = "real_T *$state";
    }
  
  $UpvarParams = "";
  if($NumberOfOutputPorts > 0) { $useComma = ",";}
  if($UpNumParams){
    for($Upi=0; $Upi < $UpNumParams - 1 ; $Upi++){
        if($isAccel ==2){
            $UpvarParams = $UpvarParams . "$ParameterName[$Upi], p_width$Upi,\n $EMPTY_SPACE"; 
        }
        else{
            $UpvarParams = $UpvarParams . "const $ParameterDataType[$Upi]  *$ParameterName[$Upi],  const int_T  p_width$Upi,\n $EMPTY_SPACE"; 
        }
        $Upn = $Upi+ 1;     
    }
    if($UpNumDStates){
        if ($NumParams == 1) {
            ## (xxx)Fixed
            if($isAccel ==2){
                $UpfcnPrototype = "$UpfcnPrototypeRequired $useComma
                           $UpvarDStates, 
                           $ParameterName[$Upn], p_width$Upn";
            }else{                
                $UpfcnPrototype = "$UpfcnPrototypeRequired $useComma
                           $UpvarDStates, 
                          const $ParameterDataType[$Upn]  *$ParameterName[$Upn], const int_T  p_width$Upn";
            }            
        } else {
          ## (xxx)Fixed
            if($isAccel ==2){
                $UpfcnPrototype = "$UpfcnPrototypeRequired $useComma
                          $UpvarDStates, 
                          $UpvarParams $ParameterName[$Upn], p_width$Upn";
            }else{        
                $UpfcnPrototype = "$UpfcnPrototypeRequired $useComma
                          $UpvarDStates, 
                          $UpvarParams const $ParameterDataType[$Upn] *$ParameterName[$Upn], const int_T  p_width$Upn";
            }            
        }
        
    } else { 
      if ($NumParams == 1) {
          if($isAccel == 2){
              $UpfcnPrototype = "$UpfcnPrototypeRequired" . " $commaStr
                          $ParameterName[$Upn], p_width$Upn";
          }else{        
              $UpfcnPrototype = "$UpfcnPrototypeRequired" . " $commaStr
                          const $ParameterDataType[$Upn]  *$ParameterName[$Upn], const int_T p_width$Upn";
          }
      } else {
          if($isAccel == 2){
              $UpfcnPrototype = "$UpfcnPrototypeRequired $commaStr $UpvarParams $ParameterName[$Upn], p_width$Upn";
          }else{
              $UpfcnPrototype = "$UpfcnPrototypeRequired $commaStr $UpvarParams const $ParameterDataType[$Upn]  *$ParameterName[$Upn], const int_T p_width$Upn";
          }
          
      }
  }
}
    else {
        $UpfcnPrototype = "$UpfcnPrototypeRequired,
                          $UpvarDStates";        
    }
    $UpfcnPrototype =  $UpfcnPrototype . 
      $portwidths . getSimStructParamStr() .")";
}

return $UpfcnPrototype;

}
######################################
# Wrapper States Function Call:      #
# sys_Update_wrapper(u, y, xD);      #
# or                                 #
# sys_Derivatives_wrapper(u, y, xC); #
######################################
sub genFunctionCall {

($NParams, $NStates, $fcnType, $state, $sfName) =  @_;
local $i, $n, $fcnType, $state;

 # port widths
 if($flagDynSize == 1){
     if($isAccel == 2){
         $portwidths = ",\n\t\t\t     y_width, u_width";
     }else{
         $portwidths = ", y_width, u_width";
     }
 } else {
     $portwidths = "";
 }

$fcnCallRequired =$sfName. "_". $fcnType . "_wrapper(";

##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
    if($IsInBusBased[0] =~ 1){
        $declareU = " &_u0BUS";
    }
    else {        
        $declareU ="$InPortName[0]";
    }
}

for($i=1;$i<$NumberOfInputPorts; $i++){
    if($IsInBusBased[$i] =~ 1){
        $declareU = $declareU  .  ", &_u".$i."BUS";
    }
    else
      {
          $declareU =  $declareU  .  ", $InPortName[$i]";
      }
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0) {
      if($IsOutBusBased[0] =~ 1)	#_y1BUS
        {
	    $declareY = ", &_y0BUS";
        }
      else
        {
	    $declareY = ", $OutPortName[0]";
        }
  } else {
      if($IsOutBusBased[0] =~ 1)	#_y1BUS
        {
            $declareY = " &_y0BUS";
        }
      else
        {
            $declareY = "$OutPortName[0]";
        }
  }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
    if($IsOutBusBased[$i] =~ 1)	#_u1BUS
      {
          $declareY = $declareY  .  ", &_y".$i ."BUS";
      }
    else
      {
          $declareY =  $declareY . ", $OutPortName[$i]";
      }
}

if ($state =~ /xC/) {
  $fcnCallRequired = $fcnCallRequired .
                     $declareU .
                     $declareY .
                     ",dx"; 
} else {
  $fcnCallRequired = $fcnCallRequired .
                     $declareU .
		     $declareY;

}

$n = 0;
if($NParams == 0 &&  $NStates == 0) {
  $fcnCall = "$fcnCallRequired" . "$portwidths" . getSimStructString() .");"; 
  
} else {

  # Have at least one parameter or state, append comma after input and output arguments (if exists)
  if( ($NumberOfInputPorts > 0 && $directFeed > 0) || ($NumberOfOutputPorts > 0)) {
    $fcnCallRequired = "$fcnCallRequired, ";
  }  

  $DStates =     $state;
  $Params = "";
  if($NParams){
    for($i=0; $i < $NParams - 1 ; $i++){
      $Params = $Params . 
	"$ParameterName[$i], p_width$i, "; 
      $n = $i+ 1;     
    }
    if($NStates){
      $fcnCall = "$fcnCallRequired " . "$DStates, $Params" . "$ParameterName[$n], " .  "p_width$n";
    } else { 
      $fcnCall = "$fcnCallRequired " . "$Params" . "$ParameterName[$n], " . "p_width$n";
    }
  }
  else {
    $fcnCall = "$fcnCallRequired " . "$DStates";
  }
  $fcnCall = $fcnCall . $portwidths . getSimStructString() . ");";
}

return $fcnCall;

}

############################
# Wrapper Outputs Fcn Call #
############################
sub genFunctionCallOutput {

($NParams, $NDStates, $NCStates, $fcnType, $sfName, $flagDynSize) =  @_;
local $i, $n, $fcnType, $Params, $declareU;

 # port widths
 if($flagDynSize == 1 && $directFeed > 0 ){
   $portwidths = ", y_width, u_width";
 } else {
   $portwidths = "";
  }
$declareU = "";
#$fcnCallRequired =$sfName. "_". $fcnType . "_wrapper(u, y";
$fcnCallRequired =$sfName. "_". $fcnType . "_wrapper(";
##########
# inputs #
##########

if($directFeed > 0) {
    if( $NumberOfInputPorts > 0) {
        if($IsInBusBased[0] =~ 1){
            $declareU = "&_u0BUS";
        }
        else{
            $declareU ="$InPortName[0]";
        }
    }
}
if($directFeed > 0 ) {
    for($i=1;$i<$NumberOfInputPorts; $i++){
        if($IsInBusBased[$i] =~ 1){
            $declareU = $declareU  .  ",&_u".$i."BUS";
        }
        else{
            $declareU =  $declareU .  ", $InPortName[$i]";
        }
    }
}
###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0 && $directFeed > 0)
    {
  	if($IsOutBusBased[0] =~ 1)	#_y1BUS
          {
              $declareY = ", &_y0BUS";
          }
	else
          {
              $declareY = ", $OutPortName[0]";
	}
    }
  else
    {
        if($IsOutBusBased[0] =~ 1)	#_y1BUS
          {
              if( $NumberOfInputPorts > 0) {
                  $declareY = ", &_y0BUS";
              } else {
                  $declareY = "&_y0BUS";
              }  
          }
        else
          {
              $declareY = "$OutPortName[0]";
          }
    }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
    if($IsOutBusBased[$i] =~ 1)	#_u0BUS
      {
          $declareY = $declareY  .  ", &_y".$i."BUS";
      }
    else
      {
          $declareY = $declareY . ", $OutPortName[$i]";
      }
}

$fcnCallRequired = $fcnCallRequired .
                   $declareU .
                   $declareY;


  
$n = 0;
if($NParams == 0 &&  $NDStates == 0 && $NCStates ==0) {
  $fcnCallOut = $fcnCallRequired . $portwidths . getSimStructString() .");"; 
  
} else {

  # Have at least one parameter or state, append comma after input and output arguments (if exists)
  if( ($NumberOfInputPorts > 0 && $directFeed > 0) || ($NumberOfOutputPorts > 0)) {
      $fcnCallRequired = "$fcnCallRequired, ";
  }  

  $DStates = "xD";
  $CStates = "xC";
  $Params = "";
  if($NParams){
      for($i=0; $i < $NParams - 1 ; $i++){
	  $Params = $Params . 
	      "$ParameterName[$i], p_width$i, ";  
	  $n = $i+ 1;     
      }
      if(($NDStates > 0) && ($NCStates == 0)){
	  $fcnCallOut = "$fcnCallRequired" . "$DStates, $Params" . "$ParameterName[$n], p_width$n";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired" . "$CStates, $Params" . "$ParameterName[$n], p_width$n";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired" . "$DStates,  $CStates, $Params" . "$ParameterName[$n] , p_width$n";
      }
      elsif(($NDStates == 0) && ($NCStates == 0)) { 
	  $fcnCallOut = "$fcnCallRequired" . "$Params" . "$ParameterName[$n], p_width$n";
      }
  } else {
      if(($NDStates > 0) && ($NCStates == 0)){
	  $fcnCallOut = "$fcnCallRequired" . "$DStates";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired" . "$CStates";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	  $fcnCallOut = "$fcnCallRequired" . "$DStates, $CStates";
      }
  }
  $fcnCallOut = $fcnCallOut . $portwidths .  getSimStructString() . ");";
}  
return $fcnCallOut;

}


#########################################################################
# Wrapper Outputs Fcn Call for the wrapper TLC:                         #
#                                                                       #  
# sys_Outputs_wrapper(%<pu>, %<py>, %<py_width>, %<pu_width>);  #
#                                                                       # 
#########################################################################
sub genFunctionCallOutputTLC {


($NParams, $NDStates, $NCStates, $fcnType, $sfName,  $flagDynSize, $isAccelForBus) =  @_;
local $i, $n, $fcnType, $Params ,$DStates, $CStates;

 my($dWorkAddrStr);

 # Dynamic post widths
 if($flagDynSize == 1 && $directFeed > 0){
   $portwidths = ", %<py_width>, %<pu_width>";
 } else {
   $portwidths = "";
 }

$fcnCallRequired = $sfName . "_". $fcnType . "_wrapper(";

if($isAccelForBus){
    if($flag_Busused){
        $fcnCallRequired = "
  %if IsModelReferenceSimTarget() || CodeFormat==\"S-Function\"\n";
    }
    else{
        return "";
    }
    
    for($i=0;$i<$NumberOfInputPorts; $i++){
        if($IsInBusBased[$i]){
            $dWorkAddrStr = $dWorkAddrStr."    %assign $InPortName[$i]"."BUS_ptr = LibBlockDWorkAddr($InPortName[$i]"."BUS, \"\", \"\", 0)\n";
        }
    }
    
    for($i=0;$i<$NumberOfOutputPorts; $i++){
        if($IsOutBusBased[$i]){
            $dWorkAddrStr = $dWorkAddrStr."    %assign $OutPortName[$i]"."BUS_ptr = LibBlockDWorkAddr($OutPortName[$i]"."BUS, \"\", \"\", 0)\n";
        }
    }
    
    $fcnCallRequired = $fcnCallRequired.$dWorkAddrStr."\t".$sfName . "_". $fcnType . "_wrapper_accel(";
}

##########
# inputs #
##########
if( $NumberOfInputPorts > 0 && $directFeed > 0) {
  $declareU ="%<pu0>"; 
  if($isAccelForBus  && $IsInBusBased[0]){
      $declareU =  $declareU . ", %<u0BUS_ptr>";
  }
}

if($directFeed > 0 ) {
    for($i=1;$i<$NumberOfInputPorts; $i++){
        $declareU =  $declareU . ", %<pu$i>";
        if($isAccelForBus  && $IsInBusBased[$i]){
            $declareU =  $declareU . ", %<u$i"."BUS_ptr>";
        }
    }
}
###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
    if( $NumberOfInputPorts > 0 && $directFeed > 0) {
        $declareY =", %<py0>";
    } else {
        $declareY =" %<py0>";
    }
    if($isAccelForBus  && $IsOutBusBased[0]){
        $declareY =  $declareY . ", %<y0BUS_ptr>";
    }
}

for($i=1;$i<$NumberOfOutputPorts; $i++){
  $declareY =  $declareY . "," . " %<py$i>";
  if($isAccelForBus  && $IsOutBusBased[$i]){
      $declareY =  $declareY . ", %<y$i"."BUS_ptr>";
  }
}


$fcnCallRequired = $fcnCallRequired .  $declareU . $declareY;

$n = 1;
if($NParams == 0 &&  $NDStates == 0 && $NCStates ==0) {
  $fcnCallOutTLC = "$fcnCallRequired" . " $portwidths" . getTLCSimStructStr() . ");\n"; 
  
} else {
  
  if($NumberOfOutputPorts > 0 || $NumberOfInputPorts > 0) {
    $fcnCallRequired = "$fcnCallRequired, "
  }
  $DStates = " %<pxd>";
  $CStates = "pxc";
  $Params = "";
  if($NParams){
      for($i=0; $i < $NParams - 1 ; $i++){
	  $n = $i + 1;     
	  $Params = $Params . 
	    " %<pp$n>, %<param_width$n>, "; 
	  $n++;
	}
      if(($NDStates > 0) && ($NCStates == 0)){
	$fcnCallOutTLC = "$fcnCallRequired" . "$DStates, $Params" . "%<pp$n>, %<param_width$n>";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired" . "$CStates, $Params" . "%<pp$n>, %<param_width$n>";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired" . "$DStates,  $CStates, $Params" . "%<pp$n>, %<param_width$n>";
      }
      elsif(($NDStates == 0) && ($NCStates == 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired" . "$Params" . "%<pp$n>, %<param_width$n>";
      }
  } else {
      if(($NDStates > 0) && ($NCStates == 0)){
	$fcnCallOutTLC = "$fcnCallRequired" . "$DStates";
      } elsif(($NDStates == 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired" . "$CStates";
      } elsif(($NDStates > 0) && ($NCStates > 0)) { 
	$fcnCallOutTLC = "$fcnCallRequired" . "$DStates, $CStates";
      }
  }
  $fcnCallOutTLC = $fcnCallOutTLC  . $portwidths . getTLCSimStructStr() . ");\n\n";
}
return $fcnCallOutTLC;

}



###################
# FunctionCallTLC #
###################

sub genFunctionCallTLC {

($NParams, $NDStates, $fcnType, $state, $sfName, $isAccelForBus) =  @_;
local $i, $n, $fcnType, $fcnCall;

 # Dynamic post widths
 if($flagDynSize == 1){
   $portwidths = ", %<py_width>, %<pu_width>";
 } else {
   $portwidths = "";
 }

$fcnCallRequired = $sfName . "_". $fcnType . "_wrapper(";

if($isAccelForBus){
    if($flag_Busused){
        $fcnCallRequired = "%if IsModelReferenceSimTarget() || CodeFormat==\"S-Function\"\n";
    }
    else{
        return "";
    }
    
    for($i=0;$i<$NumberOfInputPorts; $i++){
        if($IsInBusBased[$i]){
            $dWorkAddrStr = $dWorkAddrStr."    %assign $InPortName[$i]"."BUS_ptr = LibBlockDWorkAddr($InPortName[$i]"."BUS, \"\", \"\", 0)\n";
        }
    }
    
    for($i=0;$i<$NumberOfOutputPorts; $i++){
        if($IsOutBusBased[$i]){
            $dWorkAddrStr = $dWorkAddrStr."    %assign $OutPortName[$i]"."BUS_ptr = LibBlockDWorkAddr($OutPortName[$i]"."BUS, \"\", \"\", 0)\n";
        }
    }
    
    $fcnCallRequired = $fcnCallRequired.$dWorkAddrStr."\t".$sfName . "_". $fcnType . "_wrapper_accel(";
}

##########
# inputs #
##########
if( $NumberOfInputPorts > 0) {
  $declareU ="%<pu0>"; 
  if($isAccelForBus  && $IsInBusBased[0]){
      $declareU =  $declareU . ", %<u0BUS_ptr>";
  }
}

for($i=1;$i<$NumberOfInputPorts; $i++){
  $declareU =  $declareU . ", %<pu$i>";
  if($isAccelForBus  && $IsInBusBased[$i]){
      $declareU =  $declareU . ", %<u$i"."BUS_ptr>";
  }
}

###########
# outputs #
###########
if( $NumberOfOutputPorts > 0) {
  if( $NumberOfInputPorts > 0) {
     $declareY =", %<py0>"; 
  } else {
     $declareY =" %<py0>"; 
  }
  if($isAccelForBus  && $IsOutBusBased[0]){
      $declareY =  $declareY . ", %<y0BUS_ptr>";
  }
}
for($i=1;$i<$NumberOfOutputPorts; $i++){
  $declareY =  $declareY . "," . " %<py$i>";
  if($isAccelForBus  && $IsOutBusBased[$i]){
      $declareY =  $declareY . ", %<y$i"."BUS_ptr>";
  }
}

$fcnCallRequired = $fcnCallRequired .  $declareU . $declareY;

if( $state =~ /pxc/){
 $fcnCallRequired =  $fcnCallRequired . ", dx";
}
$n = 1;
if($NParams == 0 &&  $NDStates == 0) {
  $fcnCall = "$fcnCallRequired" . "$portwidths". getTLCSimStructStr() . ");"; 
  
} else {
  
  if($NumberOfOutputPorts > 0 || $NumberOfInputPorts > 0) {
      $fcnCallRequired = "$fcnCallRequired, "; 
  }
  $DStates =     $state;
  $Params = "";
  if($NParams){
    for($i=0; $i < $NParams - 1 ; $i++){
      $Params = $Params . 
	"%<pp$n>, %<param_width$n>, "; 
      $n++;
    }
    if($NDStates){
      $fcnCall = "$fcnCallRequired" . "$DStates, $Params" . "%<pp$n>, %<param_width$n>";
    } else { 
      $fcnCall = "$fcnCallRequired" . "$Params" . "%<pp$n>, %<param_width$n>";
    }
  }
  else {
   $fcnCall = "$fcnCallRequired" . "$DStates";
  }
  $fcnCall = $fcnCall . $portwidths . getTLCSimStructStr() . ");";
}

return $fcnCall;

}



#####################################
# Generate the Update TLC function #
#####################################
sub getBodyFunctionUpdateTLC {

($NParams, $sfNameWrapperTLC, $fcnCallUpdateTLC) =   @_;
local $n,  $Body, $inportAddrInfo, $outportAddrInfo;
if($UseSimStruct) {
  $simStructAccessCode = getSimStructAccessTLC_Code() . "\n  {\n   " .  getSimStructDec();
  $closeScope ="}";
} else {
  $simStructAccessCode = "";
  $closeScope ="\n";
}
$Params = "";
$n = 1;
if($NParams){
 for($i=0; $i < $NParams; $i++){
  $Params = "$Params 
  %assign nelements$n = LibBlockParameterSize(P$n)
  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]  
  %if (param_width$n) > 1  
   %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n)
  %else  
   %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
  %endif";
  $n++;
  }
}
if($flagDynSize == 1){
  $WidthInfoTLC = "%assign py_width = LibBlockOutputSignalWidth(0)\n  %assign pu_width = LibBlockInputSignalWidth(0)";
}
$inportAddrInfo ="";
for($i = 0; $i < $NumberOfInputPorts ; $i++){
  $inportAddrInfo =   $inportAddrInfo . "\n  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)";
}
$outportAddrInfo ="";   
for($i=0; $i < $NumberOfOutputPorts ; $i++){
   $outportAddrInfo =  $outportAddrInfo . "\n  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)";
}   
$Body ="%% Function: Update ==========================================================
%% Abstract:
%%    Update
%%     
%%
%function Update(block, system) Output
    /* S-Function \"$sfNameWrapperTLC\" Block: %<Name> */
  $inportAddrInfo $outportAddrInfo
  %assign pxd = LibBlockDWorkAddr(DSTATE, \"\", \"\", 0)
  $WidthInfoTLC
  $Params\n $simStructAccessCode
  $fcnCallUpdateTLC
  $closeScope
  %%
%endfunction ";

return $Body;
}

#########################################
# Generate the Derivatives TLC function #
#########################################
sub getBodyFunctionDerivativesTLC {

($NParams, $sfNameWrapperTLC, $fcnCallDerivativesTLC) =   @_;
local $n,  $Body;
if($UseSimStruct) {
  $simStructAccessCode = getSimStructAccessTLC_Code();
  $simStructDec = "\n    " . getSimStructDec();
} else {
  $simStructAccessCode = "";
  $simStructDec = "";
}
$Params = "";
$n = 1;
if($NParams){
 for($i=0; $i < $NParams; $i++){
  $Params = "$Params
  %assign nelements$n = LibBlockParameterSize(P$n)
  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]
  %if (param_width$n) > 1    
   %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n) 
  %else    
   %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
  %endif";
  $n++;
  }
}

if($flagDynSize == 1){
  $WidthInfoTLC = "%assign py_width = LibBlockOutputSignalWidth(0)\n  %assign pu_width = LibBlockInputSignalWidth(0)";
}
$inportAddrInfo ="";
for($i=0; $i < $NumberOfInputPorts ; $i++){
  $inportAddrInfo =   $inportAddrInfo . "\n  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)";
} 
$outportAddrInfo ="";  
for($i=0; $i < $NumberOfOutputPorts ; $i++){
   $outportAddrInfo =  $outportAddrInfo . "\n  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)";
}   
$Body ="\n%% Function: Derivatives ======================================================
%% Abstract:
%%      Derivatives
%%
%function Derivatives(block, system) Output
   /* S-Function \"$sfNameWrapperTLC\" Block: %<Name> */  

  $inportAddrInfo
  $outportAddrInfo
  $Params
  $WidthInfoTLC\n 
  $simStructAccessCode
 { $simStructDec\n   real_T *pxc = &%<LibBlockContinuousState(\"\", \"\", 0)>;\n   real_T *dx  =  &%<LibBlockContinuousStateDerivative(\"\",\"\",0)>;\n   $fcnCallDerivativesTLC\n  }
  %%
%endfunction ";

return $Body;
}



###############################################
#  DimsInfo Function for -1 and 1 port widths #
#  or for n and 1 port widths                 #            
###############################################

sub getBodyDimsInfoWidthMdlPortWidth {

($InRow[0], $OutRow[0], $strDynSize, $Inframe[0]) =   @_;

if($Inframe[0] == 1 ||
   ($InRow[0] > 1  && $InCol[0] == 1)) {
 $DimsInfoBody  = "#if defined(MATLAB_MEX_FILE)
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
static void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                         int_T            port,
                                         const DimsInfo_T *dimsInfo)
{
    if(!ssSetInputPortDimensionInfo(S, port, dimsInfo)) return;
}
#endif

#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
#if defined(MDL_SET_OUTPUT_PORT_DIMENSION_INFO)
static void mdlSetOutputPortDimensionInfo(SimStruct        *S, 
                                          int_T            port, 
                                          const DimsInfo_T *dimsInfo)
{
 if (!ssSetOutputPortDimensionInfo(S, port, dimsInfo)) return;
}
#endif\n";
if(($InRow[0] > 1  && $InCol[0] == 1) &&
    ($OutRow[0] == 1  && $OutCol[0] == 1) ) {
  
    $inPortDimsInfoWidth = "INPUT_0_WIDTH";
    $outPortDimsInfoWidth = "OUTPUT_0_WIDTH";
    $defaultDimsInfo = "#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { INPUT_0_WIDTH, 1 };
  bool  frameIn = ssGetInputPortFrameData(S, 0) == FRAME_YES;

  /* Neither the input nor the output ports have been set */

  portDimsInfo.width   = INPUT_0_WIDTH;
  portDimsInfo.numDims = frameIn ? 2 : 1;
  portDimsInfo.dims    = frameIn ? dims : &portDimsInfo.width;
  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {  
   ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
  portDimsInfo.width   = OUTPUT_0_WIDTH;
  dims[0]              = OUTPUT_0_WIDTH;
  dims[1]              = $OutCol[0];
  portDimsInfo.dims    = frameIn ? dims : &portDimsInfo.width;
 if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {  
  ssSetOutputPortDimensionInfo(S, 0, &portDimsInfo);
 }
  return;
}\n";
  }
} else {
if($InRow[0] =~ $strDynSize && $OutCol[0] == 1) {
  $inPortDimsInfoWidth = 1;
  $outPortDimsInfoWidth = 1;
  $defaultDimsInfo = "#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { $outPortDimsInfoWidth, 1 };
  bool  frame = (ssGetInputPortFrameData(S, 0) == FRAME_YES) ||
                  (ssGetOutputPortFrameData(S, 0) == FRAME_YES);

  /* Neither the input nor the output ports have been set */

  portDimsInfo.width   = 1;
  portDimsInfo.numDims = frame ? 2 : 1;
  portDimsInfo.dims    = frame ? dims : &portDimsInfo.width;

  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {  
      ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }

  if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {
      ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
}\n";

} elsif (($InRow[0] > 1  && $OutCol[0] == 1) || $OutDims[0] == "2-D") { 
  $inPortDimsInfoWidth = "INPUT_0_WIDTH";
  $outPortDimsInfoWidth = "OUTPUT_0_WIDTH";
  $defaultDimsInfo = "#define MDL_SET_DEFAULT_PORT_DIMENSION_INFO
static void mdlSetDefaultPortDimensionInfo(SimStruct *S)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { INPUT_0_WIDTH, 1 };
  bool  frameIn = ssGetInputPortFrameData(S, 0) == FRAME_YES;

  /* Neither the input nor the output ports have been set */

  portDimsInfo.width   = INPUT_0_WIDTH;
  portDimsInfo.numDims = frameIn ? 2 : 1;
  portDimsInfo.dims    = frameIn ? dims : &portDimsInfo.width;
  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {  
   ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
  portDimsInfo.width   = OUTPUT_0_WIDTH;
  dims[0]              = OUTPUT_0_WIDTH;
 if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {  
  ssSetOutputPortDimensionInfo(S, 0, &portDimsInfo);
 }
  return;
}\n";
}

$DimsInfoBody = "
#define MDL_SET_INPUT_PORT_DIMENSION_INFO
void mdlSetInputPortDimensionInfo(SimStruct        *S, 
                                  int              portIndex, 
                                  const DimsInfo_T *dimsInfo)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { OUTPUT_0_WIDTH, 1 };
  bool  frameIn = (ssGetInputPortFrameData(S, 0) == FRAME_YES);

  ssSetInputPortDimensionInfo(S, 0, dimsInfo);

  if (ssGetOutputPortNumDimensions(S, 0) == (-1)) {
      /* the output port has not been set */

      portDimsInfo.width   = $outPortDimsInfoWidth;
      portDimsInfo.numDims = frameIn ? 2 : 1;
      portDimsInfo.dims    = frameIn ? dims : &portDimsInfo.width;
      
      ssSetOutputPortDimensionInfo(S, 0, &portDimsInfo);
  }
}


#define MDL_SET_OUTPUT_PORT_DIMENSION_INFO
void mdlSetOutputPortDimensionInfo(SimStruct        *S,         
                                   int_T            portIndex,
                                   const DimsInfo_T *dimsInfo)
{
  DECL_AND_INIT_DIMSINFO(portDimsInfo);
  int_T dims[2] = { OUTPUT_0_WIDTH, 1 };
  bool  frameOut = (ssGetOutputPortFrameData(S, 0) == FRAME_YES);

  ssSetOutputPortDimensionInfo(S, 0, dimsInfo);

  if (ssGetInputPortNumDimensions(S, 0) == (-1)) {
      /* the input port has not been set */

      portDimsInfo.width   = $inPortDimsInfoWidth;
      portDimsInfo.numDims = frameOut ? 2 : 1;
      portDimsInfo.dims    = frameOut ? dims : &portDimsInfo.width;
      
      ssSetInputPortDimensionInfo(S, 0, &portDimsInfo);
  }
}

\n";
}
return $DimsInfoBody . $defaultDimsInfo;

}

###############################################
#  DimsInfo Function for -1 and N port widths #            
###############################################

sub getBodyMdlPortWidthMinusByN {

$bodyDimsInfoMbyN =
"#if defined(MATLAB_MEX_FILE)
# define MDL_SET_INPUT_PORT_WIDTH
  static void mdlSetInputPortWidth(SimStruct *S, int_T port,
                                    int_T inputPortWidth)
  {
      ssSetInputPortWidth(S,port,inputPortWidth);
  }
# define MDL_SET_OUTPUT_PORT_WIDTH
  static void mdlSetOutputPortWidth(SimStruct *S, int_T port,
                                     int_T outputPortWidth)
  {
      ssSetOutputPortWidth(S,port,ssGetInputPortWidth(S,0));
  }
#endif";

return $bodyDimsInfoMbyN;
}

###############################################
# Get data type macors
###############################################

sub getDataTypeMacros {
($localDataTypeMacors) = @_; 

my($iDataTypeMacors);
  
if($localDataTypeMacors =~ /real_T$/) {
  $iDataTypeMacors = "SS_DOUBLE";
}
elsif($localDataTypeMacors =~ /real32_T$/) {
  $iDataTypeMacors =  "SS_SINGLE";
}
elsif($localDataTypeMacors =~ /^int8_T$/ 
      || $localDataTypeMacors =~ /^cint8_T$/) {
  $iDataTypeMacors = "SS_INT8";
}
elsif($localDataTypeMacors =~ /^int16_T$/
      || $localDataTypeMacors =~ /^cint16_T$/) {
  $iDataTypeMacors =  "SS_INT16";
}
elsif($localDataTypeMacors =~ /^int32_T$/
      || $localDataTypeMacors =~ /^cint32_T$/) {
  $iDataTypeMacors = "SS_INT32";
}
elsif($localDataTypeMacors =~ /^uint8_T$/
      || $localDataTypeMacors =~ /^cuint8_T$/) {
  $iDataTypeMacors =  "SS_UINT8";
}
elsif($localDataTypeMacors =~ /^uint16_T$/
      || $localDataTypeMacors =~ /^cuint16_T$/) {
  $iDataTypeMacors = "SS_UINT16";
}
elsif($localDataTypeMacors =~ /^uint32_T$/
      || $localDataTypeMacors =~ /^cuint32_T$/) { 
  $iDataTypeMacors = "SS_UINT32";
}
elsif($localDataTypeMacors =~ /^boolean_T$/) {
  $iDataTypeMacors =  "SS_BOOLEAN";
}
elsif($localDataTypeMacors =~ /^fixpt$/) {
  $iDataTypeMacors =  "DataTypeId";
}
return $iDataTypeMacors;
}

sub genStartFcnMethods {
my($startmethods);
$startmethods = "\n\n#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START) 
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
  static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */\n";
return $startmethods;
}


sub genBusHeaderFile{
my($outbus_header,$inbus_header,$genHeader_Flag) = @_;
open(INBusHeaderFile,"<$inbus_header") || die "Unable to open $inbus_header Please check the directory permission\n";
$myline0 = "";
$myline1 = "";
$myline2 = "";
$line = "";
$user_data = "";

if($genHeader_Flag == 0){
    while(<INBusHeaderFile>){
        $line = $line.$_;
    }
close(INBusHeaderFile);
return $line;
}
else{
    if (-e $outbus_header){
    	open(OUTBusHeaderFile,"<$outbus_header") || die "Unable to open $filename Please check the directory permission\n";
			$str_match_flag = 0;
			while(<OUTBusHeaderFile>){
      	$line = $_;
		    if($str_match_flag == 1){
		    	$user_data = $user_data.$line;
	      }
	      if($line =~ /Read only - ENDS/){
	      	$str_match_flag = 1;
		    }
			} # end of while(<OUTBusHeaderFile>)

	  	close(OUTBusHeaderFile);
	    unlink $outbus_header;
	    $word = "#endif";
	    my $ri = rindex($user_data,$word);
	    substr($user_data,$ri,length($word)) = '' if $ri > -1;
	    $user_data =~ s/^\s+//;
	    $user_data =~ s/\s+$//;
    }

		open(OUTBusHeaderFile,">$outbus_header") || die "Unable to create $filename Please check the directory permission\n";
		while(<INBusHeaderFile>){
    	$line = $_;
    	if($line =~ /INCLUDE_FILES/){
        $myline  = substr($line, index($line,"=") + 1);
        $myline0 = $myline0.$myline;
    	}
    	elsif($line =~ /SETUP_BUSHEADER/){
        $myline  = substr($line, index($line,"=") + 1);
        $myline1 = $myline1.$myline;
    	}
    	elsif(1){
        $myline2 = $myline2.$line;
    	}
		}
	print OUTBusHeaderFile $myline1.$myline0.$myline2.$user_data."\n\n#endif\n";
	close(OUTBusHeaderFile);
	close(INBusHeaderFile);
	return 0;
	}
}

sub genFunctionforBus{
my($filename,$fcncallstr,$complex_parameter_str) = @_;
open(tempfile2, "<$filename") || die "Unable to open  $filename";
$inputs_busInfo = 0;
$outputs_busInfo = 0;
$busDeclarationStr = "";
$memcpyInpstr = "\t/*Copy input bus into temporary structure*/\n";
$memcpyOutstr = "\t/*Copy temporary structure into output bus*/\n";
while(<tempfile2>){
    chomp $_;
    if($_ =~ /complex_param_flag/){
        $complex_param_flag = substr($_, index($_,"=") + 1);
        if($complex_param_flag == 1){
            $bus_access_str = "\tint_T* busInfo = c->busInfo;\n";
        }else{
            $bus_access_str = "\tint_T* busInfo = (int_T *) ssGetUserData(S);\n";
        }
    }
    
    if($_ =~ /INPUTS/){
        $inputs_busInfo = 1;
        $businfoIdx = 0;
    }
    if($_ =~ /OUTPUTS/){
        $outputs_busInfo = 1;
        $businfoIdx = 0;
        $inputs_busInfo = 0;
    }
    if($inputs_busInfo == 1){
        if($_ =~ /Port number/){
            $portNumber = substr($_, index($_,":") + 1);
            $tempBusName = "_u".$portNumber."BUS";
        }
        if($_ =~ /Associated Bus/){
            $busDeclarationStr = $busDeclarationStr."\t".substr($_, index($_,":") + 1)." ".$tempBusName.";\n";
        }
        if(/^\./){              #if string starts with a '.'
			@busElementsInfo = split(",");
            #$businfoIdx = substr($_, index($_,",") + 1);
			$elementName = @busElementsInfo[0];
			$businfoIdx = @busElementsInfo[1];			
            #$elementName = substr($_,0,index($_,","));
			if (@busElementsInfo[2] > 1)
			{
				$isArray = ""; 
				#reference the element only if it is not an array else the element name is the reference anyway
			}
			else
			{
				$isArray = "&";
			}
            $memcpyInpstr = $memcpyInpstr."\t"."(void) memcpy(".$isArray.$tempBusName.$elementName.",".@InPortName[$portNumber]." + busInfo[".$businfoIdx."], busInfo[".++$businfoIdx."]);\n";
        }    
    }
    
    if($outputs_busInfo == 1){
        if($_ =~ /Port number/){
            $portNumber = substr($_, index($_,":") + 1);
            $tempBusName = "_y".$portNumber."BUS";
        }
        if($_ =~ /Associated Bus/){
            $busDeclarationStr = $busDeclarationStr."\t".substr($_, index($_,":") + 1)." ".$tempBusName.";\n";
        }
        if(/^\./){              #if string starts with a '.'
			@busElementsInfo = split(",");
			$businfoIdx = @busElementsInfo[1];
			$elementName = @busElementsInfo[0];
            #$businfoIdx = substr($_, index($_,",") + 1);
            #$elementName = substr($_,0,index($_,","));
			if (@busElementsInfo[2] > 1)
			{
				$isArray = ""; 
				#reference the element only if it is not an array else the element name is the reference anyway
			}
			else
			{
				$isArray = "&";
			}
            $memcpyOutstr = $memcpyOutstr."\t"."(void) memcpy(".@OutPortName[$portNumber]."+ busInfo[".$businfoIdx."], ".$isArray.$tempBusName.$elementName.", busInfo[".++$businfoIdx."]);\n";
        }
    }
}
close(tempfile2);

$busDeclarationStr = "\n\t/* Temporary bus copy declarations */\n".$busDeclarationStr;
$myline = $bus_access_str.$busDeclarationStr."\n".$complex_parameter_str.$memcpyInpstr."\t\n\t".$fcncallstr."\n\n".$memcpyOutstr;
return $myline;

}


sub genStartFcnMethodsforBus {
$filename = $_[0];
my($startmethodsforBus1);
my($startmethodsforBus2);
my($fileHandler);


$startmethodsforBus1 = "\n\n#define MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
  /* Function: mdlStart =======================================================
   * Abstract:
   *    This function is called once at start of model execution. If you
   *    have states that should be initialized once, this is the place
   *    to do it.
   */
static void mdlStart(SimStruct *S)
{
    /* Bus Information */
    slDataTypeAccess *dta = ssGetDataTypeAccess(S);
    const char *bpath = ssGetPath(S);\n";

$GetDataTypeId = "";
$malloc_check_str = "\tif(busInfo==NULL) {
        ssSetErrorStatus(S, \"Memory allocation failure\");
        return;
    }

      /* Calculate offsets of all primitive elements of the bus */\n\n";

open(fileHandler, "<$filename") || die "Unable to open  $filename";



 my @DataTypeNames  =('double', 'single','int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32','boolean');
 $sizeofDataTypeNames =  @DataTypeNames;
while(<fileHandler>){
    chomp $_;
    $busTypeIdVar = "";
    if($_ =~ /BusName/){
         $Busname = substr($_, index($_,":") + 1);
         $busTypeIdVar = $busTypeIdVar . "$Busname" ."Id";
         $getDataType = "\tDTypeId ".$Busname."Id = ssGetDataTypeId(S, \"$Busname\");\n";
         $GetDataTypeId = $GetDataTypeId.$getDataType;
         next;
    }
    if($_ =~ /offsetStorageSize/){
        $offsetStorageStr = substr($_, index($_,"=") + 1);
        $offsetStorageStr = "\n\tint_T *busInfo = (int_T *)malloc(".$offsetStorageStr."*sizeof(int_T));\n";
        next;
    }

    if($_ =~ /complex_param_flag/){
        $complex_param_flag = substr($_, index($_,"=") + 1);
        $bus_access_str = "";
        if($complex_param_flag == 1){
            $bus_access_str = "\tSFcnBCache *c =(SFcnBCache *)ssGetUserData(S);\n";
            $bus_access_str1 = "\tc->busInfo = busInfo;\n";
        }else{
            $bus_access_str1 = "\tssSetUserData(S, busInfo);\n";
        }
        next;
    }

    if($_ =~ /Bus_Offsets_End/){
        $Bus_Offsets_Begin = 0;
        next;
    }

    if($Bus_Offsets_Begin == 1){
        $offsetStr = "";
        @offsetInfo = split(",");
        $sizeoffsetInfo = @offsetInfo;
        for($i = 0;$i < $sizeoffsetInfo-5; $i=$i+2)
        {
            $offsetStr = $offsetStr."dtaGetDataTypeElementOffset(dta, bpath,".@offsetInfo[$i].",".@offsetInfo[$i+1].") +";
        }
        $offsetStr = $offsetStr."dtaGetDataTypeElementOffset(dta, bpath,".@offsetInfo[$i].",".@offsetInfo[$i+1].");\n";
        @offsetArray[$count_elements] = "busInfo[".$count_elements."] = ".$offsetStr;
        chomp @offsetInfo[$i+2];

                $isBuiltinDataTypes = 0;
                for ($k = 0; $k < $sizeofDataTypeNames; $k++) {
                   if (@DataTypeNames[$k] eq @offsetInfo[$i+2]) {
                      $isBuiltinDataTypes = 1;                 
                   }
                }
                if ($isBuiltinDataTypes == 1) {
                    $datatypeStr = "dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, \"".@offsetInfo[$i+2]."\"));\n";
                } else {
                    $datatypeStr = "dtaGetDataTypeSize(dta, bpath, ". @offsetInfo[$i] . ");\n";
                }

		$size_multiplier = 1;		
		if(@offsetInfo[$sizeoffsetInfo-1] eq "complex")
		{
			$size_multiplier = 2;
		}
		if(@offsetInfo[$sizeoffsetInfo-2] != 1)
		{
			$size_multiplier = $size_multiplier*@offsetInfo[$sizeoffsetInfo-2];						
		}
        $count_elements++;
		if($size_multiplier != 1)
		{
			$datatypeStr = $size_multiplier." * ".$datatypeStr;
		}		
        @datatypeArray[$count_elements] = "busInfo[".$count_elements."] = ".$datatypeStr;
        $count_elements++;
        next;
    }

    if($_ =~ /Bus_Offsets_Begin/){
        $Bus_Offsets_Begin = 1;
        $count_elements = 0;
        next;
    }

}
close(fileHandler);

$print_mdlStart = $startmethodsforBus1.$GetDataTypeId.$offsetStorageStr.$bus_access_str.$malloc_check_str;
for($i = 0;$i < $count_elements; $i++){
    $print_mdlStart = $print_mdlStart."\t".@offsetArray[$i];
    $print_mdlStart = $print_mdlStart.@datatypeArray[$i];
}

$startmethodsforBus2 = "}
#endif /*  MDL_START */\n";
$print_mdlStart = $print_mdlStart.$bus_access_str1.$startmethodsforBus2;
return $print_mdlStart;
}

  
sub genStartFcnMethodsTLC {

local $startmethodsTLC, $ParamsDec, $inportAddrInfo, $outportAddrInfo;

$inportAddrInfo ="";
for($i = 0; $i < $NumberOfInputPorts ; $i++){
  $inportAddrInfo =   $inportAddrInfo . "\n  %assign pu$i = LibBlockInputSignalAddr($i, \"\", \"\", 0)";
}
$outportAddrInfo ="";   
for($i=0; $i < $NumberOfOutputPorts ; $i++){
   $outportAddrInfo =  $outportAddrInfo . "\n  %assign py$i = LibBlockOutputSignalAddr($i, \"\", \"\", 0)";
}   
$n = 1;
if($NumParams){
 for($i=0; $i < $NumParams; $i++){
  $ParamsDec = "$ParamsDec 
  %assign nelements$n = LibBlockParameterSize(P$n)
  %assign param_width$n = nelements$n\[0\] * nelements$n\[1\]  
  %if (param_width$n) > 1  
   %assign pp$n = LibBlockMatrixParameterBaseAddr(P$n)
  %else  
   %assign pp$n = LibBlockParameterAddr(P$n, \"\", \"\", 0)
  %endif";
  $n++;
  }
}
$startmethodsTLC ="\n%% Function: Start =============================================================
%%
%function Start(block, system) Output
   /* %<Type> Block: %<Name> */
   $inportAddrInfo $outportAddrInfo
   $ParamsDec\n
%endfunction\n";
return $startmethodsTLC;
}
sub genTerminateFcnMethodsTLC {
my($terminatemethodsTLC);
$terminatemethodsTLC ="\n%% Function: Terminate =============================================================
%%
%function Terminate(block, system) Output
   /* %<Type> Block: %<Name> */

%endfunction\n";
return $terminatemethodsTLC;
}
sub genPortDataTypeMethods {
my($pmethods);
my($inp_methods);
my($ssInpPDT);

  if($NumberOfInputPorts > 0) { 
    $inp_methods = "\n#define MDL_SET_INPUT_PORT_DATA_TYPE
static void mdlSetInputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    ssSetInputPortDataType( S, 0, dType);
}";
    $ssInpPDT = "ssSetInputPortDataType( S, 0, SS_DOUBLE);\n"
  }

$pmethods ="\n#define MDL_SET_OUTPUT_PORT_DATA_TYPE
static void mdlSetOutputPortDataType(SimStruct *S, int port, DTypeId dType)
{
    ssSetOutputPortDataType(S, 0, dType);
}

#define MDL_SET_DEFAULT_PORT_DATA_TYPES
static void mdlSetDefaultPortDataTypes(SimStruct *S)
{
  $ssInpPDT ssSetOutputPortDataType(S, 0, SS_DOUBLE);
}\n";

return $inp_methods . $pmethods;
}


sub writeParamsDeclaration {

 for($i=0; $i < $NumParams ; $i++){
    print OUT "    const int_T   p_width$i  = mxGetNumberOfElements(PARAM_DEF$i(S));\n";
 }

 for($i=0; $i < $NumParams ; $i++) {
    if($ParameterComplexity[$i]  =~ /COMPLEX_NO/) {
    print OUT "    const $ParameterDataType[$i]  *$ParameterName[$i]  = mxGetData(PARAM_DEF$i(S));\n";
    }
 }

 @ArrayOfComplexParamsDataType = ();
 @ArrayCplxIndex = ();
 local $k = 0;
 local $printIdx = 0;
 for($i=0; $i < $NumParams ; $i++) {
    if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
        $printIdx = 1;
        #print OUT "    $ParameterDataType[$i]      $ParameterName[$i]" . "[p_width$i];\n";
        $ArrayOfComplexParamsDataType[$k] = $ParameterDataType[$i];
        $ArrayCplxIndex[$k] = $i;
        $k++;
    }
 }
 local $iCplx = 0;
 if( $printIdx > 0) {
    print OUT  "    SFcnBCache *c =(SFcnBCache *)ssGetUserData(S);\n";
    print OUT "    int   pIdx;";
 }
 foreach $ArrCplxParams (@ArrayOfComplexParamsDataType){
    $ArrCplxParams =~ s/^c//;
    print OUT "\n"."    $ParameterDataType[$ArrayCplxIndex[$iCplx]] *$ParameterName[$ArrayCplxIndex[$iCplx]]" .  "= c->" . "$ParameterName[$ArrayCplxIndex[$iCplx]];";
    $ArrayCplxIndex++;
    $iCplx++;
 }
} # end of writeParamsDeclaration


sub writeParamsDeclaration_cmplx {

 @ArrayOfComplexParamsDataType = ();
 @ArrayCplxIndex = ();
 local $k = 0;
 local $printIdx = 0;
 for($i=0; $i < $NumParams ; $i++) {
    if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
        $printIdx = 1;
        $ArrayOfComplexParamsDataType[$k] = $ParameterDataType[$i];
        $ArrayCplxIndex[$k] = $i;
        $k++;
    }
 }
 local $iCplx = 0;

 foreach $ArrCplxParams (@ArrayOfComplexParamsDataType){
    $ArrCplxParams =~ s/^c//;
 }

 $iCplx = 0;
 $ArrayCplxIndex = 0;
 my($complex_parameter_str) = "";

 foreach $ArrCplxParams (@ArrayOfComplexParamsDataType){
    $ArrCplxParams =~ s/^c//;
    $complex_parameter_str = $complex_parameter_str. "
    /*  Populate Complex Parameter: $ParameterName[$ArrayCplxIndex[$iCplx]]  */
    for (pIdx = 0; pIdx < p_width$ArrayCplxIndex[$iCplx]; pIdx++) {
        $ParameterName[$ArrayCplxIndex[$iCplx]]" . "" ."[pIdx]". ".re  = (($ArrCplxParams *)mxGetData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)))[pIdx];
        $ParameterName[$ArrayCplxIndex[$iCplx]]" . "" ."[pIdx]". ".im  = (($ArrCplxParams *)mxGetImagData(PARAM_DEF$ArrayCplxIndex[$iCplx](S)))[pIdx];
    }\n\n";
       $ArrayCplxIndex++;
       $iCplx++;
    }
  return $complex_parameter_str;
} # end of writeParamsDeclaration_cmplx

sub writeSFcnBCache {
 #my($flag_Busused) = $_[0];
 $writeCacheDecl = 1;

 for($i=0; $i < $NumParams ; $i++) {
    if ( $ParameterComplexity[$i]  =~ /COMPLEX_YES/) {
        if ($writeCacheDecl == 1) {
            print OUT "\ntypedef struct SFcnBCache_tag {\n";
            $writeCacheDecl = 2;
        }
            print OUT "  $ParameterDataType[$i]*  $ParameterName[$i];\n";
        }
    }
     if ($writeCacheDecl == 2){
        if($flag_Busused == 1){
            print OUT " int_T* busInfo;\n";
        }
        print OUT "} SFcnBCache;\n";
  }
 } # end of writeSFcnBCache
