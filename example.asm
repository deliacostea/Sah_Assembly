.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0

culoare_proc DD 0
counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
 arg3 EQU 16
arg4 EQU 20

symbol_width EQU 10
symbol_height EQU 20
piesa_width EQU 47
piesa_height EQU 48
include digits.inc
include letters.inc
include piesa.inc
tabla_x equ 155
tabla_y equ 90
tabla_size equ 320
t dd 195
mutari dd -4,-3,-2,-6,-5,-2,-3,-4
dd -1,-1,-1,-1,-1,-1,-1,-1
dd 0,0,0,0,0,0,0,0
dd 0,0,0,0,0,0,0,0
dd 0,0,0,0,0,0,0,0
dd 0,0,0,0,0,0,0,0
dd 1,1,1,1,1,1,1,1
dd 4,3,2,6,5,2,3,4

col dd 0
lin dd 0
piesutz dd 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0E0DBD2h
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp


make_piese proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	lea esi, piesa
	
	mov ebx, 39
	mul ebx
	mov ebx, 40
	mul ebx
	add esi, eax
	mov ecx, 40
bucla_sim_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, 40
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, 39
bucla_sim_coloane:
	cmp byte ptr [esi], 0
	je sim_pixel_alb
	mov ebx, dword ptr [ebp+24]
	cmp ebx, 0
	jne ioi
	mov dword ptr [edi], 0
	jmp ioi1
	ioi:
	mov dword ptr [edi], 0FFFFFFh
	ioi1:
	jmp sim_pixel_next
sim_pixel_alb:

	cmp dword ptr [edi],0F0D2A2h
	jne askdgi
	mov dword ptr [edi], 0F0D2A2h
	
	askdgi:
	
sim_pixel_next:
	inc esi
	add edi, 4
	loop bucla_sim_coloane
	pop ecx
	loop bucla_sim_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_piese endp

make_piese_macro macro symbol1, drawArea1, x1, y1, jucator
	
	push jucator
	push y1
	push x1
	push drawArea1
	push symbol1
	call make_piese
	add esp, 20
endm


; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm
;pt linia orizontala
orizontal macro x,y,len,color
	local bucla
mov eax,y
mov ebx,area_width
mul ebx
add eax,x
shl eax,2
add eax,area
mov ecx,len
bucla:
mov dword ptr[eax],color
add eax,4
loop bucla
endm

vertical macro x,y,len,color
	local bucla
mov eax,y
mov ebx,area_width
mul ebx
add eax,x
shl eax,2
add eax,area
mov ecx,len
bucla:
mov dword ptr[eax],color
add eax,area_width*4
loop bucla
endm


culoare macro x,y
local et1,final
mov ebx,y+1
et1:
cmp ebx,y+39
jg final
push ebx
orizontal x+1,ebx,39,0F0D2A2h
pop ebx
inc ebx
jmp et1
final:
endm


culoare2 macro x,y
local et1,final
mov ebx,y+1
et1:
cmp ebx,y+39
jg final
push ebx
orizontal x+1,ebx,39,0A18353h
pop ebx
inc ebx
jmp et1
final:
endm

cul3 macro x,y
local et1,final
mov ebx,y+2
et1:
cmp ebx,y+30
jg final
push ebx
orizontal 126,ebx,379,0E0DBD2h
pop ebx
inc ebx
jmp et1
final:
endm

cul4 macro x,y
local et1,final
mov ebx,y
et1:
cmp ebx,y+320
jg final
push ebx
orizontal 126,ebx,380,0E0DBD2h
pop ebx
inc ebx
jmp et1
final:
endm



cautare_piesa macro a,b
pusha; a coloana, b linie
mov eax,b
shl eax,3
add eax,a
shl eax,2
mov ebx, dword ptr mutari[eax]

mov piesutz,ebx

popa
endm


mutare_piese macro piesa_joc,a,b
local final,next,pion,cal,turn,nebun,rege,regina
pusha
mov edx,0
cmp piesa_joc,0
je final
cmp piesa_joc,0
jg next
mov eax,piesa_joc
mov ebx,-1
;mov edx,0
mul ebx
mov piesa_joc,eax
mov edx,1
next:
cmp piesa_joc,1
je pion

; cmp piesa_joc,2
 ;je cal
