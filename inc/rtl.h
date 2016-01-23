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

#ifdef __cplusplus
}
#endif

#endif

