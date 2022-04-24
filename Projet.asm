; external functions from X11 library
extern XOpenDisplay
extern XDisplayName
extern XCloseDisplay
extern XCreateSimpleWindow
extern XMapWindow
extern XRootWindow
extern XSelectInput
extern XFlush
extern XCreateGC
extern XSetForeground
extern XDrawLine
extern XNextEvent
 
 
; external functions from stdio library (ld-linux-x86-64.so.2)    
extern printf
extern scanf
extern exit

 
; ======= DEFINE =======
%define StructureNotifyMask     131072
%define KeyPressMask            1
%define ButtonPressMask         4
%define MapNotify               19
%define KeyPress                2
%define ButtonPress             4
%define Expose                  12
%define ConfigureNotify         22
%define CreateNotify            16
%define QWORD                   8
%define DWORD                   4
%define WORD                    2
%define BYTE                    1
 
 
 
global main
 
; ======= VAR RESERVATION ========
section .bss
display_name:  resq     1
screen:        resd     1
depth:         resd     1
connection:    resd     1
width:         resd     1
height:        resd     1
window:        resq     1
gc:            resq     1
 
cosinus:       resd   360
sinus:         resd   360

rotaX:         resd     0
rotaY:         resd     0
rotaZ:         resd     0

 
 
; ======= VAR DECLARATION =======
section .data
event:         times   24   dq 0
angle:         dd      0
demiangle:     dd      180
x1: dd  0.0
y1: dd  0.0
z1: dd  0.0
x2: dd  0.0
y2: dd  0.0
z2: dd  0.0
x3: dd  0.0
y3: dd  0.0
z3: dd  0.0
x21:    dd      0.0
y21:    dd      0.0
x23:    dd      0.0
y23:    dd      0.0
display:    dd  0
x_ieme_point:      db  0
compteur_face:     db  0
start_coordonnes_p1:    db  0
start_coordonnes_p2:    db  0
start_coordonnes_p3:    db  0 
calcul_projection_1:    dd  0.0
calcul_projection_2:    dd  0.0 
projection_X1:          dd  0
projection_Y1:          dd  0 
projection_X2:          dd  0
projection_Y2:          dd  0 
projection_X3:          dd  0
projection_Y3:          dd  0 
numero_p1:              db  0
numero_p2:              db  0
numero_p3:              db  0
df:     dd  300.0
xoff:   dd  200.0
yoff:   dd  200.0
zoff:   dd  300.0
 
 
; ------- COORDONNES -------
; Un point par ligne sous la forme X,Y,Z
dodec:  dd           0.0,50.0,80.901699     ; point 0
        dd           0.0,-50.0,80.901699    ; point 1
        dd           80.901699,0.0,50.0     ; point 2
        dd           80.901699,0.0,-50.0    ; point 3
        dd           0.0,50.0,-80.901699    ; point 4
        dd           0.0,-50.0,-80.901699   ; point 5
        dd           -80.901699,0.0,-50.0   ; point 6
        dd           -80.901699,0.0,50.0    ; point 7
        dd           50.0,80.901699,0.0     ; point 8
        dd           -50.0,80.901699,0.0    ; point 9
        dd           -50.0,-80.901699,0.0   ; point 10
        dd           50.0,-80.901699,0.0    ; point 11
 
faces:    dd           0,8,9,0       ; face 0
          dd           0,2,8,0       ; face 1
          dd           2,3,8,2       ; face 2
          dd           3,4,8,3       ; face 3
          dd           4,9,8,4       ; face 4
          dd           6,9,4,6       ; face 5
          dd           7,9,6,7       ; face 6
          dd           7,0,9,7       ; face 7
          dd           1,10,11,1     ; face 8
          dd           1,11,2,1      ; face 9
          dd           11,3,2,11     ; face 10
          dd           11,5,3,11     ; face 11
          dd           11,10,5,11    ; face 12
          dd           10,6,5,10     ; face 13
          dd           10,7,6,10     ; face 14
          dd           10,1,7,10     ; face 15
          dd           0,7,1,0       ; face 16
          dd           0,1,2,0       ; face 17
          dd           3,5,4,3       ; face 18
          dd           5,6,4,5       ; face 19
 

