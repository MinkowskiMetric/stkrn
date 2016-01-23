#include <rtl.h>
#include "real.h"

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

extern "C" int main()
{
	RlPrint("running in C++\r\n");
	
	RMCallContext rmc;
	RtlZeroMemory(&rmc, sizeof(rmc));
	
	rmc.OpCode = 0x01;
    rmc.Vector = 0x10;
    rmc.EAX = 0x02;
	RlCallRealMode(&rmc);
	
	DbgPrintf("Hello %d\n", 42);
	
	return 0;
}

