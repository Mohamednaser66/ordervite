import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String role;

  const OtpScreen({
    super.key,
    required this.verificationId,
    required this.role,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (isLoading) return;
    if (codeController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid OTP")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      PhoneAuthCredential credential =
      PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: codeController.text.trim(),
      );
      UserCredential userCredential =
      await FirebaseAuth.instance
          .signInWithCredential(credential);

      User user = userCredential.user!;
      var doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      String role;

      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'phone': user.phoneNumber,
          'role': widget.role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        role = widget.role;
      } else {
        role = doc.data()?['role'] ?? widget.role;
      }

      // 🚀 Navigation
      if (!mounted) return;

      if (role == 'shipper') {
        Navigator.pushReplacementNamed(context, '/shipperHome');
      } else {
        Navigator.pushReplacementNamed(context, '/supplierHome');
      }

    } on FirebaseAuthException catch (e) {
      String message =e.toString();
      print("ERROR CODE: ${e.code}");
      print("ERROR MESSAGE: ${e.message}");
print(message);
      if (e.code == 'invalid-verification-code') {
        message = "Wrong code";
      } else if (e.code == 'session-expired') {
        message = "Code expired";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong")),
      );
    }

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter the code sent to your phone",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: "OTP Code",
                border: OutlineInputBorder(),
                counterText: "",
              ),
            ),

            const SizedBox(height: 20),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: verifyOTP,
                child: const Text("Verify"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}