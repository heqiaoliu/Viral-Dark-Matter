// Convert an stl file to a MuPAD list
// for details refer to plot::SurfaceSTL
// Andreas Sorgatz, 21.08.2003
// read       ( file )
// boundingBox( file )
//
MMG( info = "import of STL graphics files" )

#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "limits.h"

#define BUFLEN 512
#define STL_MIN (float) LONG_MIN
#define STL_MAX (float) LONG_MAX

///////////////////////////////////////////////////////////////////////////////
// Read a character string until the end of line
bool readLine( FILE *fptr, char *s, unsigned long lmax=BUFLEN )
{
  unsigned long  i = 0;
  signed char    c;

  s[0] = '\0';
  while ((c = fgetc(fptr)) != '\n' && c != '\r')
  {
    if (c == EOF)
    {
      return(false);
    }
    if (c == '\t' || c == ' ')
    {
      continue;
    }
    s[i] = c;
    i++;
    s[i] = '\0';
    if (i >= lmax)
    {
      break;
    }
  }
  return(true);
}

///////////////////////////////////////////////////////////////////////////////
// Read a possibly byte swapped integer
bool readInt( FILE *fptr, unsigned long *n, bool swap=false )
{
   unsigned char *cptr, tmp;

   if (fread(n, 4, 1, fptr) != 1)
   {
      return(false);
   }
   if (swap)
   {
      cptr    = (unsigned char *) n;
      tmp     = cptr[0];
      cptr[0] = cptr[3];
      cptr[3] = tmp;
      tmp     = cptr[1];
      cptr[1] = cptr[2];
      cptr[2] = tmp;
   }
   return(true);
}

///////////////////////////////////////////////////////////////////////////////
// Read a possibly byte swapped float
bool readFloat( FILE *fptr, float *n, bool swap=false )
{
   unsigned char *cptr, tmp;

   if (fread(n, 4, 1, fptr) != 1)
   {
      return(false);
   }
   if (swap)
   {
      cptr    = (unsigned char *) n;
      tmp     = cptr[0];
      cptr[0] = cptr[3];
      cptr[3] = tmp;
      tmp     = cptr[1];
      cptr[1] = cptr[2];
      cptr[2] = tmp;
   }
   return(true);
}

///////////////////////////////////////////////////////////////////////////////
// Open STL file, check for ASCII|BINARY format and determine number of facets
FILE* openSTLFile( const char* file, unsigned long *facets, bool *isAscii )
{
  FILE *fptr = fopen(file, "r");
  if (fptr == NULL)
  {
    return(NULL);
  }
  *facets = 0;

  // ASCII file starts with the keyword 'solid' and an optional name
  char token[BUFLEN];
  if (fscanf(fptr, "%s", token) == 1 && (strcmp(token,"solid") == 0
       || strcmp(token,"SOLID") == 0 ||  strcmp(token,"Solid") == 0))
  {
    *isAscii = true;
    readLine(fptr, token);
    while (fscanf(fptr, "%s", token) == 1)
    {
      if (strcmp(token, "facet") == 0 || strcmp(token, "FACET") == 0
                                      || strcmp(token, "Facet") == 0) (*facets)++;
    }
    if (*facets > 0)
    {
      rewind(fptr);
      return(fptr);
    }
    else
    {
      ; // no facets. however, this may be a binary file
    }
  }
  fclose(fptr);

  // BINARY file starts with 80 characters followed by the number of facets
  fptr = fopen(file, "rb");
  if (fread(token, 1, 80, fptr) == 80 && readInt(fptr, facets))
  {
    *isAscii = false;
    rewind(fptr);
    return(fptr);
  }

  fclose(fptr);
  return(NULL);
}

