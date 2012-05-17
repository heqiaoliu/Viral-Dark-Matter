/* Copyright 2004 The MathWorks, Inc. */

/*
 * fi_mdl_radix2fft_withscaling.c
 * 
 * Real-Time Workshop code generation for Simulink model "fi_mdl_radix2fft_withscaling.mdl".
 *
 * Model Version              : 1.12
 * Real-Time Workshop version : 6.1  (R14SP2)  01-Nov-2004
 * C source code generated on : Tue Dec  7 16:22:22 2004
 */

#include "fi_mdl_radix2fft_withscaling.h"
#include "fi_mdl_radix2fft_withscaling_private.h"

/* Block states (auto storage) */
D_Work_fi_mdl_radix2fft_withscaling fi_mdl_radix2fft_withscaling_DWork;

/* Real-time model */
rtModel_fi_mdl_radix2fft_withscaling fi_mdl_radix2fft_withscaling_M_;
rtModel_fi_mdl_radix2fft_withscaling *fi_mdl_radix2fft_withscaling_M =
  &fi_mdl_radix2fft_withscaling_M_;

/* Model output function */
static void fi_mdl_radix2fft_withscaling_output(int_T tid)
{

  /* local block i/o variables */

  cint16_T rtb_FFT[64];
  int16_T rtb_FromWorkspace[64];

  /* FromWorkspace: '<Root>/From Workspace' */
  {
    real_T t = fi_mdl_radix2fft_withscaling_M->Timing.t[0];
    real_T *pTimeValues = (real_T *)
      fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_PWORK.TimePtr;
    int16_T *pDataValues = (int16_T *)
      fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_PWORK.DataPtr;
    if (t < pTimeValues[0]) {
      {
        int_T i1;

        int16_T *y0 = rtb_FromWorkspace;

        for (i1=0; i1 < 64; i1++) {
          y0[i1] = 0;
        }
      }
    } else if (t == pTimeValues[0]) {
      {
        int_T i1;

        int16_T *y0 = rtb_FromWorkspace;

        for (i1=0; i1 < 64; i1++) {
          y0[i1] = pDataValues[0];
          pDataValues += 1;
        }
      }
    } else if (t > pTimeValues[0]) {
      {
        int_T i1;

        int16_T *y0 = rtb_FromWorkspace;

        for (i1=0; i1 < 64; i1++) {
          y0[i1] = 0;
        }
      }
    } else {
      int_T currTimeIndex =
        fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_IWORK.PrevIndex;
      if (t < pTimeValues[currTimeIndex]) {
        while (t < pTimeValues[currTimeIndex]) {
          currTimeIndex--;
        }
      } else {
        while (t >= pTimeValues[currTimeIndex + 1]) {
          currTimeIndex++;
        }
      }
      {
        int_T i1;

        int16_T *y0 = rtb_FromWorkspace;

        for (i1=0; i1 < 64; i1++) {
          y0[i1] = pDataValues[currTimeIndex];
          pDataValues += 1;
        }
      }
      fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_IWORK.PrevIndex =
        currTimeIndex;
    }
  }

  /* DSP Blockset FFT (sdspfft2) - '<Root>/FFT' */
  /* Real input, 1 channels, 64 rows, linear output order */
  {                                     /* Bit reverse scramble and copy from input buffer to output */
    int_T j=0, i=0;
    for (;i<63; i++) {
      rtb_FFT[j].re = rtb_FromWorkspace[i];
      rtb_FFT[j].im = 0;
      {
        int_T bit = 64;
        do { bit>>=1; j^=bit; } while (!(j & bit));
      }
    }
    rtb_FFT[j].re = rtb_FromWorkspace[i];
    rtb_FFT[j].im = 0;
  }
  {                                     /* Decimation in time FFT */
    int32_T accum;
    int32_T prod;
    cint16_T ctemp, ctemp2;
    int_T i;
    /* Remove trivial multiplies for first stage */
    for (i=0; i<63; i+=2) {
      /* CTEMP = y[i] - y[i+1]; */

      accum = LSL_S32(15,((int32_T)rtb_FFT[i].re));

      accum -= LSL_S32(15,((int32_T)rtb_FFT[i+1].re));

      accum = ASR(1,accum);

      ctemp.re = ((int16_T)ASR(15,accum));

      accum = LSL_S32(15,((int32_T)rtb_FFT[i].im));

      accum -= LSL_S32(15,((int32_T)rtb_FFT[i+1].im));

      accum = ASR(1,accum);

      ctemp.im = ((int16_T)ASR(15,accum));
      /* y[i] = y[i] + y[i+1]; */

      accum = LSL_S32(15,((int32_T)rtb_FFT[i].re));

      accum += LSL_S32(15,((int32_T)rtb_FFT[i+1].re));

      accum = ASR(1,accum);

      rtb_FFT[i].re = ((int16_T)ASR(15,accum));

      accum = LSL_S32(15,((int32_T)rtb_FFT[i].im));

      accum += LSL_S32(15,((int32_T)rtb_FFT[i+1].im));

      accum = ASR(1,accum);

      rtb_FFT[i].im = ((int16_T)ASR(15,accum));
      /* y[i+1] = CTEMP; */
      rtb_FFT[i+1].re = ctemp.re;
      rtb_FFT[i+1].im = ctemp.im;
    }
    {
      int_T idelta=2;
      int_T k = 16;
      int_T kratio = 16;
      while (k > 0) {
        int_T istart = 0;
        int_T i2;
        int_T j=kratio;
        int_T i1=istart;
        /* Remove trivial multiplies for first butterfly in remaining stages */
        for (i=0; i<k; i++) {
          i2 = i1 + idelta;
          /* CTEMP = y[0] - y[idelta]; */

          accum = LSL_S32(15,((int32_T)rtb_FFT[i1].re));

          accum -= LSL_S32(15,((int32_T)rtb_FFT[i2].re));

          accum = ASR(1,accum);

          ctemp.re = ((int16_T)ASR(15,accum));

          accum = LSL_S32(15,((int32_T)rtb_FFT[i1].im));

          accum -= LSL_S32(15,((int32_T)rtb_FFT[i2].im));

          accum = ASR(1,accum);

          ctemp.im = ((int16_T)ASR(15,accum));
          /* y[0] = y[0] + y[idelta]; */

          accum = LSL_S32(15,((int32_T)rtb_FFT[i1].re));

          accum += LSL_S32(15,((int32_T)rtb_FFT[i2].re));

          accum = ASR(1,accum);

          rtb_FFT[i1].re = ((int16_T)ASR(15,accum));

          accum = LSL_S32(15,((int32_T)rtb_FFT[i1].im));

          accum += LSL_S32(15,((int32_T)rtb_FFT[i2].im));

          accum = ASR(1,accum);

          rtb_FFT[i1].im = ((int16_T)ASR(15,accum));
          /* y[idelta] = CTEMP */
          rtb_FFT[i2].re = ctemp.re;
          rtb_FFT[i2].im = ctemp.im;
          i1 += (idelta<<1);
        }
        istart++;
        for (; j<32; j+= kratio) {
          int_T i1=istart;
          for (i=0; i<k; i++) {
            i2 = i1 + idelta;
            /* Compute ctemp = W * y[i2] */
            MUL_S32_S16_S16(prod,rtb_FFT[i2].re,(fi_mdl_radix2fft_withscaling_P.FFT_TwiddleTable[j+16]));
            accum = prod;
            MUL_S32_S16_S16(prod,rtb_FFT[i2].im,(fi_mdl_radix2fft_withscaling_P.FFT_TwiddleTable[j+32]));
            accum -= prod;

            ctemp.re = ((int16_T)ASR(15,accum));
            MUL_S32_S16_S16(prod,rtb_FFT[i2].re,(fi_mdl_radix2fft_withscaling_P.FFT_TwiddleTable[j+32]));
            accum = prod;
            MUL_S32_S16_S16(prod,rtb_FFT[i2].im,(fi_mdl_radix2fft_withscaling_P.FFT_TwiddleTable[j+16]));
            accum += prod;

            ctemp.im = ((int16_T)ASR(15,accum));
            /* Compute ctemp2 = y[i1] + ctemp */

            accum = LSL_S32(15,((int32_T)rtb_FFT[i1].re));

            accum += LSL_S32(15,((int32_T)ctemp.re));

            accum = ASR(1,accum);

            ctemp2.re = ((int16_T)ASR(15,accum));

            accum = LSL_S32(15,((int32_T)rtb_FFT[i1].im));

            accum += LSL_S32(15,((int32_T)ctemp.im));

            accum = ASR(1,accum);

            ctemp2.im = ((int16_T)ASR(15,accum));
            /* Compute y[i2] = y[i1] - ctemp */

            accum = LSL_S32(15,((int32_T)rtb_FFT[i1].re));

            accum -= LSL_S32(15,((int32_T)ctemp.re));

            accum = ASR(1,accum);

            rtb_FFT[i2].re = ((int16_T)ASR(15,accum));

            accum = LSL_S32(15,((int32_T)rtb_FFT[i1].im));

            accum -= LSL_S32(15,((int32_T)ctemp.im));

            accum = ASR(1,accum);

            rtb_FFT[i2].im = ((int16_T)ASR(15,accum));
            /* y[i1] = ctemp2 */
            rtb_FFT[i1].re = ctemp2.re;
            rtb_FFT[i1].im = ctemp2.im;
            i1 += (idelta<<1);
          }
          istart++;
        }
        idelta <<= 1;
        k >>= 1;
        kratio>>=1;
      }
    }
  }

  /* ToWorkspace: '<Root>/To Workspace' */

  {
    creal_T u[64];

    {
      int_T i1;

      const cint16_T *u0 = rtb_FFT;

      for (i1=0; i1 < 64; i1++) {
        u[i1].re = ldexp((double)u0[i1].re, -14);
        u[i1].im = ldexp((double)u0[i1].im, -14);
      }
    }

    rt_UpdateLogVar((LogVar*)fi_mdl_radix2fft_withscaling_DWork.ToWorkspace_PWORK.LoggedData,
     u);
  }
}

