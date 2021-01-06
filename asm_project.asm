data segment para public 'data'
err_open db 'Error opening file!$', 0
err_close db 'Invalid handle!$', 0
handle dw 0
filename db 'to_read.txt', 0
file_pointer dd filename
msg db 'Word to search for: $', 0
len dw 0, 0
row dw 1, 0
num_in_row dw 1, 0
count dw 0, 0
buffer dw 501, 500 dup ('?')
file_buffer dw 500 dup('?')
equal_msg db 'The strings are equal!$', 0
options db 'Choose an operation: ',13,10,'1. Search for word',13,10,'2. Search for punctuation mark',13,10,'3. Count sentences',13,10,'$',0
opt_ptr dw options, 0
msg_ptr dw msg, 0
data 	ends

code segment para public 'code'
		
	assume cs:code, ds:data

print:
	push bp
	mov bp, sp
	xor ax, ax	
	mov ah, 09h
	mov dx, [bp + 4]
	int 21h
	pop bp
	ret 2

word_search:
	push bp
	push msg_ptr
	call print
	
	xor ax, ax
	mov ah, 0ah
	lea dx, buffer
	int 21h
	
	mov ah, 02h
	mov dl, 10
	int 21h
	
	lea si, buffer
	inc si
	mov ax, [si]
	xor ah, ah
	mov len, ax
	
	lea di, file_buffer
compare:
	push di
	lea si, buffer
	add si, 2
	mov cx, len
cycle:
	mov al, [di]
	cmp al, [si]
	jne not_equal
	dec cx
	inc si
	inc di
	cmp cx, 0
	jnz cycle
	xor ax, ax
	mov ah, 02h
	mov dl, byte ptr[row]
	add dl, 48
	int 21h
	mov dl, 32
	int 21h
	mov dl, byte ptr[num_in_row]
	add dl, 48
	int 21h
	mov dl, 10
	int 21h
not_equal:
	pop di
	inc di
	mov al, [di]
	cmp al, 10
	jne same_row
	
	inc [row]
	mov [num_in_row], 1
	
same_row:
	cmp al, 32
	jne same_word
	inc [num_in_row]
	
same_word:
	mov bx, [len]
	dec bx
	cmp byte ptr[di + bx], 0
	jnz compare
	
	pop bp
	ret 
	
main: 
	mov ax, data
	mov ds, ax
	mov es, ax
	xor ax, ax
	
	xor ax, ax
	mov ah, 3dh
	lds dx, file_pointer
	int 21h
	mov handle, ax
	
	xor ax, ax
	mov ah, 3fh
	mov bx, handle
	mov cx, 255
	lea dx, file_buffer
	int 21h

	push opt_ptr
	call print
	
	mov ah, 01h
	int 21h
	push ax
	mov ah, 02h
	mov dl, 10
	int 21h
	pop ax
	cmp al, 49
	jne not_1
	call word_search
	
not_1:
	cmp al, 50
	jne not_2
	call punctuation_search
	
not_2:
	cmp al, 51
	jne not_3
	call sentence_count
not_3:
	xor ax, ax
	mov ah, 3eh
	mov bx, handle
	int 21h
mov ax, 4c00h
int 21h

code 	ends
end main
	