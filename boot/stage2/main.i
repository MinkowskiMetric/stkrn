	.text
	.file	"main.cpp"
	.globl	main
	.align	16, 0x90
	.type	main,@function
main:                                   # @main
	.cfi_startproc
# BB#0:
	pushl	%ebp
.Ltmp0:
	.cfi_def_cfa_offset 8
.Ltmp1:
	.cfi_offset %ebp, -8
	movl	%esp, %ebp
.Ltmp2:
	.cfi_def_cfa_register %ebp
	subl	$88, %esp
	leal	.L.str, %eax
	movl	$0, -4(%ebp)
	movl	%eax, (%esp)
	calll	RlPrint
	movl	$64, %eax
	leal	-72(%ebp), %ecx
	movl	%ecx, (%esp)
	movl	$64, 4(%esp)
	movl	%eax, -76(%ebp)         # 4-byte Spill
	calll	RtlZeroMemory
	leal	-72(%ebp), %eax
	movl	$16, -68(%ebp)
	movl	$2, -64(%ebp)
	movl	%eax, (%esp)
	calll	RlCallRealMode
	xorl	%eax, %eax
	addl	$88, %esp
	popl	%ebp
	retl
.Ltmp3:
	.size	main, .Ltmp3-main
	.cfi_endproc

	.type	.L.str,@object          # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"running in C++\r\n"
	.size	.L.str, 17


	.ident	"Ubuntu clang version 3.6.2-1 (tags/RELEASE_362/final) (based on LLVM 3.6.2)"
	.section	".note.GNU-stack","",@progbits