/* Model update function */
static void fi_mdl_radix2fft_withscaling_update(int_T tid)
{

  /* Update absolute time for base rate */

  if(!(++fi_mdl_radix2fft_withscaling_M->Timing.clockTick0))
  ++fi_mdl_radix2fft_withscaling_M->Timing.clockTickH0;
  fi_mdl_radix2fft_withscaling_M->Timing.t[0] =
    fi_mdl_radix2fft_withscaling_M->Timing.clockTick0 *
    fi_mdl_radix2fft_withscaling_M->Timing.stepSize0 +
    fi_mdl_radix2fft_withscaling_M->Timing.clockTickH0 *
    fi_mdl_radix2fft_withscaling_M->Timing.stepSize0 * 4294967296.0;
}

/* Model initialize function */
void fi_mdl_radix2fft_withscaling_initialize(boolean_T firstTime)
{

  if (firstTime) {
    /* registration code */
    /* initialize real-time model */
    (void)memset((char_T *)fi_mdl_radix2fft_withscaling_M, 0,
     sizeof(rtModel_fi_mdl_radix2fft_withscaling));

    /* Initialize timing info */
    {
      int_T *mdlTsMap =
        fi_mdl_radix2fft_withscaling_M->Timing.sampleTimeTaskIDArray;
      mdlTsMap[0] = 0;
      fi_mdl_radix2fft_withscaling_M->Timing.sampleTimeTaskIDPtr =
        (&mdlTsMap[0]);
      fi_mdl_radix2fft_withscaling_M->Timing.sampleTimes =
        (&fi_mdl_radix2fft_withscaling_M->Timing.sampleTimesArray[0]);
      fi_mdl_radix2fft_withscaling_M->Timing.offsetTimes =
        (&fi_mdl_radix2fft_withscaling_M->Timing.offsetTimesArray[0]);
      /* task periods */
      fi_mdl_radix2fft_withscaling_M->Timing.sampleTimes[0] = (0.25);

      /* task offsets */
      fi_mdl_radix2fft_withscaling_M->Timing.offsetTimes[0] = (0.0);
    }

    rtmSetTPtr(fi_mdl_radix2fft_withscaling_M,
     &fi_mdl_radix2fft_withscaling_M->Timing.tArray[0]);

    {
      int_T *mdlSampleHits =
        fi_mdl_radix2fft_withscaling_M->Timing.sampleHitArray;
      mdlSampleHits[0] = 1;
      fi_mdl_radix2fft_withscaling_M->Timing.sampleHits = (&mdlSampleHits[0]);
    }

    rtmSetTFinal(fi_mdl_radix2fft_withscaling_M, 0.0);
    fi_mdl_radix2fft_withscaling_M->Timing.stepSize0 = 0.25;

    /* Setup for data logging */
    {
      static RTWLogInfo rt_DataLoggingInfo;

      fi_mdl_radix2fft_withscaling_M->rtwLogInfo = &rt_DataLoggingInfo;

      rtliSetLogFormat(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, 0);

      rtliSetLogMaxRows(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, 1000);

      rtliSetLogDecimation(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, 1);

      rtliSetLogVarNameModifier(fi_mdl_radix2fft_withscaling_M->rtwLogInfo,
       "rt_");

      rtliSetLogT(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, "tout");

      rtliSetLogX(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, "");

      rtliSetLogXFinal(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, "");

      rtliSetSigLog(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, "");

      rtliSetLogXSignalInfo(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, NULL);

      rtliSetLogXSignalPtrs(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, NULL);

      rtliSetLogY(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, "");

      rtliSetLogYSignalInfo(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, NULL);

      rtliSetLogYSignalPtrs(fi_mdl_radix2fft_withscaling_M->rtwLogInfo, NULL);
    }

    fi_mdl_radix2fft_withscaling_M->solverInfoPtr =
      (&fi_mdl_radix2fft_withscaling_M->solverInfo);
    fi_mdl_radix2fft_withscaling_M->Timing.stepSize = (0.25);
    rtsiSetFixedStepSize(&fi_mdl_radix2fft_withscaling_M->solverInfo, 0.25);
    rtsiSetSolverMode(&fi_mdl_radix2fft_withscaling_M->solverInfo,
     SOLVER_MODE_SINGLETASKING);

    /* parameters */
    fi_mdl_radix2fft_withscaling_M->ModelData.defaultParam = ((real_T *)
      &fi_mdl_radix2fft_withscaling_P);

    /* data type work */
    fi_mdl_radix2fft_withscaling_M->Work.dwork = ((void *)
      &fi_mdl_radix2fft_withscaling_DWork);
    (void)memset((char_T *) &fi_mdl_radix2fft_withscaling_DWork, 0,
     sizeof(D_Work_fi_mdl_radix2fft_withscaling));

    /* initialize non-finites */
    rt_InitInfAndNaN(sizeof(real_T));
  }
}