; cmp piesa_joc,3
; je turn
; cmp piesa_joc,4
; je nebun
; cmp piesa_joc,5
; je rege
; cmp piesa_joc,6
; je regina
jmp final
pion:
mov eax,b
shl eax,3
add eax,a
shl eax,2
;mov ebx, dword ptr mutari[eax]
mov dword ptr mutari[eax],0
sub eax,32
mov dword ptr mutari[eax],1

final:
popa
endm

calcul_coordonate proc ; calculez coordonatele 
	push ebp
	mov ebp, esp
	push edi

	
	mov edi, 40
	mov eax, [arg2 + ebp]
	mul edi
	add eax,156
	mov esi, eax
	
	mov eax, [arg1 + ebp]
	mul edi
	add eax,91
	
	pop edi
	mov esp, ebp
	pop ebp
	ret
calcul_coordonate endp
	
afisare_piese proc ; afisez piesele
	
	push ebp
	mov ebp, esp
	pusha
	
	mov ecx, [ebp + arg1] ;valoare matrice
	mov esi, [ebp + arg2] ;x
	mov eax, [ebp + arg3] ;y
	
	cmp ecx,0
	
	jl negru123
	dec ecx
	
	make_piese_macro ecx, area,  esi, eax, 0
	jmp et123 
	negru123:
	
	push eax
	

	mov eax, ecx
	mov ebx,-1
	mov edx,0
	mul ebx
	mov ecx,eax
	pop eax
	dec ecx
	
	make_piese_macro ecx, area,  esi, eax, 1
	et123:
	
	popa
	mov esp, ebp
	pop ebp
	ret
afisare_piese endp
	
desenare_matrice proc
	push ebp
	mov ebp, esp
	pusha
	; mutari , 
	
	mov ebx, [ebp + arg1]
	
	mov esi, 0
	mov edi, 0
	
	lop1:
	mov edi,0
	lop2:
	
	mov eax,esi
	shl eax,3
	add eax,edi
	shl eax,2
	
	mov ecx, [ebx + eax]
	
	cmp ecx,0
	je final13
	
	
	push esi
	push edi
	push esi
	call calcul_coordonate
	add esp, 8
	
	push eax
	push esi
	push ecx
	call afisare_piese
	add esp, 12
	
	pop esi
	final13:
	inc edi
	cmp edi,8
	jne lop2
	
	inc esi
	
	cmp esi,8
	jne lop1
	
	
	
	
	
	popa
	mov esp, ebp
	pop ebp
	ret
desenare_matrice endp

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 144
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	
mov eax,[arg2+ebp]
cmp eax,155
jb afisare_litere
cmp eax,475
ja afisare_litere

sub eax,155
mov ebx,40
mov edx,0
div ebx
mov col,eax
;mul ebx
;add eax,156

mov eax,[arg3+ebp]
cmp eax,90
jb afisare_litere
cmp eax,410
ja afisare_litere
sub eax,90
mov ebx,40
mov edx,0
div ebx
mov lin,eax
;mul ebx
;add eax,91
;mutare_piese piesutz,[arg2+ebp],[arg3+ebp]	
	jmp afisare_litere
	
evt_timer:
	inc counter
	
afisare_litere:

	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	cul3 tabla_x,tabla_y-31
