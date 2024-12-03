import 'package:flutter/material.dart';
import 'package:home_service_app/screens/auth/upload_proof_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TokenEntryPage extends StatelessWidget {
  TokenEntryPage({super.key});

  final TextEditingController _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.token,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.enterToken,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.tokenPlaceholder,
                labelText: AppLocalizations.of(context)!.token,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.tokenCannotBeEmpty;
                }
                if (value.length < 16) {
                  return AppLocalizations.of(context)!.tokenTooShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final token = _tokenController.text.trim();
                if (token.isEmpty || token.length < 16) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context)!.invalidToken,
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UploadProofPage(
                            token: _tokenController.text,
                          )));
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.submit,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