/* Model terminate function */
void fi_mdl_radix2fft_withscaling_terminate(void)
{
}

/*========================================================================*
 * Start of GRT compatible call interface                                 *
 *========================================================================*/

void MdlOutputs(int_T tid) {

  fi_mdl_radix2fft_withscaling_output(tid);
}

void MdlUpdate(int_T tid) {

  fi_mdl_radix2fft_withscaling_update(tid);
}

void MdlInitializeSizes(void) {
  fi_mdl_radix2fft_withscaling_M->Sizes.numContStates = (0); /* Number of continuous states */
  fi_mdl_radix2fft_withscaling_M->Sizes.numY = (0); /* Number of model outputs */
  fi_mdl_radix2fft_withscaling_M->Sizes.numU = (0); /* Number of model inputs */
  fi_mdl_radix2fft_withscaling_M->Sizes.sysDirFeedThru = (0); /* The model is not direct feedthrough */
  fi_mdl_radix2fft_withscaling_M->Sizes.numSampTimes = (1); /* Number of sample times */
  fi_mdl_radix2fft_withscaling_M->Sizes.numBlocks = (3); /* Number of blocks */
  fi_mdl_radix2fft_withscaling_M->Sizes.numBlockIO = (0); /* Number of block outputs */
  fi_mdl_radix2fft_withscaling_M->Sizes.numBlockPrms = (64); /* Sum of parameter "widths" */
}

