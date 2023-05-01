;i20-0555 Saad Bin Farooq
;i20-0696 Umer Mukhtar
;ON THE INITIAL SCREEN,PLEASE ENTER YOUR NAME FOR INPUT AND THEN PRESS ENTER
;THERE ARE 5 CANDIES AND 1 COLOR BOMB(The one with 5 colors)
;PRESS ESCAPE TO EXIT FROM THE GAME
include main.inc
include disp.inc
.model small
.stack 100h
.386
.data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR INITIAL DISPLAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
userName db 50 dup(?) ;Will store the userName
fileUserName db 50 dup(?)


;Messages to display to the user at various scenarios in the menu/pages
welcomeMsg1 db "Welcome To Candy Crush $"
nameMsg db "Enter your name and press [ENTER] $"
nameMsg2 db "to continue $"

;Keeps track of cursor location and page number being used
cursorRow db 8
cursorCol db 29
pageNum db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR INITIAL DISPLAY ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR THE GAME RULES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ruleMsg db "RULES $"
goodLuck db "Happy Crushing! $"
continueMsg db "Press [ENTER] to continue $"
rule1 db "1. This Game Consists of 3 Levels $"
rule4 db "4. You can swap two vertically or horizontally adjacent candies $"
rule3 db "3. The aim is to create either a vertical row or vertical column $"
rule3_1 db "of 3 or more same candies. These matching candies will be crushed $" 
rule3_2 db "and the candies above will fall to take their place $"
rule5 db "5. If more then 3 candies are crushed, a color bomb will be created, $"
rule5_1 db "these color bombs will crush entire row and column of the candy $"
rule5_2 db "they are swapped with $"
rule2 db "2. After each level is completed, you unlock the next level $"



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR THE GAME RULES ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR SCREEN/SCORE TEXT DISPLAY;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
scoreMsg db "Points: $"
exitMsg db "Press [ESC] to exit $"
nameTextMsg db "Name: $"
pixelColor db 0 ;Is used to select the pixel color when drawing pixels, can be used in a variety of places
levelOneMsg db "Level 1 $"
levelTwoMsg db "Level 2 $"
levelThreeMsg db "Level 3 $"
movesMsg db "Moves $"



numMoves dw 15 ;Stores the number of moves so far made, needs to be reset to 0 for every level
levelOnePoints dw 0
levelTwoPoints dw 0
levelThreePoints dw 0
scoreDisplayCount dw 0 ;Temporary varaible for displaying the score

;Boolean indicators for which level is currently active, ONLY ONE CAN BE ACTIVE AT A TIME
isLevelOne db 0
isLevelTwo db 0
isLevelThree db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR SCREEN/SCORE TEXT DISPLAY ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLE FOR RANDUM NUM GENERATION;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

randNumSeed dw 0;in this variable, the seed to create random numbers will be saved. just like srand(unsigned(time(0))) in c++

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLE FOR RANDUM NUM GENERATION ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ARRAYS FOR GRID, CANDIES, X+Y COORDS OF GRIDS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

candyArr dw 1,2,3,4,5 ;1 = green box...... 5 = hexagon
gridStatus dw 7*7 dup(0) ;grid[7][7]----- 0 = no candy, candyNum= candy (1-5), 6= color bomb, 7= Block, 8= empty
gridXCords dw 7*7 dup(0) ;top left x coordinates of the grid
gridYCords dw 7*7 dup(0) ;top left y coordinates of the grid
generateCandies dw 1;when generateCandies = 1, it generates candies and then those candies freeze unless a swap or crush is occured
generateGrid dw 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;ARRAYS FOR GRID, CANDIES, X+Y COORDS OF GRIDS ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR SWAPPING CANDIES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

isSelected dw 0;is zero if a box is not selected, is 1 if a box is selected
selectedCellNo dw 100 ;100 initially because 0-48 cells get selected, so it should be set above 48 when no cell should be selected
checkForSwap dw 0;is zero when swap should not be checked and 1 when swapping candies should be checked
initCellNo dw 100;number of the cell that is initially selected 0-48
finalCellNo dw 100;number of the cell that is finally selected 0-48
initCandyNum dw 0 ;cand
finalCandyNum dw 0
successfulSwap dw 0 ;if candies are successfully swapped, successfulSwap is 1

tempFinalCandyNumIndexSI dw 0 ;temp variable to store initialCandy's cell number so that it can be later swapped back

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR SWAPPING CANDIES ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR LOSE/MOVE PAGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


moveMsg1 db "You failed to complete this level in the optimal moves! $"
moveMsg2 db "Restart to try again $"
moveMsg3 db "Press [ENTER] to exit $"
moveMsg4 db "Your Score: $"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR LOSE/MOVE ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR CRUSHING CANDIES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

curshingCandies dw 7 dup (100) ;array contains the cells of candies that are crushing. initialized with 100 because 100 is above the cell numbers i.e.0-48
countOfCrushingCandies dw 0
successfulCrush dw 0 ;if candies are successfully crushed, successfulCrush is 1

crushingCandiesCountRow dw 0
crushingCandiesCountCol dw 0
startingCellNoRow dw 20 dup (100) ;variable to store starting and ending cell numbers of the candies that are being crushed in a row or column
endingCellNoRow dw 20 dup (100)
startingCellNoCol dw 20 dup (100) ;variable to store starting and ending cell numbers of the candies that are being crushed in a row or column
endingCellNoCol dw 20 dup (100)
tempCandyNo dw 0
tempCandyCounter dw 0

				;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR CREATING BOMB;;;;;;;;;;;;;;;;;;;;;;;;;;

bombCounter dw 0 ;counts the total bombs forming after a successful swap
bombPositions dw 10 dup (100) ;array to store the positions on which color bomb would be generated
		
				;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR CREATING BOMB ENDV;;;;;;;;;;;;;;;;;;;
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR CRUSHING CANDIES ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR DROPPING CANDIES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tempCandyTop dw 0;temp number to save the candy at the top so when it is swapped, we can use this variable to assign the candy num to the candy at the bottom
candyTopIndex dw 0;saves the index of the candy present at the top so that it can be swapped
tempCandyBottom dw 0;temp var to save the candy at the bottom during dropping
candyBottomIndex dw 0;saves the index of the candy present at the bottom so that it can be swapped

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES FOR DROPPING CANDIES ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES TO STORE MOUSE INITIAL AND FINAL POSITIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mouseInitXCord dw 0
mouseInitYCord dw 0
mouseFinXCord dw 0
mouseFinYCord dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES TO STORE MOUSE INITIAL AND FINAL POSITIONS ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES TO HIDE MOUSE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

mouseXCordSaveVar dw 0
mouseYCordSaveVar dw 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;VARIABLES TO HIDE MOUSE ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TEMP VARIABLES USED IN VARIOUS FUNCTIONS;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tempCellNo dw 0; to pass argument to a function. using as an intermediate in a function
tempCandyNoForSwapping dw 100 ; a temp no used to store the initial candy num when swapping candies
tempCellNoForSwapping dw 100 ; a temp no used to store the initial cell num when swapping candies
tempForHexaCandy dw 0;a temp number only used for drawing hexa candy
tempRtAddressfindCellNo dw 0 ; a temp var to hold the return address of the function findCellNo
tempCandyNoForScore dw  0 ;a temp var to store candy number so that score can be updated in accordance with it

newLine db 13,10 
fileName db "data.txt"
handle dw ?
fileLevelOneScore db "Level 1: "
fileLevelTwoScore db "Level 2: "
fileLevelThreeScore db "Level 3: "
Filetemp dw ?
fileDigitCount db 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TEMP VARIABLES USED IN VARIOUS FUNCTIONS ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;WINPAGE VARIABLES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


winMsg1 db "You have completed all 3 levels! $"
scoresMsg1 db "Your scores are displayed below: $"

winMsg2 db "Level 1: $"
winMsg3 db "Level 2: $"
winMsg4 db "Level 3: $"
winMsg5 db "Press [ENTER] to exit $"
winMsgScore db "SCORE $"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;WINPAGE VARIABLES ENDV;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