txt_rotaX:  db  "Selectionner un angle de rotation autour de l axe X : ",0
txt_rotaY:  db  "Selectionner un angle de rotation autour de l axe Y : ",0
txt_rotaZ:  db  "Selectionner un angle de rotation autour de l axe Z : ",0

fmt_scan:   db  "%hd",0


 
section .text
 
calculs_trigo:                     ; cette fonction précalcule les cosinus et sinus des angles de 0 à 360°
                                   ; et les sauvegarde dans les tableaux cosinus et sinus.
    boucle_trigo:
        fldpi                           ; st0=PI
        fimul dword[angle]              ; st0=PI*angle
        fidiv dword[demiangle]          ; st0=(PI*angle)/demi=angle en radians
        fsincos                         ; st0=cos(angleradian), st1=sin(angleradian)
        mov ecx,dword[angle]
        fstp dword[cosinus+ecx*DWORD]   ; cosinus[REAL8*angle]=st0=cos(angle) puis st0=sin(angle)
        fstp dword[sinus+ecx*DWORD]     ; sinus[REAL8*angle]=st0=sin(angle) puis st0 vide
        inc dword[angle]
        cmp dword[angle],360
        jbe boucle_trigo
ret
 
;##################################################
;########### PROGRAMME PRINCIPAL ##################
;##################################################
 
main:
mov rbp, rsp
push rbp
mov rdi,txt_rotaX
mov rax,0
call printf
mov rdi,fmt_scan
mov rsi,rotaX
mov rax,0
call scanf
mov rdi,txt_rotaY
mov rax,0
call printf
mov rdi,fmt_scan
mov rsi,rotaY
mov rax,0
call scanf
mov rdi,txt_rotaZ
mov rax,0
call printf
mov rdi,fmt_scan
mov rsi,rotaZ
mov rax,0
call scanf
pop rbp
call calculs_trigo               ; précalcul des cosinus et sinus
 
 
;####################################
;## Code de création de la fenêtre ##
;####################################
xor     rdi,rdi
call    XOpenDisplay        ; Création de display
mov     qword[display_name],rax            ; rax=nom du display
 
; display_name structure
; screen = DefaultScreen(display_name);
mov     rax,qword[display_name]
mov     eax,dword[rax+0xe0]
mov     dword[screen],eax
 
mov rdi,qword[display_name]
mov esi,dword[screen]
call XRootWindow
mov rbx,rax
 
mov rdi,qword[display_name]
mov rsi,rbx
mov rdx,10
mov rcx,10
mov r8,400              ; largeur
mov r9,400              ; hauteur
push 0xFFFFFF  ; background  0xRRGGBB
push 0x00FF00
push 1
call XCreateSimpleWindow
mov qword[window],rax
 
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,131077 ;131072
call XSelectInput
 
mov rdi,qword[display_name]
mov rsi,qword[window]
call XMapWindow
 
mov rdi,qword[display_name]
mov rsi,qword[window]
mov rdx,0
mov rcx,0
call XCreateGC
mov qword[gc],rax
 
mov rdi,qword[display_name]
mov rsi,qword[gc]
mov rdx,0x000000           ; Couleur du crayon
call XSetForeground
 
 
; boucle de gestion des évènements
boucle: 
    mov rdi,qword[display_name]
    mov rsi,event
    call XNextEvent
 
    cmp dword[event],ConfigureNotify   ; à l'apparition de la fenêtre
    je prog_principal              ; on saute au label 'dessin'
 
    cmp dword[event],KeyPress      ; Si on appuie sur une touche
    je closeDisplay                ; on saute au label 'closeDisplay' qui ferme la fenêtre
jmp boucle
 
 
;###########################################
;## Fin du code de création de la fenêtre ##
;###########################################
 
