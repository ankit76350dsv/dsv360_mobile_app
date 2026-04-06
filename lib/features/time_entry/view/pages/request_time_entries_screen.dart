import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/features/time_entry/model/time_entry_model.dart';
import 'package:dsv360/features/time_entry/view/pages/timer_service.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class RequestTimeEntriesScreen extends StatefulWidget {


  final TimeEntry? editingEntry; // For editing existing entry

  const RequestTimeEntriesScreen({super.key, this.editingEntry,});

  

  @override
  State<RequestTimeEntriesScreen> createState() => _RequestTimeEntriesScreenState();
}


  


class _RequestTimeEntriesScreenState extends State<RequestTimeEntriesScreen> {
  late TextEditingController _userController;
  late TextEditingController _dateController;

  DateTime? _selectedDate;


  Future<void> _selectDate(BuildContext context) async {
    final customColors = Theme.of(context).custom;
    final DateTime today = DateTime.now();
    final DateTime sevenDaysAgo = today.subtract(const Duration(days: 6));
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: sevenDaysAgo,
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: customColors.primary!,
              onPrimary: Colors.white,
              surface: customColors.cardBackground!,
              onSurface: customColors.textPrimary!,
            ),
            dialogBackgroundColor: customColors.cardBackground!,
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      // Validate that the selected date is within the last 7 days
      if (pickedDate.isBefore(sevenDaysAgo) || pickedDate.isAfter(today)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('You can only add time entries for the last 7 days'),
            backgroundColor: customColors.error,
          ),
        );
        return;
      }
      
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
      });
    }
  }



  
  

  @override
  void initState() {
    // Todo: implement initState
    super.initState();
     _userController = TextEditingController(text: "ZMeraj"); //replace it with dynamic value later
     _dateController = TextEditingController();

     _selectedDate = DateTime.now();

     _dateController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);

     if(widget.editingEntry != null){

      final entry = widget.editingEntry!;
      _selectedDate = entry.date;
      _dateController.text = DateFormat('dd-MM-yyyy').format(entry.date);

     }

     
   
    
  }

  

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).custom;
    return Scaffold(
     backgroundColor: customColors.background,

    //app bar here
     appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Padding(
          padding: const EdgeInsets.only(top: 48),
          child: TopBar(
            title: ' add dynamic widget code here - Time Entries',
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      ),

      //body here
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // User field (read-only)
              CustomInputField(
               controller: _userController,
                labelText: 'User',
                hintText: 'User name',
                prefixIcon: Icons.person_outline,
                enabled: false,
              ),
              const SizedBox(height: 20),


               // Date field
              InkWell(
                onTap: TimerService.instance.isRunning ? null : () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: TimerService.instance.isRunning ? customColors.cardBackground!.withOpacity(0.5) : customColors.cardBackground,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: customColors.inputBorder!, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 196, 196, 196).withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, color: customColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date',
                              style: TextStyle(
                                color: customColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate == null
                                  ? 'Select date'
                                  : DateFormat('dd-MM-yyyy').format(_selectedDate!),
                              style: TextStyle(
                                color: _selectedDate == null
                                    ? customColors.textHint
                                    : customColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}