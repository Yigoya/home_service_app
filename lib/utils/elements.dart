import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SimpleComponents {
  static Widget buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isEmail = false,
    bool isPassword = false,
    bool isPhone = false,
    bool isLongText = false,
  }) {
    bool obscureText = true;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return isPhone
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ethiopian flag
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Image.asset(
                            'assets/images/ethiopian_flag.jpg', // Ethiopian flag
                            width: 30,
                            height: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            '+251',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.phone,
                      maxLines: 1,
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 18),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        hintText: label,
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[100]!,
                            width: 0.1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey[400]!,
                            width: 1,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.blue,
                            width: 2.0,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter $label';
                        }
                        if (value.length < 9 || value.length > 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              )
            : TextFormField(
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
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  hintText: label,
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.black.withOpacity(0.3),
                      width: 0.1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey[400]!,
                      width: 1,
                    ),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2.0,
                    ),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget buildButton(
      {required bool isLoading,
      required VoidCallback onTap,
      required String buttonText,
      required Color color}) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(32.r),
              ),
              alignment: Alignment.center,
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ),
          );
  }
}
