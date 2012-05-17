/* Copyright 2009 The MathWorks, Inc. */

#ifndef INT64_T
# if defined(__ia64__)
#  define INT64_T                      long
# elif defined(_MSC_VER) || (defined(__BORLANDC__) && __BORLANDC__ >= 0x530) || (defined(__WATCOMC__) && __WATCOMC__ >= 1100)
#  define INT64_T                      __int64
# elif defined(__GNUC__) || defined(TMW_ENABLE_INT64) || defined(__sun)
#  define INT64_T                      long
# endif
#endif

#define int64_T                        INT64_T
#ifndef uint64_T
# if defined(__ia64__)
#  define uint64_T                     unsigned long
# elif defined(_MSC_VER) || (defined(__BORLANDC__) && __BORLANDC__ >= 0x530) || (defined(__WATCOMC__) && __WATCOMC__ >= 1100)
#  define uint64_T                     unsigned __int64
# elif defined(__GNUC__) || defined(TMW_ENABLE_INT64) || defined(__sun)
#  define uint64_T                     unsigned long
# endif
#endif

#if defined(__APPLE__)
extern int64_T cputime_stamp(void);
#elif defined __LCC__ 
extern int64_T pentium_cyclecount(void);
#else 
extern double cputime(void);
#endif

