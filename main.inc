initializeVideoMode macro
	mov ah,00h
	mov al,12h ;using video mode 640 x 480 16 color graphics
	int 10h
	
	mov ah,00h   ; interrupt to get system timer in CX:DX 
	int 1AH
	mov randNumSeed, dx
endm

setActiveDisplay macro pageNo
	mov ah,05h
	mov al,pageNo 
	int 10h
endm

hideMouseCursor macro  ;this macro hides the mouse cursor
	pushA
	mov ax,02
	int 33h
	
	mov ax,03
	int 33h
	mov mouseXCordSaveVar,cx
	mov mouseYCordSaveVar,dx
	
	mov ax,4
	mov cx,459
	mov dx,379
	int 33h

	popA
endm

showMouseCursor macro ;this macro shows the mouse cursor
	pushA	

	mov ax,4
	mov cx,mouseXCordSaveVar
	mov dx,mouseYCordSaveVar
	int 33h
	
	mov ax,01
	int 33h
	popA
endm

updateScore macro
	pushA
	mov dx,tempCandyNoForScore
	.if(isLevelOne==1)
		add levelOnePoints,dx
	.elseif(isLevelTwo==1)
		add levelTwoPoints,dx
	.elseif(isLevelThree==1)
		add levelThreePoints,dx
	.endif
	popA
endm

delay macro delayFactor
	pushA
	mov cx,1000
	.repeat
		mov bx,delayFactor      ;; increase this number if you want to add more delay, and decrease this number if you want to reduce delay.
		.repeat
			dec bx
		.until(bx==0)
	dec cx
	.until(cx==0)
	popA
endm

getRandNum macro firstNum,lastNum
	push 0000 ; local variable for random number
	push bp;storing base pointer if it is already being used
	mov bp,sp
	pushA
	.repeat
		mov     ax, 25173          ; LCG Multiplier
		mul randNumSeed
		add     ax, 13849          ; Add LCG increment value
		mov	randNumSeed, ax          ; Update seed = return value
		mov		dx,0
		mov     cx, 10    
		div     cx        ; here dx contains the remainder - from 0 to 9
	.until(dl>=firstNum && dl<=lastNum)
	mov dh,0
	mov word ptr[bp+2],dx ;moving rand no to the local variable
	popA; restoring registers
	pop bp;restore bp's previous value
	;now the random num will be stored at the top of the stack
endm

isEven macro num;returns 1 in top of the stack if number is even
	push 0000 ; local variable for random number
	push bp;storing base pointer if it is already being used
	mov bp,sp
	pushA
	mov ax,num
	mov bl,2 ;divisor
	div bl
	.if(ah==0);isEven
		mov word ptr[bp+2],1 ;moving one to the local variable
	.else;isOdd
		mov word ptr[bp+2],0 ;moving zero to the local variable
	.endif
	popA; restoring registers
	pop bp;restore bp's previous value
endm

setMouseMinMaxPositions macro

mov ax,7
mov cx,180
mov dx,460
int 33h

mov ax,8
mov cx,100
mov dx,380
int 33h

endm

shiftLogicalLeft macro register,count
	push cx
	mov cx,count
	.while(cx!=0)
		shl register,1
		dec cx
	.endw
	pop cx
endm

shiftLogicalRight macro register,count
	push cx
	mov cx,count
	.while(cx!=0)
		shr register,1
		dec cx
	.endw
	pop cx
endm

getBit macro register,bitNumber ;only works with 16 bit register
	;returns the bitNumber in register that the user wants, bitNumber can be from 0-15
	shiftLogicalLeft register,15-bitNumber
	shiftLogicalRight register,15
endm

