#include <rtl.h>
#include "memory.h"
#include "real.h"

typedef struct _BiosMemoryEntry
{
	uint64_t Base;
	uint64_t Length;
	uint32_t Type;
	uint32_t ExtendedAttributes;
} BiosMemoryEntry;

typedef struct _MemoryRegion
{
	char* Base;
	uint32_t Size;
} MemoryRegion;

MemoryRegion RootMemoryRegion;

ListEntry MemoryMapHead;

extern char _STAGE2_START_[];
extern char _TEXT_START_[];
extern char _TEXT_END_[];
extern char _DATA_START_[];
extern char _DATA_END_[];
extern char _RODATA_START_[];
extern char _RODATA_END_[];
extern char _BSS_START_[];
extern char _BSS_END_[];
extern char _STAGE2_END_[];

const uint64_t _STAGE2_LIMIT_ = 0x100000;
const uint64_t PageSize = 4096;
const uint64_t MaxPhysAddress = UINT64_T_MAX & ~(PageSize - 1);

uint64_t VirtToPhys(void* p)
{
	return ((uint32_t)p) - 0xc0000000;
}

/*
For the first call to the function, point ES:DI at the destination buffer for the list. Clear EBX. 
Set EDX to the magic number 0x534D4150. Set EAX to 0xE820 (note that the upper 16-bits of EAX should be set to 0). 
Set ECX to 24. Do an INT 0x15.

If the first call to the function is successful, EAX will be set to 0x534D4150, and the Carry flag will be clear. 
EBX will be set to some non-zero value, which must be preserved for the next call to the function. CL will contain
 the number of bytes actually stored at ES:DI (probably 20).
 
For the subsequent calls to the function: increment DI by your list entry size, reset EAX to 0xE820, 
and ECX to 24. When you reach the end of the list, EBX may reset to 0. If you call the function
 again with EBX = 0, the list will start over. If EBX does not reset to 0, the function will return with 
 Carry set when you try to access the entry after the last valid entry.
*/
static int ReadBiosMemoryMap(BiosMemoryEntry* entry, uint32_t* position)
{
	RMCallContext ctx;
	RtlZeroMemory(&ctx, sizeof(ctx));
	
	ctx.OpCode = 1;
	ctx.Vector = 0x15;
	ctx.EAX = 0xe820;
	ctx.EBX = *position;
	ctx.ECX = 24;
	ctx.EDX = 0x534d4150;
	ctx.ES = ((uint32_t)entry) >> 4;
	ctx.EDI = ((uint32_t)entry) & 0xf;
	
	RlCallRealMode(&ctx);
	
	if (ctx.EAX != 0x534d4150)
	{
		DbgPrintf("Unexpected return value from bios memory scan\n");
		return -1;
	}
	
	*position = ctx.EBX;
	
	if (*position == 0 || 0 != (ctx.EFLAGS & EFLAG_CF))
	{
		DbgPrintf("End of BIOS memory list found\n");
		return -1;
	}
	
	return 0;
}

static uint32_t CombinePhysicalMemoryFlags(uint32_t left, uint32_t right)
{
	if (left == PMRFLAGS_TYPE_UNKNOWN)
	{
		ASSERT(right != PMRFLAGS_TYPE_UNKNOWN);
		return right;
	}
	else if (right == PMRFLAGS_TYPE_UNKNOWN)
	{
		ASSERT(left != PMRFLAGS_TYPE_UNKNOWN);
		return left;
	}
	else if (left == PMRFLAGS_TYPE_INUSE || right == PMRFLAGS_TYPE_INUSE)
	{
		return PMRFLAGS_TYPE_INUSE;
	}
	else if (left == PMRFLAGS_TYPE_BOOTLOADER || right == PMRFLAGS_TYPE_BOOTLOADER)
	{
		return PMRFLAGS_TYPE_BOOTLOADER;
	}
	else
	{
		ASSERT(left == PMRFLAGS_TYPE_FREE && right == PMRFLAGS_TYPE_FREE);
		return PMRFLAGS_TYPE_FREE;
	}
}