///////////////////////////////////////////////////////////////////////////////
// Read an ASCII STL file
MTcell readSTLFileAscii( FILE *fptr, unsigned long facets, char **errstr,
                         bool  boundingbox = false )
{
  if (fptr == NULL)
  {
    return(false);
  }

  char   token[BUFLEN];
  MTcell name;

  // parse 'solid' keyword
  if (fscanf(fptr, "%s", token) != 1 || strcmp(token,"solid") != 0)
  {
    fclose(fptr);
    return(MCnull);
  }

  // parse name of solid
  if (!readLine(fptr, token))
  {
    fclose(fptr);
    return(MCnull);
  }
  if (!*token)
  {
    name = MFstring("solid");
  } else {
    name = MFstring(token);
  }

  unsigned long    nf = 0;
  unsigned long    np = 0;
  double           xmin = STL_MAX, 
                   xmax = STL_MIN, 
                   ymin = STL_MAX, 
                   ymax = STL_MIN, 
                   zmin = STL_MAX, 
                   zmax = STL_MIN;
  double           x, y, z;

  MTcell facet = MCnull;
  MTcell list  = MCnull;

  if (!boundingbox) {
    list = MFnewList(facets*12);
  }

  while (fscanf(fptr, "%s", token) == 1)
  {
    if (strcmp(token, "facet") == 0)
    {
      if (nf == facets || np == 12*facets)
      {
        //MFprintf("Warn.: invalid file format (#facets)!\n");
        fclose(fptr);
        if( name != MCnull) MFfree(name);
        if( list != MCnull) {
          for (unsigned long i=np; i<12*facets; i++) {
            MFsetList(&list, i, MCnull);
          }
          MFfree(list);
        }
        *errstr = (char*) "Too many facets.";
        return(MCnull);
      }
      nf++;

      if (fscanf(fptr, "%s %lf %lf %lf", token, &x, &y, &z) != 4 || strcmp(token, "normal") != 0)
      {
        //MFprintf("Warn.: invalid file format (#normals)!\n");
        fclose(fptr);
        if( name != MCnull) MFfree(name);
        if( list != MCnull) {
          for (unsigned long i=np; i<12*facets; i++) {
            MFsetList(&list, i, MCnull);
          }
          MFfree(list);
        }
        *errstr = (char*) "Keyword \"normal x y z\" expected.";
        return(MCnull);
      }

      if (boundingbox) {
        np += 3;
      } else {
        MFsetList(&list, np++, MFdouble(x));
        MFsetList(&list, np++, MFdouble(y));
        MFsetList(&list, np++, MFdouble(z));
      }
    }

    if (strcmp(token,"vertex") == 0)
    {
      if (fscanf(fptr, "%lf %lf %lf", &x, &y, &z) != 3)
      {
        //MFprintf("Warn.: invalid file format (#vertex)!\n");
        fclose(fptr);
        if( name != MCnull) MFfree(name);
        if( list != MCnull) {
          for (unsigned long i=np; i<12*facets; i++) {
            MFsetList(&list, i, MCnull);
          }
          MFfree(list);
        }
        if (facet != MCnull) MFfree(facet);
        *errstr = (char*) "Reading keyword \"vertex x y z\" failed.";
        return(MCnull);
      }

      if (x < xmin) xmin = x;
      if (x > xmax) xmax = x;
      if (y < ymin) ymin = y;
      if (y > ymax) ymax = y;
      if (z < zmin) zmin = z;
      if (z > zmax) zmax = z;

      if (boundingbox) {
        np += 3;
      } else {
        MFsetList(&list, np++, MFdouble(x));
        MFsetList(&list, np++, MFdouble(y));
        MFsetList(&list, np++, MFdouble(z));
      }
    }
  }
  fclose(fptr);

  if (nf < facets || np < 12*facets)
  {
    if( name != MCnull) MFfree(name);
    if( list != MCnull) {
      for (unsigned long i=np; i<facets; i++) {
        MFsetList(&list, i, MCnull);
      }
      MFfree(list);
    }
    if (facet != MCnull) MFfree(facet);
    *errstr = (char*) "More facets or points/normals expected.";
    return(MCnull);
  }

  MTcell bbox = MFnewList(3);
  MFsetList(&bbox, 0, MFnewExpr(3,MF("_range"),MFdouble(xmin),MFdouble(xmax)));
  MFsetList(&bbox, 1, MFnewExpr(3,MF("_range"),MFdouble(ymin),MFdouble(ymax)));
  MFsetList(&bbox, 2, MFnewExpr(3,MF("_range"),MFdouble(zmin),MFdouble(zmax)));

  MTcell result = MFnewList(3);

  if( list != MCnull) MFsetList(&result, 0, name);
  else                MFsetList(&result, 0, MFstring(""));
  if( list != MCnull) MFsetList(&result, 1, list);
  else                MFsetList(&result, 1, MFnewList(0));
  if( bbox != MCnull) MFsetList(&result, 2, bbox);
  else                MFsetList(&result, 2, MFnewList(0));
  return(result);
}