findCoordinatesOfCell macro cellNo ;this macro pushes the x and y coordinates of top left corner of the selected cell into the stack
	push 0000 ;y cordinate local variable
	push 0000 ; x coordinate local variable
	mov bp,sp; [bp] can access x coordinate, [bp+2] can access y coordinate variable
	pushA

	mov ax,cellNo ;cellNo/7 == Q: rowNum, R= colNum
	mov bl,7
	div bl ;Q=al, R=ah
	
	;First extracting remainder(colNum)
	mov al,ah
	mov ah,0
	;now remainder is in AX	
	mov bx,40
	mul bx; 40*colNum will be stored in DX:AX but the result will never go to DX but stay in AX as number is small
	add ax,180
	mov word ptr[bp],ax ;storing x coordinate in local variable
	

	mov ax,cellNo ;cellNo/7 == Q: rowNum, R= colNum
	mov bl,7
	div bl ;Q=al, R=ah
	;Now extracting Quotient(rowNum)
	mov ah,0
	;now quotient is in AX
	
	mov bx,40
	mul bx; 40*rowNum will be stored in DX:AX but the result will never go to DX but stay in AX as number is small
	add ax,100
	mov word ptr[bp+2],ax ;storing y coordinate in local variable
	popA
endm

isCellInRange macro xSelect,ySelect,xPixel,yPixel ;returns 1 in ax if xSelect,ySelect coordinate are in the range of xPixel,yPixel coordinates
							;here xSelect has x coordinate of selected Cell and ySelect has y coordinate of selected cell
							;and xPixel has x coordinate of the printing pixel and yPixel has y coordinate of printing pixel
	mov ax,xSelect
	mov bx,ySelect
	mov cx,xPixel
	mov dx,yPixel
	
	.if(cx>=ax && dx>=bx)
		add ax,40
		add bx,40
		.if(cx<=ax && dx<=bx)
			mov ax,1
		.else
			mov ax,0
		.endif
	.else
		mov ax,0
	.endif

endm

multiply macro reg,intVal ;multiplies 2 values and returns the return value in ax
	pushA
	mov ax,reg
	mov bx,intVal
	mul bx
	mov bp,sp
	mov [bp+14],ax
	popA
endm

divide macro reg,intVal ;divides 2 values and returns the quotient value in al and remainder in ah
						;reg is dividend, intVal is divisor
	pushA
	mov ax,reg
	mov bl,intVal
	div bl
	mov bp,sp
	mov [bp+14],ax
	popA
endm

printSpace macro 
	pushA
	mov dx,' '
	mov ah,02
	int 21h
	popA
endm

printNum macro num
	pushA
	push 0000
	push num
	mov bp,sp; now [bp] can access number to print out and [bp+2] can access digit count
	 .repeat
		 mov ax, word ptr[bp]
		 mov dx,0
		 mov bx,10
		 div bx    
		 push dx
		 
		 mov word ptr[bp],ax
		 inc word ptr[bp+2]
	 .until(ax==0)
	 
	 .while(word ptr[bp+2]!=0)
		 dec word ptr[bp+2] 
		 pop dx
		 add dx,48
		 mov ah,02h
		 int 21h
	 .endw
	pop ax
	pop ax
	popA
endm

makeNullArray macro arrOffset,arrSize,nullNumber
	;this macro nullifies an array with the given number in nullNumber
	pushA
	mov bx arrOffset
	mov cx,arrSize
	mov si,0
	mov dx,nullNumber
	.while(cx!=0)
		mov [bx+si],dx
		add si,2
	.endw
	popA
endm
















