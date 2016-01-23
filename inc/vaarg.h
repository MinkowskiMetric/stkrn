#ifndef _VAARG_H_
#define _VAARG_H_

typedef __builtin_va_list 	va_list;
typedef __builtin_va_list 	__gnuc_va_list;

#define 	_VA_LIST
#define 	va_start(ap, param)   __builtin_va_start(ap, param)
#define 	va_end(ap)   __builtin_va_end(ap)
#define 	va_arg(ap, type)   __builtin_va_arg(ap, type)
#define 	__va_copy(d, s)   __builtin_va_copy(d,s)
#define 	va_copy(dest, src)   __builtin_va_copy(dest, src)
#define 	__GNUC_VA_LIST   1

#endif
