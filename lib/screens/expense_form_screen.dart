// lib/screens/expense_form_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para formateadores de entrada
import 'package:intl/intl.dart'; // Para formateo de fechas
import '../database/database_helper.dart'; // Para acceder a la base de datos
import '../models/expense.dart'; // Modelo de gasto
import '../utils/constants.dart'; // Constantes de la aplicación
import '../utils/validators.dart'; // Validadores de formularios
import '../widgets/custom_text_field.dart'; // Widget personalizado para campos de texto

/// Pantalla para añadir o editar un gasto.
/// Puede recibir un objeto Expense opcional para modo edición.
class ExpenseFormScreen extends StatefulWidget {
 final Expense? expense; // Gasto a editar (null para crear nuevo)

 const ExpenseFormScreen({
   super.key,
   this.expense,
 });

 @override
 State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
 // Clave global para identificar y validar el formulario
 final _formKey = GlobalKey<FormState>();
 
 // Controladores para los campos de texto
 final _descriptionController = TextEditingController(); // Para la descripción
 final _amountController = TextEditingController(); // Para el monto
 
 // Instancia del helper de base de datos para realizar operaciones
 final _databaseHelper = DatabaseHelper();
 
 // Variables para almacenar los valores seleccionados
 late String _selectedCategory; // Categoría seleccionada
 late DateTime _selectedDate; // Fecha seleccionada
 
 // Estado de carga
 bool _isLoading = false;
 
 /// Propiedad para determinar si estamos en modo edición o creación
 bool get isEditing => widget.expense != null;

 @override
 void initState() {
   super.initState();
   
   // Inicializamos los campos con valores por defecto o del gasto a editar
   _selectedCategory = widget.expense?.category ?? ExpenseCategories.categories.first;
   _selectedDate = widget.expense?.date ?? DateTime.now();
   
   // Si estamos en modo edición, llenamos los campos con los datos del gasto
   if (isEditing) {
     _descriptionController.text = widget.expense!.description;
     _amountController.text = widget.expense!.amount.toString();
   }
 }

 @override
 void dispose() {
   // Liberamos los recursos de los controladores cuando se destruye el widget
   _descriptionController.dispose();
   _amountController.dispose();
   super.dispose();
 }