static void InsertPhysicalMemoryRegionEntry(uint64_t base, uint64_t limit, uint32_t flags)
{
	ASSERT(limit > base);
	ASSERT((base & (PageSize - 1)) == 0);
	ASSERT((limit & (PageSize - 1)) == 0);
	
	ASSERT(!IsListEmpty(&MemoryMapHead));
	
	for (ListEntry* pos = MemoryMapHead.Next; limit > base && pos != &MemoryMapHead; pos = pos->Next)
	{
		PhysicalMemoryRegion* posRegion = CONTAINING_RECORD(pos, PhysicalMemoryRegion, Entry);
		
		ASSERT(posRegion->Limit > posRegion->Base);
		ASSERT((posRegion->Base & (PageSize - 1)) == 0);
		ASSERT((posRegion->Limit & (PageSize - 1)) == 0);
		
		if (posRegion->Limit <= base)
		{
			// This region ends entirely before the region we're inserting so
			// ignore it
			continue;
		}
		
		// At this point we know we have found an overlapping block because
		// we should have a contiguous run of blocks
		ASSERT(posRegion->Base <= base);
		
		if (posRegion->Base < base)
		{
			PhysicalMemoryRegion* newRegion = MemAlloc(sizeof(PhysicalMemoryRegion));
			newRegion->Base = posRegion->Base;
			newRegion->Limit = base;
			newRegion->Flags = posRegion->Flags;
			InsertListTail(&posRegion->Entry, &newRegion->Entry);
			
			posRegion->Base = base;
			
			// Rewind to the new region so that we evaluate this newly fixed up region next time around
			pos = &newRegion->Entry;
			
			continue;
		}
	
		if (posRegion->Limit > limit)
		{
			PhysicalMemoryRegion* newRegion = MemAlloc(sizeof(PhysicalMemoryRegion));
			newRegion->Base = limit;
			newRegion->Limit = posRegion->Limit;
			newRegion->Flags = posRegion->Flags;
			InsertListHead(&posRegion->Entry, &newRegion->Entry);
			
			posRegion->Limit = limit;
		}
			
		// We should now have a region which starts at the same place as
		// the region we're hoping to insert and ends before or at the same
		// place as it
		ASSERT(posRegion->Limit <= limit);
		
		// Combine the flags together
		posRegion->Flags = CombinePhysicalMemoryFlags(posRegion->Flags, flags);
		
		// The advance the region we're trying to insert
		base = posRegion->Limit;
		
		// And keep searching
	}
	
	// We should have inserted everything
	ASSERT(base == limit);
}

static void InsertPhysicalMemoryRegion(uint64_t base, uint64_t size, int available)
{
	uint64_t limit;
	if (MaxPhysAddress - size >= base)
	{
		limit = base + size;
	}
	else
	{
		limit = MaxPhysAddress;
	}
	
	if (available)
	{
		// Always round the available blocks inward so that we don't expand
		// them into ranges which might be available
		base = (base + PageSize - 1) & ~(PageSize - 1);
		limit = limit & ~(PageSize - 1);
	}
	else
	{
		// Round non-available blocks outward so that we don't contract them
		base = base & ~(PageSize - 1);
		limit = (limit + PageSize - 1) & ~(PageSize - 1);
	}
	
	if (base >= limit)
	{
		// If we're left with nothing (this would be an available range 
		// less than a page long) then continue
		ASSERT(available);
		return;
	}
	
	if (!available)
	{
		InsertPhysicalMemoryRegionEntry(base, limit, PMRFLAGS_TYPE_INUSE);
	}
	else if (base < _STAGE2_LIMIT_ && limit > _STAGE2_LIMIT_)
	{
		InsertPhysicalMemoryRegionEntry(base, _STAGE2_LIMIT_, PMRFLAGS_TYPE_BOOTLOADER);
		InsertPhysicalMemoryRegionEntry(_STAGE2_LIMIT_, limit, PMRFLAGS_TYPE_FREE);
	}
	else if (base < _STAGE2_LIMIT_)
	{
		InsertPhysicalMemoryRegionEntry(base, limit, PMRFLAGS_TYPE_BOOTLOADER);
	}
	else
	{
		InsertPhysicalMemoryRegionEntry(base, limit, PMRFLAGS_TYPE_FREE);
	}
}

