#include <rtl.h>

void RtlZeroMemory(void* p, size_t cb)
{
	for (char* pos = (char*)p, *end = pos + cb; pos != end; ++pos)
	{
		*pos = 0;
	}
}

