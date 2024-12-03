import 'package:flutter/material.dart';

class SimpleComponents {
  static Widget buildTextField(
      TextEditingController controller, String label, String hint,
      {bool isEmail = false,
      bool isPassword = false,
      bool isPhone = false,
      bool isLongText = false}) {
    bool obscureText = true;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 235, 247, 250),
                borderRadius: BorderRadius.circular(32),
              ),
              child: TextFormField(
                controller: controller,
                obscureText: isPassword ? obscureText : false,
                keyboardType: isEmail
                    ? TextInputType.emailAddress
                    : (isPhone
                        ? TextInputType.phone
                        : (isLongText
                            ? TextInputType.multiline
                            : TextInputType.text)),
                maxLines: isLongText ? null : 1,
                minLines: isLongText ? 4 : 1,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                decoration: InputDecoration(
                  hintText: hint,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                    color: Color.fromARGB(255, 150, 150, 150),
                    fontSize: 16,
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter $label';
                  }
                  if (isEmail &&
                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}')
                          .hasMatch(value)) {
                    return 'Enter a valid email';
                  }
                  if (isPassword && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget buildSocialButton(String text, IconData icon, Color color) {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement Google/Facebook sign-in functionality
      },
      icon: Icon(icon, color: Colors.white),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static Widget buildButton(
      {required bool isLoading,
      required VoidCallback onTap,
      required String buttonText}) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(32),
              ),
              alignment: Alignment.center,
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ),
          );
  }
}
