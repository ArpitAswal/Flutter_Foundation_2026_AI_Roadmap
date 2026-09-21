# 📘 Day 20: Text Input, Focus Management & Form Validation

**Module 03:** [User Interaction, Input & Scrollables](../README.md) • **Phase 02:** [Flutter Foundation](../../README.md)

> [!NOTE]
> **Lesson Objective:** Learn how Flutter captures and validates user input through TextField, TextFormField, and Form. Master TextEditingController lifecycle and memory management, programmatic focus traversal using FocusNode and FocusScope, custom input formatting via TextInputFormatter, soft keyboard handling with viewInsets, and production-grade form validation strategies.

**Tags:** `Flutter` `TextField` `TextFormField` `Form` `TextEditingController` `FocusNode` `Form Validation` `Input Formatting` `Keyboard Insets`

---

## 🚦 Prerequisites
Day 16: StatefulWidget, State & setState; Day 17: BuildContext & The Three Trees (Widget, Element, RenderObject); Day 18: Widget Keys & State Preservation. You should understand StatefulWidget lifecycle, State disposal, and how GlobalKey<FormState> queries child State.

## 📖 Overview
Handling user text input in mobile and desktop applications is significantly more complex than rendering static text. A production input system must seamlessly coordinate:

1. **Hardware & Virtual Keyboards**: Displaying the right keyboard layout (email, phone, numeric, multiline) and handling action keys (*Next*, *Done*, *Search*).
2. **Text State Management**: Storing the active string, tracking cursor selection offsets, and supporting undo/redo operations.
3. **Focus Traversal**: Navigating between fields smoothly when the user taps *Next* or presses the *Tab* key.
4. **Validation Rules**: Synchronous format checking, real-time error messages, and coordinated form submission.
5. **Viewport Obstruction**: Preventing the onscreen virtual keyboard from obscuring input fields.

Flutter organizes these capabilities into a cohesive hierarchy: `TextField`, `TextFormField`, `TextEditingController`, `FocusNode`, and the `Form` widget.

## 📚 Topics Covered
* **1. The Core Challenge of Capturing User Input**: 1. **Hardware & Virtual Keyboards**: Displaying the right keyboard layout (email, phone, numeric, multiline) and handling action keys (*N...
* **2. TextField vs TextFormField**: `TextField` is a raw, standalone material text input widget.
* **3. TextEditingController & Memory Lifecycle**: A `TextEditingController` manages the state of an editable text field, including its text content and selection range.
* **4. Focus Management: FocusNode & FocusScope**: Flutter manages keyboard focus through a dedicated tree of focus nodes.
* **5. Form Architecture & Validation Workflow**: The `Form` widget acts as an ambient container that coordinates multiple `FormField` and `TextFormField` widgets.
* **6. TextInputFormatter (Real-Time Formatting)**: `TextInputFormatter` intercepts and transforms text before it is displayed or stored in the controller.
* **7. Soft Keyboard Insets & Overflow Handling**: > `A RenderFlex overflowed by 248 pixels on the bottom.`

## 🎯 Implementation Objective
Build a production-grade registration and payment checkout form with custom TextInputFormatter, automatic focus advancement across fields, live validation on user interaction, soft keyboard dismissal on outside tap, and safe controller/focus lifecycle management.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const FormMasteryApp());
}

/// Root application entrypoint.
class FormMasteryApp extends StatelessWidget {
  const FormMasteryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Forms & Focus Mastery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const CheckoutFormScreen(),
    );
  }
}

/// Production checkout form screen demonstrating Form, FocusNode traversal,
/// TextInputFormatter, and soft keyboard dismissal.
class CheckoutFormScreen extends StatefulWidget {
  const CheckoutFormScreen({super.key});

  @override
  State<CheckoutFormScreen> createState() => _CheckoutFormScreenState();
}

class _CheckoutFormScreenState extends State<CheckoutFormScreen> {
  // Form key to trigger batch validation and save
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for text inputs
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cardNumberController;

  // Focus nodes for programmatic focus progression
  late final FocusNode _nameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _cardFocusNode;

  bool _obscureCard = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _cardNumberController = TextEditingController();

    _nameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _cardFocusNode = FocusNode();
  }

  @override
  void dispose() {
    // CRITICAL: Always dispose controllers and focus nodes to avoid memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _cardNumberController.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _cardFocusNode.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Dismiss virtual keyboard
    FocusScope.of(context).unfocus();

    // Validate all form fields simultaneously
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isProcessing = true);

      // Simulate network checkout operation
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      setState(() => _isProcessing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order placed successfully for ${_nameController.text.trim()}!'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tapping outside input fields automatically dismisses keyboard
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Checkout & Form Validation'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Customer Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 1. Full Name Field
                  TextFormField(
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'John Doe',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name.';
                      }
                      if (value.trim().length < 3) {
                        return 'Name must be at least 3 characters.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      // Automatically advance focus to Email field
                      FocusScope.of(context).requestFocus(_emailFocusNode);
                    },
                  ),
                  const SizedBox(height: 16),

                  // 2. Email Field
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email Address *',
                      hintText: 'user@domain.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email address is required.';
                      }
                      final emailRegex = RegExp(r'^[^@]+@[^@]+[.][^@]+$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) {
                      // Automatically advance focus to Card field
                      FocusScope.of(context).requestFocus(_cardFocusNode);
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Payment Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 3. Card Number with Custom Input Formatter
                  TextFormField(
                    controller: _cardNumberController,
                    focusNode: _cardFocusNode,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscureCard,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                      CardNumberInputFormatter(), // Custom 4-digit grouping formatter
                    ],
                    decoration: InputDecoration(
                      labelText: 'Card Number *',
                      hintText: 'XXXX XXXX XXXX XXXX',
                      prefixIcon: const Icon(Icons.credit_card_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureCard ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureCard = !_obscureCard),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Card number is required.';
                      }
                      // Unformatted digits count check (16 digits)
                      final cleanDigits = value.replaceAll(' ', '');
                      if (cleanDigits.length != 16) {
                        return 'Card number must be exactly 16 digits.';
                      }
                      return null;
                    },
                    onFieldSubmitted: (_) => _submitForm(),
                  ),
                  const SizedBox(height: 28),

                  // Submit Button
                  SizedBox(
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _isProcessing ? null : _submitForm,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.lock_outline),
                      label: Text(_isProcessing ? 'Processing Order...' : 'Complete Purchase (USD 49.99)'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom TextInputFormatter that groups digits into chunks of 4 (e.g., '1234 5678 9012 3456').
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      final nextIndex = i + 1;
      if (nextIndex % 4 == 0 && nextIndex != text.length) {
        buffer.write(' ');
      }
    }

    final string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
```

## 💡 Deep-Dive Materials Included

* **16 Interview Prep Scenarios** included
* **Technology Comparisons:** TextField vs TextFormField, TextEditingController vs onChanged Callback, FocusNode vs FocusScope, AutovalidateMode Options, FormState.validate() vs Manual Variable Validation
* **Common Pitfalls & Optimizations** included
* **Architecture & Production Patterns** included

---

## 🧭 Navigation

[📂 Module Index](../README.md) | [Day 21: Gestures, Touch Feedback & The Gesture Arena ➡️](../Day-21/README.md)

> [!TIP]
> **Interactive Experience:** To run code interactively, view full theoretical breakdowns, test interview questions, and chat with the AI Tutor, launch the **Flutter AI Tutor App**!