 /// Guarda el gasto en la base de datos (nuevo o actualizado).
 Future<void> _saveExpense() async {
   // Primero validamos que el formulario sea correcto
   if (_formKey.currentState!.validate()) {
     // Activamos el indicador de carga
     setState(() {
       _isLoading = true;
     });

     try {
       // Convertimos el texto del monto a un valor numérico
       final amount = double.parse(_amountController.text);
       
       if (isEditing) {
         // Si estamos editando, actualizamos el gasto existente
         final updatedExpense = widget.expense!.copyWith(
           description: _descriptionController.text.trim(), // Descripción sin espacios adicionales
           category: _selectedCategory, // Categoría seleccionada
           amount: amount, // Monto convertido a double
           date: _selectedDate, // Fecha seleccionada
         );
         
         // Actualizar en la base de datos
         await _databaseHelper.updateExpense(updatedExpense);
         
         // Mostrar mensaje de éxito
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Gasto actualizado exitosamente'),
               backgroundColor: Colors.green,
             ),
           );
         }
       } else {
         // Si estamos creando, instanciamos un nuevo gasto
         final newExpense = Expense(
           userId: UserSession.userId!, // ID del usuario actual
           description: _descriptionController.text.trim(),
           category: _selectedCategory,
           amount: amount,
           date: _selectedDate,
         );
         
         // Insertar en la base de datos
         await _databaseHelper.insertExpense(newExpense);
         
         // Mostrar mensaje de éxito
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(
               content: Text('Gasto agregado exitosamente'),
               backgroundColor: Colors.green,
             ),
           );
         }
       }
       
       // Regresar a la pantalla anterior con resultado positivo (para recargar los datos)
       if (mounted) {
         Navigator.pop(context, true);
       }
     } catch (e) {
       // Si ocurre un error durante el guardado, mostramos el mensaje
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Error al guardar gasto: ${e.toString()}'),
             backgroundColor: Colors.red,
           ),
         );
         // Desactivamos el indicador de carga
         setState(() {
           _isLoading = false;
         });
       }
     }
   }
 }

 /// Muestra el selector de fecha.
 Future<void> _selectDate() async {
   // Mostramos el selector de fecha nativo
   final DateTime? picked = await showDatePicker(
     context: context,
     initialDate: _selectedDate, // Fecha inicialmente seleccionada
     firstDate: DateTime(2020), // Fecha mínima permitida
     lastDate: DateTime.now().add(const Duration(days: 1)), // Fecha máxima (permite el día actual)
   );
   
   // Si se seleccionó una fecha y es diferente a la actual, actualizamos
   if (picked != null && picked != _selectedDate) {
     setState(() {
       _selectedDate = picked;
     });
   }
 }

 @override
 Widget build(BuildContext context) {
   // Construimos la interfaz del formulario de gastos
   return Scaffold(
     appBar: AppBar(
       // Título dinámico según el modo (edición o creación)
       title: Text(isEditing
           ? AppConstants.editExpenseTitle
           : AppConstants.addExpenseTitle),
     ),
     body: SafeArea(
       child: SingleChildScrollView(
         padding: const EdgeInsets.all(20),
         child: Form(
           key: _formKey, // Asociamos la clave del formulario
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               // Campo para la descripción del gasto
               CustomTextField(
                 label: 'Descripción',
                 hint: 'Ingrese la descripción del gasto',
                 controller: _descriptionController,
                 validator: (value) => Validators.validateNotEmpty(value, 'descripción'),
                 prefixIcon: const Icon(Icons.description), // Icono decorativo
               ),
               // Selector de categoría (método personalizado)
               _buildCategoryDropdown(),
               // Campo para el monto del gasto
               CustomTextField(
                 label: 'Monto',
                 hint: 'Ingrese el monto del gasto',
                 controller: _amountController,
                 validator: Validators.validateAmount, // Validador de monto
                 keyboardType: const TextInputType.numberWithOptions(decimal: true), // Teclado numérico con decimales
                 prefixIcon: const Icon(Icons.attach_money), // Icono de dinero
                 inputFormatters: [
                   // Formateador para permitir solo números con hasta 2 decimales
                   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                 ],
               ),
               // Selector de fecha (método personalizado)
               _buildDatePicker(),
               const SizedBox(height: 30),
               // Botón de guardar
               ElevatedButton(
                 onPressed: _isLoading ? null : _saveExpense, // Desactivamos durante la carga
                 child: _isLoading
                     ? const SizedBox(
                         height: 20,
                         width: 20,
                         child: CircularProgressIndicator(
                           color: Colors.white,
                           strokeWidth: 2,
                         ),
                       ) // Indicador de carga
                     : Text(isEditing ? 'Actualizar Gasto' : 'Guardar Gasto'), // Texto dinámico
               ),
             ],
           ),
         ),
       ),
     ),
   );
 }

 /// Construye el widget para seleccionar la categoría del gasto.
 Widget _buildCategoryDropdown() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Etiqueta del campo
       const Text(
         'Categoría',
         style: TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
           color: Colors.black87,
         ),
       ),
       const SizedBox(height: 8),
       // Contenedor estilizado para el dropdown
       Container(
         padding: const EdgeInsets.symmetric(horizontal: 16),
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(8),
           border: Border.all(color: Colors.grey.shade300),
         ),
         // Widget dropdown con las categorías
         child: DropdownButtonHideUnderline(
           child: DropdownButton<String>(
             value: _selectedCategory, // Valor actualmente seleccionado
             isExpanded: true, // Para que ocupe todo el ancho disponible
             hint: const Text('Seleccione una categoría'),
             // Generamos los ítems del dropdown a partir de la lista de categorías
             items: ExpenseCategories.categories.map((String category) {
               return DropdownMenuItem<String>(
                 value: category,
                 child: Text(category),
               );
             }).toList(),
             // Cuando se selecciona una categoría, actualizamos el estado
             onChanged: (String? newValue) {
               if (newValue != null) {
                 setState(() {
                   _selectedCategory = newValue;
                 });
               }
             },
           ),
         ),
       ),
       const SizedBox(height: 16),
     ],
   );
 }

 /// Construye el widget para seleccionar la fecha del gasto.
 Widget _buildDatePicker() {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       // Etiqueta del campo
       const Text(
         'Fecha',
         style: TextStyle(
           fontSize: 14,
           fontWeight: FontWeight.w500,
           color: Colors.black87,
         ),
       ),
       const SizedBox(height: 8),
       // Contenedor tappeable que muestra la fecha y abre el selector
       InkWell(
         onTap: _selectDate, // Al tocar, abre el selector de fecha
         child: Container(
           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
           decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.circular(8),
             border: Border.all(color: Colors.grey.shade300),
           ),
           child: Row(
             children: [
               const Icon(Icons.calendar_today, color: Colors.grey), // Icono de calendario
               const SizedBox(width: 12),
               // Texto que muestra la fecha seleccionada en formato día/mes/año
               Text(
                 DateFormat('dd/MM/yyyy').format(_selectedDate),
                 style: const TextStyle(fontSize: 16),
               ),
             ],
           ),
         ),
       ),
       const SizedBox(height: 16),
     ],
   );
 }
}