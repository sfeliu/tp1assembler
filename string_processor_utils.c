#include <stdbool.h>
#include <stdio.h>
#include "string_processor.h"
#include "string_processor_utils.h"

//TODO: debe implementar
/**
*	Debe devolver el largo de la lista pasada por parámetro
*/
uint32_t string_proc_list_length(string_proc_list* list){ 
	uint32_t length = 0;
	string_proc_node* nodo_actual = list->first;
	while(nodo_actual != NULL){
		length++;
		nodo_actual = nodo_actual->next;
	}
	return length; 
}

//TODO: debe implementar
/**
*	Debe insertar el nodo con los parámetros correspondientes en la posición indicada por index desplazando en una
*	posición hacia adelante los nodos sucesivos en caso de ser necesario, la estructura de la lista debe ser
*	actualizada de forma acorde
*	si index es igual al largo de la lista debe insertarlo al final de la misma
*	si index es mayor al largo de la lista no debe insertar el nodo
*	debe devolver true si el nodo pudo ser insertado en la lista, false en caso contrario
*/
bool string_proc_list_add_node_at(string_proc_list* list, string_proc_func f, string_proc_func g, string_proc_func_type type, uint32_t index){
	uint32_t length = string_proc_list_length(list);
	string_proc_node* node	= string_proc_node_create(f, g, type);
	if (index > length){
		string_proc_node_destroy(node);				// Lo libero asi no pierdo memoria.
		return false; 
	}else if (length == 0){
		list->last = node;
		list->first = node;
	}else if(index == length){
		list->last->next = node;
		node->previous = list->last;
		list->last = node;
	}else if(index == 0){
		list->first->previous = node;
		node->next = list->first;
		list->first = node;
	}else{
		uint32_t i = 0;
		string_proc_node* previous_node = list->first;
		while(i < index-1){
			previous_node = previous_node->next;
			i++;
		}
		previous_node->next->previous = node;
		node->next = previous_node->next;
		node->previous = previous_node;
		previous_node->next = node;
	}
	return true;
}

//TODO: debe implementar
/**
*	Debe eliminar el nodo que se encuentra en la posición indicada por index de ser posible
*	la lista debe ser actualizada de forma acorde y debe devolver true si pudo eliminar el nodo o false en caso contrario
*/
bool string_proc_list_remove_node_at(string_proc_list* list, uint32_t index){
	uint32_t length = string_proc_list_length(list);
	if (index >= length){
		return false; 
	}else if(length == 1){
		string_proc_node* nodo = list->last;
		list->last = NULL;
		list->first = NULL;
		string_proc_node_destroy(nodo); 			//Se encarga de mantener los punteros de los nodos en orden
	}else if(index == length-1){
		string_proc_node* nodo = list->last;
		list->last = list->last->previous;
		string_proc_node_destroy(nodo); 			//Mismo que antes
	}else if(index == 0){
		string_proc_node* nodo = list->first;
		list->first = list->first->next;
		string_proc_node_destroy(nodo);				//Mismo que antes
	}else{
		uint32_t i = 0;
		string_proc_node* node = list->first;
		while(i < index){
			node = node->next;
			i++;
		}
		string_proc_node_destroy(node);				//La función en asm se encarga de mantener la estructura interna en orden
	}
	return true;
}

//TODO: debe implementar
/**
*	Debe devolver una copia de la lista pasada por parámetro copiando los nodos en el orden inverso
*/
string_proc_list* string_proc_list_invert_order(string_proc_list* list){
	string_proc_list* new_list = string_proc_list_create(list->name);
	string_proc_node* current_node = list->last;			//Comienzo desde el último nodo
	while(current_node != NULL){
		string_proc_list_add_node(new_list, current_node->f, current_node->g, current_node->type);	//Voy agregando de a un nodo en la lista
		current_node = current_node->previous;
	}
	return new_list;	
}

//TODO: debe implementar
/**
*	Hace una llamada sucesiva a los nodos de la lista pasada por parámetro siguiendo la misma lógica
*	que string_proc_list_apply pero comienza imprimiendo una línea 
*	"Encoding key 'valor_de_la_clave' through list nombre_de_la_list\n"
* 	y luego por cada aplicación de una función f o g escribe 
*	"Applying function at [direccion_de_funcion] to get 'valor_de_la_clave'\n"
*/
void string_proc_list_apply_print_trace(string_proc_list* list, string_proc_key* key, bool encode, FILE* file){
	fprintf( file, "%s key '%s' through list %s\n", encode ? "Encoding": "Decoding", key->value, list->name);
	
	string_proc_node* current_node = encode ? list->first : list->last;
	while(current_node != NULL){
		encode ? current_node->f(key) : current_node->g(key);
		fprintf(file, "Applying function at [%p] to get '%s'\n", encode ? current_node->f : current_node->g, key->value); 
		current_node = encode ? current_node->next : current_node->previous;
	}
}

//TODO: debe implementar
/**
*	Debe desplazar en dos posiciones hacia adelante el valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición impar, resolviendo los excesos de representación por saturación
*/
void saturate_2_odd(string_proc_key* key){
	uint32_t i;
	for(i = 1; i < key->length; i = i + 2){
		key->value[i] = saturate_int(((int32_t)key->value[i]) + 2);
	}
}

//TODO: debe implementar
/**
*	Debe desplazar en dos posiciones hacia atrás el valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición impar, resolviendo los excesos de representación por saturación
*/
void unsaturate_2_odd(string_proc_key* key){
	uint32_t i;
	for(i = 1; i < key->length; i = i + 2){
		key->value[i] = saturate_int(((int32_t)key->value[i]) - 2);
	}
}

// Funcion auxiliar para saber si el numero dado es primo.
bool is_prime(uint32_t number){
	if(number == 1){return false;}
	for(uint32_t i = 2; i < (number^1/2); i++){
		if(number % i == 0){
			return false;
		}
	}
	return true;
}


//TODO: debe implementar
/**
*	Debe desplazar en tantas posiciones como sea la posición hacia adelante del valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición que sea un número primo, resolviendo los excesos de representación con wrap around
*/
void shift_position_prime(string_proc_key* key){
	uint32_t i;
	for(i = 0; i < key->length; i++){
		if(is_prime(i)){
			key->value[i] = wrap_around_int(((int32_t)key->value[i]) + i);
		}
	}
}

//TODO: debe implementar
/**
*	Debe desplazar en tantas posiciones como sea la posición hacia atrás del valor de cada caracter de la clave pasada por parámetro
*	si el mismo se encuentra en una posición que sea un número primo, resolviendo los excesos de representación con wrap around
*/
void unshift_position_prime(string_proc_key* key){
	uint32_t i;
	for(i = 0; i < key->length; i++){
		if(is_prime(i)){
			key->value[i] = wrap_around_int(((int32_t)key->value[i]) - i);	
		}
	}
}