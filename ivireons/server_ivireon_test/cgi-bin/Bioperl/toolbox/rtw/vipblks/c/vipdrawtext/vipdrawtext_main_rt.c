/*
*  vipdrawtext_main_rt.c
*
*  Copyright 1995-2008 The MathWorks, Inc.
*  $Revision: 1.1.12.11 $ $Date: 2008/11/18 02:11:48 $
*/

#include "vipdrawtext_rt.h"
#include <string.h> 

/***************************************  double *************************************************************/

/*  RGB  */

EXPORT_FCN void MWVIP_DrawText_RGB_double_AA(const uint8_T* bitmap,
                                             int32_T pen_x,
                                             int32_T pen_y,
                                             int32_T left_bearing,
                                             int32_T top_bearing,
                                             uint16_T bitmapWidth,
                                             uint16_T bitmapHeight,
                                             uint32_T imageWidth,
                                             uint32_T imageHeight,
                                             void* outputImageR,
                                             void* outputImageG,
                                             void* outputImageB,
                                             const void* colorVect,
                                             const void* opacityPtr,
                                             boolean_T isImageTransposed)
{ 
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real_T	bitmapVal, valR, valG, valB;
    real_T *outR = (real_T*) outputImageR,
        *outG = (real_T*) outputImageG,
        *outB = (real_T*) outputImageB;
    const real_T*  colorVector = (const real_T*) colorVect; 
    real_T opacity = *((const real_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++)
        {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                    bitmapIndx++;
                    continue;
            }

            if (isImageTransposed)
                bitmapVal = (real_T)bitmap[bitmapIndx++] / 255.0;
            else
                bitmapVal = (real_T)bitmap[j * bitmapWidth + i] / 255.0;
            

            if(bitmapVal == 0.0)
                continue;

            if(bitmapVal == 1.0)	/* just the text color  */
            {
                valR = colorVector[0];
                valG = colorVector[1];
                valB = colorVector[2];
            }
            else	/* on the edge, need to figure out for nice anti-aliasing */
            {
                valR = (colorVector[0] - outR[pixelIndex]) * bitmapVal + outR[pixelIndex];
                valG = (colorVector[1] - outG[pixelIndex]) * bitmapVal + outG[pixelIndex];
                valB = (colorVector[2] - outB[pixelIndex]) * bitmapVal + outB[pixelIndex];
            }

            if(opacity < 1.0) 
            {
                valR = (opacity * valR) + ((1.0 - opacity) * outR[pixelIndex]);
                valG = (opacity * valG) + ((1.0 - opacity) * outG[pixelIndex]);
                valB = (opacity * valB) + ((1.0 - opacity) * outB[pixelIndex]);
            }

            outR[pixelIndex] = valR;
            outG[pixelIndex] = valG;
            outB[pixelIndex] = valB;
        }
        pixelIndexCpy += imageHeight;
    }
}


EXPORT_FCN void MWVIP_DrawText_RGB_double(const uint8_T* bitmap,
                                          int32_T pen_x,
                                          int32_T pen_y,
                                          int32_T left_bearing,
                                          int32_T top_bearing,
                                          uint16_T bitmapWidth,
                                          uint16_T bitmapHeight,
                                          uint32_T imageWidth,
                                          uint32_T imageHeight,
                                          void* outputImageR,
                                          void* outputImageG,
                                          void* outputImageB,
                                          const void* colorVect,
                                          const void* opacityPtr,
                                          boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real_T	bitmapVal, valR, valG, valB;
    real_T	*outR = (real_T*) outputImageR,
        *outG = (real_T*) outputImageG,
        *outB = (real_T*) outputImageB;
    const real_T *colorVector = (const real_T*) colorVect;
    real_T opacity = *((const real_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real_T)bitmap[bitmapIndx++] / 255.0;
            else
                bitmapVal = (real_T)bitmap[j * bitmapWidth + i] / 255.0;

            if(bitmapVal == 0.0)
                continue;

            valR = colorVector[0];
            valG = colorVector[1];
            valB = colorVector[2];

            if(opacity < 1.0)
            {
                valR = (opacity * valR) + ((1.0 - opacity) * outR[pixelIndex]);
                valG = (opacity * valG) + ((1.0 - opacity) * outG[pixelIndex]);
                valB = (opacity * valB) + ((1.0 - opacity) * outB[pixelIndex]);
            }

            outR[pixelIndex] = valR;
            outG[pixelIndex] = valG;
            outB[pixelIndex] = valB;
        }
        pixelIndexCpy += imageHeight;
    }
}