void MemInitialize(void)
{
	BiosMemoryEntry entry;
	uint32_t position;
	uint32_t found;
	uint32_t count;
	uint64_t maximumPhysicalAddress;
	
	DbgPrintf("_STAGE2_START_ = %lx\n", _STAGE2_START_);
	DbgPrintf("_TEXT_START_   = %lx\n", _TEXT_START_);
	DbgPrintf("_TEXT_END_     = %lx\n", _TEXT_END_);
	DbgPrintf("_DATA_START_   = %lx\n", _DATA_START_);
	DbgPrintf("_DATA_END_     = %lx\n", _DATA_END_);
	DbgPrintf("_RODATA_START_ = %lx\n", _RODATA_START_);
	DbgPrintf("_RODATA_END_   = %lx\n", _RODATA_END_);
	DbgPrintf("_BSS_START_    = %lx\n", _BSS_START_);
	DbgPrintf("_BSS_END_      = %lx\n", _BSS_END_);
	DbgPrintf("_STAGE2_END_   = %lx\n", _STAGE2_END_);
	
	DbgPrintf("Loading memory map from BIOS...\n");
	
	InitializeListHead(&MemoryMapHead);
	
	// We need to build up a memory map. This is a challenge
	// because we need to map memory before we can allocate
	// memory to store the memory map in. So we make several passes
	// over the memory map.
	
	// Pass 1 - find a region of memory we can actually use between
	// the end of stage2 and 1MB.
	uint64_t targetRegionBase = VirtToPhys(&_STAGE2_END_);
	targetRegionBase = (targetRegionBase + 7) & ~(7);
	uint64_t targetRegionLimit = _STAGE2_LIMIT_;
	targetRegionLimit = targetRegionLimit & ~(7);
	
	position = 0;
	found = 0;
	count = 0;
	maximumPhysicalAddress = 0;
	while (0 == ReadBiosMemoryMap(&entry, &position))
	{
		DbgPrintf("\tEntry %llx - %llx (%d)\n", entry.Base, entry.Base + entry.Length, entry.Type);
		++count;
		
		uint64_t entryBase = entry.Base, entryLimit;
		if (MaxPhysAddress - entry.Length >= entryBase)
		{
			entryLimit = entryBase + entry.Length;
		}
		else
		{
			entryLimit = MaxPhysAddress;
		}
		
		if (entryLimit > maximumPhysicalAddress)
		{
			maximumPhysicalAddress = entryLimit;
		}
		
		if (entry.Type != 1)
		{
			// This is not a free memory region so don't worry too much
			// about it yet
			continue;
		}
		
		// Round up to the nearest multiple of 8
		entryBase = (entryBase + 7) & ~(7);
		// Round down to the nearest multiple of 8
		entryLimit = entryLimit & ~(7);
		
		if (entryLimit > entryBase && entryBase < targetRegionLimit && entryLimit > targetRegionBase)
		{
			// This is an available region which overlaps our target region,
			// so truncate it to fit
			if (entryBase < targetRegionBase)
			{
				entryBase = targetRegionBase;
			}
			if (entryLimit > targetRegionLimit)
			{
				entryLimit = targetRegionLimit;
			}
			
			if (!found || (entryLimit - entryBase) > RootMemoryRegion.Size)
			{
				// This region is the new largest known memory region, so use it
				RootMemoryRegion.Base = (char*)(0xc0000000 + entryBase);
				RootMemoryRegion.Size = (uint32_t)(entryLimit - entryBase);
				found = 1;
			}
		}
	}
	
	if (!found)
	{
		Panic("Failed to find root memory region!\n");
	}
		
	DbgPrintf("Found root memory region at %08x to %08x\n", RootMemoryRegion.Base, RootMemoryRegion.Base + RootMemoryRegion.Size);
	
	// Now create a physical memory region for the whole of memory marked as "Unknown"
	PhysicalMemoryRegion* fullRegion = (PhysicalMemoryRegion*)MemAlloc(sizeof(PhysicalMemoryRegion));
	fullRegion->Base = 0;
	fullRegion->Limit = maximumPhysicalAddress & ~(PageSize - 1);
	fullRegion->Flags = PMRFLAGS_TYPE_UNKNOWN;
	InsertListTail(&MemoryMapHead, &fullRegion->Entry);
	
	// Now that we have some memory to allocate from, we can read the whole memory region
	position = 0;
	while (0 == ReadBiosMemoryMap(&entry, &position))
	{
		InsertPhysicalMemoryRegion(entry.Base, entry.Length, entry.Type == 1);
	}
	
	// Now cleanup and print the list
	for (ListEntry* pos = MemoryMapHead.Next; pos != &MemoryMapHead; pos = pos->Next)
	{
		PhysicalMemoryRegion* thisEntry = CONTAINING_RECORD(pos, PhysicalMemoryRegion, Entry);
		int removeEntry = 0;
		
		if (thisEntry->Flags == PMRFLAGS_TYPE_UNKNOWN)
		{
			// Remove all unknown entries
			removeEntry = 1;
		}
		else if (thisEntry->Entry.Next != &MemoryMapHead)
		{
			PhysicalMemoryRegion* nextEntry = CONTAINING_RECORD(thisEntry, PhysicalMemoryRegion, Entry);
			
			if (thisEntry->Limit == nextEntry->Base && thisEntry->Flags == nextEntry->Flags)
			{
				nextEntry->Base = thisEntry->Base;
				removeEntry = 1;
			}
		}
		
		if (removeEntry)
		{
			pos = pos->Prev;
			RemoveEntryList(&thisEntry->Entry);
		}
		else
		{
			DbgPrintf("PhysMem: %llx - %llx (%lu)\n", thisEntry->Base, thisEntry->Limit, thisEntry->Flags);
		}
	}
}

void* MemAlloc(size_t cb)
{
	// Round up to eight bytes
	cb = (cb + 7) & ~(7);
	
	if (cb > RootMemoryRegion.Size)
	{
		Panic("Out of memory in stage 2\n");
	}
	
	void* ret = RootMemoryRegion.Base;
	RootMemoryRegion.Base += cb;
	RootMemoryRegion.Size -= cb;
	return ret;
}
