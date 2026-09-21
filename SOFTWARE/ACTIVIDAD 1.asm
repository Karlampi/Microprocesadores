; code segment starts here
	ORG 0000h
START:

	;(Port A output, Port C input)
	ld a, 89h
	out (CW), a

	; Inicializar stack pointer
	ld SP, F800h

	; a. Mostrar texto
	ld hl, text_1
	call desp_text

	ld b, 0         ; B será nuestro contador de letras

input_loop:
	; b. Ingresar nombre y apellidos con espacios
	call lee_KEYB   ; Lee la tecla

	; Verificar si se presionó ENTER
	cp 0Dh
	jp z, mostrar_resultado

	; Verificar si es ESPACIO
	cp 20h
	jp z, es_espacio

	; c. Validar si es letra mayúscula (Rango 'A' a 'Z')
	cp 41h          ; Compara con 'A'
	jp c, error_caracter   ; Si es menor que 'A', da error
	cp 5Bh          ; Compara con 'Z' + 1
	jp c, letra_valida     ; Si está entre 'A' y 'Z', es válido

	; Validar si es letra minúscula (Rango 'a' a 'z')
	cp 61h          ; Compara con 'a'
	jp c, error_caracter   ; Si está entre 'Z' y 'a', da error
	cp 7Bh          ; Compara con 'z' + 1
	jp nc, error_caracter  ; Si es mayor que 'z', da error

letra_valida:
	; d. Contar el número de letras, sin considerar los espacios
	inc b           ; Incrementa el registro B (contador de letras)

es_espacio:
	jp input_loop   ; Repite el ciclo para el siguiente carácter

error_caracter:
	; c. Enviar mensaje de error si se teclea un carácter no válido
	ld hl, text_error
	call desp_text
	jp START        ; Reinicia el programa por completo

mostrar_resultado:
	; e. Mostrar texto y la cantidad de letras
	ld hl, text_result
	call desp_text


	ld a, b
	call desp_numero
	halt            ; Fin del programa

; SUBRUTINAS

desp_text:	;--init (Despliega texto hasta encontrar '&')
	ld a, (hl)
	cp '&'
	ret z
	out (LCD), a
	inc hl
	jp desp_text

lee_KEYB:
espera_tecla:
	in a, (KEYB)
	cp 0
	jp z, espera_tecla   ; Bucle de espera hasta presionar una tecla
	out (LCD), a
	ret

desp_numero:
	ld c, 0
conv_dec:
	cp 10
	jr c, imprime_digitos
	sub 10
	inc c
	jr conv_dec
imprime_digitos:
	ld d, a              ; Guarda las unidades en D
	ld a, c
	add a, 30h
	out (LCD), a         ; Imprime decenas
	ld a, d              ; Carga las unidades
	add a, 30h
	out (LCD), a         ; Imprime unidades
	ret


; DATA SEGMENT

	ORG F800h
text_1:      db 0Dh, 0Ah, "Ingresa tu nombre y apellidos: &"
text_error:  db 0Dh, 0Ah, "UPS!: Caracter invalido. &"
text_result: db 0Dh, 0Ah, "Cantidad de letras: &"

	; constants
LCD:    equ 40h     ; Puerto de salida de texto
KEYB:   equ 41h     ; Puerto de entrada de teclado
CW:     equ 43h     ; Palabra de control

	END

