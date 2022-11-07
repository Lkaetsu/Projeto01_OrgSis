TITLE Nome: Leonardo Seiji Kaetsu       RA: 22008336
.model small
.data
    msg1 db 'Entre o primeiro numero: $'
    msg2 db 'Entre a operacao desejada(+,-,*,/): $'
    msg3 db 'Entre o segundo numero: $'
    res db '    Resto: $'
    error db 'Erro: Operacao invalida!',10,'(Cheque se a operacao esta entre as 4 opcoes ou se fez uma divisao por zero.)$'
.CODE
IMPRESSAO_OP PROC
    MOV DL,BL           ;impressao da operacao completa
    INT 21h
    MOV DL,CL
    INT 21h
    MOV DL,BH
    INT 21h
    MOV DL,'='
    INT 21h
    SUB BL,30h          ;transforma caracteres em numeros para as operacoes
    SUB BH,30h
    RET
IMPRESSAO_OP ENDP

MAIOR_10 PROC
    MOV AX,0            ;divisao por 10 para separar o numero
    MOV AL,BL           ;em dois numeros a unidade e a dezena
    MOV BL,0Ah
    DIV BL

    MOV BL,AH           ;impressao do numero separadamente
    ADD AL,30h
    ADD BL,30h
    MOV AH,02
    MOV DL,AL
    INT 21h
    MOV DL,BL
    INT 21h
    RET
MAIOR_10 ENDP

OP_SOMA PROC
    CALL IMPRESSAO_OP

    ADD BL,BH           ;operacao
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
    CALL IMPRESSAO_OP

    SUB BL,BH           ;operacao
    JNS Negativo        ;se o resultado for negativo transforma-lo em positivo e imprimir um - em sua frente
        MOV DL,'-'
        INT 21h
        NEG BL
    Negativo:
            
    ADD BL,30h          ;impressao do resultado
    MOV DL,BL
    INT 21h
    RET
OP_SUBTRACAO ENDP

OP_MULTIPLICACAO PROC
    CALL IMPRESSAO_OP
    
    MOV AX,0            ;zera ax para ser utilizado na operacao como prod
    MOV AL,BH
    MOV CH,8            ;inicializa contador do loop volta
    VOLTA:
    TEST AL,01          ;se al AND 1=1
    JZ SE1
    ADD AH,BL           ;faz a operacao prod=prod+mcand
    SE1:
    SHR AX,1            ;desloca ax para a direita
    DEC CH
    JNZ VOLTA           ;enquanto ch for diferente volta para o comeco do loop

    MOV BL,AL
    CMP BL,0Ah
    JBE Ma_10           ;se o resultado for maior que dez entra na funcao
    CALL MAIOR_10
    JMP FIM1
    Ma_10:

    MOV AH,02
    ADD BL,30h          ;impressao do resultado
    MOV DL,BL
    INT 21h
    RET
OP_MULTIPLICACAO ENDP

OP_DIVISAO PROC
    CALL IMPRESSAO_OP

    AND AX,0            ;zera ax para ser utilizado na operacao como rem
    MOV AL,BL
    AND BL,0            ;zera bl para utilizar bx como div
    AND CL,0            ;zera cl para ser utilizado na operacao como quo
    MOV CH,9            ;inicializa contador do loop volta
    VOLTA2:
    SUB AX,BX           ;faz a operacao rem=rem-div
    JNS SE2             ;se ax<0
    ADD AX,BX           ;faz operaracao rem=rem-div
    SHL CL,1            ;e desloca o quociente para a esquerda
    JMP FIM2
    SE2:                ;se ax>=0
    SHL CL,1            ;desloca para a esquerda
    INC CL              ;e coloca 1 no q0
    FIM2:
    SHR BX,1            ;desloca bx para a direita
    DEC CH
    JNZ VOLTA2          ;enquanto ch for diferente volta para o comeco do loop

    MOV BH,AL
    MOV AH,02
    ADD CL,30h          ;impressao do quociente
    MOV DL,CL
    INT 21h
    MOV AH,09
    LEA DX,res
    INT 21h
    MOV AH,02           ;impressao do resto
    MOV DL,BH
    ADD DL,30h
    INT 21h
    RET
OP_DIVISAO ENDP

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
    JMP FIM_SOMA            ;pula para o final do programa
    Soma:

    CMP CL,'-'
    JNZ Subtracao           ;se o caracter da operacao for diferente de - pular para a proxima operacao
    CALL OP_SUBTRACAO
    JMP FIM_SUB             ;pula para o final do programa
    Subtracao:

    CMP CL,'*'
    JNZ Multiplicacao       ;se o caracter da operacao for diferente de * pular para a proxima operacao
    CALL OP_MULTIPLICACAO
    JMP FIM_MULT            ;pula para o final do programa
    Multiplicacao:

    CMP CL,'/'
    JNZ Divisao             ;se o caracter da operacao for diferente de / pular para a proxima operacao
    CMP BH,30h
    JZ DIV0
    CALL OP_DIVISAO
    JMP FIM_DIVI            ;pula para o final do programa
    DIV0:
    Divisao:

    MOV AH,09               ;impressao da mensagem de erro se a operacao nao for uma das aplicaveis ou em caso de uma divisao por 0
    LEA DX,error
    INT 21h

    FIM_SOMA:
    FIM_SUB:
    FIM_MULT:
    FIM_DIVI:

    MOV AH,4Ch              ;exit
    INT 21h
    MAIN ENDP
END MAIN
