import 'dart:convert';

import 'package:dokterku/components/button.dart';
import 'package:dokterku/main.dart';
import 'package:dokterku/models/auth_models.dart';
import 'package:dokterku/providers/dio_provider.dart';
import 'package:dokterku/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool obsecurePass = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: Config.primaryColor,
            decoration: const InputDecoration(
              hintText: 'Email Address',
              labelText: 'Email',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.email_outlined),
              prefixIconColor: Config.primaryColor,
            ),
          ),
          Config.spaceSmall,
          TextFormField(
            controller: _passController,
            keyboardType: TextInputType.visiblePassword,
            cursorColor: Config.primaryColor,
            obscureText: obsecurePass,
            decoration: InputDecoration(
                hintText: 'Password',
                labelText: 'Password',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.lock_outline),
                prefixIconColor: Config.primaryColor,
                suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obsecurePass = !obsecurePass;
                      });
                    },
                    icon: obsecurePass
                        ? const Icon(
                            Icons.visibility_off_outlined,
                            color: Colors.black38,
                          )
                        : const Icon(
                            Icons.visibility_outlined,
                            color: Config.primaryColor,
                          ))),
          ),
          Config.spaceSmall,
          Consumer<AuthModel>(
            builder: (context, auth, child) {
              return Button(
                width: double.infinity,
                title: 'Sign In',
                onPressed: () async {
                  final token = await DioProvider()
                      .getToken(_emailController.text, _passController.text);

                  if (token) {
                    // auth.loginSuccess(); //update login status
                    // redirect to main page
                    final SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    final tokenValue = prefs.getString('token') ?? '';

                    if (tokenValue.isNotEmpty && tokenValue != '') {
                      // get user data
                      final response = await DioProvider().getUser(tokenValue);
                      if (response != null) {
                        setState(() {
                          Map<String, dynamic> appointment = {};
                          final user = json.decode(response);

                          // check if any appointment today
                          for (var doctorData in user['doctor']) {
                            //if there is appointment return for today
                            // then pass doctor info
                            if (doctorData['appointments'] != null) {
                              appointment = doctorData;
                            }
                          }

                          auth.loginSuccess(user, appointment);
                          MyApp.navigatorKey.currentState!.pushNamed('main');
                        });
                      }
                    }
                  }
                  // Navigator.of(context).pushNamed('main');
                },
                disable: false,
              );
            },
          )
        ],
      ),
    );
  }
}
