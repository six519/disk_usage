%macro print_val 1
        mov             rdi, %1
        sub             rsp, 8
        mov             al, 1
        call            printf
        add             rsp, 8 
%endmacro

%macro compute_val 1
        movsd           xmm0, [gb]
        cvtsi2sd        xmm1, [svfs + %1]
        cvtsi2sd        xmm2, [svfs + f_frsize]
        mulsd           xmm1, xmm2
        divsd           xmm1, xmm0
        movsd           xmm0, xmm1
%endmacro

	global		main
	extern		printf, statvfs

	section		.text

main:	
	mov		r14, 0
	call		get_arg
	cmp		r14, 2
	jne		exit

	mov		rdi, r15
	mov		rsi, svfs
	call		statvfs
	cmp		rax, 0
	jne		exit

	;get total
	compute_val	f_blocks
	movsd		xmm5, xmm0
	print_val	total

	;get available
	compute_val	f_bfree
	print_val	avail

	;get used
	compute_val	f_blocks
	movsd		xmm3, xmm0
	movsd		xmm4, xmm3
	compute_val	f_bfree
	subsd		xmm3, xmm0
	movsd		xmm0, xmm3
	movsd		xmm6, xmm3
	print_val	used
	
	;get used percentage
	divsd		xmm6, xmm5
	movsd		xmm0, [pcnt]
	mulsd		xmm6, xmm0
	movsd		xmm0, xmm6
	print_val	usedp

	jmp		exit

get_arg:
	push		rdi
	push		rsi
	sub		rsp, 8
	mov		r15, [rsi]
	inc		r14
	add		rsp, 8
	pop		rsi
	pop		rdi
	add		rsi, 8
	dec		rdi
	jnz		get_arg
	ret

exit:
	mov		rax, 0x3c
	mov		rdi, 0
	syscall

	section		.data

gb:	dq		1073741824.0
pcnt:	dq		100.0
total	db		`\x1b[33;1mTotal: \x1b[32;1m%fGB`, 0xa, 0
avail:	db		`\x1b[34;1mAvailable: \x1b[32;1m%fGB`, 0xa, 0
used:	db		`\x1b[35;1mUsed: \x1b[32;1m%fGB`, 0xa, 0
usedp:	db		`\x1b[36;1mUsed Percentage: \x1b[32;1m%.0f%% \x1b[0m`, 0xa, 0

struc SVFS
	f_bsize: resq 1
	f_frsize: resq 1
	f_blocks: resq 1
	f_bfree: resq 1
	f_bavail: resq 1
	f_files: resq 1
	f_ffree: resq 1
	f_favail: resq 1
	f_fsid: resq 1
	f_flag: resq 1
	f_namemax: resq 1
endstruc	

svfs: istruc SVFS
	at f_bsize, dq 0
	at f_frsize, dq 0
	at f_blocks, dq 0
	at f_bfree, dq 0
	at f_bavail, dq 0
	at f_files, dq 0
	at f_ffree, dq 0
	at f_favail, dq 0
	at f_fsid, dq 0
	at f_flag, dq 0
	at f_namemax, dq 0
iend