void MdlInitializeSampleTimes(void) {
}

void MdlInitialize(void) {
}

void MdlStart(void) {

  /* FromWorkspace Block: <Root>/From Workspace */
  {

    static real_T pTimeValues[] = { 0.0 };

    static int16_T pDataValues[] = { 24576, 21375, 13255, 3838, -3129, -5793,
      -5063, -3838, -5063, -9789, -16384, -21375, -21447, -15423, -5063, 5793,
      13255, 15423, 13255, 9789, 8192, 9789, 13255, 15423, 13255, 5793, -5063,
      -15423, -21447, -21375, -16384, -9789, -5063, -3838, -5063, -5793, -3129,
      3838, 13255, 21375, 24576, 21375, 13255, 3838, -3129, -5793, -5063, -3838,
      -5063, -9789, -16384, -21375, -21447, -15423, -5063, 5793, 13255, 15423,
      13255, 9789, 8192, 9789, 13255, 15423 };

    fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_PWORK.TimePtr = (void *)
      pTimeValues;
    fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_PWORK.DataPtr = (void *)
      pDataValues;

    fi_mdl_radix2fft_withscaling_DWork.FromWorkspace_IWORK.PrevIndex = 0;
  }

  /* ToWorkspace Block: <Root>/To Workspace */
  {
    int_T dimensions[2] = {1, 64};

    fi_mdl_radix2fft_withscaling_DWork.ToWorkspace_PWORK.LoggedData =
      rt_CreateLogVar(
      fi_mdl_radix2fft_withscaling_M->rtwLogInfo,
      0.0,
     rtmGetTFinal(fi_mdl_radix2fft_withscaling_M),
     fi_mdl_radix2fft_withscaling_M->Timing.stepSize0,
     &(rtmGetErrorStatus(fi_mdl_radix2fft_withscaling_M)),
     "y_sim",
     SS_DOUBLE,
     0,
     1,
     0,
     64,
     2,
     dimensions,
     0,
     1,
     0.25,
     1);

    if (fi_mdl_radix2fft_withscaling_DWork.ToWorkspace_PWORK.LoggedData == NULL)
    return;
  }

  MdlInitialize();
}

rtModel_fi_mdl_radix2fft_withscaling *fi_mdl_radix2fft_withscaling(void) {
  fi_mdl_radix2fft_withscaling_initialize(1);
  return fi_mdl_radix2fft_withscaling_M;
}

void MdlTerminate(void) {
  fi_mdl_radix2fft_withscaling_terminate();
}

/*========================================================================*
 * End of GRT compatible call interface                                   *
 *========================================================================*/

