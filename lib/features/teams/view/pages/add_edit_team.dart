import 'package:dsv360/views/widgets/bottom_two_buttons.dart';
import 'package:dsv360/views/widgets/custom_dropdown_field.dart';
import 'package:dsv360/views/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditTeamPage extends ConsumerStatefulWidget {
	final String? teamName;
	final String? reportingManager;

	const AddEditTeamPage({
		super.key,
		this.teamName,
		this.reportingManager,
	});

	@override
	ConsumerState<AddEditTeamPage> createState() => _AddEditTeamPageState();
}

class _AddEditTeamPageState extends ConsumerState<AddEditTeamPage> {
	final _formKey = GlobalKey<FormState>();

	late bool isEditing;
	final TextEditingController _teamNameController = TextEditingController();
	String? _selectedReportingManager;

	final String bottomTwoButtonsLoadingKey = 'add_edit_team_key';

	static const List<String> _reportingManagers = [
		'Mohammed Meraj',
		'Ankit Kumar',
		'Abhay Singh',
		'Rohan Shinde',
		'Sneha Patil',
	];

	@override
	void initState() {
		super.initState();
		isEditing = widget.teamName != null;

		if (isEditing) {
			_teamNameController.text = widget.teamName!;
			_selectedReportingManager = widget.reportingManager;
		}
	}

	@override
	void dispose() {
		_teamNameController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final colors = Theme.of(context).colorScheme;

		return Scaffold(
			appBar: AppBar(
				backgroundColor: colors.surface,
				toolbarHeight: 35.0,
				leading: IconButton(
					icon: const Icon(Icons.arrow_back_ios, size: 18),
					onPressed: () {
						Navigator.pop(context);
					},
				),
				centerTitle: true,
				elevation: 0,
				title: Text(
					isEditing ? 'Edit Team' : 'Add New Team',
					style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
				),
				actions: const [],
			),
			body: SafeArea(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Padding(
							padding: const EdgeInsets.only(left: 16.0, top: 12.0),
							child: Text(
								'Team Information',
								style: Theme.of(context).textTheme.titleMedium?.copyWith(
									color: colors.primary,
									fontWeight: FontWeight.w700,
								),
							),
						),
						Expanded(
							child: SingleChildScrollView(
								padding: const EdgeInsets.all(20),
								child: Form(
									key: _formKey,
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											CustomInputField(
												controller: _teamNameController,
												hintText: 'Team Name',
												labelText: 'Team Name',
												prefixIcon: Icons.groups_2_outlined,
												validator: (value) {
													if (value == null || value.trim().isEmpty) {
														return 'Please enter team name';
													}
													return null;
												},
											),
											const SizedBox(height: 20),
											CustomDropDownField(
												hintText: 'Reporting Manager',
												labelText: 'Reporting Manager',
												prefixIcon: Icons.person_search,
												selectedOption: _selectedReportingManager,
												searchable: true,
												searchHintText: 'Search reporting manager',
												options: _reportingManagers
														.map(
															(name) => DropdownMenuItem<String>(
																value: name,
																child: Text(name),
															),
														)
														.toList(),
												onChanged: (value) {
													setState(() => _selectedReportingManager = value);
												},
											),
											const SizedBox(height: 32),
											BottomTwoButtons(
												loadingKey: bottomTwoButtonsLoadingKey,
												button1Text: 'Cancel',
												button2Text: isEditing ? 'save changes' : 'add team',
												button1Function: () => Navigator.pop(context),
												button2Function: () {
													if (!_formKey.currentState!.validate()) return;
													if (_selectedReportingManager == null ||
															_selectedReportingManager!.trim().isEmpty) {
														ScaffoldMessenger.of(context).showSnackBar(
															const SnackBar(
																content: Text('Please select reporting manager'),
															),
														);
														return;
													}

													Navigator.pop(context, {
														'teamName': _teamNameController.text.trim(),
														'reportingManager': _selectedReportingManager,
													});
												},
											),
										],
									),
								),
							),
						),
					],
				),
			),
		);
	}
}