.code
main proc

	mov ax,@data
	mov ds,ax
	mov es, ax	
	
	
	
	initiateFile fileName ;Opens the file to write to 
	mov handle, ax
	
	mov ah,42h; adjust/edit file pointer command
	mov bx,handle; Bx holds the handle which tells in which file we have to write
	xor cx,cx; Movig 0 bytes to CX
	xor dx,dx; Movig 0 bytes to DX
	mov al, 2 ;2 movement oode is used to specify movement based on end of file 
	INT 21H
	
	writeLine
	
	;;;;;;;;;;;;first page starts;;;;;;;;;;;;;;;;;;
	initializeVideoMode
	call displayInitialPromptsInputs
	;Writing the user name into the file
	mov ah, 40h
	mov bx, handle
	mov cx, lengthof fileUserName
	mov dx, offset fileUserName
	int 21h
	;;;;;;;;;;;first page ends;;;;;;;;;;;;;;;;;;;;;
	
	;;;;;;;;;;;diplaying the rule page;;;;;;;;;;;;;
	initializeVideoMode
	call displayRules
	;;;;;;;;;;;displaying rule page ends;;;;;;;;;;;
	
	
	
	
	inc isLevelOne ;change this line to any other level to debug levels or view them, level one is the default level loaded here
	;Note: Only one 'islevel' boolean can be active at a time
	
	initializeVideoMode ;Setting the video mode
	setMouseMinMaxPositions
	call populateGridVars
	call crushInitialCandies

	;setting background color
	mov ah,0Bh
	mov bh,00h
	mov bl,00000000b; rightmost 4 bits = 0000 i.e. black color for background
	int 10h
	
	infiniteLoop:
	
	;If the player reaches level 3 and completes it in the required moves, then player has won the game and their scores are displayed
	.if(numMoves >= 0 && isLevelThree == 1 && levelThreePoints >= 50) ;LEVEL 3 needs 50 or above score to beat
		call displayWinPage
		jmp EXIT
	.endif
	
	;If the player is unable to make the required score in the number of moves
	.if(numMoves == 0) ;If the number of remaining moves finish, the exit/lose screen is shown 
		call displayEndPage
		;Writing to the file based the number of levels the player has reached
		.if(isLevelOne == 1)
		
			writeLine
			writeData fileLevelOneScore
			mov bx, levelOnePoints
			call writeLevelScore
			
			writeLine
			writeData fileLevelTwoScore
			mov bx, levelTwoPoints
			call writeLevelScore
			
		.elseif (isLevelTwo == 1)
		
			writeLine
			writeData fileLevelTwoScore
			mov bx, levelTwoPoints
			call writeLevelScore
		
		.endif
		 
		jmp EXIT
	.endif
		
	;If the player has scored over 400 points in the first level, then we move to level 2 and write the level one score to the file 
	.if(isLevelOne == 1 && levelOnePoints >= 350) ;Needs 350 to go to level 2
		dec isLevelOne
		inc isLevelTwo
		
		writeLine
		writeData fileLevelOneScore
		mov bx, levelOnePoints
		call writeLevelScore
		
		mov numMoves, 12
		initializeVideoMode ;Setting the video mode
		call populateGridVars
		call crushInitialCandies
		call displayGameData
		call displayPlayerScore
		call makeGrid
	.endif
	;If the player has scored over 300 points, then we move to level 3 and the level 2 score is written to file
	.if(isLevelTwo == 1 && levelTwoPoints >= 300) ;Needs 300 to go to level 3
		dec isLevelTwo
		inc isLevelThree
		
		writeLine
		writeData fileLevelTwoScore
		mov bx, levelTwoPoints
		call writeLevelScore
		
		mov numMoves, 5
		initializeVideoMode
		call populateGridVars
		call displayGameData
		call displayPlayerScore
		call makeGrid
		call makeCandies
		call crushInitialCandies
	.endif
		
	
	call displayGameData
	call displayPlayerScore
	.if(generateGrid==1) ;grid needs to be generated ONLY when a box is selected or deselected
		call makeGrid
	.endif
	.if(generateCandies==1)	;candies are first generated at the starting
							;then generated ONLY when either they are swapped OR they are crushed
		call makeCandies
	.endif
	call checkForMouseInput
	.if(checkForSwap==1)
		call checkForSwapProc
	.endif
	
	checkForExit:
	; this label checks if a key is being pressed
	;if a key is not being pressed, it continues to run the infinite loop
	;if a key is pressed, it checks whether the key is escape key or not. If it is escape key, it exits the game
	mov ah,01h
	int 16h
	jz infiniteLoop
	mov ah,00h
	int 16h
	.if al==27
	.else
		jmp infiniteLoop
	.endif
	
	
	EXIT:
	
	;Storing the player score of level 3
	
	writeLine
	writeData fileLevelThreeScore
	mov bx, levelThreePoints
	call writeLevelScore
	writeLine
	
	mov ah,3eh
	mov bx,handle
	int 21h
	
	moveCursor 0, 0, pageNum
	
	mov ah,4ch
	int 21h
	main endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PROCEDURES;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;writeLevelScore;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

writeLevelScore PROC uses bx
	
	mov fileDigitCount, 0 ;temporary variable for stroing length of the score 
	
	mov ax, bx
	mov bx,10
	pushData:
		mov dx,0
		div bx
		push dx
		inc fileDigitCount
		cmp ax, 0
	jne pushData

	;We pop the digit and store it in the file
	writeToFile:
		cmp fileDigitCount,0
		je closeFile 
		dec fileDigitCount
		pop bx
		add bx, 48
		mov Filetemp, bx

		mov ah,40h
		mov bx,handle
		mov cx, 1
		mov dx, offset Filetemp
		int 21h
	jmp writeToFile

	
	closeFile:
		ret
	
writeLevelScore endp


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;displayWinPage;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
displayWinPage proc

	

	;Displying the inital messages
	initializeVideoMode
	mov cursorRow, 5
	mov cursorCol, 24
	mov dx, offset winMsg1
	push dx
	mov dx, lengthof winMsg1
	push dx
	call displayColorData
	
	mov cursorRow, 8
	mov cursorCol, 37
	mov dx, offset winMsgScore
	push dx
	mov dx, lengthof winMsgScore
	push dx
	call displayColorData
	
	;Display the scores
	;Level 1 score
	mov cursorRow, 12 
	mov cursorCol, 31
	mov dx, offset winMsg2
	push dx
	mov dx, lengthof winMsg2
	push dx
	call displayColorData
	
	moveCursor 12, 41, pageNum
	mov dx, 0
	mov bx, 10
	mov ax, levelOnePoints
		
	.while(ax != 0)
		div bx
		push dx
		mov dx, 0
		inc scoreDisplayCount
	.endw
	
	.while(scoreDisplayCount != 0)
		pop dx
		add dx, 48
		mov ah, 02
		int 21h
		dec scoreDisplayCount
	.endw
	
	
	;Level 2 score
	mov cursorRow, 15
	mov cursorCol, 31
	mov dx, offset winMsg3
	push dx
	mov dx, lengthof winMsg3
	push dx
	call displayColorData
	
	
	moveCursor 15, 41, pageNum
	mov dx, 0
	mov bx, 10
	mov ax, levelTwoPoints
		
	.while(ax != 0)
		div bx
		push dx
		mov dx, 0
		inc scoreDisplayCount
	.endw
	
	.while(scoreDisplayCount != 0)
		pop dx
		add dx, 48
		mov ah, 02
		int 21h
		dec scoreDisplayCount
	.endw
	
	
	;Level 3 score
	mov cursorRow, 18
	mov cursorCol, 31
	mov dx, offset winMsg4
	push dx
	mov dx, lengthof winMsg4
	push dx
	call displayColorData
	
	moveCursor 18, 41, pageNum
	mov dx, 0
	mov bx, 10
	mov ax, levelThreePoints
		
	.while(ax != 0)
		div bx
		push dx
		mov dx, 0
		inc scoreDisplayCount
	.endw
	
	.while(scoreDisplayCount != 0)
		pop dx
		add dx, 48
		mov ah, 02
		int 21h
		dec scoreDisplayCount
	.endw
	
	
	mov cursorRow, 25
	mov cursorCol, 29
	mov dx, offset winMsg5
	push dx
	mov dx, lengthof winMsg5
	push dx
	call displayColorData
	
	;Checking for user input
	moveCursor 50, 50, pageNum
	.while(al != 13)
		mov ah, 01
		int 21h
	.endw
	
	
	ret
	
displayWinPage endp
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;displayEndPage;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

