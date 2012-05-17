/******************************************************************************/
/* Part of the MuPAD product code. Protected by law. All rights reserved.     */
/* FILE   : MKT_mapi.h                                                        */
/******************************************************************************/

#ifndef __MMMstorage_lean__
#define __MMMstorage_lean__

/*
Definements fuer die Speicherverwaltung:
MMMDEBUG           - Debug-Version
MMMD_LIT_SP        - erlaubt literale S-Pointer (nicht dynamisch alloziiert)
MMMD_GEN_LIT_SP    - ermoeglicht die Generierung literaler S-Pointer
*/

#ifdef WIN32
typedef unsigned __int32 uint32_t;
#include <crtdbg.h>
#else
#include <stdint.h>
#endif

#define MEXDSTANDARD
#include "MEX_extern.h"
#include "MDE_declare.h"

#ifdef PARALLEL
#  error Sequential only, sorry.
#endif
#if (defined MMMD_LIT_SP) && (defined MMMD_GEN_LIT_SP)
#  error Both MMMD_LIT_SP and MMMD_GEN_LIT_SP are defined.
#endif
#if (defined MMMD_STATISTICS) && (! defined MMMDEBUG)
#  error MMMDEBUG is needed for MMMD_STATISTICS.
#endif

////////////////////////////////////////////////////////////////////////
// Typen

typedef size_t MUPTSize ;
// special index types
typedef signed long  MUPTIndex ;
// special counter Type
typedef signed long MUPTCounter ;

class MMMTheader;
typedef MMMTheader* S_Pointer;
typedef void (*MMMTno_memory)();
typedef void (*MMMTevent_handler)();

#ifdef MMMDEBUG
struct _MMMT_stats {
    MUPTCounter used_page_blocks;
    MUPTCounter used_big_blocks;
    MUPTCounter reserved_blocks;
    MUPTSize        max_reserved_memory;
    MUPTCounter frees;
    MUPTCounter realfrees;
    MUPTCounter mallocs;
};
typedef struct _MMMT_stats MMMT_stats;
#endif // MMMDEBUG

typedef unsigned char MTbool;   // Fuer Module

////////////////////////////////////////////////////////////////////////
// Deklaration der Hilfsfunktionen

S_Pointer *MMMgetPtrAdr(S_Pointer s, MUPTIndex i);
char *MMMgetMemAdr(S_Pointer s);
char *MMMgetMemAdr(S_Pointer s, MUPTSize mv);

extern void MMMrecFree(S_Pointer s);
extern void MMMfreeBlock(S_Pointer s);

#if (defined WIN32)
void *MMMsysIrrMalloc(MUPTSize len);
void MMMsysIrrFree(void *p);
#else
inline void *MMMsysIrrMalloc(MUPTSize len);
inline void MMMsysIrrFree(void *p);
#endif

////////////////////////////////////////////////////////////////////////
// Makros

#define MMMZ(s,T) \
           (reinterpret_cast<T *>(MMMgetMemAdr(*(s))))

#define MMMarr(s,i,T) \
           (reinterpret_cast<T *>(MMMgetMemAdr(*(s), (i)*sizeof(T))))

#define MMMmv(s,mv,T) \
           (reinterpret_cast<T *>(MMMgetMemAdr(*(s), (mv))))

#define MMMmvarr(s,mv,i,T) \
           (reinterpret_cast<T *>(MMMgetMemAdr(*(s), (mv) + (i)*sizeof(T))))

// These are identical, and the compiler should produce
// absolutely identical code for a release build.
// Just to make sure this does happen, use a macro for releases.
#ifdef MMMDEBUG
inline S_Pointer* MMMP(const S_Pointer * const s, MUPTIndex i) {
  return MMMgetPtrAdr(*(s), (i));
}
#else
#define MMMP(s, i) MMMgetPtrAdr(*(s), (i))
#endif

////////////////////////////////////////////////////////////////////////
// Oeffentliche Schnittstelle

const S_Pointer MMMNULL = 0;

void MMMresetReservedMemory(void);

S_Pointer MMMmalloc(MMME_type typ, MUPTSize size, MUPTIndex count);
S_Pointer MMMpalloc(MMME_type typ, MUPTSize size, MUPTIndex count);
S_Pointer MMMcalloc(MMME_type typ, MUPTSize size, MUPTIndex count);

