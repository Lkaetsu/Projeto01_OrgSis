TITLE Nome: Leonardo Seiji Kaetsu       RA: 22008336
.model small
.data
    msg1 db 'Entre o primeiro numero: $'
    msg2 db 'Entre a operacao desejada(+,-,*,/): $'
    msg3 db 'Entre o segundo numero: $'
.CODE
MAIOR_10 PROC
    AND AX,0
    MOV AL,BL
    MOV BL,10
    DIV BL
    MOV DL,AH
    MOV AH,02
    INT 21h
    MOV DL,AL
    INT 21h
    RET
MAIOR_10 ENDP

OP_SOMA PROC
    MOV DL,BL           ;impressao da operacao completa
    INT 21h
    MOV DL,'+'
    INT 21h
    MOV DL,BH
    INT 21h
    MOV DL,'='
    INT 21h

    SUB BL,30h          ;operacao
    SUB BH,30h
    ADD BL,BH

    CMP BL,0Ah
    JBE M_10             ;se o resultado for maior que dez entra na funcao
    CALL MAIOR_10
    JMP FIM1
    M_10:
    ADD BL,30h          ;impressao do resultado
    MOV DL,BL
    INT 21h
    FIM1:
    RET
OP_SOMA ENDP

OP_SUBTRACAO PROC
    RET
OP_SUBTRACAO ENDP

MAIN PROC
    MOV AX,@data            ;inicializacao o segmento de dados
    MOV DS,AX

    MOV AH,09               ;impressao da primeira mensagem
    LEA DX,msg1
    INT 21h

    MOV AH,01               ;armazenamento do primeiro numero em bl
    INT 21h
    MOV BL,AL

    MOV AH,02               ;pulando linha
    MOV DL,10
    INT 21h
    MOV AH,09               ;impressao da segunda mensagem
    LEA DX,msg2
    INT 21h

    MOV AH,01               ;armazenamento do caracter da operacao em cl
    INT 21h
    MOV CL,AL             

    MOV AH,02               ;pulando linha
    MOV DL,10
    INT 21h
    MOV AH,09               ;impressao da terceira mensagem
    LEA DX,msg3
    INT 21h

    MOV AH,01               ;armazenamento do segundo numero em bh
    INT 21h
    MOV BH,AL

    MOV AH,02               ;pulando linha
    MOV DL,10
    INT 21h

    CMP CL,'+'
    JNZ Soma                ;se o caracter da operacao for diferente de + pular para a proxima operacao
    CALL OP_SOMA
    JMP FIM2
    Soma:

    CMP CL,'-'
    JNZ Subtracao           ;se o caracter da operacao for diferente de - pular para a proxima operacao
        MOV DL,BL           ;impressao da operacao completa
        INT 21h
        MOV DL,'-'
        INT 21h
        MOV DL,BH
        INT 21h
        MOV DL,'='
        INT 21h

        SUB BL,30h          ;operacao
        SUB BH,30h
        SUB BL,BH

        JNS Negativo        ;se o resultado for negativo transforma-lo em positivo e imprimir um - em sua frente
            MOV DL,'-'
            INT 21h
            NEG BL
            Negativo:
            
        ADD BL,30h          ;impressao do resultado
        MOV DL,BL
        INT 21h
        Subtracao:
        FIM2:

    MOV AH,4Ch              ;exit
    INT 21h
    MAIN ENDP
END MAIN