areCellsAdjacent macro cellOne,cellTwo ;this macro puts 1 in ax if both the cells are adjacent otherwise it puts 0 in ax
	push 0000 ;local variable
	mov bp,sp ;now [bp] can access local variable that will be 0 or 1 in accordance with the result of this macro and will later be popped into ax for returning
	pushA
	.if(cellOne==0)
		.if(cellTwo==1 || cellTwo==7)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==1)
		.if(cellTwo==0 || cellTwo==2 || cellTwo==8)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==2)
		.if(cellTwo==1 || cellTwo==3 || cellTwo==9)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==3)
		.if(cellTwo==2 || cellTwo==4 || cellTwo==10)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==4)
		.if(cellTwo==3 || cellTwo==5 || cellTwo==11)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==5)
		.if(cellTwo==4 || cellTwo==12 || cellTwo==6)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==6)
		.if(cellTwo==5 || cellTwo==13)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==7)
		.if(cellTwo==0 || cellTwo==8 || cellTwo==14)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==8)
		.if(cellTwo==1 || cellTwo==7 || cellTwo==9 || cellTwo==15)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==9)
		.if(cellTwo==2 || cellTwo==8 || cellTwo==10 || cellTwo==16)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==10)
		.if(cellTwo==3 || cellTwo==9 || cellTwo==11 || cellTwo==17)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==11)
		.if(cellTwo==4 || cellTwo==10 || cellTwo==12 || cellTwo==18)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==12)
		.if(cellTwo==5 || cellTwo==11 || cellTwo==13 || cellTwo==19)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==13)
		.if(cellTwo==6 || cellTwo==12 || cellTwo==20)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==14)
		.if(cellTwo==7 || cellTwo==15 || cellTwo==21)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==015)
		.if(cellTwo==8 || cellTwo==14 || cellTwo==16 || cellTwo==22)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==016)
		.if(cellTwo==9 || cellTwo==15 || cellTwo==17 || cellTwo==23)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==017)
		.if(cellTwo==10 || cellTwo==16 || cellTwo==18 || cellTwo==24)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==018)
		.if(cellTwo==11 || cellTwo==17 || cellTwo==19 || cellTwo==25)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==019)
		.if(cellTwo==12 || cellTwo==18 || cellTwo==20 || cellTwo==26)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==020)
		.if(cellTwo==13 || cellTwo==19 || cellTwo==27)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==021)
		.if(cellTwo==14 || cellTwo==22 || cellTwo==28)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==022)
		.if(cellTwo==15 || cellTwo==21 || cellTwo==23 || cellTwo==29)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==023)
		.if(cellTwo==16 || cellTwo==22 || cellTwo==24 || cellTwo==30)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==024)
		.if(cellTwo==17 || cellTwo==23 || cellTwo==25 || cellTwo==31)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==025)
		.if(cellTwo==18 || cellTwo==24 || cellTwo==26 || cellTwo==32)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==026)
		.if(cellTwo==19 || cellTwo==25 || cellTwo==27 || cellTwo==33)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==027)
		.if(cellTwo==20 || cellTwo==26 || cellTwo==34)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==028)
		.if(cellTwo==21 || cellTwo==29 || cellTwo==35)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==029)
		.if(cellTwo==22 || cellTwo==28 || cellTwo==30 || cellTwo==36)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==030)
		.if(cellTwo==23 || cellTwo==31 || cellTwo==29 || cellTwo==37)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==031)
		.if(cellTwo==24 || cellTwo==30 || cellTwo==32 || cellTwo==38)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==032)
		.if(cellTwo==25 || cellTwo==31 || cellTwo==33 || cellTwo==39)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==033)
		.if(cellTwo==26 || cellTwo==32 || cellTwo==34 || cellTwo==40)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==034)
		.if(cellTwo==27 || cellTwo==33 || cellTwo==41)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==035)
		.if(cellTwo==28 || cellTwo==36 || cellTwo==42)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==036)
		.if(cellTwo==29 || cellTwo==35 || cellTwo==37 || cellTwo==43)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==037)
		.if(cellTwo==30 || cellTwo==36 || cellTwo==38 || cellTwo==44)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==038)
		.if(cellTwo==31 || cellTwo==37 || cellTwo==39 || cellTwo==45)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==039)
		.if(cellTwo==32 || cellTwo==38 || cellTwo==40 || cellTwo==46)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==040)
		.if(cellTwo==33 || cellTwo==39 || cellTwo==41 || cellTwo==47)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==041)
		.if(cellTwo==34 || cellTwo==40 || cellTwo==48)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==042)
		.if(cellTwo==35 || cellTwo==43)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==043)
		.if(cellTwo==36 || cellTwo==42 || cellTwo==44)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==044)
		.if(cellTwo==37 || cellTwo==43 || cellTwo==45)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==045)
		.if(cellTwo==38 || cellTwo==44 || cellTwo==46)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==046)
		.if(cellTwo==39 || cellTwo==45 || cellTwo==47)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==047)
		.if(cellTwo==40 || cellTwo==46 || cellTwo==48)
			mov word ptr[bp],1
		.endif
	.elseif(cellOne==048)
		.if(cellTwo==41 || cellTwo==47)
			mov word ptr[bp],1
		.endif
	.endif	
	popA
	pop ax
endm