cul3 tabla_x+tabla_size,tabla_y+tabla_size-1
cul4 tabla_x,tabla_y
	;scriem un mesaj
	 make_text_macro 'A', area, 170, 65
	 make_text_macro 'B', area, 210, 65
	 make_text_macro 'C', area, 250, 65
	 make_text_macro 'D', area, 290, 65
     make_text_macro 'E', area, 330, 65
	 make_text_macro 'F', area, 370, 65
     make_text_macro 'G', area, 410, 65
	 make_text_macro 'H', area, 450, 65
	 
	 make_text_macro 'A', area, 170, 415
	 make_text_macro 'B', area, 210, 415
	 make_text_macro 'C', area, 250, 415
	 make_text_macro 'D', area, 290, 415
     make_text_macro 'E', area, 330, 415
	 make_text_macro 'F', area, 370, 415
     make_text_macro 'G', area, 410, 415
	 make_text_macro 'H', area, 450, 415

	 make_text_macro '8', area, 140, 100
	 make_text_macro '7', area, 140, 140
	 make_text_macro '6', area, 140, 180
	 make_text_macro '5', area, 140, 220
     make_text_macro '4', area, 140, 260
	 make_text_macro '3', area, 140, 300
     make_text_macro '2', area, 140, 340
	 make_text_macro '1', area, 140, 380
	 
	  make_text_macro '8', area, 480, 100
	 make_text_macro '7', area, 480, 140
	 make_text_macro '6', area, 480, 180
	 make_text_macro '5', area, 480, 220
     make_text_macro '4', area, 480, 260
	 make_text_macro '3', area, 480, 300
     make_text_macro '2', area, 480, 340
	 make_text_macro '1', area, 480, 380
		 
	; mov ebx,tabla_y
	; et1:
	; cmp ebx,tabla_y+40
	; jg final
	; push ebx
	; orizontal tabla_x,ebx,tabla_y-50,0FF0000h
	; pop ebx
	; inc ebx
	; jmp et1
	; final:
	
	  
	 orizontal tabla_x,tabla_y,tabla_size,0
	 orizontal tabla_x, tabla_y+40 ,tabla_size,0
	 orizontal tabla_x,tabla_y+80,tabla_size,0
	 orizontal tabla_x, tabla_y+120 ,tabla_size,0
	 orizontal tabla_x, tabla_y+160 ,tabla_size,0
	 orizontal tabla_x, tabla_y+200 ,tabla_size,0
	 orizontal tabla_x, tabla_y+240 ,tabla_size,0
	 orizontal tabla_x, tabla_y+280 ,tabla_size,0
	 orizontal tabla_x, tabla_y+320 ,tabla_size,0
	 
	 vertical tabla_x, tabla_y ,tabla_size,0
	 vertical tabla_x+40, tabla_y ,tabla_size,0
	 vertical tabla_x+80, tabla_y ,tabla_size,0
	 vertical tabla_x+120, tabla_y ,tabla_size,0
	 vertical tabla_x+160, tabla_y ,tabla_size,0
	 vertical tabla_x+200, tabla_y ,tabla_size,0
	 vertical tabla_x+240, tabla_y ,tabla_size,0
	 vertical tabla_x+280, tabla_y ,tabla_size,0
	  vertical tabla_x+320, tabla_y ,tabla_size,0
	  
	 ;cadran
	 orizontal tabla_x-30, tabla_y-30 ,tabla_size+60,0
	 vertical tabla_x-30, tabla_y-30 ,tabla_size+60,0
	 orizontal tabla_x-30, tabla_y+tabla_size+30 ,tabla_size+60,0
	  vertical tabla_x+tabla_size+30, tabla_y-30 ,tabla_size+60,0
	 
	;colorez tabla
	 culoare tabla_x,tabla_y
	 culoare2 tabla_x+40,tabla_y
	 culoare tabla_x+80,tabla_y
	culoare2 tabla_x+120,tabla_y
	 culoare tabla_x+160,tabla_y
	culoare2 tabla_x+200,tabla_y
	culoare tabla_x+240,tabla_y
	culoare2 tabla_x+280,tabla_y
	
	culoare2 tabla_x,tabla_y+40
	culoare tabla_x+40,tabla_y+40
	culoare2 tabla_x+80,tabla_y+40
	culoare tabla_x+120,tabla_y+40
	culoare2 tabla_x+160,tabla_y+40
	culoare tabla_x+200,tabla_y+40
	culoare2 tabla_x+240,tabla_y+40
	culoare tabla_x+280,tabla_y+40
	
	culoare tabla_x,tabla_y+80
	culoare2 tabla_x+40,tabla_y+80
	culoare tabla_x+80,tabla_y+80
	culoare2 tabla_x+120,tabla_y+80
	culoare tabla_x+160,tabla_y+80
	culoare2 tabla_x+200,tabla_y+80
	culoare tabla_x+240,tabla_y+80
	culoare2 tabla_x+280,tabla_y+80
	
	culoare2 tabla_x,tabla_y+120
	culoare tabla_x+40,tabla_y+120
	culoare2 tabla_x+80,tabla_y+120
	culoare tabla_x+120,tabla_y+120
	culoare2 tabla_x+160,tabla_y+120
	culoare tabla_x+200,tabla_y+120
	culoare2 tabla_x+240,tabla_y+120
	culoare tabla_x+280,tabla_y+120
	
	
	culoare tabla_x,tabla_y+160
	culoare2 tabla_x+40,tabla_y+160
	culoare tabla_x+80,tabla_y+160
	culoare2 tabla_x+120,tabla_y+160
	culoare tabla_x+160,tabla_y+160
	culoare2 tabla_x+200,tabla_y+160
	culoare tabla_x+240,tabla_y+160
	culoare2 tabla_x+280,tabla_y+160
	
	culoare2 tabla_x,tabla_y+200
	culoare tabla_x+40,tabla_y+200
	culoare2 tabla_x+80,tabla_y+200
	culoare tabla_x+120,tabla_y+200
	culoare2 tabla_x+160,tabla_y+200
	culoare tabla_x+200,tabla_y+200
	culoare2 tabla_x+240,tabla_y+200
	culoare tabla_x+280,tabla_y+200
	  
	culoare tabla_x,tabla_y+240
	culoare2 tabla_x+40,tabla_y+240
	culoare tabla_x+80,tabla_y+240
	culoare2 tabla_x+120,tabla_y+240
	culoare tabla_x+160,tabla_y+240
	culoare2 tabla_x+200,tabla_y+240
	culoare tabla_x+240,tabla_y+240
	culoare2 tabla_x+280,tabla_y+240
	
	culoare2 tabla_x,tabla_y+280
	culoare tabla_x+40,tabla_y+280
	culoare2 tabla_x+80,tabla_y+280
	culoare tabla_x+120,tabla_y+280
	culoare2 tabla_x+160,tabla_y+280
	culoare tabla_x+200,tabla_y+280
	culoare2 tabla_x+240,tabla_y+280
	culoare tabla_x+280,tabla_y+280
	
	 ; make_piese_macro 0,area,156,131,0
	 ; make_piese_macro 0,area,196,131,0
	 ; make_piese_macro 0,area,236,131,0
	 ; make_piese_macro 0,area,276,131,0
	 ; make_piese_macro 0,area,316,131,0
	 ; make_piese_macro 0,area,356,131,0
	 ; make_piese_macro 0,area,396,131,0
	 ; make_piese_macro 0,area,436,131,0
	 ; push 436
		; push 131
		; push -1
		; call afisare_piese
		; add esp,12
	 ; make_piese_macro 0,area,156,331,1
	 ; make_piese_macro 0,area,196,331,1
	 ; make_piese_macro 0,area,236,331,1
	 ; make_piese_macro 0,area,276,331,1
	 ; make_piese_macro 0,area,316,331,1
	 ; make_piese_macro 0,area,356,331,1
	 ; make_piese_macro 0,area,396,331,1
	 ; make_piese_macro 0,area,436,331,1
	
	  ; make_piese_macro 2,area,196,91,0
	  ; make_piese_macro 1,area,236,91,0
	  ; make_piese_macro 1,area,356,91,0
	  ; make_piese_macro 5,area,276,91,0
	  ; make_piese_macro 4,area,316,91,0
	  
	  ; make_piese_macro 2,area,396,91,0
	  ; make_piese_macro 2,area,196,371,1
	  ; make_piese_macro 2,area,396,371,1
	  
	   ; make_piese_macro 3,area,156,91,0
	   ; make_piese_macro 3,area,436,91,0
	   ; make_piese_macro 1,area,236,371,1
	   ; make_piese_macro 1,area,356,371,1
	   ; make_piese_macro 5,area,276,371,1
	   ; make_piese_macro 4,area,316,371,1
	   ; make_piese_macro 3,area,156,371,1
	    ; make_piese_macro 3,area,436,371,1
		
		
		cautare_piesa col,lin
		mov eax,'0'
		cmp piesutz,0
		jl negru
		add eax,piesutz
		make_text_macro eax,area,80,30
		jmp et 
		negru:
		
		mov eax, piesutz
		mov ebx,-1
		mul ebx
		
		;add eax,piesutz
		add eax,'0'
		;make_text_macro eax,area,80,30
		make_text_macro eax,area,80,30
		et:
		mov eax, offset mutari
		push eax
		call desenare_matrice
		add esp,4
		mov eax,piesutz
		mov ebx,col
		mov ecx,lin
		mutare_piese eax,ebx,ecx
		
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
