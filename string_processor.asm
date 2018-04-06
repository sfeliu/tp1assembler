; FUNCIONES de C
	extern malloc
	extern free
	extern fopen
	extern fclose
	extern fprintf
	extern str_len
	extern str_copy

; /** defines bool y puntero **/
	%define NULL 0
	%define TRUE 1
	%define FALSE 0

	%define list_size 				24
	%define offset_nombre_list 		0
	%define offset_first_list 		8
	%define offset_last_list 		16

	%define node_size 				36
	%define offset_next_node 		0
	%define offset_previous_node	8
	%define offset_f_node 			16
	%define offset_g_node 			24
	%define offset_type_node 		32

	%define key_size 				12
	%define offset_length_key 		0
	%define offset_value_key 		4


section .data


section .text

global string_proc_list_create				;///////////////////////////////////////////////////////////////////////
string_proc_list_create:
	push rbp									; Stack frame								'ALINEADO'
	mov rbp, rsp
	push rdi									; Guardo puntero a nombre de lista (*char) 	'DESALINEADO'
	sub	rsp, 8									; 											'ALINEADO'

	call str_copy 								; Copio el nombre
	add rsp, 8
	push rax									; Guardo en pila el puntero a la copia del nombre

	mov rdi, list_size							; Pongo tamaño en rdi para malloc
	call malloc									; en rax se encuentra el puntero a la memoria pedida

	pop r8
	pop rdi
	mov [rax + offset_nombre_list], r8			; Pongo el puntero a nombre en su posicion
	mov qword [rax + offset_first_list], NULL	; Pongo first y last en NULL
	mov qword[rax + offset_last_list], NULL

	pop rbp
	ret

global string_proc_node_create				;///////////////////////////////////////////////////////////////////////
string_proc_node_create:
	push rbp								; Stack frame						'ALINEADO'
	mov rbp, rsp
	
	push rdi								; Guardo los parametros de entrada	'DESALINEADO'
	push rsi 								;									'ALINEADO'
	push rdx 								;									'DESALINEADO'
	sub rsp, 8								;									'ALINEADO'

	mov rdi, node_size						; Tamaño de nodo para malloc
	call malloc								; En rax puntero a nodo

	add rsp, 8	
	pop rdx									; Traigo los paramentros de entrada
	pop rsi
	pop rdi

	mov qword [rax + offset_next_node], NULL	; Pongo en previous y next NULL
	mov qword [rax + offset_previous_node], NULL
	mov [rax + offset_f_node], rdi				; En los demas pongo los parametros de entrada
	mov [rax + offset_g_node], rsi
	mov [rax + offset_type_node], edx			; Solo tengo que poner los bits menos significativos
	

	pop rbp	
	ret

global string_proc_key_create				;///////////////////////////////////////////////////////////////////////
string_proc_key_create:
	push rbp								; Stack frame 						'ALINEADO'
	mov rbp, rsp

	call str_copy 							; Copio value, en rdi se encuentra el puntero a value
	push rax								; Guardo el puntero a la copia		'DESALINEADO'
	sub rsp, 8								;									'ALINEADO'

	mov rdi, rax							; Llamo a str_len para obtener la longitud de string
	call str_len

	add rsp, 8								;									'DESALINEADO'
	push rax								; Guardo la longitud de value 		'ALINEADO'

	mov rdi, key_size						; Pido espacio en memoria para key
	call malloc								; Puntero a key en rax

	pop rdx									; En rdx longitud de value
	pop r8									; En r8 puntero a cópia de value

	mov [rax + offset_length_key], edx		; dx porque es uint_32
	mov [rax + offset_value_key], r8		; Pongo en sus posiciones los valores de key

	pop rbp	
	ret

global string_proc_list_destroy				;///////////////////////////////////////////////////////////////////////
string_proc_list_destroy:
	push rbp								; Stack frame						'ALINEADO'
	mov rbp, rsp
	
	mov r9, rdi								; lista en r9
	mov r8, [r9 + offset_first_list] 		; First en r8

.chequear_lista_vacia:
	cmp r8, NULL							; Comparo first con NULL, si son iguales lista vacia
	jne .eliminar_primero					; sino chequeo el próximo caso (solo un elemento.)

	mov r8, [rdi + offset_nombre_list]		; Guardo en r8 el puntero a nombre
	push r8									; Guardo en la pila 			   	'DESALINEADO'
	sub rsp, 8								;									'ALINEADO'

	call free								; En rdi ya esta el puntero a la lista. solo libero
	
	add rsp, 8
	pop rdi									; Recupero el puntero a nombre de la pila

	call free								; Libero el espacio pedido para la copia del nombre

	pop rbp
	ret