/* Intensity */

EXPORT_FCN void MWVIP_DrawText_I_double_AA(const uint8_T* bitmap,
                                           int32_T pen_x,
                                           int32_T pen_y,
                                           int32_T left_bearing,
                                           int32_T top_bearing,
                                           uint16_T bitmapWidth,
                                           uint16_T bitmapHeight,
                                           uint32_T imageWidth,
                                           uint32_T imageHeight,
                                           void* outputImageR,
                                           const void* colorVect,
                                           const void* opacityPtr,
                                           boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real_T	bitmapVal, valI;
    real_T	*out = (real_T*) outputImageR;
    const real_T  *colorVector = (const real_T*) colorVect;
    real_T opacity = *((const real_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real_T)bitmap[bitmapIndx++] / 255.0;
            else
                bitmapVal = (real_T)bitmap[j * bitmapWidth + i] / 255.0;

            if(bitmapVal == 0.0)
                continue;

            if(bitmapVal == 1.0)	/* just the text intensity  */
            {
                valI = *colorVector;
            }
            else	/* on the edge, need to figure out for nice anti-aliasing */
            {
                valI = (*colorVector - out[pixelIndex]) * bitmapVal + out[pixelIndex];
            }

            if(opacity < 1.0)
            {
                valI = (opacity * valI) + ((1.0 - opacity) * out[pixelIndex]);
            }

            out[pixelIndex] = valI;
        }
        pixelIndexCpy += imageHeight;
    }
}


EXPORT_FCN void MWVIP_DrawText_I_double(const uint8_T* bitmap,
                                        int32_T pen_x,
                                        int32_T pen_y,
                                        int32_T left_bearing,
                                        int32_T top_bearing,
                                        uint16_T bitmapWidth,
                                        uint16_T bitmapHeight,
                                        uint32_T imageWidth,
                                        uint32_T imageHeight,
                                        void* outputImageR,
                                        const void* colorVect,
                                        const void* opacityPtr,
                                        boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real_T	bitmapVal, valI;
    real_T	*out = (real_T*) outputImageR;
    const real_T*  colorVector = (const real_T*) colorVect;
    real_T opacity = *((const real_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real_T)bitmap[bitmapIndx++] / 255.0;
            else
                bitmapVal = (real_T)bitmap[j * bitmapWidth + i] / 255.0;

            if(bitmapVal == 0.0)
                continue;

            valI = *colorVector;

            if(opacity < 1.0)
            {
                valI = (opacity * valI) + ((1.0 - opacity) * out[pixelIndex]);
            }
            out[pixelIndex] = valI;
        }
        pixelIndexCpy += imageHeight;
    }
}



/***************************************  single *************************************************************/

/*  RGB  */

