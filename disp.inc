
writePixel macro col

	mov ah, 0Ch
	mov al, col
	int 10h
endm


moveCursor macro row, col, pg
	mov ah, 02
	mov bh, pg
	mov dh, row
	mov dl, col
	int 10h
endm

writeLine macro
	mov ah, 40h
	mov bx, handle
	mov cx, lengthof newLine
	mov dx, offset newLine
	int 21h
endm

initiateFile macro FileName

	mov ah,3dh
	mov dx,offset FileName
	mov al, 2  ;access code: 0 open for reading; 1 open for writing;2 for both 
	int 21h
endm

writeData macro var

	mov ah, 40h
	mov bx, handle
	mov cx, lengthof var
	mov dx, offset var
	int 21h

endm