void MMMresize(S_Pointer *s,  MUPTSize size);
void MMMnewcounter(S_Pointer *s, MUPTIndex count);
void MMMrealloc(S_Pointer *s, MUPTSize size,  MUPTIndex count);
void MMMchange(S_Pointer *s);

void MMMfree(S_Pointer s);
void MMMlfree(S_Pointer s);
MUPTCounter MMMrefs(S_Pointer s);

char *MMMEmalloc(MUPTSize size);
void MMMEfree(char *);

bool MMMequal(S_Pointer s, S_Pointer t);
void MMMset(S_Pointer *p, S_Pointer s);
void MMMreplace(S_Pointer *p, S_Pointer s);
void MMMreplaceNoCopy(S_Pointer *p, S_Pointer s);
void MMMshift(S_Pointer sour, MUPTIndex spos,
              S_Pointer dest, MUPTIndex dpos, MUPTIndex count);

MUPTSize MMMsize(S_Pointer s);
MUPTIndex MMMcounter(S_Pointer s);
MMME_type MMMtype(S_Pointer s);

uint32_t MMMsignature(S_Pointer s);
void MMMnewsignature(S_Pointer s, uint32_t sig);

void MMMinsert_global(S_Pointer *s);
void MMMmark_globals();
void MMMmark_tree(S_Pointer s, bool mark=true);
bool MMMfree_unmarked(S_Pointer s);
void MMMfreeUnmarked(S_Pointer s);
void MMMfree_unused();
void MMMshare_all();

void MMMfirst_init(MMMTevent_handler eventHandler = 0);
MMMTno_memory MMMout_of_memory_handler(MMMTno_memory hdl);
MMMTno_memory MMMmemory_limit_handler(MMMTno_memory hdl);
void MMMinit(MUPTSize memory_limit);
void MMMexit();


MUPTSize MMMused_memory();
MUPTSize MMMreserved_memory();
MUPTSize MMMmax_reserved_memory();
#ifdef MMMDEBUG
void MMMget_stats(MMMT_stats* stats);
#endif

////////////////////////////////////////////////////////////////////////
// Debuggen

#ifdef MMMDEBUG
#if (defined WIN32)
// We use ASSERT here, because we can avoid the message box while
// throwing an assertion. This has a big advantage in our non interactive
// tests.
#define MMMASSERT(e) _ASSERT(e)
#else
#define MMMASSERT(e) assert(e)
#endif
#else
#define MMMASSERT(e)
#endif

#if (defined MMMDEBUG || defined ALPHA)
void MMMtrace(const char*, ...);
#  define MMMTRACE MMMtrace
#  define MMMTRACE2 MMMtrace
#else
#define MMMTRACE(f)
#define MMMTRACE2(f,p)
#endif

////////////////////////////////////////////////////////////////////////
// MMMTheader
// Jede MAMMUT-Zelle enth"alt in einem Header Verwaltungsinformationen.
// Dieser Header wird am Anfang der Zelle gespeichert.
// Die Zelle kann frei oder belegt sein. Ist sie frei, so wird in next
// ein Zeiger auf die naechste freie Zelle gespeichert.

class MMMTheader;

/** prototype for the finalizer functions
    Do the finalization for the S-Pointer sp
    @param sp The processed S-Pointer
 */
typedef void(*MMMT_finalizer)(MMMTheader* sp);
/** prototype for the copy functions
    Copy special data fron the S-Pointer src to the S-Pointer dest
    @param sp The processed S-Pointer
    @param sp The processed S-Pointer
 */
typedef void(*MMMT_physicalcopy)(MMMTheader* src, MMMTheader* dest);

class MMMTheader
{
private:
    MMME_type type_ : 16;     // MMMM-Typ
    unsigned long static_ : 1;    // 1 falls _nicht_ auf dem Heap alloziiert
    unsigned long const_ : 1;     // 1 falls konstant (im ROM)
    unsigned long mark_ : 1;      // fuer Markierung
    unsigned long is_blk_ : 1;    // 1 falls der Block regulaer in einer Page
                                  // gespeichert ist
    unsigned long blk_idx_ : 4;   // Block-Index (falls is_blk_=1)
    unsigned long dead_ : 1;      // 1 iff dead node

