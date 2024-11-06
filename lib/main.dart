import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(CHDPredictorApp());
}

class CHDPredictorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CHD Predictor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CHDPredictorForm(),
    );
  }
}

class CHDPredictorForm extends StatefulWidget {
  @override
  _CHDPredictorFormState createState() => _CHDPredictorFormState();
}

class _CHDPredictorFormState extends State<CHDPredictorForm> {
  // Controllers to manage user inputs
  final _ageController = TextEditingController();
  final _systolicBpController = TextEditingController();
  final _diastolicBpController = TextEditingController();
  final _cholesterolController = TextEditingController();
  final _bmiController = TextEditingController();
  final _heartrateController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _cigarettesPerDayController = TextEditingController(); // Controller for cigarettes per day

  bool _smoking = false; // For smoking history
  bool _bpmeds = false; // For blood pressure medication
  bool _prevalentStroke = false; // For prevalent stroke
  bool _prevalentHyp = false; // For prevalent hypertension
  bool _diabetes = false; // For diabetes
  String _sex = 'Male'; // For sex input

  // Variable to store prediction result
  String _result = '';

  // Function to submit form and get prediction
  Future<void> _submitForm() async {
    // Clear previous result before submitting new data
    setState(() {
      _result = ''; // Reset result
    });

    final String apiUrl = 'https://health-care-app-4.onrender.com'; // Update with your API URL

    // Validate and prepare data to send to the API
    final data = {
      "sex": _sex == 'Male' ? 1 : 0, // Convert to 1/0 for sex
      "age": int.tryParse(_ageController.text) ?? 0,
      "smoking": _smoking ? 1 : 0, // Convert to 1/0 for smoking history
      "cigarettes_per_day": _smoking ? int.tryParse(_cigarettesPerDayController.text) ?? 0 : 0, // Only send if smoking
      "bpmeds": _bpmeds ? 1 : 0, // Convert to 1/0 for blood pressure medication
      "prevalent_stroke": _prevalentStroke ? 1 : 0, // Convert to 1/0 for prevalent stroke
      "prevalent_hyp": _prevalentHyp ? 1 : 0, // Convert to 1/0 for prevalent hypertension
      "diabetes": _diabetes ? 1 : 0, // Convert to 1/0 for diabetes
      "systolic_blood_pressure": int.tryParse(_systolicBpController.text) ?? 0,
      "diastolic_blood_pressure": int.tryParse(_diastolicBpController.text) ?? 0,
      "cholesterol": int.tryParse(_cholesterolController.text) ?? 0,
      "bmi": double.tryParse(_bmiController.text) ?? 0.0,
      "heart_rate": int.tryParse(_heartrateController.text) ?? 0,
      "glucose_level": int.tryParse(_glucoseController.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        setState(() {
          _result = 'Predicted Probability: ${responseBody['prediction'].toStringAsFixed(2)}%'; // Display the prediction result
        });
      } else {
        setState(() {
          _result = 'Error: Could not get prediction';
        });
      }
    } catch (error) {
      setState(() {
        _result = 'Error: Failed to connect to the API';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CHD Predictor')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Age Input Field
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Age'),
              ),
              SizedBox(height: 10),
              // Systolic Blood Pressure Input Field
              TextField(
                controller: _systolicBpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Systolic Blood Pressure'),
              ),
              SizedBox(height: 10),
              // Diastolic Blood Pressure Input Field
              TextField(
                controller: _diastolicBpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Diastolic Blood Pressure'),
              ),
              SizedBox(height: 10),
              // Cholesterol Input Field
              TextField(
                controller: _cholesterolController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Cholesterol'),
              ),
              SizedBox(height: 10),
              // BMI Input Field
              TextField(
                controller: _bmiController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'BMI'),
              ),
              SizedBox(height: 10),
              // Heart Rate Input Field
              TextField(
                controller: _heartrateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Heart Rate'),
              ),
              SizedBox(height: 10),
              // Glucose Level Input Field
              TextField(
                controller: _glucoseController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Glucose Level'),
              ),
              SizedBox(height: 10),
              // Sex Dropdown
              DropdownButton<String>(
                value: _sex,
                onChanged: (String? newValue) {
                  setState(() {
                    _sex = newValue!;
                  });
                },
                items: <String>['Male', 'Female'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              // Smoking Checkbox
              Row(
                children: [
                  Text('Current Smoker'),
                  Checkbox(
                    value: _smoking,
                    onChanged: (bool? value) {
                      setState(() {
                        _smoking = value!;
                        // Clear cigarettes per day controller when smoking status changes
                        if (!_smoking) {
                          _cigarettesPerDayController.clear(); // Clear field if not smoking
                        }
                      });
                    },
                  ),
                ],
              ),
              // Cigarettes Per Day Input Field
              if (_smoking) // Show this field only if smoking is checked
                TextField(
                  controller: _cigarettesPerDayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Cigarettes Per Day'),
                ),
              SizedBox(height: 10),
              // Blood Pressure Medication Checkbox
              Row(
                children: [
                  Text('Blood Pressure Medication'),
                  Checkbox(
                    value: _bpmeds,
                    onChanged: (bool? value) {
                      setState(() {
                        _bpmeds = value!;
                      });
                    },
                  ),
                ],
              ),
              // Prevalent Stroke Checkbox
              Row(
                children: [
                  Text('Prevalent Stroke'),
                  Checkbox(
                    value: _prevalentStroke,
                    onChanged: (bool? value) {
                      setState(() {
                        _prevalentStroke = value!;
                      });
                    },
                  ),
                ],
              ),
              // Prevalent Hypertension Checkbox
              Row(
                children: [
                  Text('Prevalent Hypertension'),
                  Checkbox(
                    value: _prevalentHyp,
                    onChanged: (bool? value) {
                      setState(() {
                        _prevalentHyp = value!;
                      });
                    },
                  ),
                ],
              ),
              // Diabetes Checkbox
              Row(
                children: [
                  Text('Diabetes'),
                  Checkbox(
                    value: _diabetes,
                    onChanged: (bool? value) {
                      setState(() {
                        _diabetes = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Get Prediction'),
              ),
              SizedBox(height: 20),
              // Result Display
              Text(
                _result,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
