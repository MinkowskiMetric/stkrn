#ifndef __RTL_H__
#define __RTL_H__

#include "types.h"
#include "vaarg.h"

#ifdef __cplusplus
extern "C" {
#endif

void RtlZeroMemory(void* p, size_t cb);

/* Printf functions */
void DbgPrint(const char* string);
void DbgPrintf(const char* fmt, ...);
void DbgPrintf_v(const char* fmt, va_list args);

void Panic(const char* string);
void DbgAssertFailed(const char* filename, int line, const char* message);

#define ASSERT(test) \
	do { \
		if (!(test)) \
		{ \
			DbgAssertFailed(__FILE__, __LINE__, # test); \
		} \
	} while (0, 0)
		

/* List functions */
typedef struct _ListEntry
{
	struct _ListEntry* Next;
	struct _ListEntry* Prev;
} ListEntry;

void InitializeListHead(ListEntry* head);
void RemoveEntryList(ListEntry* entry);
void InsertListHead(ListEntry* list, ListEntry* entry);
void InsertListTail(ListEntry* list, ListEntry* entry);
int IsListEmpty(ListEntry* list);

#define offsetof(t, m) __builtin_offsetof(t, m)

#define CONTAINING_RECORD(entry, type, member) \
	((type*)((uintptr_t)(entry) - offsetof(type, member)))
	
#ifdef __cplusplus
}
#endif

#endif

