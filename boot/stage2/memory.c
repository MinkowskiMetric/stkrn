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

void MemInitialize(void)
{
	BiosMemoryEntry entry;
	uint32_t position;
	
	DbgPrintf("Loading memory map from BIOS...\n");
	
	position = 0;
	while (0 == ReadBiosMemoryMap(&entry, &position))
	{
		DbgPrintf("\tEntry %llx - Length %llx - Type %lx\n", entry.Base, entry.Length, entry.Type);
	}
}