    S_Pointer* mem_;              // Zeiger auf Mem-Teil
    MUPTSize size_;                // Groesse des Mem-Teils
    MUPTCounter refs_;         // Referenz-Zaehler
    union {
      uint32_t signature_;        // Signatur
      MMMTheader* next_free_;     // Zeiger auf naechsten freien Block
    };

public:
    /// maximum numbers of MMM_XXX and CAT_XXX types
    enum { MAX_TYPE = 0xff };
    enum { MAX_BLK = 0xf };       // max block index
    /// do we have a MMM_XXX or a CAT_XXX S-Pointer
    enum { MMM_TYPE = 0 , CAT_TYPE = 10 };

    static MUPTSize getLength(MUPTIndex count, MUPTSize size);

    void init(MUPTSize s, MUPTIndex c, MMME_type t, bool b, unsigned long i);

    void initFree(MMMTheader *next_free, unsigned long block_idx);
    /** Returns the finalizer function for the underlying S-Pointer */
    MMMT_finalizer getFinalizer();
    /** Sets the finalizer function for the underlying S-Pointer
        @param final the finalizer function
        @param spointerType the type of S-Pointer e.g. CAT_INT
        @param tableTyp MMM_TYPE e.g. for a MMM_STRING or CAT_TYPE
               e.g. for a CAT_INT
     */
    static void setFinalizer(MMMT_finalizer final, short spointerType,
                             short tableTyp) ;
    /** Returns the copy function for the underlying S-Pointer */
    MMMT_physicalcopy getCopier();
    /** Sets the copy function for the underlying S-Pointer
        @param copier the copy function
        @param spointerType the type of S-Pointer e.g. CAT_INT
        @param tableTyp MMM_TYPE e.g. for a MMM_STRING or CAT_TYPE
               e.g. for a CAT_INT
     */
    static void setCopier(MMMT_physicalcopy copier, short spointerType,
                             short tableTyp) ;
    long getSignature() const;
    void setSignature(long sig);
    MUPTSize getSize() const;
    bool setSize(MUPTSize s);
    MUPTIndex getCount() const;
    S_Pointer* getMem() const;
    bool release();
    void addRef();
    MUPTCounter getRefs() const;
    MMME_type getType() const;
    void setType(MMME_type t);
    bool isMarked() const;
    void setMark(bool is_marked=true);
    bool isBlock() const;
    unsigned long getBlockIdx() const;
    MMMTheader *getNextFree() const;
    void setNextFree(MMMTheader *s);
    void signDead();
    bool isDead();
#ifdef MMMD_LIT_SP
    bool isStatic() const;
    bool isConst() const;
#endif
#ifdef MMMD_GEN_LIT_SP
    void printLiteralHeader(const char*, bool, FILE*);
#endif
};

// Tabelle für die entsprechenden Finalizer und Copy Funktionen
// für S-Pointer
// Die Finalizer Funktionen werden benutzt, wenn S-Pointer freigegeben
// werden
// Die Kopier Funktionen werden benutzt, wenn S-Pointer physikalisch
// geändert werden (MMMchange).

/// table for the finalizers for the MMM_XXX types
extern MMMT_finalizer    MMMVMmmFinalizers[MMMTheader::MAX_TYPE];
/// table for the finalizers for the CAT_XXX types
extern MMMT_finalizer    MMMVCatFinalizers[MMMTheader::MAX_TYPE];
/// table for the copy functions for the MMM_XXX types
extern MMMT_physicalcopy MMMVMmmCopiers[MMMTheader::MAX_TYPE];
/// table for the copy functions for the CAT_XXX types
extern MMMT_physicalcopy MMMVCatCopiers[MMMTheader::MAX_TYPE];

#ifdef MMMD_LIT_SP

inline bool
MMMTheader::isStatic() const
{
    MMMASSERT(this != NULL);
    return (bool) static_;
}

inline bool
MMMTheader::isConst() const
{
    MMMASSERT(this != NULL);
    return (bool) const_;
}

#endif // MMMD_LIT_SP

inline long
MMMTheader::getSignature() const
{
    MMMASSERT(this != NULL);
    return signature_;
}