displayEndPage Proc

	pushA
	initializeVideoMode
	mov cursorRow, 7
	mov cursorCol, 12
	mov dx, offset moveMsg1
	push dx
	mov dx, lengthof moveMsg1
	push dx
	call displayColorData
	
	mov cursorCol, 32
	mov cursorRow, 15
	mov dx, offset moveMsg4
	push dx
	mov dx, lengthof moveMsg4
	push dx
	call displayColorData
	
	moveCursor 15, 44, pageNum
	.if(isLevelOne == 1)
		.if(levelOnePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelOnePoints
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelTwo == 1)
		.if(levelTwoPoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelTwoPoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelThree == 1)
		.if(levelThreePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelThreePoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.endif
	
	
	mov cursorCol, 29
	mov cursorRow, 25
	mov dx, offset moveMsg3
	push dx
	mov dx, lengthof moveMsg3
	push dx
	call displayColorData
	
	
	
	mov ah, 01
	int 21h
	
	.while(al != 13)
		mov ah, 01
		int 21h
	.endw
	
	
	mov cursorRow, 8
	mov cursorRow, 29
	
	popA
	ret

displayEndPage endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;removeBombs;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

removeBombs proc; when initially (before game starts) candies are being crushed, bombs may generate. This procedure crushes them
	mov bx,offset gridStatus
	mov si,0
	.repeat
		mov dx,[bx+si]
		.if(dx==6); it is a color bomb
			getRandNum 1,5
			pop [bx+si] ;replace bomb with a arandom candy
		.endif
		add si,2
	.until(si==98) ;48*2 = 96, plus 2 for the last box

	ret
removeBombs endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;crushInitialCandies;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

crushInitialCandies proc ;this procedure crushes any combinations that ar formed initially before starting the game
	.repeat
	mov successfulCrush,0 ;if successfulCrush == 1 then CHECK FOR CRUSHING AGAIN. otherwise END CRUSHING
							;this is because after one crushing, when candies drop down, the situation can be such that more candies get crushed
	call removeBombs
	call dropCandies
	;call makeCandies
	;delay 1000
	call crushCandies
	.until(successfulCrush == 0)
	mov generateCandies,1 ;they have already been generated using the loop
	
	.if(isLevelOne == 1)
		mov levelOnePoints,0
	.elseif(isLevelTwo == 1)
		mov levelTwoPoints,0
	.else
		mov levelThreePoints,0
	.endif
	
	ret
crushInitialCandies endp	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;dropCandies;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
dropCandies proc ;if candies are crushed then new candies have to be dropped from above and the top candies should be replaced with random candies
	;this procedure will start from the last index of the gridStatus array and move backwards row-wise
	;As a result, whenever it will encounter '9' in a cell
	;It will start to move up and look for the nearest candy, if it exists, it will fall down to the vacant place(9)
	;If not, it will generate a new candy at that place
	pushA
	mov bx,offset gridStatus
	mov si,96 ;96 = (48*2) (word type array)
	.repeat
		.if(word ptr[bx+si] == 9) ;vacant cell detected
			push si
			mov candyBottomIndex,si
			.repeat
				.if(si < 14) ;this means that there is no vacant candy above the candy below
					jmp generateNewCandy
				.endif
				sub si,14 ;go one row above
				.if(word ptr[bx+si] == 0) ;this is for level 2 as there are zero index-ed boxes to keep empty
					jmp generateNewCandy
				.endif
			.until(word ptr[bx+si]!=9 && word ptr[bx+si] != 7) ;7 in case of level 3, dont drop the blockades
			;if a candy is found,then we have to swap them
			;currently si has the index of the candy found above the vacant cell
			;and on top of the stack, the vacant candy cell's index is also present so swapping is easy
			mov dx,[bx+si]
			mov tempCandyTop,dx ;now the candy num of the candy at the top is saved in tempCandyTop
			mov candyTopIndex,si		
			mov word ptr[bx+si],9 ;making the candy at the top's candy num '9' in gridStatus array
			
			;we also need to remove the candies from the GUI
			pushA
			mov cx,si
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA
			
			jmp dontGenerateNewCandy
			generateNewCandy:
				pop si
				getRandNum 1,5
				pop [bx+si] ;popping the returned random num(from stack) to [bx+si] position to generate a new candy
				jmp exitDroppingCandies
			dontGenerateNewCandy: ;swap the candies instead
				pop si
				mov dx,tempCandyTop
				mov [bx+si],dx
			exitDroppingCandies:
		.endif
		sub si,2
	.until(si == -2) ;0th index can also have a vacant cell
	popA
	ret
dropCandies endp	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;crushCandies;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

crushCandies proc
	;this procedure is called when candies are swapped, it looks for each row, one by one and each column one by one
	;and then crushes those candies 
	
	;in this procedure, tempCandyNo is the candy that is currently in the index[si] to keep track of repetition of candies
	;tempCandyCounter is to keep track of number of same candies that occur
	
	pushA
	
	;;;;;;;;;;;;;;;POPULATING ARRAYS FOR ROW WISE CRUSHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov crushingCandiesCountRow,0 ;initializing variable for counting size of Row Crushing Arrays
	mov cx,0
	mov bx,offset gridStatus
	mov si,0
	mov dx,[bx+si]
	mov tempCandyNo,dx ;initializing tempCandyNo with the first candy
	mov tempCandyCounter,0 ;initializing counter of candies to zero
	.while(cx!=49) ;48 indices of the array
		push cx
		mov dx,[bx+si] ;moving currentCandyNum to dx
		.if(tempCandyNo==dx) ;if previous candy == current candy
			inc tempCandyCounter ;increment the candy counter
		.else ;if previous candy != current candy
			mov tempCandyNo,dx ;temp candy = current candy
			mov tempCandyCounter,1 ;temp candy counter = 1
		.endif
		
		.if(tempCandyNo == 7) ;in level 3, blockades are candy Num 7
			mov tempCandyCounter,0
		.endif

		.if(tempCandyCounter == 3) ;if 3 candies are in row
			
			mov successfulCrush,1 ;now the outer function will know NOT to swap back the candies

			push bx
			push si ;saving registers
			mov si,crushingCandiesCountRow
			mov bx,offset endingCellNoRow
			mov [bx+si],cx ;mov cell No(cx) in the endingCellNoRow array
			sub cx,2 ;going back 2 cells
			mov bx,offset startingCellNoRow
			mov [bx+si],cx  ;mov (cell No(cx) - 2) in the startingCellNoRow Array
			add crushingCandiesCountRow,2 ;this counter variable is used as a multiple of 2(because arrays are of size word)
			pop si ;recovering registers
			pop bx
		.elseif(tempCandyCounter > 3) ;if there are more than 3 consecutive candies in a row
			push bx
			push si ;saving registers
			sub crushingCandiesCountRow,2 
			mov si,crushingCandiesCountRow ; moving to the previous index in the startingCellNo,endingCellNoRow ARRAYS
			mov bx,offset endingCellNoRow
			mov [bx+si],cx ;updating endingCellNoRow with the newer cell 
			add crushingCandiesCountRow,2 ;reBalancing counter variable (as 2 was deducted from it temporarily)
			pop si ;recovering values
			pop bx
		.endif
		pop cx
		inc cx
		add si,2 ;word size array
		.if(cx == 7 || cx == 14 || cx == 21 || cx == 28 || cx == 35 || cx == 42) ;if cx reaches the end of a row
			mov tempCandyCounter,0 ;initialize the counter with zero again
			mov dx,[bx+si] 
			mov tempCandyNo,dx ;move the new candy to tempCandyNo
		.endif
	.endw

	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;POPULATING ARRAY FOR COLUMN WISE CRUSHING;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov crushingCandiesCountCol,0
	mov cx,0
	mov bx,offset gridStatus
	mov si,0
	mov dx,[bx+si] 
	mov tempCandyNo,dx ;initializing tempCandyNo with the first candy
	mov tempCandyCounter,0 ;temp var to count candies that are coming in a single row/col
	.while(cx!=55) ;48 indices of the array +7 = 55(for the last box)
		push cx
		mov ax,cx
		multiply ax,2
		mov si,ax
		mov dx,[bx+si] ;moving currentCandyNum to dx
		.if(tempCandyNo==dx) ;if previous candy == current candy
			inc tempCandyCounter ;increment the candy counter
		.else ;if previous candy != current candy
			mov tempCandyNo,dx ;temp candy = current candy
			mov tempCandyCounter,1 ;temp candy counter = 1
		.endif
		
		.if(tempCandyNo == 7) ;in level 3, blockades are candy Num 7
			mov tempCandyCounter,0
		.endif
		
		.if(tempCandyCounter == 3) ;if 3 candies are in a single row
		
			mov successfulCrush,1 ;now the outer function will know NOT to swap back the candies

			push bx
			push si ;saving registers
			mov si,crushingCandiesCountCol 
			mov bx,offset endingCellNoCol
			mov [bx+si],cx ;mov cell No(cx) in the endingCellNoCol array
			sub cx,14  ; sub 14 because 7*2 = 14 for previous row
			mov bx,offset startingCellNoCol
			mov [bx+si],cx ;mov (cell No(cx) - 2) in the startingCellNoCol Array
			add crushingCandiesCountCol,2 ;this counter variable is used as a multiple of 2(because arrays are of size word)
			pop si ;recovering register
			pop bx
		.elseif(tempCandyCounter > 3)
			push bx
			push si ;saving registers
			sub crushingCandiesCountCol,2  ; moving to the previous index in the startingCellNo,endingCellNoCols ARRAYS
			mov si,crushingCandiesCountCol
			mov bx,offset endingCellNoCol
			mov [bx+si],cx ;updating endingCellNoRow with the newer cell 
			add crushingCandiesCountCol,2 ;reBalancing counter variable (as 2 was deducted from it temporarily)
			pop si ;recover registers
			pop bx
		.endif
		pop cx
		add cx,7
		.if(cx == 49 || cx == 50 || cx == 51 || cx == 52 || cx == 53 || cx == 54) ;if cx reaches the end of a column
			push cx
			mov tempCandyCounter,0 ;initialize the counter with zero again
			mov ax,cx
			multiply ax,2
			mov si,ax
			mov dx,[bx+si]
			mov tempCandyNo,dx  ;move the new candy to tempCandyNo
			pop cx
			sub cx,48 ;to move to the next column 
		.endif
	.endw


	;now we need to make those indices of the grid status array, '9',  so that candies can be dropped from above
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;CRUSHING ROW WISE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov cx,crushingCandiesCountRow ;moving size of rowCrushingArray to cx (as counter)
	.while(cx!=0)
		push cx
		sub cx,2 ;moving to previous index from the size
		mov si,cx
		mov bx,offset startingCellNoRow
		mov ax,[bx + si] ;moving starting cell number to ax
		mov bx,offset endingCellNoRow
		mov dx,[bx + si] ;moving ending cell number to dx
		mov bx,offset gridStatus
		
		push ax
		multiply ax,2
		mov si,ax;multiplying ax by 2 and saving in si because gridStatus is a word array and word size is x2 of byte
		pop ax
		
		add dx,1 ;increment dx once for the loop to run another time so that the last candy is crushed
		push cx
		mov cx,0
		.repeat
			push dx
			mov dx,word ptr[bx+si]
			mov tempCandyNoForScore,dx ;move candy num to temp variable so that score can be updated in accordance with it
			pop dx
			updateScore
			
			.if(cx==3) ;drop a color bomb in this position
				mov word ptr[bx+si],6;color bomb
			.else
				mov word ptr[bx+si],9;remove the candies
			.endif
			
			;we also need to remove the candies from the GUI
			pushA
			mov cx,si ;moving current index to cx
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA
				
			add si,2
			inc ax
			inc cx
		.until(ax == dx)
		pop cx
		pop cx
		sub cx,2 ; as crushingCandiesCountRow was being used as a counter of 2 so it will be decremented by 2
	.endw
	
	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;CRUSHING COLUMN WISE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov cx,crushingCandiesCountCol
	.while(cx!=0)
		push cx
		sub cx,2 ;moving to previous index from the size
		mov si,cx
		mov bx,offset startingCellNoCol
		mov ax,[bx + si] ;moving starting cell number to ax
		mov bx,offset endingCellNoCol
		mov dx,[bx + si] ;moving ending cell number to dx
		mov bx,offset gridStatus
		push ax
		multiply ax,2
		mov si,ax;multiplying ax by 2 and saving in si because gridStatus is a word array and word size is x2 of byte
		pop ax
		add dx,1 ;increment dx once for the loop to run another time so that the last candy is crushed
		push cx
		mov cx,0
		.repeat
			push dx
			mov dx,word ptr[bx+si]
			mov tempCandyNoForScore,dx ;move candy num to temp variable so that score can be updated in accordance with it
			pop dx
			updateScore
			.if(cx==3) ;drop a color bomb in this position
				mov word ptr[bx+si],6;color bomb
			.else
				mov word ptr[bx+si],9;remove the candies
				;we also need to remove the candies from the GUI
			.endif
			; we need to add si,(2*7) in this case
			pushA
			mov cx,si
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA

			add si,14 ; 14 = 2*7
			add ax,7
			inc cx
		.until(ax > dx)
		pop cx
		pop cx
		sub cx,2 ; as crushingCandiesCountCol was being used as a counter of 2 so it will be decremented by 2
	.endw
	
	popA
	ret
crushCandies endp


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;removeCandies;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

removeCandy proc ;gets passed a cell number to remove candies from using the stack
	;here [bp] can access that cell number i.e. the local variable
	pushA
	hideMouseCursor
	mov dx,word ptr[bp]
	mov tempCellNo,dx
	findCoordinatesOfCell tempCellNo
	;mov bp,sp
	;now [bp] can access x coordinates and [bp+2] can access y coordinates
	;now we need to make a black box at those coordinates 
	mov ax,word ptr[bp+2]
	;printNum ax
	add word ptr[bp],1
	add word ptr[bp+2],1
	mov cx,38 ;candies are within the grid size of 38*38 pixels
	.while(cx!=0)
		push cx
		mov dx, word ptr[bp]
		push dx
		mov cx,38
		.while(cx!=0)
			push cx
			mov ah,0ch
			mov al,00000000b ;put black color over candy to remove it
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			int 10h
			inc word ptr[bp]
			pop cx
			dec cx
		.endw
		pop dx
		mov word ptr[bp],dx
		pop cx
		dec cx
		inc word ptr[bp+2]
	.endw
	pop ax;destroying local variables from stack
	pop ax;destroying local variables from stack
	showMouseCursor
	popA
	ret 2;destroying local variable that was passed
removeCandy endp
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;explodeBomb;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;This procedure gets passed the candy num to explode through the stack with [bp] pointing to that local variable	
explodeBomb proc
	pushA
	mov bx,offset gridStatus
	mov si,0
	.repeat
		mov dx,[bx+si]
		.if(dx == word ptr[bp]) ;if currentCandy == the candy in [bp] (the candy that was swapped with the bomb)
			mov tempCandyNoForScore,dx
			updateScore
			
			mov word ptr[bx+si],9 ;remove candy
			
			;we also need to remove the candy from the GUI
			pushA
			mov cx,si
			divide cx,2 ;now the quotient is in AL register
			mov ah,0 ;making remainder zero
			push ax; pushing the cell no(si/2 = ax ) which is the cell number
			mov bp,sp
			call removeCandy
			popA		
			
		.endif
		add si,2
	.until(si == 98) ;48*2 = 96 ; plus 2 for last cell
	popA
	ret 2 ;destroying local variable of candyNum
explodeBomb endp	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;checkForSwapProc;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
checkForSwapProc proc
	;if checkForSwap variable is 1 then it first swaps candy numbers, then checks if the swap is possible
	;if the swap is not possible it simply deselects the candy initally selected(still being implemented)
	;if the swap is possible it then checks for crushing the combo
	;if the combo can be crushed, it crushes the combo
	;else the candies are reversed back
	;this function simply swaps the candyNum of the grid of the initial and final candies
	pushA
	.if(checkForSwap==1) 
		mov cx,0
		mov bx,offset gridStatus
		mov si,0
		.while(cx!=49)
			.if(cx==initCellNo) ;if cx comes accross the cell no that was selected initially
				push si ;saving si of initial cell number so that it can be used later by popping
				mov cx,[bx+si]
				mov tempCandyNoForSwapping,cx
				mov initCandyNum,cx ;saving initial candy num in initCandyNum
				mov si,0
				mov cx,0
				.while(cx!=49)
					.if(cx==finalCellNo) ;if cx comes accross final cell number
						areCellsAdjacent initCellNo,finalCellNo
						.if(ax==1)
							;If we are on level 2 and the player selected an empty area in the grid, then it is not a swap even if adjacent
							.if(isLevelTwo == 1 && (initCandyNum ==  0)) 
								pop si
								jmp candiesNotSwapped
							.endif
							.if(isLevelTwo == 1 && (finalCellNo ==  0 || finalCellNo == 3 || finalCellNo == 6 || finalCellNo == 7 || finalCellNo == 13 || finalCellNo == 21 || finalCellNo == 27 || finalCellNo == 35 || finalCellNo == 41 || finalCellNo == 42 || finalCellNo == 45 || finalCellNo == 48))
								pop si
								jmp candiesNotSwapped
							.endif
							;If we are on level 3 and the player selected a blockage, the it is not a swap and the blockage is not selected
							.if(isLevelThree == 1 && (initCandyNum == 7))
								pop si
								jmp candiesNotSwapped
							.endif
							.if(isLevelThree == 1 && (finalCellNo == 3 || finalCellNo == 10 || finalCellNo == 17 || finalCellNo == 24 || finalCellNo == 31 || finalCellNo == 38 || finalCellNo == 45 || finalCellNo == 21 || finalCellNo == 22 || finalCellNo == 23 || finalCellNo == 25 || finalCellNo == 26 || finalCellNo == 27))
								pop si
								jmp candiesNotSwapped
							.endif
							;continue
						.else
							;swapping not possible
							pop si
							jmp candiesNotSwapped
						.endif
						
						push finalCellNo ;making a local variable for final Cell number
						mov bp,sp ;now [bp] can access the local variable
						call removeCandy ;removing candies from those boxes
						
						push initCellNo ; making a local variable for initial cell number
						mov bp,sp ;now [bp] can access the local variable
						call removeCandy ;removing candies from those boxes
						
						mov dx,[bx+si]
						mov finalCandyNum,dx ;saving final candy num in finalCandyNum
						;now it's time to swap the candies
						mov tempFinalCandyNumIndexSI,si

						mov dx,initCandyNum
						mov [bx+si],dx
						pop si;getting initial candy number si value
						mov dx,finalCandyNum
						mov [bx+si],dx
						jmp candiesSuccessfullySwapped
					.endif
				add si,2
				inc cx
				.endw
				
			.endif
		add si,2
		inc cx
		.endw
		candiesSuccessfullySwapped:
			call makeGrid
			call makeCandies
			delay 900
			.if(initCandyNum == 6 || finalCandyNum == 6) ;one of them was a color bomb
				.if(initCandyNum == 6) ;initCandyNum is bomb
					mov bx,offset gridStatus
					mov ax,finalCellNo
					multiply ax,2
					mov si,ax
					mov word ptr[bx+si],9 ;removing bomb after it has been exploded
					
					push finalCellNo ;making a local variable for init Cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing COLOR BOMB from that cell
					
					push finalCandyNum
					mov bp,sp
					call explodeBomb
				.else ; finalCandyNum is bomb
					mov bx,offset gridStatus
					mov ax,initCellNo
					multiply ax,2
					mov si,ax
					mov word ptr[bx+si],9 ;removing bomb after it has been exploded

					push initCellNo ;making a local variable for final Cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing COLOR BOMB from that cell
				
					push initCandyNum
					mov bp,sp
					call explodeBomb
				.endif
				jmp bombExploded
			.endif
			mov successfulCrush,0 ;if successfulCrush == 1 then DONT swap back candies. otherwise swap them back as there was nothing to be crushed
			call crushCandies
			.if(successfulCrush==1)
				bombExploded: ;this label after exploding the bomb acts as a jumping place for the program to continue to
				;this label is only jumped to in case of bomb explosion. During crushing, it plays no role
				
				.repeat
					mov successfulCrush,0 ;if successfulCrush == 1 then CHECK FOR CRUSHING AGAIN. otherwise END CRUSHING
											;this is because after one crushing, when candies drop down, the situation can be such that more candies get crushed
					call dropCandies
					call makeCandies
					delay 1300
					call crushCandies
				.until(successfulCrush == 0)
				dec numMoves
				mov generateCandies,0 ;they have already been generated using the loop
			.else;swap back the candies
				.if(isLevelOne==1 || isLevelTwo==1)
					push finalCellNo ;making a local variable for final Cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing candies from those boxes
					
					push initCellNo ; making a local variable for initial cell number
					mov bp,sp ;now [bp] can access the local variable
					call removeCandy ;removing candies from those boxes
					
					;now it's time to swap BACK the candies
					mov dx,initCandyNum
					mov [bx+si],dx 
					;instead of 'pop si' :-
					mov si,tempFinalCandyNumIndexSI ;getting final candy number si value
					mov dx,finalCandyNum
					mov [bx+si],dx
					mov generateCandies,1
				.endif
			.endif
			mov successfulSwap,1 ;initializing helping variables again
			mov checkForSwap,0
			mov initCandyNum,0
			mov finalCandyNum,0
			mov initCellNo,100
			mov finalCellNo,100
			mov successfulCrush,0
			
			jmp exitSwappingChecks
		candiesNotSwapped:		
			mov successfulSwap,0 ;initializing helping variables again
			mov checkForSwap,0
			mov initCandyNum,0
			mov finalCandyNum,0
			mov initCellNo,100
			mov finalCellNo,100
			mov generateCandies,0
			
			jmp exitSwappingChecks
	.endif
	exitSwappingChecks:
	
	popA
	ret
checkForSwapProc endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;displayPlayerScore;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
displayPlayerScore proc

	;Whenever the score is updated, this function will be called so that the updated score can be displayed. Function is currently called in the infinite loop
	pushA
	;Displaying the name message of the score first
	mov dx, offset scoreMsg;Name Message 
	push dx
	mov dx, lengthof scoreMsg
	push dx
	mov cursorRow, 2
	mov cursorCol, 66
	call displayColorData
	
	;Dispalying the actual number of points of the player
	moveCursor 2, 74, pageNum
	;mov levelOnePoints, 60000 uncomment for debugging or demo
	
	.if(isLevelOne == 1)
		.if(levelOnePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelOnePoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelTwo == 1)
		.if(levelTwoPoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelTwoPoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.elseif(isLevelThree == 1)
		.if(levelThreePoints == 0)
			mov dx, '0'
			mov ah, 02
			int 21h
		.else
			mov dx, 0
			mov bx, 10
			mov ax, levelThreePoints
	
			.while(ax != 0)
				div bx
				push dx
				mov dx, 0
				inc scoreDisplayCount
			.endw
	
			.while(scoreDisplayCount != 0)
				pop dx
				add dx, 48
				mov ah, 02
				int 21h
				dec scoreDisplayCount
			.endw
		.endif
	.endif
	popA
	ret
	

displayPlayerScore endp
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;displayGameData;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
displayGameData proc
	
	;This prcodeucre displays data of the player while the game is running, this includes their name and exit message
	
	pushA 
	
	;Displaying the current level number based on the active level
	.if(isLevelOne == 1)
		mov dx, offset levelOneMsg
		push dx
		mov dx, lengthof levelOneMsg
		push dx
		mov cursorRow, 2
		mov cursorCol, 37
		call displayColorData
	.elseif(isLevelTwo == 1)
		mov dx, offset levelTwoMsg
		push dx
		mov dx, lengthof levelTwoMsg
		push dx
		mov cursorRow, 2
		mov cursorCol, 37
		call displayColorData
	.elseif(isLevelThree == 1)
		mov dx, offset levelThreeMsg
		push dx
		mov dx, lengthof levelThreeMsg
		push dx
		mov cursorRow, 2
		mov cursorCol, 37
		call displayColorData
	.endif
	
	;Displaying the name with color
	mov dx, offset nameTextMsg ;Name Message 
	push dx
	mov dx, lengthof nameTextMsg
	push dx
	mov cursorRow, 2
	mov cursorCol, 4
	call displayColorData
	
	moveCursor 2, 10, pageNum
	mov dx, offset userName ;Displaying the actual name
	mov ah, 09
	int 21h
	
	;Displaying the exit message
	mov dx, offset exitMsg ;Name Message 
	push dx
	mov dx, lengthof exitMsg
	push dx
	mov cursorRow, 29
	mov cursorCol, 31
	call displayColorData
	
	;Dispalying the text for the number of moves
	mov dx, offset movesMsg ;Name Message 
	push dx
	mov dx, lengthof movesMsg
	push dx
	mov cursorRow, 25
	mov cursorCol, 38
	call displayColorData
	
	
	;Displaying the number of moves
	;mov numMoves, 9 ;Uncomment for debugging or for demo
	
	.if(numMoves == 0)
		moveCursor 27, 40, pageNum
		mov dx, '0'
		mov ah, 02
		int 21h
	.elseif(numMoves <= 9)
	
		moveCursor 27, 39, pageNum
			
		mov dx, ' '
		mov ah, 02
		int 21h
			
		mov dx, numMoves
		add dx, 48
		mov ah, 02
		int 21h
			
	.else
		moveCursor 27, 39, pageNum
		mov dx, 0
		mov bx, 10
		mov ax, numMoves
	
		.while(ax != 0)
			div bx
			push dx
			mov dx, 0
			inc scoreDisplayCount
			mov dx, 0
		.endw
	
		.while(scoreDisplayCount != 0)
			pop dx
			add dx, 48
			mov ah, 02
			int 21h
			dec scoreDisplayCount
		.endw
		
	.endif
	
	
	popA
	ret

displayGameData endp	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;calculateCellNo;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;e.g arguments [bp]=180, [bp+2] = 140, [bp+4]=0000
calculateCellNo proc ;this function gets passed arguments through base pointer [bp] and it calculates the cell number(0-49) which is the location of the x and y coordinates that are passed
	pushA;storing registers
	;here [bp] contains x coordinate, [bp+2] contains y coordinate and [bp+4] contains the local variable to mov the cell number to
	
	;now the top left x coordinate is in [bp] 
	;to calculate the col number, it will first be subtracted by 180 then divided by 40
	sub word ptr[bp],180
	mov ax,word ptr[bp] ; dividend
	mov bl,40 ;divisor
	div bl
	mov ah,0 ;we dont need the remainder, just need the quotient. the remainder will always be zero
	mov word ptr[bp],ax ;saving the col number in [bp] now
	
	;now the top left y coordinate is in [bp+2] 
	;to calculate the row number, it will first be subtracted by 100 then divided by 40
	sub word ptr[bp+2],100
	mov ax,word ptr[bp+2] ; dividend
	mov bl,40 ;divisor
	div bl
	mov ah,0 ;we dont need the remainder, just need the quotient. the remainder will always be zero
	mov word ptr[bp+2],ax ;saving the row number in [bp+2] now
	
	;now the col no is in [bp] and row num is in [bp+2]
	;now formula: (rowNum*7)+colNum = cellNo 
	mov ax,word ptr[bp+2] ;row no is now in [bp+2]
	mov bx,7;according to formula
	mul bx
	;now the result is stored in DX:AX but the result will always be less than 16 bits so it will be stored in AX
	add ax,word ptr[bp] ; colNum is in [bp]
	mov word ptr[bp+4],ax ;[bp+4] is the local variable for cellNo
	
	popA ;restoring registers
	ret 4  ;destroying x and y coordinates from stack while keeping the local variable
calculateCellNo endp	

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;findCellNo;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;e.g arguments [bp]=180, [bp+2] = 140, [bp+4]=0000
findCellNo proc;finds the cell no that was selected by the user(first candy) and moves it to the selectedCellNo variable
	pop tempRtAddressfindCellNo ; saving the return address at the top of the stack and popping it along with it
	;now [bp] will be used for x coordinate and [bp+2] for y coordinate,[bp+4] for local variable
	pushA ;storing registers
	mov bx,offset gridXCords
	mov si,0
	mov cx,7
	.while(cx!=0)	 ;this loop finds the top left x coordinate of the box that was clicked
		mov dx,word ptr[bx+si]
		add dx,40
		.if (dx >= word ptr[bp]); - 40 )
			sub dx,40
			mov [bp],dx ;moving the new x coordinate to local variable for x coordinate
			jmp exitXCordFinder
		.endif
		add si,2
		dec cx
	.endw
	exitXCordFinder:
	
	mov bx,offset gridYCords
	mov si,0
	mov cx,7
	.while(cx!=0)	;this loop finds the top left y coordinate of the box that was clicked
		mov dx,word ptr[bx+si]
		add dx,40
		.if (dx >= word ptr[bp+2])
			sub dx,40
			mov [bp+2],dx ;moving the new y coordinatey to local variable for y coordinate
			jmp exitYCordFinder
		.endif
		add si,14 ;14 = 7*2 where 2 is size of a word and 7 a whole row
		dec cx
	.endw
	exitYCordFinder:
	popA ;restoring registers
	;now we have the x and y coordinates in [bp] and [bp+2] respectively
	call calculateCellNo ;calculateCellNo will calculate the cell no as [bp+4],[bp],[bp+2] still hold local variables of cellNo,x coordinate and y coordinate respectively
	push tempRtAddressfindCellNo ;pushing back the return address at the top of the stack 
	ret
findCellNo endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;checkForMouseInput;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

checkForMouseInput proc
	mov ax,01
	int 33h;display the mouse cursor
	
	mov ax,5
	mov bx,0
	int 33h;to check if LMB is being pressed or not
	.if isSelected==0
		mov checkForSwap,0
		.if(bx!=0);LMB pressed
			mov ax,5
			int 33h
			getBit ax,0 ;getting the last bit of ax as it is the one that contains LMB's current status
			;while LMB is kept pressed, this loop will keep running and only break when it is released
			.while(ax==1)
				mov cx,0
				mov isSelected,1
				mov ax,3 ;check for x and y coordinates of mouse
				int 33h
				mov mouseInitXCord,cx
				mov mouseInitYCord,dx
				push 0000 ;pushing a local variable into the stack which will be used for returning cell Number
				push dx
				push cx
				mov bp,sp
				call findCellNo ;now [bp] points to x coordinate and [bp+2] to y coordinate and [bp+4] points to the local variable
				pop initCellNo
				mov ax,initCellNo
				mov selectedCellNo,ax
				mov ax,5
				int 33h;to check if LMB is still pressed or not
				getBit ax,0 ;again getting last bit of ax to check LMB's status
				mov generateGrid,1
			.endw
		.endif
	.else ;isSelected=1
		.if(bx!=0);LMB pressed
			mov ax,5
			int 33h
			getBit ax,0 ;getting the last bit of ax as it is the one that contains LMB's current status
			;while LMB is kept pressed, this loop will keep running and only break when it is released
			.while(ax==1)
				mov checkForSwap,1 ;now the checkForSwap Procedure will check if swap is possible or not
				mov isSelected,0
				mov selectedCellNo,100
				mov ax,3
				int 33h
				mov mouseFinXCord,cx
				mov mouseFinYCord,dx
				push 0000 ;pushing a local variable into the stack which will be used for returning cell Number
				push dx
				push cx
				mov bp,sp ;now [bp] points to x coordinate and [bp+2] to y coordinate
				call findCellNo
				pop finalCellNo
				mov ax,5
				int 33h;to check if LMB is still pressed or not
				getBit ax,0 ;again getting last bit of ax to check LMB's status
				mov generateGrid,1
			.endw
		.endif

	.endif

	ret
checkForMouseInput endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;populateGridVars;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

populateGridVars proc ;populates the arrays having x and y coordinates of the grid along with the candies in the grid(initialize)
	mov bx,offset gridStatus
	mov si,0
	mov cx,0
	
	.if(isLevelOne == 1) ;Generating the array numbers for level 1
	
		.repeat
			getRandNum 1,5 ;get any random candy number
			pop word ptr[bx+si] ;popping candy number from stack
			add si,2
			inc cx
		.until(cx==49);array size 49
		
	.elseif(isLevelTwo == 1) ;If level 2 is active, then level 2 candy numbers will be generated, but based on the edited board
		.repeat
			.if(cx == 0 || cx == 3 || cx == 6 || cx == 7 || cx == 13 || cx == 21 || cx == 27 || cx == 35 || cx == 41 || cx == 42 ||  cx == 45 || cx == 48)
				mov word ptr[bx + si], 0
				add si, 2
				inc cx
			.else
				getRandNum 1,5 ;get any random candy number
				pop word ptr[bx+si] ;popping candy number from stack
				add si,2
				inc cx
			.endif
		.until(cx==49);array size 49
		
	.elseif(isLevelThree == 1)
		.repeat
			.if(cx == 3 || cx == 10 || cx == 17 || cx == 24 || cx == 31 || cx == 38 || cx == 45 || cx == 21 || cx == 22 || cx == 23 || cx == 25 || cx == 26 || cx == 27)
				mov word ptr[bx + si], 7
				add si, 2
				inc cx
			.else
				getRandNum 1,5 ;get any random candy number
				pop word ptr[bx+si] ;popping candy number from stack
				add si,2
				inc cx
			.endif
		.until(cx==49);array size 49
		
	.endif
	
	
	mov bx,offset gridXCords
	mov si,0
	mov cx,0
	push 180 ; 180 is the x coordinate from the left side of the screen to the first grid box
	mov bp,sp ; now we can access a local variable of x coordinates 180 using [bp]
	.repeat
		push cx
		mov cx,0
		mov word ptr[bp],180 ; 180 is the x coordinate from the left side of the screen to the first grid box
		.repeat
			mov dx,word ptr[bp]
			mov word ptr[bx+si],dx
			add word ptr[bp],40 ; incrementing 40 pixels for each grid square 
			add si,2
			inc cx
		.until(cx==7);2d array rows 7
		pop cx
		inc cx
	.until(cx==7);2d array cols 7
	pop ax;destroying local variable
	
	mov bx,offset gridYCords
	mov si,0
	mov cx,0
	push 100 ; 100 is the y coordinate from the top side of the screen to the first grid box
	mov bp,sp ; now we can access a local variable of y coordinates 100 using [bp]
	.repeat
		push cx
		mov cx,0
		;mov word ptr[bp],100 ; 100 is the y coordinate from the top side of the screen to the first grid box
		.repeat
			mov dx,word ptr[bp]
			mov word ptr[bx+si],dx
			add si,2
			inc cx
		.until(cx==7);2d array rows 7
		pop cx
		inc cx
		add word ptr[bp],40 ; incrementing 40 pixels for each grid square 
	.until(cx==7);2d array cols 7
	pop ax;destroying local variable
	ret 
populateGridVars endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;makeGrid;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

makeGrid proc; this procedure makes the grid
	pushA
	hideMouseCursor
	push 100 ;starting y coordinate
	push 180 ;starting x coordinate
	mov bp,sp
	;made 2 local variables in stack for making the grid
	;now [bp] can be used for accessing x, and [bp+2] for accessing y
	
	mov cx,8 ;need to make 8 horizontal and vertical lines
	horizontalLines: ;this label prints the horizontal lines of the grid
		push cx
		.repeat
			mov ah,0ch
			push cx
			mov al,00001111b ;first 4 bits useless,
			pop cx
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			
			pushA
			.if (isSelected==1) ;a cell is already selected
				findCoordinatesOfCell selectedCellNo ;this macro will return 1 in ax if the cx,dx coordinates lie within the range of the selected cell
				mov bp,sp ;;now [bp] can access x coordinate and [bp+2] can access y coordinate of selected Cell
				isCellInRange word ptr[bp],word ptr[bp+2],cx,dx
				.if(ax==1)
					pop ax
					pop ax;destroying local variables from stack
					popA
					;do nothing
					;means do not print the pixel
				.else
					pop ax
					pop ax;destroying local variables from stack
					;Deciding which type of grid to display based on the level, for level 2 an adjusted grid is used (this is after selection display)
					.if(isLevelOne == 1 || isLevelThree == 1)
						popA
						int 10h
					.elseif(isLevelTwo == 1 && ((cx <= 220 && dx == 140) || (cx <= 220 && dx == 340) || (cx >= 420 && dx == 140) || (cx >= 420 && dx == 340) || (cx >= 420 && dx == 380) || (cx <= 220 && dx == 380) || (cx <= 220 && dx == 100) || (cx >= 420 && dx == 100)))
						popA
					.elseif(isLevelTwo == 1 && ((cx >= 300 && cx <= 340 && dx == 100) || (cx >= 300 && cx <= 340 && dx == 380)))
						popA
					.else
						popA
						int 10h
					.endif
				.endif
			.else
				;Deciding which type of grid to display based on the level, for level 2 an adjusted grid is used
				.if(isLevelOne == 1 || isLevelThree == 1)
					popA
					int 10h
				.elseif(isLevelTwo == 1 && ((cx <= 220 && dx == 140) || (cx <= 220 && dx == 340) || (cx >= 420 && dx == 140) || (cx >= 420 && dx == 340) || (cx >= 420 && dx == 380) || (cx <= 220 && dx == 380) || (cx <= 220 && dx == 100) || (cx >= 420 && dx == 100)))
					popA
				.elseif(isLevelTwo == 1 && ((cx >= 300 && cx <= 340 && dx == 100) || (cx >= 300 && cx <= 340 && dx == 380)))
					popA
				.else
					popA
					int 10h
				.endif
			.endif
			;the above conditions only print a box when it is not selected i.e. selected box do not get printed with white lines
			
			inc word ptr[bp]
			mov ax,[bp]
		.until ax==460
		pop cx
		mov word ptr[bp],180
		add word ptr[bp+2],40
		dec cx
		jnz horizontalLines
		;loop horizontalLines
	mov cx,8
	mov word ptr[bp],180 ;starting x coordinate
	mov word ptr[bp+2],100 ;starting y coordinate
	verticalLine: ;this label prints the vertical lines of the gridpush cx
		push cx
		.repeat
			mov ah,0ch
			mov al,00001111b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			
			pushA
			.if (isSelected==1) ;a cell is already selected
				findCoordinatesOfCell selectedCellNo ;this macro will return 1 in ax if the cx,dx coordinates lie within the range of the selected cell
				mov bp,sp ;;now [bp] can access x coordinate and [bp+2] can access y coordinate of selected Cell
				isCellInRange word ptr[bp],word ptr[bp+2],cx,dx
				.if(ax==1)
					pop ax
					pop ax;destroying local variables from stack
					popA
					;do nothing
					;means do not print the pixel
				.else
					pop ax
					pop ax;destroying local variables from stack
					;Adjusting the grid according to the current level, level 2 needs a modified grid while grid lines are unchanged for level 1 and 3
					.if(isLevelOne == 1 || isLevelThree == 1)
						popA
						int 10h
					.elseif(isLevelTwo == 1 && (dx >= 220 && dx <= 260 && cx == 180) || (dx >= 220 && dx <= 260 && cx == 460) || (dx >= 100 && dx <= 180 && (cx == 460 || cx == 180) || (dx >= 300 && (cx == 460 || cx == 180))))
						popA
					.else
						popA
						int 10h
					.endif
				.endif
			.else
				;Adjusting the grid according to the current level, level 2 needs a modified grid while grid lines are unchanged for level 1 and 3
				.if(isLevelOne == 1 || isLevelThree == 1)
					popA
					int 10h
				.elseif(isLevelTwo == 1 && (dx >= 220 && dx <= 260 && cx == 180) || (dx >= 220 && dx <= 260 && cx == 460) || (dx >= 100 && dx <= 180 && (cx == 460 || cx == 180) || (dx >= 300 && (cx == 460 || cx == 180))))
					popA
				.else
					popA
					int 10h
				.endif
			.endif
			;the above conditions only print a box when it is not selected i.e. selected box do not get printed with white lines
			
			inc word ptr[bp+2]
			mov ax,[bp+2]
		.until ax==380
		pop cx
		add word ptr[bp],40
		mov word ptr[bp+2],100
		dec cx
		jnz verticalLine
		;loop verticalLine
	pop ax;removing local variables from stack
	pop ax
	mov ax,0
	;now we have to make a selected highlighting box for the selected candy so that user knows that it is selected
	.if (isSelected==1)
		
		.if(isLevelTwo == 1 && (selectedCellNo == 0 || selectedCellNo == 3 || selectedCellNo == 6 || selectedCellNo == 7 || selectedCellNo == 13 || selectedCellNo == 21 || selectedCellNo == 27 || selectedCellNo == 35 || selectedCellNo == 41 || selectedCellNo == 42 || selectedCellNo == 45 || selectedCellNo == 48))
			jmp cannotSelectCell ;the selected cell did not exist was was empty based on the level
		.elseif(isLevelThree == 1 && (selectedCellNo == 3 || selectedCellNo == 10 || selectedCellNo == 17 || selectedCellNo == 24 || selectedCellNo == 31 || selectedCellNo == 38 || selectedCellNo == 45 || selectedCellNo == 21 || selectedCellNo == 22 || selectedCellNo == 23 || selectedCellNo == 25 || selectedCellNo == 26 || selectedCellNo == 27))
			jmp cannotSelectCell ;the selected cell was part of the a filled cell/blockage 
		.endif
		
		findCoordinatesOfCell selectedCellNo ;this function will return x and y coordinates stored in the stack
		mov bp,sp ;now [bp] can access x coordinate and [bp+2] can access y coordinate
		;now we have to make a square along it's edges
		;add word ptr[bp],180
		;add word ptr[bp+2],100
		mov cx,40
		horizontalSelectedLines:
			push cx
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			int 10h
			inc word ptr[bp]
			
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			add dx,40
			int 10h
			pop cx
			loop horizontalSelectedLines
		mov cx,40
		sub word ptr[bp],40
		verticalSelectedLines:
			push cx
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			int 10h
			inc word ptr[bp+2]
			
			mov ah,0ch
			mov al,00001010b ;first 4 bits useless,
			mov bh,0 ;page 1
			mov cx,[bp]
			mov dx,[bp+2]
			add cx,40
			int 10h
			pop cx
			loop verticalSelectedLines
		
		pop ax;removing local variables from stack
		pop ax
		
	.endif	
	
	cannotSelectCell:
	mov generateGrid,0
	showMouseCursor
	popA
	ret
makeGrid endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;makeCandies;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

makeCandies proc
	;push 1
	;push 100
	;push 180
	;mov bp,sp
	;call makeCandy
	pushA
	hideMouseCursor
	mov si,0
	mov cx,0
	.repeat
		pushA
		;push cx
		;mov bp,sp
		;call removeCandy
		
		mov bx,offset gridStatus
		push word ptr[bx+si];pushing the gridStatus i.e. the candy number that is in the grid
		mov bx,offset gridYCords
		push word ptr[bx+si];pushing the grid box's Y coordinate in the grid
		mov bx,offset gridXCords
		push word ptr[bx+si];pushing the grid box's X coordinate in the grid
		mov bp,sp
		call makeCandy
		popA
		add si,2
		inc cx
	.until(cx==49)
	mov generateCandies,0
	showMouseCursor
	popA
	ret
makeCandies endp

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;makeCandy;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

makeCandy proc
	;here [bp] contains x coordinate, [bp+2] contains y, coordinate, [bp+4] contains the candy number
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	.if word ptr[bp+4]==1 ; if candyNum==1 -> draw green box
	add word ptr[bp],9
	add word ptr[bp+2],9
	mov cx,23 ;green box width 20
	greenBoxLabel1:
		push cx
		mov cx,23 ; green box height 20
		mov dx,[bp]
		push dx
		greenBoxLabel2:
			push cx
			mov ah,0ch
			mov al,00001010b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
			mov bh,0 ;page 0
			mov cx,[bp] ; x cordinate
			mov dx,[bp+2] ; y cordinate
			int 10h
			inc word ptr[bp]
			pop cx
			loop greenBoxLabel2
		pop dx
		mov [bp],dx
		pop cx
		inc word ptr[bp+2]
		loop greenBoxLabel1
	.elseif word ptr[bp+4]==2 ; cyan diamond
		mov cx,13
		add word ptr[bp],20
		add word ptr[bp+2],7
		mov si,1
		cyanDiamondLabel1: ; this label makes the right triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the increasing right triangle
				push cx
				mov ah,0ch
				mov al,00001011b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			mov cx,si
			.repeat ;this loop makes the increasing left triangle
				push cx
				mov ah,0ch
				mov al,00001011b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				dec word ptr[bp]
				pop cx
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			inc si
			pop cx
			inc word ptr[bp+2]
			loop cyanDiamondLabel1
			
			
		mov cx,13
		cyanDiamondLabel2:  ;this label makes the left triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the decreasing right triangle
				push cx
				mov ah,0ch
				mov al,00001011b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			mov cx,si
			.repeat ;this loop makes the decreasing left triangle
				push cx
				mov ah,0ch
				mov al,00001011b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				dec word ptr[bp]
				pop cx
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			dec si
			pop cx
			inc word ptr[bp+2]
			loop cyanDiamondLabel2
	.elseif word ptr[bp+4]==3 ; magenta triangle
		mov cx,12
		add word ptr[bp],8
		add word ptr[bp+2],8
		mov si,1
		triangleLabel1: ; this label makes the right triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the increasing right triangle
				push cx
				mov ah,0ch
				mov al,00001101b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				mov cx,[bp] ; x cordinate
				inc word ptr[bp]
				int 10h
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			inc si
			pop cx
			inc word ptr[bp+2]
			loop triangleLabel1
		mov cx,12
		triangleLabel2:  ;this label makes the left triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the decreasing right triangle
				push cx
				mov ah,0ch
				mov al,00001101b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				mov cx,[bp] ; x cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			dec si
			pop cx
			inc word ptr[bp+2]
			loop triangleLabel2	
	.elseif word ptr[bp+4]==4 ;toffee
		mov cx,13
		add word ptr[bp],20
		add word ptr[bp+2],7
		mov si,1
		toffeeLabel1: ; this label makes the right triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			sub word ptr[bp],13
			.repeat ;this loop makes the increasing right triangle
				push cx
				mov ah,0ch
				mov al,00001100b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			add word ptr[bp],13
			mov cx,si
			.repeat ;this loop makes the increasing left triangle
				push cx
				mov ah,0ch
				mov al,00001100b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				dec word ptr[bp]
				pop cx
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			inc si
			pop cx
			inc word ptr[bp+2]
			loop toffeeLabel1
			
			
		mov cx,13
		toffeeLabel2:  ;this label makes the left triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			sub word ptr[bp],13
			.repeat ;this loop makes the decreasing right triangle
				push cx
				mov ah,0ch
				mov al,00001100b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			add word ptr[bp],13
			mov cx,si
			.repeat ;this loop makes the decreasing left triangle
				push cx
				mov ah,0ch
				mov al,00001100b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				dec word ptr[bp]
				pop cx
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			dec si
			pop cx
			inc word ptr[bp+2]
			loop toffeeLabel2
			
	.elseif word ptr[bp+4]==5 ; if candyNum==5 -> draw hexa candy
		mov cx,13
		add word ptr[bp],20
		add word ptr[bp+2],7
		mov si,15
		yellowHexaLabel1: ; this label makes the right triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the increasing right triangle
				push cx
				mov ah,0ch
				mov al,00001110b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				pop cx
				isEven cx
				pop tempForHexaCandy
				.if(tempForHexaCandy==0)
					inc word ptr[bp]
				.else
				.endif
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			mov cx,si
			.repeat ;this loop makes the increasing left triangle
				push cx
				mov ah,0ch
				mov al,00001110b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				;dec word ptr[bp]
				pop cx
				isEven cx
				pop tempForHexaCandy
				.if(tempForHexaCandy==0)
					dec word ptr[bp]
				.else
				.endif
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			inc si
			pop cx
			inc word ptr[bp+2]
			;loop yellowHexaLabel1
			dec cx
			jne yellowHexaLabel1
			
		mov cx,13
		yellowHexaLabel2:  ;this label makes the left triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the decreasing right triangle
				push cx
				mov ah,0ch
				mov al,00001110b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				;inc word ptr[bp]
				pop cx
				isEven cx
				pop tempForHexaCandy
				.if(tempForHexaCandy==0)
					inc word ptr[bp]
				.else
				.endif
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			mov cx,si
			.repeat ;this loop makes the decreasing left triangle
				push cx
				mov ah,0ch
				mov al,00001110b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				;dec word ptr[bp]
				pop cx
				isEven cx
				pop tempForHexaCandy
				.if(tempForHexaCandy==0)
					dec word ptr[bp]
				.else
				.endif
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			dec si
			pop cx
			inc word ptr[bp+2]
			;loop yellowHexaLabel2
			dec cx
			jne yellowHexaLabel2
	.elseif word ptr[bp+4]==6 ;color bomb
		mov dx,word ptr[bp]
		push dx
		mov dx,word ptr[bp+2]
		push dx
		add word ptr[bp],9 ;11
		add word ptr[bp+2],8 ;11
		mov cx,24 ;19
		greenBoxColorBombLabel1:
			push cx
			mov cx,24 ; 19
			mov dx,[bp]
			push dx
			greenBoxColorBombLabel2:
				push cx
				mov ah,0ch
				mov al,00001110b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				;try 10001010b
				mov bh,0 ;page 0
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				loop greenBoxColorBombLabel2
			pop dx
			mov [bp],dx
			pop cx
			inc word ptr[bp+2]
			loop greenBoxColorBombLabel1
			
		pop dx
		mov word ptr[bp+2],dx
		pop dx
		mov word ptr[bp],dx
		mov cx,17
		add word ptr[bp],20
		add word ptr[bp+2],3
		mov si,1
		diamondColorBombLabel1: ; this label makes the right triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the increasing right triangle
				push cx
				mov ah,0ch
				mov al,00001011b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			mov cx,si
			.repeat ;this loop makes the increasing left triangle
				push cx
				mov ah,0ch
				mov al,00001101b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				dec word ptr[bp]
				pop cx
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			inc si
			pop cx
			inc word ptr[bp+2]
			loop diamondColorBombLabel1
			
			
			mov cx,17
		diamondColorBombLabel2:  ;this label makes the left triangle
			push cx
			mov cx,si
			mov dx,word ptr[bp]
			push dx
			.repeat ;this loop makes the decreasing right triangle
				push cx
				mov ah,0ch
				mov al,00001100b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				inc word ptr[bp]
				pop cx
				dec cx
			.until cx==0
			pop dx
			mov word ptr[bp],dx
			push dx
			mov cx,si
			.repeat ;this loop makes the decreasing left triangle
				push cx
				mov ah,0ch
				mov al,00001010b ;light green candy. idk why but here the colors were working opposite. e.g 0010 was not green but 1010 was green
				mov bh,0 ;page 0	
				mov cx,[bp] ; x cordinate
				mov dx,[bp+2] ; y cordinate
				int 10h
				dec word ptr[bp]
				pop cx
				dec cx
			.until (cx==0)
			pop dx
			mov word ptr[bp],dx
			dec si
			pop cx
			inc word ptr[bp+2]
			loop diamondColorBombLabel2
	.elseif (word ptr[bp+4]==7)
			
			mov cx, word ptr [bp] 
			add cx, 5 ;Staring position for the main center line on x-axis
			
			mov dx, [bp+2] 
			add dx, 33 ;Starting position for the main center line on the y-axis
			
			mov bx, word ptr[bp]
			add bx, 35 ;Ending position for the x-axis
			
			mov ax, 03
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;CENTRAL LINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			;This loop makes the first line central line for the bloackage
			.while(ax != 0)
				push ax
				;add dx, 2
				add cx, 1
				push cx
				.while(cx < bx)
					push bx
					mov ah, 0Ch
					mov al, 00000011b ;This is the chosen color for the center line
					mov bh, 0
					int 10h
					inc cx
					dec dx
					pop bx
				.endw
				
				mov dx, [bp+2]
				add dx, 33
				pop cx
				
				pop ax
				dec ax
			.endw
			
			
			
			;;;;;;;;;;;;;;;;;;;;;LOWER LINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			mov cx, word ptr [bp] 
			add cx, 20 ;Staring position for the lower center line on x-axis
			
			mov dx, [bp+2] 
			add dx, 33 ;Starting position for the lower center line on the y-axis
			
			mov bx, word ptr[bp]
			add bx, 35 ;Ending position for the x-axis
			
			mov ax, 03
			
			;This loop makes the lower central line for the blockage, outer loop controls thickness, inner loop draws the line
			.while(ax != 0)
				push ax
				;add dx, 2
				add cx, 1
				push cx
				.while(cx < bx)
					push bx
					mov ah, 0Ch
					mov al, 00000011b
					mov bh, 0
					int 10h
					inc cx
					dec dx
					pop bx
				.endw
				
				mov dx, [bp+2]
				add dx, 33
				pop cx
				
				pop ax
				dec ax
			.endw
			
			
			
			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;UPPER LINE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
			mov cx, word ptr [bp] 
			add cx, 5 ;Staring position for the upper line on x-axis
			
			mov dx, [bp+2] 
			add dx, 19 ;Starting position for the upper line on the y-axis
			
			mov bx, word ptr[bp]
			add bx, 21 ;Ending position for the x-axis
			
			mov ax, 03
			
			;This loop makes the upper line for the blockage, outer loop controlc thickness, inner loop draws the line
			.while(ax != 0)
				push ax
				;add dx, 2
				add cx, 1
				push cx
				.while(cx < bx)
					push bx
					mov ah, 0Ch
					mov al, 00000011b
					mov bh, 0
					int 10h
					inc cx
					dec dx
					pop bx
				.endw
				
				mov dx, [bp+2]
				add dx, 19
				pop cx
				
				pop ax
				dec ax
			.endw
			
	.endif
	ret 6 ;destroying candy number, x and y coordinate from stack
makeCandy endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;PROCEDURES FOR DISPLAYING INITIAL PAGE;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;displayInitialPromptsInputs PROC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


displayRules proc

	pushA
	
	;Displaying the title
	mov dx, offset ruleMsg
	push dx
	mov dx, lengthof ruleMsg
	push dx
	mov cursorRow, 3
	mov cursorCol, 38
	call displayColorData
	
	;Displaying the rules
	mov dx, offset rule1
	push dx
	mov dx, lengthof rule1
	push dx
	mov cursorRow, 7
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset rule2
	push dx
	mov dx, lengthof rule2
	push dx
	mov cursorRow, 9
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset rule3
	push dx
	mov dx, lengthof rule3
	push dx
	mov cursorRow, 11
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset rule3_1
	push dx
	mov dx, lengthof rule3_1
	push dx
	mov cursorRow, 12
	mov cursorCol, 11
	call displayColorData
	
	mov dx, offset rule3_2
	push dx
	mov dx, lengthof rule3_2
	push dx
	mov cursorRow, 13
	mov cursorCol, 11
	call displayColorData
	
	mov dx, offset rule4
	push dx
	mov dx, lengthof rule4
	push dx
	mov cursorRow, 15
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset rule5
	push dx
	mov dx, lengthof rule5
	push dx
	mov cursorRow, 17
	mov cursorCol, 8
	call displayColorData
	
	mov dx, offset rule5_1
	push dx
	mov dx, lengthof rule5_1
	push dx
	mov cursorRow, 18
	mov cursorCol, 11
	call displayColorData
	
	mov dx, offset rule5_2
	push dx
	mov dx, lengthof rule5_2
	push dx
	mov cursorRow, 19
	mov cursorCol, 11
	call displayColorData
	
	;END OF DISPLAYING THE RULES
	
	mov dx, offset goodLuck
	push dx
	mov dx, lengthof goodLuck
	push dx
	mov cursorRow, 22
	mov cursorCol, 33
	call displayColorData
	
	mov dx, offset continueMsg
	push dx
	mov dx, lengthof continueMsg
	push dx
	mov cursorRow, 26
	mov cursorCol, 27
	call displayColorData
	
	
	
	moveCursor 100, 100, pageNum
	;Checking for input
	mov ax, 0
	.while(al != 13)
	mov ah, 01
	int 21h
	.endw
	
	
	popA
	ret

displayRules endp



	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;displayInitialPromptsInputs PROC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

displayInitialPromptsInputs proc

	pushA

	;Displaying the welcome message
	mov dx, offset WelcomeMsg1
	push dx
	mov dx, lengthof welcomeMsg1
	push dx
	call displayColorData
	
	;User Input starts here, displaying the first part of the name prompt
	add cursorRow, 5
	sub cursorCol, 5
	mov dx, offset nameMsg
	push dx
	mov dx, lengthof nameMsg
	push dx
	call displayColorData
	
	add cursorRow, 1 ;Displaying second part of the name prompt
	add cursorCol, 11
	mov dx, offset nameMsg2
	push dx
	mov dx, lengthof nameMsg2
	push dx
	call displayColorData
	
	
	add cursorRow, 5
	moveCursor cursorRow, cursorCol, pageNum
	
	;Taking the actual input from the user
	mov ch, 0
	mov cl, 7
	mov ah, 01
	int 10h
	
	mov si, offset userName ;will store the name of the player
	input:
		mov ah, 01
		int 21h
		mov [si], al
		inc si
		cmp al, 13
		jne input
		mov al, '$'
		mov [si], al
	
	popA
	ret

displayInitialPromptsInputs endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;DisplayColorData PROC;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

displayColorData proc
	mov bp, sp
	pushA
	mov dx, [bp+2] ;Stores the length of the data
	mov si, [bp +4]
	
	
	mov cx, dx
	dec cx
	
	mov bp, si
	mov ah,13h 		; function 13 - write string
	mov al,01h 		; attrib in bl,move cursor
	mov bh, pageNum	
	mov bl,9	; attribute - magenta
	mov dh,cursorRow		; row to put string
	mov dl, cursorCol 		; column to put string
	int 10h
	
	popA
	ret 4
displayColorData endp
end main