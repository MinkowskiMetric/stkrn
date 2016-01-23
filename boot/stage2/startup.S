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
STAGE2STARTCTX_BootDiskNumber:
  .struct STAGE2STARTCTX_BootDiskNumber + 4
  .balign 4
STAGE2STARTCTX_SIZE:

.extern main

.text
.code32

  # We need to start with a relative jmp to some other location
  jmp stage2_entry
  
  .balign 4
StartContext:
  .fill STAGE2STARTCTX_SIZE, 1, 0
  .balign 4
  
Stage2ReturnedError:
  .asciz "ERROR! Stage2 returned!\r\n"
  
.func stage2_entry
stage2_entry:
  # Copy the start context
  mov esi, ecx
  lea edi, StartContext
  mov ecx, STAGE2STARTCTX_SIZE
  rep movsb
  
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
  call BxPrint
  
1:  
  cli
  hlt
  jmp 1b
  
.endfunc

.func BxPrint
BxPrint:

  lea eax, [StartContext + STAGE2STARTCTX_Print]
  jmp [eax]
  
.endfunc

.func BxCallRealMode
BxCallRealMode:

  lea eax, [StartContext + STAGE2STARTCTX_CallRealMode]
  jmp [eax]
  
.endfunc

.global RlPrint
.func RlPrint
RlPrint:
  
  mov ecx, [esp + 4]
  call BxPrint
  
  ret
  
.endfunc

.global RlCallRealMode
.func RlCallRealMode
RlCallRealMode:

  mov ecx, [esp + 4]
  call BxCallRealMode
  
  ret
  
.endfunc

.global RlGetStartCtx
.func RlGetStartCtx
RlGetStartCtx:

  lea eax, StartContext
  ret
  
.endfunc