EXPORT_FCN void MWVIP_DrawText_RGB_single_AA(const uint8_T* bitmap,
                                             int32_T pen_x,
                                             int32_T pen_y,
                                             int32_T left_bearing,
                                             int32_T top_bearing,
                                             uint16_T bitmapWidth,
                                             uint16_T bitmapHeight,
                                             uint32_T imageWidth,
                                             uint32_T imageHeight,
                                             void* outputImageR,
                                             void* outputImageG,
                                             void* outputImageB,
                                             const void* colorVect,
                                             const void* opacityPtr,
                                             boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real32_T	bitmapVal, valR, valG, valB;
    real32_T *outR = (real32_T*) outputImageR,
        *outG = (real32_T*) outputImageG,
        *outB = (real32_T*) outputImageB;
    const real32_T*  colorVector = (const real32_T*) colorVect;
    real32_T opacity = *((const real32_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real32_T)bitmap[bitmapIndx++] / 255.0F;
            else
                bitmapVal = (real32_T)bitmap[j * bitmapWidth + i] / 255.0F;

            if(bitmapVal == 0.0F)
                continue;

            if(bitmapVal == 1.0F)	/* just the text color  */
            {
                valR = colorVector[0];
                valG = colorVector[1];
                valB = colorVector[2];
            }
            else	/* on the edge, need to figure out for nice anti-aliasing */
            {
                valR = (colorVector[0] - outR[pixelIndex]) * bitmapVal + outR[pixelIndex];
                valG = (colorVector[1] - outG[pixelIndex]) * bitmapVal + outG[pixelIndex];
                valB = (colorVector[2] - outB[pixelIndex]) * bitmapVal + outB[pixelIndex];
            }

            if(opacity < 1.0F)
            {
                valR = (real32_T)((opacity * valR) + ((1.0F - opacity) * outR[pixelIndex]));
                valG = (real32_T)((opacity * valG) + ((1.0F - opacity) * outG[pixelIndex]));
                valB = (real32_T)((opacity * valB) + ((1.0F - opacity) * outB[pixelIndex]));
            }

            outR[pixelIndex] = valR;
            outG[pixelIndex] = valG;
            outB[pixelIndex] = valB;
        }
        pixelIndexCpy += imageHeight;
    }
}


EXPORT_FCN void MWVIP_DrawText_RGB_single(const uint8_T* bitmap,
                                          int32_T pen_x,
                                          int32_T pen_y,
                                          int32_T left_bearing,
                                          int32_T top_bearing,
                                          uint16_T bitmapWidth,
                                          uint16_T bitmapHeight,
                                          uint32_T imageWidth,
                                          uint32_T imageHeight,
                                          void* outputImageR,
                                          void* outputImageG,
                                          void* outputImageB,
                                          const void* colorVect,
                                          const void* opacityPtr,
                                          boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real32_T	bitmapVal, valR, valG, valB;
    real32_T	*outR = (real32_T*) outputImageR,
        *outG = (real32_T*) outputImageG,
        *outB = (real32_T*) outputImageB;
    const real32_T   *colorVector = (const real32_T*) colorVect;
    real32_T opacity = *((const real32_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real32_T)bitmap[bitmapIndx++] / 255.0F;
            else
                bitmapVal = (real32_T)bitmap[j * bitmapWidth + i] / 255.0F;

            if(bitmapVal == 0.0F)
                continue;

            valR = colorVector[0];
            valG = colorVector[1];
            valB = colorVector[2];

            if(opacity < 1.0F)
            {
                valR = (real32_T)((opacity * valR) + ((1.0F - opacity) * outR[pixelIndex]));
                valG = (real32_T)((opacity * valG) + ((1.0F - opacity) * outG[pixelIndex]));
                valB = (real32_T)((opacity * valB) + ((1.0F - opacity) * outB[pixelIndex]));
            }

            outR[pixelIndex] = valR;
            outG[pixelIndex] = valG;
            outB[pixelIndex] = valB;
        }
        pixelIndexCpy += imageHeight;
    }
}


/* Intensity */

