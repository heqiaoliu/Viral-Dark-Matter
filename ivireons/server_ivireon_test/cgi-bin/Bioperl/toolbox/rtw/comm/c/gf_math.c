/* This file contains the function definitions of all the Galois-field math
 * math functions. 
 *    Copyright 1996-2007 The MathWorks, Inc.
 *    $Revision: 1.1.6.4 $
 *    $Date: 2009/03/09 19:25:15 $
 *    Author: Sam Keene
 */

#include<math.h>
#include "gf_math.h"

/* gf_mul multiplies the scalar x times the scalar y using 
*  Galois field multiplication */
SPC_DECL int gf_mul( int x, int y, int m, const int32_T *table1, const int32_T *table2 )
{
    int N = (1<<m); 
    int z,temp;

    if ((x==0)||(y==0)) {
        z=0;
    } else {
        temp = ((int)table2[x-1]+(int)table2[y-1])%(N-1);
        if (temp==0) {temp=(N-1);}
        z=table1[ temp-1 ];
    }
    return z;
}


SPC_DECL int gf_pow(int x, int Yd,  int m, const int32_T *table1, const int32_T *table2)
{


    /* Raise every element of x to the power Yd
     * width is the width of x
     * table1 and table2 are pointers to the Galois field multiplication tables */


    int N = (1<<m);   /* 2^m, just 1 right shifted m times */
    int temp;

    if(Yd <0){
        x = gf_div(1,x,m,table1,table2);
        Yd = -Yd;
    }

    if (x == 0) {
        if(Yd == 0)
            x = 1;
        else
            x = 0;
    } 

    else {
        temp = (table2[(int)x-1]*Yd) %(N-1);
		
        if (temp==0) {temp=(N-1);}
        x = table1[temp-1 ];
    }
    return x;
}

SPC_DECL int gf_div(int x, int b, int m, const int32_T *table1, const int32_T *table2)
{
    /* implements x/b  element by element right division. */

    int inv, r;
    int N = (1<<m);
	
    /* compute inverse of b*/
    inv = table1[(N-1)-(int)table2[(int)b-1]-1];

    /* multiply by inverse */
    r = gf_mul(inv,x,m,table1, table2);

    return r;
}


SPC_DECL int gf_roots(int *roots, int *X, int *d,int *newPoly,int *tmpQuotient, int width, int m, const int32_T *table1, const int32_T *table2)
{                
    /*This function will take in vector X, compute the roots and store them in roots 
      it will return the number of roots */

    /* newPoly starts off as being the same as X.
     *  Roots get de-convolved out of X and stored in newPoly  */

    int i      = 0;
    int isRoot = 0;
    int mpow   = 0;
    int q      = 0;
    int currWidth = width;
    int numRoot = 0;
    int factor[2];
    /* copy X to newPoly */
    for(i = 0;i < currWidth;i++) {newPoly[i] = X[i]; }
    i = 0;
	
	
	
    while( i < pow(2,m) ){
        isRoot = 0;
        /*set all of d = i */
        for(q = 0;q < currWidth;q++){d[q] = i;}

        for(mpow=0;mpow < currWidth;mpow++) { d[mpow] = gf_pow((int)d[mpow],mpow,m,table1,table2);  }

        for(q=0;q < currWidth;q++) { isRoot = isRoot ^ (gf_mul((int)d[q],(int)newPoly[q],m,table1, table2))  ; }


        if(isRoot == 0 ){
            /* add to the root vector */
            roots[numRoot] = i;
            numRoot++;
				
            /* deconvolve the root, check again */
            factor[0] = 1;
            factor[1] = i;
            factor[0] = gf_div(1,(int)factor[0],m,table1, table2);
            factor[1] = gf_div(1,(int)factor[1],m,table1, table2);

            gf_deconv(newPoly, factor,tmpQuotient,currWidth,m,table1, table2);

            currWidth--;

            i--;
        }
        i++;
    }
    for(q = 0;q < numRoot;q++) {
        roots[q] = gf_div(1,(int)roots[q],m,table1,table2);
    }
    return numRoot;
}



SPC_DECL void gf_deconv(int *A,int *B,int *tmpQuotient,int lengthA, int m, const int32_T *table1, const int32_T *table2)
{
    /* deconvolves A from B */
	
	
    int i,j = 0;
    int frontA = 0;
    int quotIdx = lengthA;

/* initialize tmpQuotient to 0 */
    for(i=0; i < lengthA;i++) { tmpQuotient[i] = 0;}

    for(i = 0;i < lengthA-1;i++){
	
	int coeff = gf_div((int)A[frontA],(int)B[0],m,table1, table2);
	
	/*push back coeff onto tmpQuotient*/
	for(j=1;j < lengthA;j++){
            tmpQuotient[j-1] = tmpQuotient[j];
        }
	tmpQuotient[lengthA-1] = coeff;
	quotIdx--;

	A[frontA] = (int)A[frontA] ^ gf_mul(coeff,(int)B[0],m,table1, table2);
	A[frontA+1] = (int)A[frontA+1] ^ gf_mul(coeff,(int)B[1],m,table1,table2);

	/*pop A */
	frontA++;
    }
    /*copy tmpQuotient to A */
    for(i = 0;i < lengthA;i++){A[i] = tmpQuotient[i+1];}
}


SPC_DECL void gf_conv(int *retValue, int *A, int *B,int aWidth, int bWidth, int m, const int32_T *table1, const int32_T *table2)
{
    /* this function will put the convolution of A and B in retValue */

    int N = (1<<m);
    int temp = 0;
    int i,j,k;
    int retValueWidth = aWidth + bWidth -1;

    /* initialize retValue to zero */
    for(i=0;i<retValueWidth; i++){ retValue[i] =0 ; }


    for (k=0;k<aWidth;k++)
    {
    	for(j=0;j<bWidth;j++)
    	{
    
    	    /* Multiply Ax[k] * Bx[j] */
    	    if( (A[k] == 0) || (B[j] == 0) ) temp = 0;
    
    	    else { temp = ((int)table2[(int)A[k]-1]+(int)table2[(int)B[j]-1])%(N-1);
    
    	    if (temp==0) {temp=(N-1);}
            temp=table1[ (int)temp-1 ];
    	    }
    
    	    retValue[k+j] = (int)temp^(int)retValue[k+j];
    	}
    }

}