;############################################
;## Ici commence VOTRE programme principal ##
;############################################ 
prog_principal:
    calculs_et_dessins:
        mov al,4
        mul byte[compteur_face]
        mov byte[x_ieme_point],al
        movzx ebx,byte[x_ieme_point]
        mov al,byte[faces+ebx*DWORD]
        mov byte[numero_p1],al
        inc byte[x_ieme_point]
        movzx ebx,byte[x_ieme_point]
        mov al,byte[faces+ebx*DWORD]
        mov byte[numero_p2],al
        inc byte[x_ieme_point]    
        movzx ebx,byte[x_ieme_point]
        mov al,byte[faces+ebx*DWORD]
        mov byte[numero_p3],al
        mov al,3
        mul byte[numero_p1]
        mov byte[start_coordonnes_p1],al
        movzx ebx,byte[start_coordonnes_p1]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[x1],xmm0
        inc byte[start_coordonnes_p1]
        movzx ebx,byte[start_coordonnes_p1]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[y1],xmm0
        inc byte[start_coordonnes_p1]
        movzx ebx,byte[start_coordonnes_p1]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[z1],xmm0
        
        ; ------- Rotations -------
            mov eax,dword[rotaY]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[z1]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[x1]
            addss xmm0,xmm1
            movss dword[x1],xmm0
            mov eax,dword[rotaZ]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[x1]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[y1]
            subss xmm0,xmm1
            movss dword[x1],xmm0
            mov eax,dword[rotaX]
            movss xmm0,[cosinus+eax*DWORD]
            mulss xmm0,dword[y1]
            movss xmm1,[sinus+eax*DWORD]
            mulss xmm1,dword[z1]
            subss xmm0,xmm1
            movss dword[y1],xmm0
            mov eax,dword[rotaZ]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[x1]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[y1]
            addss xmm0,xmm1
            movss dword[y1],xmm0
            mov eax,dword[rotaX]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[y1]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[z1]
            addss xmm0,xmm1
            movss dword[z1],xmm0
            mov eax,dword[rotaY]
            movss xmm0,[cosinus+eax*DWORD]
            mulss xmm0,dword[z1]
            movss xmm1,[sinus+eax*DWORD]
            mulss xmm1,dword[x1]
            movss dword[z1],xmm0
        mov al,3
        mul byte[numero_p2]
        mov byte[start_coordonnes_p2],al
        movzx ebx,byte[start_coordonnes_p2]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[x2],xmm0
        inc byte[start_coordonnes_p2]
        movzx ebx,byte[start_coordonnes_p2]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[y2],xmm0
        inc byte[start_coordonnes_p2]
        movzx ebx,byte[start_coordonnes_p2]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[z2],xmm0
            mov eax,dword[rotaY]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[z2]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[x2]
            addss xmm0,xmm1
            movss dword[x2],xmm0
            mov eax,dword[rotaZ]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[x2]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[y2]
            subss xmm0,xmm1
            movss dword[x2],xmm0
            mov eax,dword[rotaX]
            movss xmm0,[cosinus+eax*DWORD]
            mulss xmm0,dword[y2]
            movss xmm1,[sinus+eax*DWORD]
            mulss xmm1,dword[z2]
            subss xmm0,xmm1
            movss dword[y2],xmm0
            mov eax,dword[rotaZ]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[x2]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[y2]
            addss xmm0,xmm1
            movss dword[y2],xmm0
            mov eax,dword[rotaX]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[y2]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[z2]
            addss xmm0,xmm1
            movss dword[z2],xmm0
            mov eax,dword[rotaY]
            movss xmm0,[cosinus+eax*DWORD]
            mulss xmm0,dword[z2]
            movss xmm1,[sinus+eax*DWORD]
            mulss xmm1,dword[x2]
            subss xmm0,xmm1
            movss dword[z2],xmm0
        mov al,3
        mul byte[numero_p3]
        mov byte[start_coordonnes_p3],al
        movzx ebx,byte[start_coordonnes_p3]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[x3],xmm0
        inc byte[start_coordonnes_p3]
        movzx ebx,byte[start_coordonnes_p3]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[y3],xmm0
        inc byte[start_coordonnes_p3]
        movzx ebx,byte[start_coordonnes_p3]
        movss xmm0,dword[dodec+ebx*DWORD]
        movss dword[z3],xmm0
            mov eax,dword[rotaY]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[z3]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[x3]
            addss xmm0,xmm1
            movss dword[x3],xmm0
            mov eax,dword[rotaZ]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[x3]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[y3]
            subss xmm0,xmm1
            movss dword[x3],xmm0
            mov eax,dword[rotaX]
            movss xmm0,[cosinus+eax*DWORD]
            mulss xmm0,dword[y3]
            movss xmm1,[sinus+eax*DWORD]
            mulss xmm1,dword[z3]
            subss xmm0,xmm1
            movss dword[y3],xmm0
            mov eax,dword[rotaZ]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[x3]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[y3]
            addss xmm0,xmm1
            movss dword[y3],xmm0
            mov eax,dword[rotaX]
            movss xmm0,[sinus+eax*DWORD]
            mulss xmm0,dword[y3]
            movss xmm1,[cosinus+eax*DWORD]
            mulss xmm1,dword[z3]
            addss xmm0,xmm1
            movss dword[z3],xmm0
            mov eax,dword[rotaY]
            movss xmm0,[cosinus+eax*DWORD]
            mulss xmm0,dword[z3]
            movss xmm1,[sinus+eax*DWORD]
            mulss xmm1,dword[x3]
            subss xmm0,xmm1
            movss dword[z3],xmm0
        
        
        
        ; ======= CALCUL =======
        movss xmm0,dword[x1]
        mulss xmm0,[df]
        movss xmm1, dword[z1]
        addss xmm1,[zoff]
        divss xmm0,xmm1
        addss xmm0,[xoff]
        cvtss2si eax,xmm0
        mov dword[projection_X1],eax
        movss xmm0,dword[y1]
        mulss xmm0,[df]
        divss xmm0,xmm1
        addss xmm0,[yoff]
        cvtss2si eax,xmm0
        mov dword[projection_Y1],eax
        movss xmm0,dword[x2]
        mulss xmm0,[df]
        movss xmm1, dword[z2]
        addss xmm1,[zoff]
        addss xmm0,[xoff]
        cvtss2si eax,xmm0
        mov dword[projection_X2],eax
        movss xmm0,dword[y2]
        mulss xmm0,[df]
        divss xmm0,xmm1
        addss xmm0,[yoff]
        cvtss2si eax,xmm0
        mov dword[projection_Y2],eax
        movss xmm0,dword[x3]
        mulss xmm0,[df]
        movss xmm1, dword[z3]
        addss xmm1,[zoff]
        divss xmm0,xmm1
        addss xmm0,[xoff]
        cvtss2si eax,xmm0
        mov dword[projection_X3],eax
        movss xmm0,dword[y3]
        mulss xmm0,[df]
        divss xmm0,xmm1
        addss xmm0,[yoff]
        cvtss2si eax,xmm0
        mov dword[projection_Y3],eax
        mov eax,dword[projection_X1]
        sub eax,dword[projection_X2]
        mov dword[x21],eax
        mov eax,dword[projection_Y1]
        sub eax,dword[projection_Y2]
        mov dword[y21],eax
        mov eax,dword[projection_X3]
        sub eax,dword[projection_X2]
        mov dword[x23],eax
        mov eax,dword[projection_Y3]
        sub eax,dword[projection_Y2]
        mov dword[y23],eax
        mov eax,dword[x21]
        imul eax,dword[y23]
        mov ebx,dword[y21]
        imul ebx,[x23]
        sub eax,ebx
        mov dword[display],eax
        cmp dword[display],0
        jg boucle_sur_faces
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov ecx,dword[projection_X1]
        mov r8d,dword[projection_Y1]
        mov r9d,dword[projection_X2]
        push qword[projection_Y2]
        call XDrawLine
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov ecx,dword[projection_X2]
        mov r8d,dword[projection_Y2]
        mov r9d,dword[projection_X3]
        push qword[projection_Y3]
        call XDrawLine
        mov rdi,qword[display_name]
        mov rsi,qword[window]
        mov rdx,qword[gc]
        mov ecx,dword[projection_X3]
        mov r8d,dword[projection_Y3]
        mov r9d,dword[projection_X1]
        push qword[projection_Y1]
        call XDrawLine
        jmp boucle_sur_faces
    boucle_sur_faces:
        cmp byte[compteur_face],19
        jae flush
        inc byte[compteur_face]
        jmp calculs_et_dessins
        
        
;##############################################
;## Ici se termine VOTRE programme principal ##
;##############################################


flush:
    mov rdi,qword[display_name]
    call XFlush
    jmp boucle
    mov rax,34
    syscall
 

closeDisplay:
    mov     rax,qword[display_name]
    mov     rdi,rax
    call    XCloseDisplay
    xor     rdi,rdi
    call    exit