EXPORT_FCN void MWVIP_DrawText_I_single_AA(const uint8_T* bitmap,
                                           int32_T pen_x,
                                           int32_T pen_y,
                                           int32_T left_bearing,
                                           int32_T top_bearing,
                                           uint16_T bitmapWidth,
                                           uint16_T bitmapHeight,
                                           uint32_T imageWidth,
                                           uint32_T imageHeight,
                                           void* outputImageR,
                                           const void* colorVect,
                                           const void* opacityPtr,
                                           boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real32_T	bitmapVal, valI;
    real32_T	*out = (real32_T*) outputImageR;
    const real32_T  *colorVector = (const real32_T*) colorVect;
    real32_T opacity = *((const real32_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real32_T)bitmap[bitmapIndx++] / 255.0F;
            else
                bitmapVal = (real32_T)bitmap[j * bitmapWidth + i] / 255.0F;

            if(bitmapVal == 0.0F)
                continue;

            if(bitmapVal == 1.0F)	/* just the text intensity  */
            {
                valI = *colorVector;
            }
            else	/* on the edge, need to figure out for nice anti-aliasing */
            {
                valI = (*colorVector - out[pixelIndex]) * bitmapVal + out[pixelIndex];
            }

            if(opacity < 1.0F)
            {
                valI = (real32_T)((opacity * valI) + ((1.0F - opacity) * out[pixelIndex]));
            }

            out[pixelIndex] = valI;
        }
        pixelIndexCpy += imageHeight;
    }
}


EXPORT_FCN void MWVIP_DrawText_I_single(const uint8_T* bitmap,
                                        int32_T pen_x,
                                        int32_T pen_y,
                                        int32_T left_bearing,
                                        int32_T top_bearing,
                                        uint16_T bitmapWidth,
                                        uint16_T bitmapHeight,
                                        uint32_T imageWidth,
                                        uint32_T imageHeight,
                                        void* outputImageR,
                                        const void* colorVect,
                                        const void* opacityPtr,
                                        boolean_T isImageTransposed)
{
    int32_T  i, j,x,y;
    uint32_T pixelIndexCpy;
    real32_T	bitmapVal, valI;
    real32_T	*out = (real32_T*) outputImageR;
    const real32_T*  colorVector = (const real32_T*) colorVect;
    real32_T opacity = *((const real32_T*)opacityPtr);
    int_T outerLoop, innerLoop, bitmapIndx = 0;
    if (isImageTransposed) {
        outerLoop = bitmapHeight;
        innerLoop = bitmapWidth;
        y = pen_x + left_bearing;
        x = pen_y - top_bearing;
    } else {
        outerLoop = bitmapWidth;
        innerLoop = bitmapHeight; 
        x = pen_x + left_bearing;
        y = pen_y - top_bearing;
    }
    pixelIndexCpy = y + (x * imageHeight);
    for(i = 0; i < outerLoop; i++) {
        uint32_T pixelIndex = pixelIndexCpy - 1;
        for(j = 0; j < innerLoop; j++) {
            pixelIndex++;
            if(	(x < (-i)) || (x >= ((int32_T)imageWidth-i)) ||
                (y < (-j)) || (y >= ((int32_T)imageHeight-j))) {
                bitmapIndx++;
                continue;
            }

            if (isImageTransposed)
                bitmapVal = (real32_T)bitmap[bitmapIndx++] / 255.0F;
            else
                bitmapVal = (real32_T)bitmap[j * bitmapWidth + i] / 255.0F;

            if(bitmapVal == 0.0F)
                continue;

            valI = *colorVector;

            if(opacity < 1.0F)
            {
                valI = (real32_T)((opacity * valI) + ((1.0F - opacity) * out[pixelIndex]));
            }

            out[pixelIndex] = valI;
        }
        pixelIndexCpy += imageHeight;
    }
}



static const DRAW_TEXT_FUNC_RGB antiAliasedDrawTextFcns_RGB[] =
{
    /* real_T */
    MWVIP_DrawText_RGB_double_AA,
    /* real32_T */
    MWVIP_DrawText_RGB_single_AA,
    /* int8_T */
    NULL,
    /* uint8_T */
    NULL,
    /* int16_T */
    NULL,
    /* uint16_T */
    NULL,
    /* int32_T */
    NULL,
    /* uint32_T */
    NULL,
    /* boolean_T */
    NULL
};