///////////////////////////////////////////////////////////////////////////////
// Read a BINARY STL file
MTcell readSTLFileBinary( FILE *fptr, unsigned long facets, char **errstr,
                          bool  boundingbox = false )
{
  if (fptr == NULL)
  {
    return(false);
  }

  char   token[BUFLEN];
  MTcell name = MCnull;

  // parse name of solid
  if (fread(token,sizeof(char),80,fptr) != 80)
  {
    fclose(fptr);
    *errstr = (char*) "Cannot read header.";
    return(MCnull);
  }
  token[80] = '\0';
  while ((*token && token[strlen(token)-1] == ' ') || token[strlen(token)-1] == '\t')
  {
    token[strlen(token)-1] = '\0';
  }
  char *pnt = token;
  while (*pnt && (*pnt == ' ' || *pnt == '\t'))
  {
    pnt++;
  }
  if (*pnt)
  {
    name = MFstring(pnt);
  } else {
    name = MFstring("solid");
  }

  if (!readInt(fptr, &facets) && facets < 1)
  {
    fclose(fptr);
    if( name != MCnull) MFfree(name);
    *errstr = (char*) "Cannot read number of facets.";
    return(MCnull);
  }

  float   xmin = STL_MAX, 
          xmax = STL_MIN, 
          ymin = STL_MAX, 
          ymax = STL_MIN, 
          zmin = STL_MAX, 
          zmax = STL_MIN;
  float   x, y, z;
  MTcell  list = MCnull;

  if (!boundingbox) {
    list = MFnewList(12*facets);
  }

  unsigned long np = 0;

  for (unsigned long nf = 0; nf < facets; nf++)
  {
    // Read the normal
    readFloat(fptr, &x);
    readFloat(fptr, &y);
    readFloat(fptr, &z);

    if (boundingbox) {
      np += 3;
    } else {
      MFsetList(&list, np++, MFfloat(x));
      MFsetList(&list, np++, MFfloat(y));
      MFsetList(&list, np++, MFfloat(z));
    }

    // Read the vertices
    for (int i = 0; i < 3; i++)
    {
      readFloat(fptr, &x);
      readFloat(fptr, &y);
      readFloat(fptr, &z);

      if (x < xmin) xmin = x;
      if (x > xmax) xmax = x;
      if (y < ymin) ymin = y;
      if (y > ymax) ymax = y;
      if (z < zmin) zmin = z;
      if (z > zmax) zmax = z;

      if (boundingbox) {
        np += 3;
      } else {
        MFsetList(&list, np++, MFfloat(x));
        MFsetList(&list, np++, MFfloat(y));
        MFsetList(&list, np++, MFfloat(z));
      }
    }

    // Read the padding
    fgetc(fptr);
    fgetc(fptr);
  }
  fclose(fptr);

  MTcell bbox = MFnewList(3);
  MFsetList(&bbox, 0, MFnewExpr(3,MF("_range"),MFdouble(xmin),MFdouble(xmax)));
  MFsetList(&bbox, 1, MFnewExpr(3,MF("_range"),MFdouble(ymin),MFdouble(ymax)));
  MFsetList(&bbox, 2, MFnewExpr(3,MF("_range"),MFdouble(zmin),MFdouble(zmax)));

  MTcell result = MFnewList(3);

  if( list != MCnull) MFsetList(&result, 0, name);
  else                MFsetList(&result, 0, MFstring(""));
  if( list != MCnull) MFsetList(&result, 1, list);
  else                MFsetList(&result, 1, MFnewList(0));
  if( bbox != MCnull) MFsetList(&result, 2, bbox);
  else                MFsetList(&result, 2, MFnewList(0));
  return(result);
}

///////////////////////////////////////////////////////////////////////////////
// MFUNC: Read an STL file
///////////////////////////////////////////////////////////////////////////////
MFUNC( read, MCnop )
{
  MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  FILE          *fptr;
  unsigned long  facets;
  bool           isAscii;

  if ((fptr = openSTLFile(MFstring(MFarg(1)), &facets, &isAscii)) == NULL)
  {
    MFerror("Invalid file name or non-STL file.");
  }

  char  *errstr;
  MTcell result;

  if (isAscii)
  {
    result = readSTLFileAscii(fptr, facets, &errstr);
  } else   {
    result = readSTLFileBinary(fptr, facets, &errstr);
  }
  if (result == MCnull)
  {
    MFerror(errstr);
  }

  MFreturn(result);
} MFEND

///////////////////////////////////////////////////////////////////////////////
// MFUNC: Compute bounding box of an STL file
///////////////////////////////////////////////////////////////////////////////
MFUNC( boundingBox, MCnop )
{
  MFnargsCheck(1);
  MFargCheck(1,DOM_STRING);

  FILE          *fptr;
  unsigned long  facets;
  bool           isAscii;

  if ((fptr = openSTLFile(MFstring(MFarg(1)), &facets, &isAscii)) == NULL)
  {
    MFerror("Invalid file name or non-STL file.");
  }

  char  *errstr;
  MTcell result;

  if (isAscii)
  {
    result = readSTLFileAscii(fptr, facets, &errstr, true);
  } else   {
    result = readSTLFileBinary(fptr, facets, &errstr, true);
  }
  if (result == MCnull)
  {
    MFerror(errstr);
  }

  MTcell bbox = MFcopy(MFop(result,2));
  MFfree(result);

  MFreturn(bbox);
} MFEND