inline void
MMMTheader::setSignature(long sig)
{
    MMMASSERT(this != NULL);
#ifndef MMMD_LIT_SP
    signature_ = sig;
#else // MMMD_LIT_SP
    // some functions (MSU_eval_subs_intern for example) wildly
    // call MSG_sig even if the object was not created from
    // scratch. so we do not throw an error if they try to set
    // the signature of constant literals
    if (! isConst()) {
        signature_ = sig;
    }
#endif // MMMD_LIT_SP
}

inline MUPTSize
MMMTheader::getSize() const
{
    MMMASSERT(this != NULL);
    return size_;
}

inline MUPTIndex
MMMTheader::getCount() const
{
    MMMASSERT(this != NULL);
    return static_cast<MUPTIndex>(mem_ - (S_Pointer*)(this + 1));
}

inline S_Pointer*
MMMTheader::getMem() const
{
    MMMASSERT(this != NULL);
    return mem_;
}

inline bool
MMMTheader::release()
{
  MMMASSERT(this != NULL);
#ifdef MMMD_LIT_SP
  if (isStatic())
    return false;
#endif
  MMMASSERT(refs_ != 0);
  if (refs_ == 0) {
    return false;               // object has already been freed,
        // avoid infinite recursion
  } else {
    refs_--;
    return (refs_ == 0);
  }
}

inline void
MMMTheader::addRef()
{
    MMMASSERT(this != NULL);
#ifdef MMMD_LIT_SP
    if (! isStatic())
        refs_++;
#else
    refs_++;
#endif
}

inline MUPTCounter
MMMTheader::getRefs() const
{
    MMMASSERT(this != NULL);
    return refs_;
}

inline MMME_type
MMMTheader::getType() const
{
    MMMASSERT(this != NULL);
    return type_;
}

inline bool
MMMTheader::isMarked() const
{
    MMMASSERT(this != NULL);
    return (bool) mark_;
}

inline void
MMMTheader::setMark(bool is_marked)
{
    MMMASSERT(this != NULL);
#ifdef MMMD_LIT_SP
    MMMASSERT(! isConst());
#endif
    mark_ = is_marked;
}

////////////////////////////////////////////////////////////////////////
// Zugriff auf den Inhalt

inline S_Pointer*
MMMgetPtrAdr(S_Pointer s, MUPTIndex i)
{
    MMMASSERT(s != NULL);
    S_Pointer *p = (S_Pointer*)(s + 1);
    return p + i;
}

inline char*
MMMgetMemAdr(S_Pointer s)
{
    MMMASSERT(s != NULL);
    return (char*)(s->getMem());
}

inline char*
MMMgetMemAdr(S_Pointer s, MUPTSize mv)
{
    return MMMgetMemAdr(s) + mv;
}

////////////////////////////////////////////////////////////////////////
// Allokieren von Speicher

inline char*
MMMEmalloc(MUPTSize size)
{
    extern MMMTno_memory MMMVno_memory;

    char *p = (char *) MMMsysIrrMalloc(size);
    if (p == NULL)
        (*MMMVno_memory)();
    return p;
}

inline void
MMMEfree(char *p)
{
    MMMsysIrrFree((void *) p);
}


////////////////////////////////////////////////////////////////////////
// Freigabe

inline void
MMMfree(S_Pointer s)
{
  if (s != MMMNULL && s->release()) {
    MMMrecFree(s);
  }
}

inline void
MMMlfree(S_Pointer s)
{
  if (s != MMMNULL && s->release()) {
    MMMfreeBlock(s);
  }
}

inline bool
MMMfree_unmarked(S_Pointer p)
{
    if (p == MMMNULL)
        return true;
#ifdef MMMD_LIT_SP
    else if (p->isStatic() || p->isMarked())
#else
    else if (p->isMarked())
#endif
        return false;
    else {
        MMMfreeUnmarked(p);
        return true;
    }
}

////////////////////////////////////////////////////////////////////////
// Vergleichen und Kopieren                                           //
////////////////////////////////////////////////////////////////////////

inline bool
MMMequal(S_Pointer s, S_Pointer t)
{
    return s == t;
}

inline S_Pointer
MMMcopy(S_Pointer s)
{
  MMMASSERT(NULL == s ||
            MMMtype(s) != MMM_NONE);
  if (s != NULL) s->addRef();
  return s;
}

void MMMchange_real(S_Pointer *s);
inline void
MMMchange(S_Pointer *s)
{
  MMMASSERT(s != NULL && *s != NULL);
  if ((*s)->getRefs() == 1) return;
  MMMchange_real(s);
}