static const DRAW_TEXT_FUNC_RGB drawTextFcns_RGB[] = 
{
    /* real_T */
    MWVIP_DrawText_RGB_double,
    /* real32_T */
    MWVIP_DrawText_RGB_single,
    /* int8_T */
    NULL,
    /* uint8_T */
    NULL,
    /* int16_T */
    NULL,
    /* uint16_T */
    NULL,
    /* int32_T */
    NULL,
    /* uint32_T */
    NULL,
    /* boolean_T */
    NULL
};



static const DRAW_TEXT_FUNC_I antiAliasedDrawTextFcns_Intensity[] =
{
    /* real_T */
    MWVIP_DrawText_I_double_AA,
    /* real32_T */
    MWVIP_DrawText_I_single_AA,
    /* int8_T */
    NULL,
    /* uint8_T */
    NULL,
    /* int16_T */
    NULL,
    /* uint16_T */
    NULL,
    /* int32_T */
    NULL,
    /* uint32_T */
    NULL,
    /* boolean_T */
    NULL
};



static const DRAW_TEXT_FUNC_I drawTextFcns_Intensity[] = 
{
    /* real_T */
    MWVIP_DrawText_I_double,
    /* real32_T */
    MWVIP_DrawText_I_single,
    /* int8_T */
    NULL,
    /* uint8_T */
    NULL,
    /* int16_T */
    NULL,
    /* uint16_T */
    NULL,
    /* int32_T */
    NULL,
    /* uint32_T */
    NULL,
    /* boolean_T */
    NULL
};


static const DRAW_TEXT_FUNC_RGB* drawTextFunctions_RGB[] = 
{
    drawTextFcns_RGB,
    antiAliasedDrawTextFcns_RGB
};

static const DRAW_TEXT_FUNC_I* drawTextFunctions_I[] = 
{
    drawTextFcns_Intensity,
    antiAliasedDrawTextFcns_Intensity
};


EXPORT_FCN DRAW_TEXT_FUNC_RGB MWVIP_GetDrawTextFcn_RGB(int_T dataTypeID, boolean_T isAntiAliased)
{
    DRAW_TEXT_FUNC_RGB ret = (drawTextFunctions_RGB[isAntiAliased])[dataTypeID];
    return ret;
}

EXPORT_FCN DRAW_TEXT_FUNC_I MWVIP_GetDrawTextFcn_I(int_T dataTypeID, boolean_T isAntiAliased)
{
    DRAW_TEXT_FUNC_I ret = (drawTextFunctions_I[isAntiAliased])[dataTypeID];
    return ret;
}


