.intel_syntax noprefix
.code32

# STAGE2STARTCTX
  .struct 0
  .balign 4
STAGE2STARTCTX_StructSize:
  .struct STAGE2STARTCTX_StructSize + 4
  .balign 4
STAGE2STARTCTX_Print:
  .struct STAGE2STARTCTX_Print + 4
  .balign 4
STAGE2STARTCTX_CallRealMode:
  .struct STAGE2STARTCTX_CallRealMode + 4
  .balign 4
STAGE2STARTCTX_SIZE:

.extern main

.text
.code32

  # We need to start with a relative jmp to some other location
  jmp stage2_entry
  
BxPrint:
  .int 0
BxCallRealMode:
  .int 0
Stage2ReturnedError:
  .asciz "ERROR! Stage2 returned!\r\n"
  
.func stage2_entry
stage2_entry:
  # Save the parameters passed to us by the bootloader
  mov eax, [ecx + STAGE2STARTCTX_Print]
  mov [BxPrint], eax
  mov eax, [ecx + STAGE2STARTCTX_CallRealMode]
  mov [BxCallRealMode], eax
  
  # zero out the bss section
  lea edi, _BSS_START_
  lea ecx, _BSS_END_
  sub ecx, edi
  xor eax, eax
  rep stosb
  
  # We can carry on running on the bootloader stack for now
  # as it is big enough.
  call main
  
  # If we get here, main returned, which is bad.
  lea ecx, Stage2ReturnedError
  call [BxPrint]
  
1:  
  cli
  hlt
  jmp 1b
  
.endfunc

.global RlPrint
.func RlPrint
RlPrint:
  
  mov ecx, [esp + 4]
  call [BxPrint]
  
  ret
  
.endfunc

.global RlCallRealMode
.func RlCallRealMode
RlCallRealMode:

  mov ecx, [esp + 4]
  call [BxCallRealMode]
  
  ret
  
.endfunc
