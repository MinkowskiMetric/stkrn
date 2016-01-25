#ifndef _MEMORY_H_
#define _MEMORY_H_

#ifdef __cplusplus
extern "C" {
#endif

void MemInitialize(void);

void* MemAlloc(size_t cb);

typedef struct _PhysicalMemoryRegion
{
	ListEntry Entry;
	uint64_t Base;
	uint64_t Limit;
	uint32_t Flags;
} PhysicalMemoryRegion;

#define PMRFLAGS_TYPE_MASK       0x0000000f
#define PMRFLAGS_TYPE_FREE       0x00000000
#define PMRFLAGS_TYPE_BOOTLOADER 0x00000001
#define PMRFLAGS_TYPE_INUSE      0x00000002
#define PMRFLAGS_TYPE_UNKNOWN    0x00000003

#ifdef __cplusplus
}
#endif

#endif
