import 'package:dsv360/core/constants/theme.dart';
import 'package:dsv360/views/widgets/TopBar.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';


class RequestTimeEntriesScreen extends StatefulWidget {
  const RequestTimeEntriesScreen({super.key});

  @override
  State<RequestTimeEntriesScreen> createState() => _RequestTimeEntriesScreenState();
}


  


class _RequestTimeEntriesScreenState extends State<RequestTimeEntriesScreen> {
  late TextEditingController _userController;



  
  

  @override
  void initState() {
    // Todo: implement initState
    super.initState();
     _userController = TextEditingController(text: "ZMeraj"); //replace it with dynamic value later
     
   
    
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
              
              
            ],
          ),
        ),
      ),
    );
  }
}