/* stuff for converting amongst data types... */
EXPORT_FCN void MWVIP_DrawText_copyDT1ToUint32(int32_T dataType1, uint32_T numElements, const void* input, void* uint32Output, int32_T dummy)
{
    uint32_T i;
    uint32_T* out = (uint32_T*)uint32Output;
    (void)dummy;
    switch(dataType1)
    {
    case 0:  /* 0 */
        {
            const real_T* in = (const real_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 1: /* 1 */
        {
            const real32_T* in = (const real32_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 2: /* SS_INT8 */
        {
            const int8_T* in = (const int8_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 3: /* SS_UINT8 */
        {
            const uint8_T* in = (const uint8_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 4: /* SS_INT16 */
        {
            const int16_T* in = (const int16_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 5: /* SS_UINT16 */
        {
            const uint16_T* in = (const uint16_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 6: /* SS_INT32 */
        {
            const int32_T* in = (const int32_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    case 7: /* SS_UINT32 */
        {
            const uint32_T* in = (const uint32_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = *in++;
            break;
        }
    default: /* SS_BOOLEAN */
        {
            const boolean_T* in = (const boolean_T*)input;
            for(i = 0; i < numElements; i++)
                *out++ = (uint32_T)*in++;
            break;
        }
    }
}


EXPORT_FCN void MWVIP_DrawText_copyDT1ToInt32(int32_T dataType1, uint32_T numElements, const void* input, void* int32Output, int32_T indx)
{
    uint32_T i;
    int32_T* out = (int32_T*)int32Output;
    switch(dataType1)
    {
    case 0: /* 0 */
        {
            const real_T* in = (const real_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 1: /* 1 */
        {
            const real32_T* in = (const real32_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 2: /* SS_INT8 */
        {
            const int8_T* in = (const int8_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 3: /* SS_UINT8 */
        {
            const uint8_T* in = (const uint8_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 4: /* SS_INT16 */
        {
            const int16_T* in = (const int16_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 5: /* SS_UINT16 */
        {
            const uint16_T* in = (const uint16_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 6: /* SS_INT32 */
        {
            const int32_T* in = (const int32_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = *in++;
            break;
        }
    case 7: /* SS_UINT32 */
        {
            const uint32_T* in = (const uint32_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    case 8: /* SS_BOOLEAN */
        {
            const boolean_T* in = (const boolean_T*)input;
            in += indx;
            for(i = 0; i < numElements; i++)
                *out++ = (int32_T)*in++;
            break;
        }
    }
}

EXPORT_FCN void MWVIP_DrawText_noCopyNeeded(int32_T dataType1, uint32_T numElements, const void* input, void* output, int32_T indx)
{
    (void)dataType1;
    (void)numElements;
    (void)input;
    (void)output;
    (void)indx;
}


EXPORT_FCN void MWVIP_DrawText_SatFltptRGBVals(int32_T dType, const void* inPtr, void* outPtr, int_T nPlanes)
{
    int32_T i = 0;
    (void)nPlanes;        
    if(dType == 0)
    {
        const real_T* in = (const real_T*)inPtr;
        real_T* out = (real_T*)outPtr;
        for(; i < 3; i++)
        {
            out[i] = in[i];
            if(out[i] < 0.0)
                out[i] = 0.0;
            else
                if(out[i] > 1.0)
                    out[i] = 1.0;
        }
    }
    else
        if(dType == 1)
        {
            const real32_T* in = (const real32_T*)inPtr;
            real32_T* out = (real32_T*)outPtr;
            for(; i < 3; i++)
            {
                out[i] = in[i];
                if(out[i] < 0.0)
                    out[i] = 0.0;
                else
                    if(out[i] > 1.0)
                        out[i] = 1.0;
            }
        }
}

EXPORT_FCN void MWVIP_DrawText_SatFltptIntensityVals(int32_T dType, const void* inPtr, void* outPtr, int_T nPlanes)
{
    int32_T i = 0;
    if(dType == 0)
    {
        const real_T* in = (const real_T*)inPtr;
        real_T* out = (real_T*)outPtr;
        for(; i < nPlanes; i++)
        {
            out[i] = in[i];
            if(out[i] < 0.0)
                out[i] = 0.0;
            else
                if(out[i] > 1.0)
                    out[i] = 1.0;
        }
    }
    else
        if(dType == 1)
        {
            const real32_T* in = (const real32_T*)inPtr;
            real32_T* out = (real32_T*)outPtr;
            for(; i < nPlanes; i++)
            {
                out[i] = in[i];
                if(out[i] < 0.0F)
                    out[i] = 0.0F;
                else
                    if(out[i] > 1.0F)
                        out[i] = 1.0F;
            }
        }
}

EXPORT_FCN void MWVIP_DrawText_noFltSaturationNeeded(int32_T dType, const void* inPtr, void* outPtr, int_T nPlanes)
{
    (void)dType;
    (void)inPtr;
    (void)outPtr;
    (void)nPlanes;
}

EXPORT_FCN int32_T MWVIP_strlen(const void * str)
{
	return ((int32_T) strlen((const char *)str));
}

/* vipdrawtext_main_rt.c */
