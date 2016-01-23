#ifndef __TYPES_H__
#define __TYPES_H__

typedef signed char int8_t;
typedef unsigned char uint8_t;
typedef short int16_t;
typedef unsigned short uint16_t;
typedef int int32_t;
typedef unsigned int uint32_t;
typedef long long int64_t;
typedef unsigned long long uint64_t;

typedef int32_t intptr_t;
typedef uint32_t uintptr_t;

typedef intptr_t ptrdiff_t;
typedef uintptr_t size_t;

#define INT8_T_MAX (int8_t)0x7f
#define INT8_T_MIN (int8_t)0x80
#define UINT8_T_MAX (uint8_t)0xff

#define INT16_T_MAX (int16_t)0x7fff
#define INT16_T_MIN (int16_t)0x8000
#define UINT16_T_MAX (uint16_t)0xffff

#define INT32_T_MAX (int32_t)0x7fffffff
#define INT32_T_MIN (int32_t)0x80000000
#define UINT32_T_MAX (uint32_t)0xffffffff

#define INT64_T_MAX (int64_t)0x7fffffffffffffff
#define INT64_T_MIN (int64_t)0x8000000000000000
#define UINT64_T_MAX (uint64_t)0xffffffffffffffff

#endif

