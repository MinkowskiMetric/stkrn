#include <rtl.h>
#include "real.h"
#include "memory.h"

extern "C" void BlPrintCharacter(char c)
{
	if (c == '\n')
	{
		// Convert to BIOS line endings
		BlPrintCharacter('\r');
	}
	
	RMCallContext rmc;
	RtlZeroMemory(&rmc, sizeof(rmc));
	
	rmc.OpCode = 0x01;
    rmc.Vector = 0x10;
    rmc.EAX = 0x0e00 + c;
    rmc.EBX = 0x09;
	RlCallRealMode(&rmc);
}

void BlClearScreen(void)
{
	RMCallContext rmc;
	RtlZeroMemory(&rmc, sizeof(rmc));
	
	rmc.OpCode = 0x01;
    rmc.Vector = 0x10;
    rmc.EAX = 0x02;
	RlCallRealMode(&rmc);
}

extern "C" int main()
{
	BlClearScreen();
	DbgPrintf("Entering stage 2 bootloader, loading from device %u\n", RlGetStartCtx()->BootDiskNumber);
	
	MemInitialize();
	
	return 0;
}

