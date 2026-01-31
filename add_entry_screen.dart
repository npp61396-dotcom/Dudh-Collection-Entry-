import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/strings.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/milk_entry.dart';
import '../../../data/models/farmer.dart';
import '../../providers/milk_entry_provider.dart';
import '../../providers/farmer_provider.dart';
import '../../widgets/milk_entry/farmer_autocomplete.dart';
import '../../widgets/milk_entry/milk_calculator.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _farmerCodeController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _snfController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();

  Farmer? _selectedFarmer;
  String _selectedMilkType = 'Cow';
  String _selectedShift = 'Morning';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _fatController.addListener(_calculateTotal);
    _snfController.addListener(_calculateTotal);
    _weightController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    if (_fatController.text.isNotEmpty &&
        _snfController.text.isNotEmpty &&
        _weightController.text.isNotEmpty) {
      try {
        double fat = double.parse(_fatController.text);
        double snf = double.parse(_snfController.text);
        double weight = double.parse(_weightController.text);
        
        // Rate calculation logic based on Fat/SNF
        double rate = _calculateRate(fat, snf);
        double total = rate * weight;
        
        _rateController.text = rate.toStringAsFixed(2);
        _totalController.text = total.toStringAsFixed(2);
      } catch (e) {
        // Handle parsing error
      }
    }
  }

  double _calculateRate(double fat, double snf) {
    // Implement rate chart logic here
    // Example: Base rate + (fat * fatRate) + (snf * snfRate)
    double baseRate = _selectedMilkType == 'Cow' ? 40 : 50;
    return baseRate + (fat * 2.5) + (snf * 1.5);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate() && _selectedFarmer != null) {
      final entry = MilkEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        farmerCode: _selectedFarmer!.code,
        farmerName: _selectedFarmer!.name,
        milkType: _selectedMilkType,
        shift: _selectedShift,
        fat: double.parse(_fatController.text),
        snf: double.parse(_snfController.text),
        weight: double.parse(_weightController.text),
        rate: double.parse(_rateController.text),
        total: double.parse(_totalController.text),
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        time: '${_selectedTime.hour}:${_selectedTime.minute}',
        timestamp: DateTime.now(),
      );

      final provider = context.read<MilkEntryProvider>();
      await provider.addEntry(entry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('दूध एंटरी सफलतापूर्वक जोड़ी गई'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _farmerCodeController.dispose();
    _fatController.dispose();
    _snfController.dispose();
    _weightController.dispose();
    _rateController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppStrings.addEntry,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farmer Selection
              FarmerAutocomplete(
                onFarmerSelected: (farmer) {
                  setState(() {
                    _selectedFarmer = farmer;
                    _farmerCodeController.text = farmer.code;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Farmer Info Card
              if (_selectedFarmer != null)
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: AppColors.primaryBlue),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedFarmer!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'कोड: ${_selectedFarmer!.code}',
                              style: const TextStyle(
                                color: AppColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Milk Type Selection
              const Text(
                AppStrings.milkType,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(AppStrings.cow),
                      value: 'Cow',
                      groupValue: _selectedMilkType,
                      onChanged: (value) {
                        setState(() {
                          _selectedMilkType = value!;
                          _calculateTotal();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(AppStrings.buffalo),
                      value: 'Buffalo',
                      groupValue: _selectedMilkType,
                      onChanged: (value) {
                        setState(() {
                          _selectedMilkType = value!;
                          _calculateTotal();
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              // Shift Selection
              const Text(
                'पारी',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(AppStrings.morningShift),
                      value: 'Morning',
                      groupValue: _selectedShift,
                      onChanged: (value) {
                        setState(() {
                          _selectedShift = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text(AppStrings.eveningShift),
                      value: 'Evening',
                      groupValue: _selectedShift,
                      onChanged: (value) {
                        setState(() {
                          _selectedShift = value!;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Date and Time Selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.date,
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectTime(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: AppStrings.time,
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedTime.format(context)),
                            const Icon(Icons.access_time),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Milk Parameters
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fatController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.fat,
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        final fat = double.tryParse(value);
                        if (fat == null || fat <= 0 || fat > 15) {
                          return '0.1 से 15 के बीच मान';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _snfController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.snf,
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppStrings.requiredField;
                        }
                        final snf = double.tryParse(value);
                        if (snf == null || snf <= 0 || snf > 20) {
                          return '0.1 से 20 के बीच मान';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Weight
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: AppStrings.weight,
                  border: OutlineInputBorder(),
                  suffixText: 'किलो',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.requiredField;
                  }
                  final weight = double.tryParse(value);
                  if (weight == null || weight <= 0) {
                    return AppStrings.invalidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Milk Calculator Widget
              MilkCalculator(
                fatController: _fatController,
                snfController: _snfController,
                weightController: _weightController,
                rateController: _rateController,
                totalController: _totalController,
                milkType: _selectedMilkType,
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    AppStrings.save,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