.eliminar_primero:
	mov r10, r8								; Pongo el nodo a eliminar en r10
	mov r8, [r8 + offset_next_node]			; Pongo en r8 el nuevo first
	push r8									;											'DESALINEADO'
	push rdi								;											'ALINEADO'

	mov rdi, r10							; Pongo el puntero al nodo para borrarlo
	call string_proc_node_destroy			; Lo borro

	pop rdi
	pop r8
	jmp .chequear_lista_vacia				; Vuelvo a chequear si la lista ya esta vacia


global string_proc_node_destroy				;///////////////////////////////////////////////////////////////////////
string_proc_node_destroy:
	push rbp								; Stack frame					'ALINEADO'
	mov rbp, rsp
	
	mov r8, [rdi + offset_previous_node]	; Puntero a anterior en r8
	mov r9, [rdi + offset_next_node]		; Puntero a próximo en r9
	cmp r8, NULL							; Chequeo si anterior es NULL
	je .chequear_prox
	mov [r8 + offset_next_node], r9			; Cambio próximo de anterior a próximo de próximo

.chequear_prox:
	cmp r9, NULL							; Chequeo si próximo es NULL
	je .liberar_memoria
	mov [r9 + offset_previous_node], r8		; Cambio anterior de próximo a anterior de anterior

.liberar_memoria:
	call free

	pop rbp
	ret

global string_proc_key_destroy				;///////////////////////////////////////////////////////////////////////
string_proc_key_destroy:
	push rbp								; Stack frame						'ALINEADO'
	mov rbp, rsp

	mov r8, [rdi + offset_value_key]		; Guardo puntero a comienzo de value en r8
	push r8									; Y lo guardo en la pila 			'DESALINEADO'
	sub rsp, 8								;									'ALINEADO'

	call free								; Como en rdi ya tengo el puntero a la estructura, solo libero

	add rsp, 8
	pop rdi									; Recupero el puntero a value, anteriormente pusheado a la pila

	call free								; Libero el espacio pedido para value.

	pop rbp
	ret

global string_proc_list_add_node			;///////////////////////////////////////////////////////////////////////
string_proc_list_add_node:
	push rbp								; Stack frame						'ALINEADO'
	mov rbp, rsp

	push rdi								; Puntero a lista 					'DESALINEADO'
	mov rdi, rsi							; Función F
	mov rsi, rdx							; Función G
	mov rdx, rcx							; Type
	sub rsp, 8								;									'ALINEADO'

	call string_proc_node_create			; Creo el nodo, puntero en rax

	add rsp, 8
	pop rdi
	mov r8, [rdi + offset_last_list]		; Puntero de last en r8
	cmp r8, NULL							; Chequeo si la lista esta vacía
	jne .lista_no_vacia

.lista_vacia;
	mov [rdi + offset_last_list], rax		; Pongo en first y last el puntero a nodo
	mov [rdi + offset_first_list], rax
	jmp .fin

.lista_no_vacia:
	mov [r8 + offset_next_node], rax		; Modifico next del último para que apunte al nuevo último
	mov [rax + offset_previous_node], r8	; Le agrego el puntero al previo para el nuevo nodo
	mov [rdi + offset_last_list], rax		; Pongo en last el puntero al nuevo nodo
	jmp .fin

.fin:
	pop rbp
	ret

global string_proc_list_apply				;///////////////////////////////////////////////////////////////////////
string_proc_list_apply:
	push rbp								; Stack frame						'ALINEADO'
	mov rbp, rsp
	push r12								;									'DESALINEADA'
	
	mov r11, rdi
	mov	rdi, rsi
	
	mov cl, TRUE							; Pongo valor de True n cl
	cmp cl, dl
	jne .aplico_reversa						; Chequeo si es False o True

	mov r8, offset_next_node				; Como es True le aplico de adelante para atras la función f
	mov r9, offset_f_node
	mov r10, [r11 + offset_first_list]
	jmp .continuar

.aplico_reversa:
	mov r8, offset_previous_node			; Como es False le aplico de atras para adelante la función g
	mov r9, offset_g_node
	mov r10, [r11 + offset_last_list]

.continuar:
	cmp r10, NULL						; Chequeo si llegué al final de la lista
	je .fin

	push r8									;									'ALINEADA'
	push r9									;									'DESALINEADA'
	push r10								;									'ALINEADA'
	push rdi								;									'DESALINEADA'
	sub rsp, 8								;									'ALINEADA'
	
	mov r12, [r10 + r9]						; Pongo en r12 el puntero a la función a ejecutar
	call r12								; Recordar en rdi se encuentra el puntero a key

	add rsp, 8
	pop rdi
	pop r10
	pop r9
	pop r8

	mov r10, [r10 + r8]						; Cambio r10 por el nodo próximo o prévio, dependiendo de lo que haya en r8
	jmp .continuar

.fin:
	pop r12
	pop rbp
	ret