inline void
MMMset(S_Pointer *p, S_Pointer s)
{
    MMMASSERT(p != NULL);
    MMMcopy(s);
    *p = s;
}

inline void
MMMreplace(S_Pointer *p, S_Pointer s)
{
    MMMASSERT(p != NULL);
    MMMcopy(s);
    MMMfree(*p);
    *p = s;
}

inline void
MMMreplaceNoCopy(S_Pointer *p, S_Pointer s)
{
    MMMASSERT(p != NULL);
    MMMfree(*p);
    *p = s;
}

////////////////////////////////////////////////////////////////////////
// Zugriff auf Statusinformationen                                    //
////////////////////////////////////////////////////////////////////////

inline MUPTSize
MMMsize(S_Pointer s)
{
    return ((s == MMMNULL) ? 0 : s->getSize());
}

inline MUPTIndex
MMMcounter(S_Pointer s)
{
    return ((s == MMMNULL) ? 0 : s->getCount());
}

inline MMME_type
MMMtype(S_Pointer s)
{
    MMMASSERT(s != NULL);
    return s->getType();
}

inline uint32_t
MMMsignature(S_Pointer s)
{
    MMMASSERT(s != NULL);
    MMMASSERT(MMMtype(s) != MMM_NONE);
    return s->getSignature();
}

inline void
MMMnewsignature(S_Pointer s, uint32_t sig)
{
    MMMASSERT(s != NULL);
    s->setSignature(sig);
}

inline bool
MMMunmoveable(S_Pointer, bool)
{
    return true;
}

inline MUPTCounter
MMMrefs(S_Pointer s)
{
    MMMASSERT(s != NULL);
    return s->getRefs();
}

////////////////////////////////////////////////////////////////////////
// Poolverwaltung                                                     //
////////////////////////////////////////////////////////////////////////

inline void MMMpoolinit() {}
#define MMMpoolinsert(p)
#define MMMpooldelete(p)

////////////////////////////////////////////////////////////////////////
// Hilfsfunktionen                                                    //
////////////////////////////////////////////////////////////////////////

#if (! defined WIN32)

// MMMsysIrrMalloc -- alloziiert irregulaeren (Non-Page) Bereich
// mit Hilfe der "uebergeordneten" Speicherverwaltung.

inline void *
MMMsysIrrMalloc(MUPTSize len)
{
    return malloc(len);
}

inline void
MMMsysIrrFree(void *p)
{
    free(p);
}

#endif

////////////////////////////////////////////////
// Generieren von Literalen

#ifdef MMMD_GEN_LIT_SP

// generate code for literal S-Pointers
void MMMgen_lit();

/// Linked list of literal S-Pointer variable references, used to
/// generate code to initialize them.
class MMMT_literal
{
public:
    /// Create literal S-Pointer variable reference given the address of
    /// the S-Pointer and its variable name.
    MMMT_literal(S_Pointer* spp, const char* name);

    static MMMT_literal* first();
    S_Pointer s_pointer() const;
    S_Pointer* spp() const;
    const char* name() const;
    MMMT_literal* next() const;
private:
    static MMMT_literal* first_;    // first reference in list
    S_Pointer* spp_;                // address of S-Pointer which is referenced
    const char* name_;              // C-variable name of the S-Pointer
    MMMT_literal* next_;            // next reference in list
};

inline MMMT_literal* MMMT_literal::first() { return first_; }
inline S_Pointer MMMT_literal::s_pointer() const { return *spp_; }
inline S_Pointer* MMMT_literal::spp() const { return spp_; }
inline const char* MMMT_literal::name() const { return name_; }
inline MMMT_literal* MMMT_literal::next() const { return next_; }

#endif // MMMD_GEN_LIT_SP

////////////////////////////////////////////////
// Iterator ueber alle Knoten (fuer Statistiken)
////////////////////////////////////////////////

// Iterate over all allocated nodes which are not freed, wether they are
// available from the root set or not.
void MMMvisit_all(void (*)(S_Pointer, bool, void*), void*);

// Iterate depth-first over all nodes which are alive, ie. may be reached
// from the root set.
void MMMvisit_live(void (*)(S_Pointer, bool, void*), void*);

#endif /* !__MMMstorage_lean__ */
