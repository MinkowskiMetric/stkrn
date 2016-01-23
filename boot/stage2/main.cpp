#include "real.h"

extern "C" int main()
{
	bl::Print("running in C++\r\n");
	
	bl::RMCallContext rmc;
	__builtin_bzero(&rmc, sizeof(rmc));
	
	rmc.Vector = 0x10;
	rmc.EAX = 0x2;
	bl::CallRealMode(&rmc);
	
	return 0;
}

