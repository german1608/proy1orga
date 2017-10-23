# Lista.s
# Autores:
#   Yuni Quintero
#   German Robayo
	.text
	.globl main
main:
	li $a0, 4
# Descripcion:inicializa el manejador de memoria.
# Argumentos:
#	$a0: Numero de bytes a ser administrados.
# Retorno:
#	$v0
	.text
	.globl init
init:
	li $v0, 9
	syscall